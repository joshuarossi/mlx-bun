import host.load.Micro
import host.ts.RenameRouteDriver
import host.ts.renameOrdinary.micro.streamed128.H0

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 47, 1 chunks [94,1,5]
host_stream_state P.RestStream.micro0.micro47 0
host_stream_state P.RestStream.micro0.micro47 1
host_stream_state P.RestStream.micro0.micro47 2
host_micro_stream P.RestStream.micro0 48, 1 chunks [27,1,72]
host_stream_state P.RestStream.micro0.micro48 0
host_stream_state P.RestStream.micro0.micro48 1
host_stream_state P.RestStream.micro0.micro48 2
end Host.Load.Run.Full

set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ConfigTripletStates
open Host.Ts
noncomputable def gridEntry : St LSt × SSrv := (P.RestStream.micro0.micro47.s1,P.RestStream.micro0.micro47.S1)
noncomputable def gridAfter : St LSt × SSrv := (P.RestStream.micro0.micro47.s2,P.RestStream.micro0.micro47.S2)
noncomputable def groupEntry : St LSt × SSrv := (P.RestStream.micro0.micro48.s1,P.RestStream.micro0.micro48.S1)
noncomputable def groupAfter : St LSt × SSrv := (P.RestStream.micro0.micro48.s2,P.RestStream.micro0.micro48.S2)
theorem grid_prefix : runS P.F 94 P.RestStream.micro0.s47 P.RestStream.micro0.S47 = some gridEntry := by host_kernel_rfl
theorem grid_step : runS P.F 1 gridEntry.1 gridEntry.2 = some gridAfter := by host_kernel_rfl
theorem group_prefix : runS P.F 27 P.RestStream.micro0.s48 P.RestStream.micro0.S48 = some groupEntry := by host_kernel_rfl
theorem group_step : runS P.F 1 groupEntry.1 groupEntry.2 = some groupAfter := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.ConfigTripletStates
