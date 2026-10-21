import host.load.run.full.link.States
import host.load.run.tail.World
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Tail

/- The link states with the world's unread readback suffix abstracted. -/
link_read_tail Lk from Host.Load.Run.Full.Link.L 0, 840 replace Host.Load.Decode.world by worldTail

end Host.Load.Run.Tail
