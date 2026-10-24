import host.load.run.prompt.link.Run
import host.load.run.prompt.H0
import host.load.run.tail.Command
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Load
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/- The finished link is the stream's boundary 0, for every prompt. -/
kernel_rfl_eager link_join : ∀ fw : List Val, (Link.Lp.x840 fw).st = P.a0 fw

/-- Booting the route with the prompt elements `fw` reaches boundary 0. -/
theorem boot (fw : List Val) : bootL (RoutePrompt.cxV fw) Decode.world 2000 = some (P.a0 fw) :=
  (Link.Lp.booted fw 2000 (by decide)).trans (congrArg some (link_join fw))

end Host.Load.Run.Prompt
