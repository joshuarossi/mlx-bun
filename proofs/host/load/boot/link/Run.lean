import host.load.boot.link.K0
import host.load.boot.link.K1
import host.load.boot.link.K2
import host.load.boot.link.K3
import host.load.boot.link.K4
import host.load.boot.link.K5
import host.load.boot.link.K6
import host.load.boot.link.K7
import host.load.boot.link.Step
set_option Elab.async false
namespace Host.Load.Run.Prompt.Link
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! `Lq.booted : ∀ fw tail m, 840 ≤ m → bootL (RoutePrompt.cxV fw) (worldTail tail) m = some (Lq.x840 fw tail).st`. -/
boot_link_run Lq from Host.Load.Run.Prompt.Link.L

end Host.Load.Run.Prompt.Link
