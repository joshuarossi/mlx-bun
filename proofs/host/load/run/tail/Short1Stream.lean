import host.load.run.tail.States
import host.load.run.tail.ShortCommand
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full
open Host.Ts

/- Budget 1: from boundary 2973 (before the first budget test) with the queue
`.ref 1, .ref 2` of `worldTail []`. -/
host_stream_branch Short1 from P 2973 := P.ta2973 [] tokens [.ref 1, .ref 2]
  valuation (fun i => F64.ofNat ([1, 100, 101, 102].getD i 0)) width 1000

end Host.Load.Run.Full
