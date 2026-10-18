import host.load.Micro
import host.ts.RenameRouteDriver
import host.ts.renameOrdinary.micro.streamed128.H1
import host.ts.renameOrdinary.micro.streamed128.H4

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 158, 1 chunks [73,1,26]
host_stream_state P.RestStream.micro0.micro158 0
host_stream_state P.RestStream.micro0.micro158 1
host_stream_state P.RestStream.micro0.micro158 2
host_micro_stream P.RestStream.micro0 522, 1 chunks [26,1,73]
host_stream_state P.RestStream.micro0.micro522 0
host_stream_state P.RestStream.micro0.micro522 1
host_stream_state P.RestStream.micro0.micro522 2
end Host.Load.Run.Full

set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.BinaryStates
open Host.Ts
noncomputable def addEntry : St LSt × SSrv := (P.RestStream.micro0.micro158.s1,P.RestStream.micro0.micro158.S1)
noncomputable def addAfter : St LSt × SSrv := (P.RestStream.micro0.micro158.s2,P.RestStream.micro0.micro158.S2)
noncomputable def multiplyEntry : St LSt × SSrv := (P.RestStream.micro0.micro522.s1,P.RestStream.micro0.micro522.S1)
noncomputable def multiplyAfter : St LSt × SSrv := (P.RestStream.micro0.micro522.s2,P.RestStream.micro0.micro522.S2)
theorem add_prefix : runS P.F 73 P.RestStream.micro0.s158 P.RestStream.micro0.S158 = some addEntry := by host_kernel_rfl
theorem add_step : runS P.F 1 addEntry.1 addEntry.2 = some addAfter := by host_kernel_rfl
theorem multiply_prefix : runS P.F 26 P.RestStream.micro0.s522 P.RestStream.micro0.S522 = some multiplyEntry := by host_kernel_rfl
theorem multiply_step : runS P.F 1 multiplyEntry.1 multiplyEntry.2 = some multiplyAfter := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.BinaryStates
