import host.sim.template.a4pre_pf_vw.SA
import host.sim.template.TemplateLower
import host.sim.template.BridgeLiteral
import host.sim.template.ServerData
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
-- x2's and x3's ends are the lowest of the classes sharing this template, so its counter is theirs.
bridge_empty PRE_pf_vwA.chooser from PRE_pf_vwA.s0
server_data PRE_pf_vwA.chooserSrv := PRE_pf_vwA.S0
set_option interpreter.prefer_native true in
tpl_lower PRE_pf_vw from PRE_pf_vwA : 2823891 («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
