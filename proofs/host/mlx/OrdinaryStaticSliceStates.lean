import host.load.Micro
import host.ts.renameOrdinary.micro.streamed128.H3

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 420, 1 chunks [72,1,27]
host_stream_state P.RestStream.micro0.micro420 0
host_stream_state P.RestStream.micro0.micro420 1
host_stream_state P.RestStream.micro0.micro420 2
end Host.Load.Run.Full
