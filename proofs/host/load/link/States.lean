import host.load.Route
import host.ts.LinkChain
import host.load.Expr
import host.load.Native
namespace Host.Load.Link
open Host.Ts Host.Load

/-! Link states of the load route: the realm, then every module (`link_chain`). -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
link_chain L : Route.cx, Route.world, [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20]

end Host.Load.Link
