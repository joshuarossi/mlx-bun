import host.load.RuntimeBlockPlan
import host.ts.RenameRetainedLiteralArrowTest
import host.ts.RenameRuntimeDerivedCuts
import host.ts.RenameLoopVariableNamespace
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.LiteralArrowPlanTest
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Ts.Owned.Annotated.Tests.LiteralArrow
host_derive_source_cuts Host.Ts.Owned.Annotated.Tests.LiteralArrow.ffi, input using server steps 5 as Region
host_source_linear_plan_subst Host.Ts.Owned.Annotated.Tests.LiteralArrow.ffi, Region from 0 plan_steps 5 substitute (fun i => SymE.var i) as Plan

theorem selected_one_call_contract : Plan.spans = [5] := by decide +kernel

theorem actual_endpoint : Region.s5 = output := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.LiteralArrowPlanTest
