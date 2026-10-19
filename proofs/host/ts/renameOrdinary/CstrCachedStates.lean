import host.load.Micro
import host.ts.RenameRuntimeDerivedCuts
import host.ts.renameOrdinary.micro.streamed128.H0

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 82, 1 chunks [75,25]
host_stream_state P.RestStream.micro0.micro82 0
host_stream_state P.RestStream.micro0.micro82 1
host_stream_state P.RestStream.micro0.micro82 2
end Host.Load.Run.Full

set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CstrCachedStates
host_derive_source_cuts P.F, P.RestStream.micro0.micro82.s1 using P.RestStream.micro0.micro82.S1 steps 25 as Body
end Host.Load.Run.Full.Ordinary.CstrCachedStates
