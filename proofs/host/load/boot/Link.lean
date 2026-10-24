import host.load.boot.link.Run
import host.load.boot.States
import host.load.run.tail.Command
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Load

/-! # Booting the prompt route with any unread readback suffix

The link (`Link.Lq`, for every prompt and suffix) ends in the boot stream's boundary 0 over the
suffix (`P.at0`), so booting `RoutePrompt.cxV fw` in `worldTail tail` (the world with the native
readbacks `.ref 1, .ref 2` then `tail`) reaches `P.at0 fw tail` (`boot_tail`). -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager Lq_join : ∀ (fw : List Val) (tail : List NumV), (Link.Lq.x840 fw tail).st = P.at0 fw tail

/-- **The boot for every prompt and unread readback suffix.** -/
theorem boot_tail (fw : List Val) (tail : List NumV) :
    bootL (RoutePrompt.cxV fw) (Run.Tail.worldTail tail) 2000 = some (P.at0 fw tail) :=
  (Link.Lq.booted fw tail 2000 (by decide)).trans (congrArg some (Lq_join fw tail))

end Host.Load.Run.Prompt
