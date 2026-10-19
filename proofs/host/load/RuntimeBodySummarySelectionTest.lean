import host.load.RuntimeNamespacedDecodePlan1220
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.BodySummarySelectionTest
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem number_return_span : NamespacedDecode.Plan1220.spans.head? = some 6 := by decide +kernel
theorem source_steps : NamespacedDecode.Plan1220.spans.sum = 65 := by decide +kernel
end Host.Load.Run.Full.Ordinary.BodySummarySelectionTest
