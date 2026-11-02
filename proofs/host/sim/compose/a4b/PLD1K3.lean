import host.sim.compose.a4b.PLD1Na
import host.sim.template.a4pre_d1_body.D4
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.ctl : D1Body.s155.ctl = PLWalkD1.R.data.map.ctl PRE_pl_entry.s0.ctl
kernel_rfl PLD1.stack : D1Body.s155.stack = PRE_pl_entry.s0.stack.map PLWalkD1.R.data.map.frame
kernel_rfl PLD1.jobs : D1Body.s155.jobs = PRE_pl_entry.s0.jobs.map PLWalkD1.R.data.map.job
kernel_rfl PLD1.stores : D1Body.s155.stores = PLWalkD1.R.data.map.stores PRE_pl_entry.s0.stores

end Host.Load.Run.Tpl
