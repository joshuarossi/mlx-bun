import kernels.delta.GatedOutputSyntax
import kernels.delta.GatedPointerSource

namespace Inference.Kernels.Delta.GatedOutputSource
open Contracts.Mlx GatedOutputSyntax GatedStores
set_option maxRecDepth 2000
attribute [local irreducible] GatedPointerSource.source GatedStepSource.source
  timeVisits stateVisits parseWriter parseAdvance
variable {initial : GatedDevice.State} {values : GatedInputs.Values}

def single (capture : Option α) (times : Option (List Nat)) (body : α → Option β)
    (advance : Option Unit) : Option β := do
  let captured ←capture
  let visits ←times
  match visits with
  | [0] =>
    let result ←body captured
    let _ ←advance
    pure result
  | _ => none

private theorem single_eq (capture : Option α) (times : Option (List Nat)) (body : α → Option β)
    (advance : Option Unit) (x : α) (y : β)
    (hc : capture=some x) (ht : times=some [0]) (hb : body x=some y) (ha : advance=some ()) :
    single capture times body advance=some y := by
  rw [single,hc,ht]
  change (body x).bind (fun result => advance.bind (fun _ => some result))=_
  rw [hb,ha]
  rfl

def runOne (input : GatedShared.Input initial values) (head : Fin 48) (row : Fin 128)
    (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction) : Option GatedStepSource.Result :=
  single (GatedPointerSource.source input head row) timeVisits
    (fun captured => GatedStepSource.source captured flags reduce) (parseAdvance advanceSource)

theorem run_one (input : GatedShared.Input initial values) (head : Fin 48) (row : Fin 128)
    (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction) :
    runOne input head row reduce flags=some ⟨
      fun lane i => Gated.sourceState (Recurrence.bind (input.state.read head row) (input.operands.inputs head row))
        reduce flags (Gated.laneIndex lane i),
      Gated.sourceOutput (Recurrence.bind (input.state.read head row) (input.operands.inputs head row)) reduce flags⟩ := by
  unfold runOne
  exact single_eq _ _ _ _ _ _ (GatedPointerSource.source_execution input head row) time_visits
    (GatedStepSource.source_execution _ flags reduce) parsed_advance

def thread (input : GatedShared.Input initial values) (stateBase outputBase : Nat)
    (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction) (label : Label) : Option (List GatedBytes.Event) := do
  let result ←runOne input label.1 label.2.1 reduce flags
  let writer ←parseWriter writerSource
  let indices ←stateVisits
  let output : List GatedBytes.Event := if label.2.2.val=writer then
    [.output ⟨outputBase/2+GatedPointerSource.valueOffset label.1 label.2.1,(BFloat16.narrow result.output).bits⟩] else []
  let state := indices.map (fun i => GatedBytes.Event.state
    ⟨stateBase/4+GatedPointerSource.stateOffset label.1 label.2.1 (Gated.laneIndex label.2.2 i),
      FloatMemory.bits (result.state label.2.2 i)⟩)
  pure (output++state)

theorem source_thread (input : GatedShared.Input initial values) (stateBase outputBase : Nat)
    (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction) (label : Label) :
    thread input stateBase outputBase reduce flags label=some (GatedBytes.thread stateBase outputBase
      (GatedDevice.producedState reduce flags input.state.read input.operands.inputs)
      (GatedDevice.producedOutput reduce flags input.state.read input.operands.inputs) label) := by
  unfold thread
  rw [run_one,parsed_writer,state_visits]
  simp only [bind,Option.bind,GatedPointerSource.value_index,GatedPointerSource.state_index]
  unfold GatedBytes.thread outputThread outputEntry stateThread stateEntry
    GatedDevice.producedState GatedDevice.producedOutput Recurrence.step Gated.value GatedBytes.bits
  by_cases writer : label.2.2.val=0
  · simp only [writer,ite_true,List.map_singleton,List.map_map,Function.comp_def]
    rfl
  · simp only [writer,ite_false,List.map_nil,List.map_map,Function.comp_def]
    rfl

def programs (input : GatedShared.Input initial values) (stateBase outputBase : Nat)
    (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction) : Option (List (List GatedBytes.Event)) :=
  labels.mapM (thread input stateBase outputBase reduce flags)

theorem source_programs (input : GatedShared.Input initial values) (stateBase outputBase : Nat)
    (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction) :
    programs input stateBase outputBase reduce flags=some (GatedBytes.programs stateBase outputBase
      (GatedDevice.producedState reduce flags input.state.read input.operands.inputs)
      (GatedDevice.producedOutput reduce flags input.state.read input.operands.inputs)) := by
  unfold programs GatedBytes.programs
  induction labels with
  | nil => rfl
  | cons label rest ih =>
    simp only [List.mapM_cons,List.map_cons,source_thread,bind,Option.bind,ih]
    rfl

variable {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}

theorem current_programs (execution : GatedShared.Execution reduce flags initial values)
    (events : List GatedBytes.Event) (inside : ∀ event ∈ events,event ∈ execution.stores.trace.schedule) :
    programs (execution.during events inside) execution.stores.trace.stateBase execution.stores.trace.outputBase reduce flags=
      some (GatedBytes.programs execution.stores.trace.stateBase execution.stores.trace.outputBase
        (GatedDevice.producedState reduce flags execution.input.state.read execution.input.operands.inputs)
        (GatedDevice.producedOutput reduce flags execution.input.state.read execution.input.operands.inputs)) := by
  rw [source_programs,execution.partial_state events inside,execution.partial_output events inside]

theorem source_execution (execution : GatedShared.Execution reduce flags initial values)
    (events : List GatedBytes.Event) (inside : ∀ event ∈ events,event ∈ execution.stores.trace.schedule) :
    ∃ writes, programs (execution.during events inside) execution.stores.trace.stateBase execution.stores.trace.outputBase reduce flags=some writes ∧
      ThreadgroupWrites.Executes writes execution.stores.trace.schedule execution.stores.trace.remaining ∧
      ThreadgroupWrites.AtBarrier execution.stores.trace.remaining :=
  ⟨_,current_programs execution events inside,execution.stores.trace.execution,execution.stores.trace.completed⟩

theorem current_state (execution : GatedShared.Execution reduce flags initial values) (head : Fin 48) (row key : Fin 128) :
    FloatMemory.load execution.stores.memory (execution.stores.trace.stateBase+4*stateIndex head row key)=
      GatedDevice.producedState reduce flags initial values.inputs head row key := by
  exact congrFun (congrFun (congrFun execution.state_eq head) row) key

theorem current_output (execution : GatedShared.Execution reduce flags initial values) (head : Fin 48) (row : Fin 128) :
    HalfMemory.load execution.stores.memory (execution.stores.trace.outputBase+2*outputIndex head row)=
      (GatedDevice.producedOutput reduce flags initial values.inputs head row).bits := by
  exact congrArg (fun value : GatedBytes.BF => value.bits) (congrFun (congrFun execution.output_eq head) row)

end Inference.Kernels.Delta.GatedOutputSource
