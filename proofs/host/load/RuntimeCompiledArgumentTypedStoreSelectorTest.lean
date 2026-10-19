import host.load.RuntimeCompiledTypedHandleStore
import host.load.RuntimeCompiledArgumentEntrySelect

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry.TypedStoreSelectorTest
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_compiled_argument_linear_plan P.F, Region from 155 plan_steps 1 as Actual

theorem selected_input : Actual.TypedStore155.input = TypedHandleStore155.input := by host_kernel_rfl
theorem selected_output : Actual.TypedStore155.output = TypedHandleStore155.output := by host_kernel_rfl
theorem selected_count : Actual.TypedStore155.count = 3 := by host_kernel_rfl
theorem selected_index : Actual.TypedStore155.index = 0 := by host_kernel_rfl
theorem selected_handle : Actual.TypedStore155.handle = 29375 := by host_kernel_rfl
theorem selected_buffer : Actual.TypedStore155.buffer = Region.s106.next := by host_kernel_rfl
theorem selected_rule : Actual.rules = [``Actual.TypedStore155.retained_transport] := by host_kernel_rfl
theorem selected_steps : Actual.spans = [1] ∧ Actual.starts = [155] ∧ Actual.sourceSteps = 1 := by
  exact ⟨by host_kernel_rfl, by host_kernel_rfl, by host_kernel_rfl⟩

host_retained_theorem selected_retained := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Actual.TypedStore155.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s155 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s155 s)
    (oldRoles : List Annotated.Byte) (head : Annotated.Tree) (tail : List Annotated.Tree)
    (selected : notes.buffers.owners Actual.TypedStore155.buffer = some oldRoles)
    (controlNote : notes.runtime.control = returnNote (.handle Actual.TypedStore155.handle))
    (stackNotes : notes.runtime.stack = head::tail)
    (notFramed : ¬ framed Actual.TypedStore155.buffer)
    (targetBound : R.a Actual.TypedStore155.buffer < 2^64)
    (targetWord : R.handle Actual.TypedStore155.handle < 2^64) => by
  host_retained_plan_chain P.F, Actual using state, inventory, inst
host_assert_retained_schema selected_retained, 1

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_retained, 2

namespace WrongEndpoint
noncomputable def s155 := Region.s155
noncomputable def S155 := Region.S155
noncomputable def s156 := Region.s157
noncomputable def S156 := Region.S157
end WrongEndpoint

namespace WrongOperand
noncomputable def s155 := Region.s155.go (.ret (.big (Int.ofNat 29376)))
noncomputable def S155 := Region.S155
noncomputable def s156 := Region.s156
noncomputable def S156 := Region.S156
end WrongOperand

namespace LateWrongEndpoint
noncomputable def s154 := Region.s154
noncomputable def S154 := Region.S154
noncomputable def s155 := Region.s155
noncomputable def S155 := Region.S155
noncomputable def s156 := Region.s157
noncomputable def S156 := Region.S157
end LateWrongEndpoint

open Lean Elab Command in
private unsafe def expectRollback (label expected : String) (action : CommandElabM Unit) : CommandElabM Unit := do
  let saved : Command.State ← get
  let mut rendered := ""
  try action
  catch exception => rendered := rendered ++ (← exception.toMessageData.toString)
  let observed : Command.State ← get
  for message in observed.messages.toList.drop saved.messages.toList.length do
    rendered := rendered ++ "\n" ++ (← message.data.toString)
  -- Inspect the failed core before the test restores its own snapshot.
  let pre := (← getCurrNamespace) ++ Name.mkSimple label
  let leaked := observed.env.constants.toList.filterMap fun (name,_) =>
    if pre.isPrefixOf name then some name else none
  unless leaked.isEmpty do
    throwError "selector rejection leaked declarations before cleanup: {leaked}"
  unless ptrEq saved observed do
    throwError "selector rejection did not restore the complete Command.State before cleanup: {label}"
  unless (rendered.splitOn expected).length > 1 do
    throwError "selector negative failed for the wrong reason: {label}: {rendered}"
  set saved

open Lean Elab Command in
run_cmd do
  let f ← `(term| P.F)
  for (label,base,start,count,expected) in [
      ("Endpoint", "WrongEndpoint", 155, 1, "(kernel) declaration type mismatch"),
      ("Operand", "WrongOperand", 155, 1, "(kernel) declaration type mismatch"),
      ("Truncated", "Region", 126, 4, "complete indexed assignment exceeds the requested endpoint"),
      ("LateEndpoint", "LateWrongEndpoint", 154, 2, "(kernel) declaration type mismatch")] do
    let base : TSyntax `ident := ⟨mkIdent (Name.mkSimple base)⟩
    let name : TSyntax `ident := ⟨mkIdent (Name.mkSimple label)⟩
    let start : TSyntax `num := ⟨Syntax.mkNumLit (toString start)⟩
    let count : TSyntax `num := ⟨Syntax.mkNumLit (toString count)⟩
    expectRollback label expected <|
      Driver.elaborateCompiledArgumentLinearPlan f base start count name
  let command := "host_retained_typed_handle_store P.F, Region.s155 using (Region.S155.substitute LoopVariables.oracleVariables) to Region.s156 using (Region.S156.substitute LoopVariables.oracleVariables) with 2 as Count"
  let stx ← liftCoreM <| ofExcept <| Parser.runParserCategory (← getEnv) `command command
  let [entry] := commandElabAttribute.getEntries (← getEnv) stx.getKind
    | throwError "expected the single typed handle store command elaborator"
  expectRollback "Count" "(kernel) declaration type mismatch" (entry.value stx)

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry.TypedStoreSelectorTest
