import host.load.Micro
import host.ts.renameOrdinary.micro.streamed128.H0

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_micro_states P.RestStream.micro0 3, 1
end Host.Load.Run.Full
