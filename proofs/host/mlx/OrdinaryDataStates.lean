import host.load.Micro
import host.ts.renameOrdinary.micro.streamed128.H0

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 43, 1 chunks [18,1,81]
host_stream_state P.RestStream.micro0.micro43 0
host_stream_state P.RestStream.micro0.micro43 1
host_stream_state P.RestStream.micro0.micro43 2
end Host.Load.Run.Full
