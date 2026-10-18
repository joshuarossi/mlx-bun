import host.load.Micro
import host.ts.renameOrdinary.micro.streamed128.H0

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000

namespace Host.Load.Run.Full
/- Candidate data from the authoritative source-2800 boundary. Execution
claims are supplied only by the downstream ordinary kernel equations. -/
host_micro_states P.RestStream.micro0 28, 1
end Host.Load.Run.Full
