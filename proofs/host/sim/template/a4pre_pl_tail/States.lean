import host.sim.template.a4pre_pl_tail.SB
import host.sim.template.TemplateDrop
import host.sim.template.BridgeLiteral
import host.sim.template.ServerData
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
-- Arrays nothing reaches, which VW and x0 don't hold.
bridge_empty PRE_pl_tailB.chooser from PRE_pl_tailB.s0
server_data PRE_pl_tailB.chooserSrv := PRE_pl_tailB.S0
set_option interpreter.prefer_native true in
tpl_drop PRE_pl_tail from PRE_pl_tailB : objs [] arrs [18165, 21991] («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
