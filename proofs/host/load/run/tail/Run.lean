import host.load.run.tail.Boot
import host.load.run.tail.Prefix
namespace Host.Load.Run.Tail
open Host.Ts Host.Load Host.Load.Run.Full

/-- Boot to the first ordinary readback cut (decode boundary 3272, about to read
`.ref 2`) for every unread native token suffix `τ`. -/
theorem boot_to_cut (τ : List NumV) :
    (bootL Route.cx (worldTail τ) 2000).bind (fun s => runS P.F 32711604 s P.S0) =
      some (P.ta3272 τ, P.S3272) :=
  (congrArg (fun o => o.bind fun s => runS P.F 32711604 s P.S0) (boot_tail τ)).trans
    ((Option.bind_some _ _).trans (tail_prefix τ))

end Host.Load.Run.Tail
