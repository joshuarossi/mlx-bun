import host.load.RuntimeCompiledArgumentEntryPlan
import host.load.RuntimeCompiledArgumentEntrySelect
import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry.AllocationSelectorTest
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_compiled_argument_linear_plan P.F, Region from 106 plan_steps 1 as Count
host_compiled_argument_linear_plan P.F, Region from 126 plan_steps 5 as Index

theorem selects_current_typed_constructor : Count.TypedCount106.input = Region.s106 ∧
    Count.TypedCount106.output = Region.s107 := by constructor <;> host_kernel_rfl

theorem selects_complete_index_assignment : Index.VariableIndex126.input = Region.s126 ∧
    Index.VariableIndex126.output = Region.s131 := by constructor <;> host_kernel_rfl

theorem selected_spans : Count.spans.sum = 1 ∧ Index.spans.sum = 5 := by decide +kernel

theorem selected_index_span : Index.VariableIndex126.span = 5 := by host_kernel_rfl

host_retained_theorem selected_index_run := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Index.VariableIndex126.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s126 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s126 s)
    (indexNote : notes.runtime.cells.cells Index.VariableIndex126.indexCell =
      some (.literal (.lit Index.VariableIndex126.literal))) => by
  host_retained_plan_chain P.F, Index using state, inventory, inst
host_assert_retained_schema selected_index_run, 5

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_index_run, 4

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_index_run, 6

/-- error: compiled argument plan: complete indexed assignment exceeds the requested endpoint -/
#guard_msgs in
host_compiled_argument_linear_plan P.F, Region from 126 plan_steps 4 as Truncated

open Lean Elab Command in
run_cmd do
  for tag in [`VariableIndex126.input,`rules,`sourceSteps] do
    if (← getEnv).contains ((← getCurrNamespace) ++ `Truncated ++ tag) then
      throwError "truncated source selection exported a partial plan"

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry.AllocationSelectorTest
