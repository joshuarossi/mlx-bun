import host.load.Micro
import host.ts.RenameRouteDriver
import host.ts.renameOrdinary.micro.streamed128.H0

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 61, 1
run_cmd do
  for i in [:5] do
    Host.Ts.Owned.Parametric.Driver.emit s!"host_stream_state P.RestStream.micro0.micro61 {i}"
end Host.Load.Run.Full

set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ConfigFreeStates
open Host.Ts
noncomputable def entry : St LSt × SSrv := (P.RestStream.micro0.micro61.s3,P.RestStream.micro0.micro61.S3)
noncomputable def after : St LSt × SSrv := (P.RestStream.micro0.micro61.s4,P.RestStream.micro0.micro61.S4)
theorem source_prefix : runS P.F 3 P.RestStream.micro0.s61 P.RestStream.micro0.S61 = some entry := by host_kernel_rfl
theorem source_step : runS P.F 1 entry.1 entry.2 = some after := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.ConfigFreeStates
