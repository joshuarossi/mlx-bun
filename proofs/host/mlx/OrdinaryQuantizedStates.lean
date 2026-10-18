import host.load.Micro
import host.ts.RenameRouteDriver
import host.ts.renameOrdinary.micro.streamed128.H0

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 83, 1 chunks [9,1,90]
host_stream_state P.RestStream.micro0.micro83 0
host_stream_state P.RestStream.micro0.micro83 1
host_stream_state P.RestStream.micro0.micro83 2
end Host.Load.Run.Full

set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.QuantizedStates
open Host.Ts
noncomputable def entry : St LSt × SSrv := (P.RestStream.micro0.micro83.s1,P.RestStream.micro0.micro83.S1)
noncomputable def after : St LSt × SSrv := (P.RestStream.micro0.micro83.s2,P.RestStream.micro0.micro83.S2)
theorem source_prefix : runS P.F 9 P.RestStream.micro0.s83 P.RestStream.micro0.S83 = some entry := by host_kernel_rfl
theorem source_step : runS P.F 1 entry.1 entry.2 = some after := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.QuantizedStates
