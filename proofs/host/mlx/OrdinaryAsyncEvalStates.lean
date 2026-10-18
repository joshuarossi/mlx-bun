import host.load.Micro
import host.ts.renameOrdinary.micro.streamed128.H4

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 612, 1 chunks [99,1]
host_stream_state P.RestStream.micro0.micro612 0
host_stream_state P.RestStream.micro0.micro612 1
host_stream_state P.RestStream.micro0.micro612 2
end Host.Load.Run.Full
