import host.load.Micro
import host.ts.RenameRouteDriver
import host.ts.renameOrdinary.micro.streamed128.H1

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 165, 1 chunks [30,1,69]
host_stream_state P.RestStream.micro0.micro165 0
host_stream_state P.RestStream.micro0.micro165 1
host_stream_state P.RestStream.micro0.micro165 2
end Host.Load.Run.Full

set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RmsStates
open Host.Ts
noncomputable def entry : St LSt × SSrv := (P.RestStream.micro0.micro165.s1,P.RestStream.micro0.micro165.S1)
noncomputable def after : St LSt × SSrv := (P.RestStream.micro0.micro165.s2,P.RestStream.micro0.micro165.S2)
theorem source_prefix : runS P.F 30 P.RestStream.micro0.s165 P.RestStream.micro0.S165 = some entry := by host_kernel_rfl
theorem source_step : runS P.F 1 entry.1 entry.2 = some after := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.RmsStates
