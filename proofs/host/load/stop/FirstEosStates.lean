import host.load.StopCommand
import host.load.run.full.H92
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full
open Host.Ts
def firstEosValuation (i : Nat) : F64 :=
  if i = 1 then .ofNat 248044 else Host.Load.Decode.valuation i
host_stop_fragment FirstEos : P.s2973, P.S2973, firstEosValuation, 2000000, 10000, 0
end Host.Load.Run.Full
