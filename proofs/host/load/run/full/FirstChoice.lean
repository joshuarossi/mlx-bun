import host.load.Native
import host.load.Decode
import host.load.Choice

namespace Host.Load.Run.Full
open Host.Ts Host.Load

/- Compact metadata and graph chosen at the first actual `for await` yield.
The source-state projection is checked separately in `FirstGraph`. -/
set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
load_replay_summary firstChoice : bootL Route.cx Decode.world 2000,
  Decode.tab, Decode.valuation, 29727013

end Host.Load.Run.Full
