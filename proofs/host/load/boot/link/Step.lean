import host.load.boot.link.States
import host.load.run.full.link.Step43
import host.load.run.full.link.Step44
set_option Elab.async false
namespace Host.Load.Run.Prompt.Link
open Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/- Link steps 43 and 44 add the two model modules through their checked reference scans
(`Full.Link.Scan43`, `Scan44`), for every prompt and unread readback suffix. -/
boot_link_step Lq from Host.Load.Run.Prompt.Link.L 43 := fun (fw : List Val) (tail : List NumV) =>
  RefScan.linkRun_one_user_scanned (RoutePrompt.cxV fw) 43 (Lq.x43 fw tail) Host.Load.Run.Full.Link.user43
    Host.Load.Run.Full.Link.Scan43.refs rfl rfl rfl Host.Load.Run.Full.Link.Scan43.checked
boot_link_step Lq from Host.Load.Run.Prompt.Link.L 44 := fun (fw : List Val) (tail : List NumV) =>
  RefScan.linkRun_one_user_scanned (RoutePrompt.cxV fw) 44 (Lq.x44 fw tail) Host.Load.Run.Full.Link.user44
    Host.Load.Run.Full.Link.Scan44.refs rfl rfl rfl Host.Load.Run.Full.Link.Scan44.checked

end Host.Load.Run.Prompt.Link
