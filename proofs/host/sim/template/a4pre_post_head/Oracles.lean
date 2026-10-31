import host.sim.template.a4pre_post_head.H0
import host.sim.lin.Table
import host.sim.LinGood
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_post_head.varMap : List (Nat × Q) := [(0, .T), (9, .L), (10, .n)]
kernel_rfl PRE_post_head.good_first :
  goodLin final_cold.r0.ps (varsOf final_cold.r0.V PRE_post_head.varMap) PRE_post_head.S0.oracle = true
end Host.Load.Run.Tpl
