import host.load.Micro
import host.ts.RenameRouteDriver
import host.ts.renameOrdinary.micro.streamed128.H0

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 50, 1
run_cmd do
  for i in [:31] do
    Host.Ts.Owned.Parametric.Driver.emit s!"host_stream_state P.RestStream.micro0.micro50 {i}"
end Host.Load.Run.Full

set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ConfigIntStates
open Host.Ts

noncomputable def entry : St LSt × SSrv := (P.RestStream.micro0.micro50.s29,P.RestStream.micro0.micro50.S29)
noncomputable def after : St LSt × SSrv := (P.RestStream.micro0.micro50.s30,P.RestStream.micro0.micro50.S30)

theorem source_prefix : runS P.F 29 P.RestStream.micro0.s50 P.RestStream.micro0.S50 = some entry := by host_kernel_rfl
theorem source_step : runS P.F 1 entry.1 entry.2 = some after := by host_kernel_rfl

end Host.Load.Run.Full.Ordinary.ConfigIntStates
