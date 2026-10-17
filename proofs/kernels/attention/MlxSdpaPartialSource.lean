import kernels.attention.MlxSdpaUpdateSource

namespace Inference.Kernels.Attention.MlxSdpaPartialSource
open Contracts.Mlx State
open Normalization.MlxRmsLoopSyntax (acceptAll)
open MlxSdpaScoreSource (thread)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

inductive Initial where | empty deriving DecidableEq, Repr

def parseInitial (source : String) : Option Initial := do
  let ts ←MlxSdpaScoreSource.lex (source.length+1) source.toList
  let rest ←acceptAll ["for","(","int","i","=","0",";","i","<","v_per_thread",";","i","+","+",")","{",
    "o","[","i","]","=","0",";","}","U","max_score","=","Limits","<","U",">",":",":","finite_min",";",
    "U","sum_exp_score","=","0",";"] ts
  if rest=[] then some .empty else none

def sourceInitial : String := r#"for (int i = 0; i < v_per_thread; i++) {
    o[i] = 0;
  }

  U max_score = Limits<U>::finite_min;
  U sum_exp_score = 0;"#
theorem parsed_initial : parseInitial sourceInitial=some .empty := by decide +kernel

def initial (_ : Initial) : SdpaUpdate.State := ⟨SdpaVector.initialShift,0,0⟩

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF}
  {cache : Kv.Cache Kv.BF steps} {input : SdpaMemory.Input query cache}
  {p : SdpaVector.Platform} {architecture : Char}

-- A witness is a real prefix of the existing buffer-ownership machine, with
-- every lane's previously captured query registers. There is no score/max/
-- exponential/denominator/numerator correctness field.
structure Witness (execution : SdpaOnePassDonation.Execution input p architecture)
    (head : Fin 24) (group : Fin 32) where
  after : SdpaQueryMemory.Machine
  events : List (ReadBeforeOverwrite.Event 24 1024)
  run : ReadBeforeOverwrite.Executes (SdpaQueryMemory.layout execution.base) (SdpaQueryMemory.read execution.base)
    (ReadBeforeOverwrite.initial input.cache.memory) events after
  registers : Fin 32 → SdpaQueryMemory.Registers
  captured : ∀ lane, after.registers head (thread group lane)=some (registers lane)

def Witness.fromExecution (execution : SdpaOnePassDonation.Execution input p architecture)
    (head : Fin 24) (group : Fin 32) : Witness execution head group where
  after := execution.queries.after
  events := execution.queries.events
  run := by rw [←execution.initial]; exact execution.queries.execution
  registers := fun lane => (execution.queries.after.registers head (thread group lane)).getD (fun _ => 0)
  captured := by
    intro lane
    cases h : execution.queries.after.registers head (thread group lane) with
    | none => exact False.elim (execution.queries.ready head (thread group lane) h)
    | some registers => simp

def update (execution : SdpaOnePassDonation.Execution input p architecture)
    (head : Fin 24) (group lane : Fin 32) (item : Fin 8)
    (witness : Witness execution head group) (iteration : Fin (SdpaLayout.count steps group))
    (state : SdpaUpdate.State) : Option SdpaUpdate.State :=
  MlxSdpaUpdateSource.source p witness.registers witness.after.memory input.cache.layout.keyBase input.cache.layout.valueBase
    (KvAllocation.capacity steps) head group lane iteration.val item state

inductive Executes (execution : SdpaOnePassDonation.Execution input p architecture)
    (head : Fin 24) (group lane : Fin 32) (item : Fin 8) :
    List (Fin (SdpaLayout.count steps group)) → SdpaUpdate.State → SdpaUpdate.State → Prop where
  | done (state) : Executes execution head group lane item [] state state
  | next (witness : Witness execution head group) (iteration : Fin (SdpaLayout.count steps group))
      (start middle finish : SdpaUpdate.State) (rest : List (Fin (SdpaLayout.count steps group)))
      (parsed : update execution head group lane item witness iteration start=some middle)
      (tail : Executes execution head group lane item rest middle finish) :
      Executes execution head group lane item (iteration::rest) start finish

variable {execution : SdpaOnePassDonation.Execution input p architecture}
  {head : Fin 24} {group lane : Fin 32} {item : Fin 8}
  {ordinals : List (Fin (SdpaLayout.count steps group))} {start finish : SdpaUpdate.State}

theorem refinement (run : Executes execution head group lane item ordinals start finish) :
    finish=SdpaLoop.run p.merge.scalar p.maximum
      (SdpaVector.scores p (query head) (cache.keys (SdpaScore.kvHead head)))
      (SdpaVector.valuesAt (cache.values (SdpaScore.kvHead head)) (SdpaScore.index lane item))
      (ordinals.map (SdpaLayout.key steps group)) start := by
  induction run with
  | done state => rfl
  | next witness iteration start middle finish rest parsed tail ih =>
    have exactUpdate := MlxSdpaUpdateSource.current_update execution witness.run head group lane iteration
      witness.registers witness.captured item start
    change update execution head group lane item witness iteration start=_ at exactUpdate
    rw [parsed] at exactUpdate
    have same := Option.some.inj exactUpdate
    rw [ih,same]
    rfl

theorem selected_complete
    (run : Executes execution head group lane item (List.finRange (SdpaLayout.count steps group))
      (initial .empty) finish) :
    finish=SdpaVector.partials p (query head) (cache.keys (SdpaScore.kvHead head))
      (cache.values (SdpaScore.kvHead head)) (SdpaScore.index lane item) group := by
  rw [refinement run]
  have schedule : (List.finRange (SdpaLayout.count steps group)).map (SdpaLayout.key steps group)=SdpaLayout.keys steps group := by
    change (List.ofFn id).map (SdpaLayout.key steps group)=_
    rw [List.map_ofFn]
    rfl
  rw [schedule]
  rfl

theorem exists_execution (witness : Witness execution head group)
    (ordinals : List (Fin (SdpaLayout.count steps group))) (start : SdpaUpdate.State) :
    ∃ finish, Executes execution head group lane item ordinals start finish := by
  induction ordinals generalizing start with
  | nil => exact ⟨start,.done start⟩
  | cons iteration rest ih =>
    have step := MlxSdpaUpdateSource.current_update execution witness.run head group lane iteration
      witness.registers witness.captured item start
    change update execution head group lane item witness iteration start=_ at step
    obtain ⟨finish,tail⟩ := ih _
    exact ⟨finish,.next witness iteration start _ finish rest step tail⟩

theorem complete_exists (execution : SdpaOnePassDonation.Execution input p architecture)
    (head : Fin 24) (group lane : Fin 32) (item : Fin 8) :
    ∃ finish, Executes execution head group lane item (List.finRange (SdpaLayout.count steps group))
      (initial .empty) finish ∧
      finish=SdpaVector.partials p (query head) (cache.keys (SdpaScore.kvHead head))
        (cache.values (SdpaScore.kvHead head)) (SdpaScore.index lane item) group := by
  obtain ⟨finish,run⟩ := exists_execution (Witness.fromExecution execution head group)
    (List.finRange (SdpaLayout.count steps group)) (initial .empty)
  exact ⟨finish,run,selected_complete run⟩

end Inference.Kernels.Attention.MlxSdpaPartialSource
