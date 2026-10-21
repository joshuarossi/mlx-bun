import host.load.run.tail.States
import host.load.run.tail.ShortCommand
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full
open Host.Ts

/- Budget 2: from boundary 3123 (before the second-token budget test) with the
queue `.ref 2` left of `worldTail []`. -/
host_stream_branch Short2 from P 3123 := P.ta3123 [] tokens [.ref 2]
  valuation (fun i => F64.ofNat ([2, 100, 101, 102].getD i 0)) width 1000

end Host.Load.Run.Full
