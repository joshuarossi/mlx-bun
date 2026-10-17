import kernels.attention.MlxSdpaTwoPassMergeSource
import kernels.attention.SdpaTwoPassDonation

namespace Inference.Kernels.Attention.MlxSdpaTwoPassOutputSource
open Contracts.Mlx State MlxSdpaTwoPassMergeSyntax MlxSdpaTwoPassMergeSource
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
variable {steps blocks : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF}
  {cache : Kv.Cache Kv.BF steps} {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform}

theorem scratch_source (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (head : Fin 24) (item : Fin 8) :
    ThreadgroupWrites.Executes
      (MlxSdpaMergeSource.transposePrograms .shared ((execution.second contracted complete).scratch head item).base
        (fun group lane => numerator .chunks contracted execution head (maximum .chunks execution head) group lane item))
      ((execution.second contracted complete).scratch head item).schedule
      ((execution.second contracted complete).scratch head item).remaining ∧
    ThreadgroupWrites.AtBarrier ((execution.second contracted complete).scratch head item).remaining ∧
    ReadOnlyThreads.AtBarrier 1024 ((execution.second contracted complete).scratch head item).readAfter := by
  rw [numerator_lanes execution complete]
  exact MlxSdpaMergeSource.transpose_execution ((execution.second contracted complete).scratch head item)

theorem denominator_correct (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (head : Fin 24) (i : Fin 256) :
    denominator .chunks contracted execution head (maximum .chunks execution head)=
      (SdpaTwoPassScratch.merged (execution.second contracted complete) head i).denominator := by
  rw [denominator_current execution complete,maximum_projected execution complete,
    SdpaTwoPassExecution.component_execution]
  simp only [execution.first.readState_projected]
  rfl

def finalNumerator (_ : Transpose) (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (head : Fin 24) (group : Fin 32) (item : Fin 8) : Float32 :=
  p.merge.reduce (fun lane => (((execution.second contracted complete).scratch head item).readAfter (group.val*32+lane.val)).getD 0)

theorem final_numerator (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (head : Fin 24) (group : Fin 32) (item : Fin 8) :
    finalNumerator .shared execution complete contracted head group item=
      ((execution.second contracted complete).scratch head item).reduce p.merge.reduce group := rfl

theorem denominator_nonzero (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (head : Fin 24)
    (finite : SdpaTwoPassVector.Finite p contracted blocks (query head) (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) :
    Model.isZero (Numerics.model (denominator .chunks contracted execution head (maximum .chunks execution head)))=false := by
  have same := denominator_correct execution complete contracted head 0
  have merged := SdpaTwoPassScratch.merged_eq (execution.second contracted complete) head 0
  conv at merged =>
    rhs
    rw [input.storage.query_eq,input.storage.keys.read_eq,input.storage.values.read_eq]
  rw [same,merged]
  exact DivisionBounds.divisor_not_zero _ (finite.normalization 0).denominator (finite.normalization 0).domain

def bits (summary : Maximum) (den : Denominator) (transpose : Transpose)
    (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (head : Fin 24) (group : Fin 32) (item : Fin 8) : BitVec 16 :=
  ArrayStorage.bits (BFloat16.narrow (MlxSdpaMergeSource.quotient .shared p.normalization
    (finalNumerator transpose execution complete contracted head group item)
    (denominator den contracted execution head (maximum summary execution head))))

theorem bits_eq (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (head : Fin 24)
    (finite : SdpaTwoPassVector.Finite p contracted blocks (query head) (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)))
    (group : Fin 32) (item : Fin 8) :
    bits .chunks .chunks .shared execution complete contracted head group item=
      ArrayStorage.bits (SdpaTwoPassScratch.forward (execution.second contracted complete) head (SdpaLayout.coordinate group item)) := by
  unfold bits MlxSdpaMergeSource.quotient
  rw [denominator_nonzero execution complete contracted head finite]
  simp only [Bool.false_eq_true,ite_false]
  rw [final_numerator,denominator_correct execution complete contracted head (SdpaLayout.coordinate group item)]
  unfold SdpaTwoPassScratch.forward SdpaNormalize.value SdpaNormalize.raw
  have gi := group.isLt
  have oi := item.isLt
  have first : (SdpaLayout.coordinate group item).val%8=item.val := by dsimp [SdpaLayout.coordinate]; omega
  have second : (SdpaLayout.coordinate group item).val/8=group.val := by dsimp [SdpaLayout.coordinate]; omega
  apply congrArg ArrayStorage.bits
  apply congrArg BFloat16.narrow
  apply congrArg (fun n => p.normalization.divide n
    (SdpaTwoPassScratch.merged (execution.second contracted complete) head (SdpaLayout.coordinate group item)).denominator)
  exact (congrArg (fun pair : Fin 8 × Fin 32 =>
    ((execution.second contracted complete).scratch head pair.1).reduce p.merge.reduce pair.2)
    (show ((⟨(SdpaLayout.coordinate group item).val%8, by omega⟩ : Fin 8),
      (⟨(SdpaLayout.coordinate group item).val/8, by omega⟩ : Fin 32)) = (item,group) from
      Prod.ext (Fin.ext first) (Fin.ext second))).symm

def sourceBits (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (head : Fin 24) (group : Fin 32) (item : Fin 8) : Option (BitVec 16) := do
  let ps ←parsePointers sourcePointers
  if ps=pointers then
    let _ ←parseInitial sourceInitial
    let maxAst ←parseMaximum sourceMaximum
    let denAst ←parseDenominator sourceDenominator
    let _ ←parseNumerator sourceNumerator
    let transpose ←parseTranspose sourceTranspose
    let _ ←parseGate sourceGate
    pure (bits maxAst denAst transpose execution complete contracted head group item)
  else none

theorem parsed_bits (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (head : Fin 24) (group : Fin 32) (item : Fin 8) :
    sourceBits execution complete contracted head group item=some (bits .chunks .chunks .shared execution complete contracted head group item) := by
  simp [sourceBits,parsed_pointers,parsed_initial,parsed_maximum,parsed_denominator,parsed_numerator,parsed_transpose,parsed_gate]

def entry (maxAst : Maximum) (denAst : Denominator) (transpose : Transpose)
    (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (base : Nat) (label : SdpaOutput.Label) (item : Fin 8) : HalfMemory.Store :=
  ⟨base/2+MlxSdpaTwoPassMergeMemory.outputAddress blocks label.1 label.2.1 item,
   bits maxAst denAst transpose execution complete contracted label.1 label.2.1 item⟩

def thread (_ : Gate) (maxAst : Maximum) (denAst : Denominator) (transpose : Transpose)
    (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (base : Nat) (label : SdpaOutput.Label) : List HalfMemory.Store :=
  if label.2.2.val=0 then List.ofFn (entry maxAst denAst transpose execution complete contracted base label) else []

def programs (gate : Gate) (maxAst : Maximum) (denAst : Denominator) (transpose : Transpose)
    (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (base : Nat) : List (List HalfMemory.Store) :=
  (SdpaTwoPassWrites.labels 32).map (thread gate maxAst denAst transpose execution complete contracted base)

def sourcePrograms (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (base : Nat) : Option (List (List HalfMemory.Store)) := do
  let ps ←parsePointers sourcePointers
  if ps=pointers then
    let _ ←parseInitial sourceInitial
    let maxAst ←parseMaximum sourceMaximum
    let denAst ←parseDenominator sourceDenominator
    let _ ←parseNumerator sourceNumerator
    let transpose ←parseTranspose sourceTranspose
    let gate ←parseGate sourceGate
    pure (programs gate maxAst denAst transpose execution complete contracted base)
  else none

theorem entry_eq (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool)
    (finite : ∀ head, SdpaTwoPassVector.Finite p contracted blocks (query head) (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)))
    (base : Nat) (label : SdpaOutput.Label) (item : Fin 8) :
    entry .chunks .chunks .shared execution complete contracted base label item=
      SdpaOutput.entry base (SdpaTwoPassScratch.forward (execution.second contracted complete)) label item := by
  unfold entry SdpaOutput.entry SdpaOutput.address
  rw [MlxSdpaTwoPassMergeMemory.output_address,SdpaAddresses.output_address,
    bits_eq execution complete contracted label.1 (finite label.1)]
  rfl

theorem programs_eq (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool)
    (finite : ∀ head, SdpaTwoPassVector.Finite p contracted blocks (query head) (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)))
    (base : Nat) :
    sourcePrograms execution complete contracted base=
      some (SdpaOutput.programs base (SdpaTwoPassScratch.forward (execution.second contracted complete))) := by
  have parsed : sourcePrograms execution complete contracted base=
      some (programs .laneZero .chunks .chunks .shared execution complete contracted base) := by
    simp [sourcePrograms,parsed_pointers,parsed_initial,parsed_maximum,parsed_denominator,parsed_numerator,parsed_transpose,parsed_gate]
  rw [parsed]
  apply congrArg some
  unfold programs SdpaOutput.programs
  apply congrArg (List.map · (SdpaTwoPassWrites.labels 32))
  funext label
  unfold thread SdpaOutput.thread
  split
  · apply congrArg List.ofFn
    funext item
    exact entry_eq execution complete contracted finite base label item
  · rfl

theorem checked {architecture : Char} {contracted : Bool}
    {first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount architecture steps)}
    (execution : SdpaTwoPassDonation.Execution first contracted)
    (finite : ∀ head, SdpaTwoPassVector.Finite p contracted (SdpaDispatched.blockCount architecture steps)
      (query head) (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) :
    ∃ nativePrograms, sourcePrograms first (SdpaDispatchedDevice.complete_blocks architecture steps) contracted execution.stores.base=some nativePrograms ∧
      ThreadgroupWrites.Executes nativePrograms execution.stores.schedule execution.stores.remaining ∧
      ThreadgroupWrites.AtBarrier execution.stores.remaining ∧
      HalfMemory.execute execution.stores.schedule first.first.memory=execution.stores.memory := by
  refine ⟨_,programs_eq first _ contracted finite execution.stores.base,execution.stores.execution,execution.stores.completed,?_⟩
  rw [←execution.initial]
  rfl

end Inference.Kernels.Attention.MlxSdpaTwoPassOutputSource
