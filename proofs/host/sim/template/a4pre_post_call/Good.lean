import host.sim.template.a4pre_post_call.H0
import host.sim.template.a4pre_post_head.Good
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
kernel_rfl PRE_post_call.empty_oracle : PRE_post_call.S0.oracle = []
end Host.Load.Run.Tpl
