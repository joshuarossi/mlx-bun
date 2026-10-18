import host.load.Micro
import host.ts.renameOrdinary.micro.streamed128.H3

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 454, 1 chunks [9,1,90]
host_stream_state P.RestStream.micro0.micro454 0
host_stream_state P.RestStream.micro0.micro454 1
host_stream_state P.RestStream.micro0.micro454 2
end Host.Load.Run.Full
