import host.load.Micro
import host.ts.RenameRouteDriver
import host.ts.renameOrdinary.micro.streamed128.H0

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 46, 1
run_cmd do
  for i in [:96] do
    Host.Ts.Owned.Parametric.Driver.emit s!"host_stream_state P.RestStream.micro0.micro46 {i}"
end Host.Load.Run.Full

set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ConfigOutputStates
open Host.Ts
noncomputable def entry : St LSt × SSrv := (P.RestStream.micro0.micro46.s94,P.RestStream.micro0.micro46.S94)
noncomputable def after : St LSt × SSrv := (P.RestStream.micro0.micro46.s95,P.RestStream.micro0.micro46.S95)
theorem source_prefix : runS P.F 94 P.RestStream.micro0.s46 P.RestStream.micro0.S46 = some entry := by host_kernel_rfl
theorem source_step : runS P.F 1 entry.1 entry.2 = some after := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.ConfigOutputStates
