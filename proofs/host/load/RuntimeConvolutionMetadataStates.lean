import host.load.Micro
import host.ts.renameOrdinary.micro.streamed128.H0

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 4000000

namespace Host.Load.Run.Full
host_micro_states_group P.RestStream.micro0 6, 4, 1
end Host.Load.Run.Full
