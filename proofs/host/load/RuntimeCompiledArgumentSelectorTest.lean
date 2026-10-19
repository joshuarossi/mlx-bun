import host.load.RuntimeCompiledArgumentEntryCuts2057
import host.load.RuntimeCompiledArgumentEntrySelect
import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry.SelectorTest
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

-- Exercise the local selector on the real twelve-step prefix. The chain
-- return at source2060 lies between two ordinary source-selected spans.
host_compiled_argument_linear_plan P.F, From2057 from 0 plan_steps 12 as Actual

theorem starts_at_source2057 : Actual.Span0.Block0.input = From2057.s0 := by
  host_kernel_rfl
theorem selects_source2060 : Actual.Chain3.input = From2057.s3 := by
  host_kernel_rfl
theorem returns_to_source2061 : Actual.Chain3.output = From2057.s4 := by
  host_kernel_rfl
theorem covers_twelve_steps : Actual.sourceSteps = 12 ∧ Actual.spans.sum = 12 := by
  decide +kernel

/-- error: compiled argument plan: expected a non-empty region inside steps 0..279 -/
#guard_msgs in
host_compiled_argument_linear_plan P.F, From2057 from 0 plan_steps 0 as Empty

/-- error: compiled argument plan: expected a non-empty region inside steps 0..279 -/
#guard_msgs in
host_compiled_argument_linear_plan P.F, From2057 from 279 plan_steps 2 as Outside

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry.SelectorTest
