import host.load.Micro
import host.ts.renameOrdinary.micro.streamed128.H3

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 500, 1
host_stream_state P.RestStream.micro0.micro500 36
host_stream_state P.RestStream.micro0.micro500 37
end Host.Load.Run.Full
