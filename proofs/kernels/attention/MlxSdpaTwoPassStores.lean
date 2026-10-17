import kernels.attention.MlxSdpaTwoPassFirstSource

namespace Inference.Kernels.Attention.MlxSdpaTwoPassStores
open Contracts.Mlx State
open Normalization.MlxRmsLoopSyntax (acceptAll)
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

inductive Stores where | raw deriving DecidableEq, Repr
inductive Initial where | zero deriving DecidableEq, Repr
inductive Advances where | blocks deriving DecidableEq, Repr

def parseStores (source : String) : Option Stores := do
  let ts ←MlxSdpaScoreSource.lex (source.length+1) source.toList
  let rest ←acceptAll ["if","(","simd_lid","=","=","0",")","{",
    "sums","[","0","]","=","sum_exp_score",";","maxs","[","0","]","=","max_score",";","}",
    "for","(","int","i","=","0",";","i","<","v_per_thread",";","i","+","+",")","{",
    "out","[","i","]","=","static_cast","<","T",">","(","o","[","i","]",")",";","}"] ts
  if rest=[] then some .raw else none

def parseInitial (source : String) : Option Initial := do
  let ts ←MlxSdpaScoreSource.lex (source.length+1) source.toList
  let rest ←acceptAll ["thread","U","o","[","v_per_thread","]","=","{","0","}",";",
    "U","max_score","=","Limits","<","U",">",":",":","finite_min",";","U","sum_exp_score","=","0",";"] ts
  if rest=[] then some .zero else none

def parseAdvances (source : String) : Option Advances := do
  let ts ←MlxSdpaScoreSource.lex (source.length+1) source.toList
  let rest ←acceptAll ["keys","+","=","blocks","*","int","(","k_seq_stride",")",";",
    "values","+","=","blocks","*","int","(","v_seq_stride",")",";"] ts
  if rest=[] then some .blocks else none

def sourceStores : String := r#"if (simd_lid == 0) {
    sums[0] = sum_exp_score;
    maxs[0] = max_score;
  }

  for (int i = 0; i < v_per_thread; i++) {
    out[i] = static_cast<T>(o[i]);
  }"#
def sourceInitial : String := r#"thread U o[v_per_thread] = {0};
U max_score = Limits<U>::finite_min;
  U sum_exp_score = 0;"#
def sourceAdvances : String := r#"keys += blocks * int(k_seq_stride);
    values += blocks * int(v_seq_stride);"#
theorem parsed_stores : parseStores sourceStores=some .raw := by decide +kernel
theorem parsed_initial : parseInitial sourceInitial=some .zero := by decide +kernel
theorem parsed_advances : parseAdvances sourceAdvances=some .blocks := by decide +kernel

variable {steps blocks : Nat}

def initial (_ : Initial) : SdpaUpdate.State := SdpaLoop.initial SdpaVector.initialShift

def partialStore (_ : Stores) (outputBase : Nat)
    (raw : Fin 24 → Fin blocks → Fin 256 → SdpaUpdate.State)
    (label : SdpaTwoPassWrites.Label blocks) (item : Fin 8) : HalfMemory.Store :=
  ⟨outputBase/2+MlxSdpaTwoPassMemory.outputAddress blocks label.1 label.2.1 label.2.2 item,
   ArrayStorage.bits (BFloat16.narrow (raw label.1 label.2.1 (SdpaScore.index label.2.2 item)).numerator)⟩

def thread (ast : Stores) (sumBase maxBase outputBase : Nat)
    (raw : Fin 24 → Fin blocks → Fin 256 → SdpaUpdate.State)
    (label : SdpaTwoPassWrites.Label blocks) : List SdpaTwoPassBytes.Event :=
  (if label.2.2.val=0 then
    [.sum ⟨sumBase/4+SdpaTwoPassLayout.summaryAddress blocks label.1 label.2.1,
        FloatMemory.bits (raw label.1 label.2.1 0).denominator⟩,
     .maximum ⟨maxBase/4+SdpaTwoPassLayout.summaryAddress blocks label.1 label.2.1,
        FloatMemory.bits (raw label.1 label.2.1 0).shift⟩] else [])++
    (List.ofFn (partialStore ast outputBase raw label)).map .output

def programs (ast : Stores) (sumBase maxBase outputBase : Nat)
    (raw : Fin 24 → Fin blocks → Fin 256 → SdpaUpdate.State) : List (List SdpaTwoPassBytes.Event) :=
  (SdpaTwoPassWrites.labels blocks).map (thread ast sumBase maxBase outputBase raw)

def source (blocks : Nat) (p : SdpaVector.Platform) (query : Fin 24 → Fin 256 → ArrayStorage.BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → ArrayStorage.BF) (sumBase maxBase outputBase : Nat) :
    Option (List (List SdpaTwoPassBytes.Event)) := do
  let ast ←parseStores sourceStores
  pure (programs (blocks:=blocks) ast sumBase maxBase outputBase (fun head block i =>
    SdpaTwoPassFirstPass.raw p (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)) i block))

theorem partial_store (outputBase : Nat) (raw : Fin 24 → Fin blocks → Fin 256 → SdpaUpdate.State)
    (label : SdpaTwoPassWrites.Label blocks) (item : Fin 8) :
    partialStore .raw outputBase raw label item=
      SdpaTwoPassWrites.partialEntry (outputBase/2)
        (fun h b i => ArrayStorage.bits (BFloat16.narrow (raw h b i).numerator)) label item := by
  unfold partialStore SdpaTwoPassWrites.partialEntry
  rw [MlxSdpaTwoPassMemory.output_address]
  rfl

theorem programs_generic (sumBase maxBase outputBase : Nat)
    (raw : Fin 24 → Fin blocks → Fin 256 → SdpaUpdate.State) :
    programs .raw sumBase maxBase outputBase raw=SdpaTwoPassBytes.programs sumBase maxBase outputBase
      (fun h b => (raw h b 0).denominator) (fun h b => (raw h b 0).shift)
      (fun h b i => BFloat16.narrow (raw h b i).numerator) := by
  unfold programs SdpaTwoPassBytes.programs
  apply congrArg (List.map · (SdpaTwoPassWrites.labels blocks))
  funext label
  have outputs : List.ofFn (partialStore .raw outputBase raw label)=
      SdpaTwoPassWrites.partialThread (outputBase/2)
        (fun h b i => ArrayStorage.bits (BFloat16.narrow (raw h b i).numerator)) label := by
    unfold SdpaTwoPassWrites.partialThread
    apply congrArg List.ofFn
    funext item
    exact partial_store _ _ label item
  unfold thread SdpaTwoPassBytes.thread
  rw [outputs]
  rfl

theorem programs_eq (p : SdpaVector.Platform) (query : Fin 24 → Fin 256 → ArrayStorage.BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → ArrayStorage.BF) (sumBase maxBase outputBase : Nat) :
    source blocks p query keys values sumBase maxBase outputBase=
      some (SdpaTwoPassBytes.programs (blocks:=blocks) sumBase maxBase outputBase
        (fun h b => (SdpaTwoPassFirstPass.raw p (query h) (keys (SdpaScore.kvHead h)) (values (SdpaScore.kvHead h)) 0 b).denominator)
        (fun h b => (SdpaTwoPassFirstPass.raw p (query h) (keys (SdpaScore.kvHead h)) (values (SdpaScore.kvHead h)) 0 b).shift)
        (fun h b i => SdpaTwoPassFirstPass.stored p (query h) (keys (SdpaScore.kvHead h)) (values (SdpaScore.kvHead h)) i b)) := by
  unfold source
  rw [parsed_stores]
  change some (programs .raw sumBase maxBase outputBase _)=_
  rw [programs_generic]
  rfl

variable {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform}

theorem checked (execution : SdpaTwoPassShared.Execution input p blocks) :
    ∃ nativePrograms, source blocks p input.storage.queryValues input.storage.keys.read input.storage.values.read
      execution.first.trace.sumBase execution.first.trace.maxBase execution.first.trace.outputBase=some nativePrograms ∧
      ThreadgroupWrites.Executes nativePrograms execution.first.trace.schedule execution.first.trace.remaining ∧
      ThreadgroupWrites.AtBarrier execution.first.trace.remaining :=
  ⟨_,programs_eq _ _ _ _ _ _ _,execution.first.trace.execution,execution.first.trace.completed⟩

theorem read_provenance (execution : SdpaTwoPassShared.Execution input p blocks)
    (head : Fin 24) (block : Fin blocks) (lane : Fin 32) (item : Fin 8) :
    ∃ finish, MlxSdpaTwoPassFirstSource.Executes p execution.inputAfter head block lane item
      (List.finRange (SdpaTwoPassLayout.count steps blocks block)) (initial .zero) finish ∧
      (execution.first.readState head block (SdpaScore.index lane item)).shift=finish.shift ∧
      (execution.first.readState head block (SdpaScore.index lane item)).denominator=finish.denominator ∧
      (execution.first.readState head block (SdpaScore.index lane item)).numerator=
        BFloat16.widen (BFloat16.narrow finish.numerator) := by
  obtain ⟨finish,run,same⟩ := MlxSdpaTwoPassFirstSource.protected_complete execution head block lane item
  refine ⟨finish,run,?_⟩
  rw [same,execution.first_to_second]
  exact ⟨rfl,rfl,rfl⟩

end Inference.Kernels.Attention.MlxSdpaTwoPassStores
