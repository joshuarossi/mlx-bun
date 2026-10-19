import host.load.RuntimeCompiledArgumentEntryPlan
import host.load.RuntimeCompiledArgumentEntrySelect
import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry.AllocationSelectorTest
open Host.Ts

host_compiled_argument_linear_plan P.F, Region from 106 plan_steps 1 as Count
host_compiled_argument_linear_plan P.F, Region from 126 plan_steps 5 as Index

theorem selects_current_typed_constructor : Count.TypedCount106.input = Region.s106 ∧
    Count.TypedCount106.output = Region.s107 := by constructor <;> host_kernel_rfl

theorem selects_complete_index_assignment : Index.VariableIndex126.input = Region.s126 ∧
    Index.VariableIndex126.output = Region.s131 := by constructor <;> host_kernel_rfl

theorem selected_spans : Count.spans.sum = 1 ∧ Index.spans.sum = 5 := by decide +kernel

/-- error: compiled argument plan: complete indexed assignment exceeds the requested endpoint -/
#guard_msgs in
host_compiled_argument_linear_plan P.F, Region from 126 plan_steps 4 as Truncated

open Lean Elab Command in
run_cmd do
  for tag in [`VariableIndex126.input,`rules,`sourceSteps] do
    if (← getEnv).contains ((← getCurrNamespace) ++ `Truncated ++ tag) then
      throwError "truncated source selection exported a partial plan"

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry.AllocationSelectorTest
