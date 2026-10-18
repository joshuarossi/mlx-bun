import host.load.StopCommand
import host.load.run.full.H92
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full
open Host.Ts
def oneEosValuation (i : Nat) : F64 :=
  if i = 0 then .ofNat 1 else if i = 1 then .ofNat 248044 else Host.Load.Decode.valuation i
host_stop_fragment OneEos : P.s2973, P.S2973, oneEosValuation, 20000, 500, 0
end Host.Load.Run.Full
