import host.load.StopCommand
import host.load.run.full.H111
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full
open Host.Ts
def finalEosValuation (i : Nat) : F64 :=
  if i = 5 then .ofNat 248044 else Host.Load.Decode.valuation i
host_stop_fragment FinalEos : P.s3573, P.S3573, finalEosValuation, 20000, 500, 0
end Host.Load.Run.Full
