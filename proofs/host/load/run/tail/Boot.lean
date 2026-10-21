import host.load.run.tail.LinkRun
import host.load.run.tail.States
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Tail
open Host.Ts Host.Load Host.Load.Run.Full

/- The finished link state is decode boundary 0 for every unread suffix
(`Full.link_join` for the original world). -/
kernel_rfl_eager Lk.join : ∀ τ : List NumV, (Lk.x840 τ).st = P.ta0 τ

/-- Booting the world with an arbitrary unread readback suffix reaches decode
boundary 0 with that suffix; the link phase does not inspect it. -/
theorem boot_tail (τ : List NumV) : bootL Route.cx (worldTail τ) 2000 = some (P.ta0 τ) :=
  (Lk.booted τ 2000 (by decide)).trans (congrArg some (Lk.join τ))

end Host.Load.Run.Tail
