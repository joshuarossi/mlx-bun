import host.load.StopCommand
import host.load.run.full.H97
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full
open Host.Ts
def twoTokenValuation (i : Nat) : F64 :=
  if i = 0 then .ofNat 2 else Host.Load.Decode.valuation i
host_stop_fragment TwoToken : P.s3123, P.S3123, twoTokenValuation, 20000, 500, 0
end Host.Load.Run.Full
