import host.sim.template.a4pre_post_head.H0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
kernel_rfl PRE_post_head.s0_tab : PRE_post_head.S0.tab =
  D1Body.S155.tab.map (·.subst (fun v => if v = 9 then .var 10 else .var v))
kernel_rfl PRE_post_head.fresh10 : D1Body.S155.tab.all (fun e => e.noVar 10) = true
end Host.Load.Run.Tpl
