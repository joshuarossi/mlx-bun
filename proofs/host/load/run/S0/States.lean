import host.load.Route
import host.load.Segment
import host.load.Expr
namespace Host.Load.Run.S0
open Host.Ts Host.Load

/-! Segment 0 of the load run: 50 chunks of 10000 steps from step 0. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
run_segment P : Host.Load.ffi, bootL Route.cx Route.world 2000, ⟨[], []⟩, 0, [10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000]

end Host.Load.Run.S0
