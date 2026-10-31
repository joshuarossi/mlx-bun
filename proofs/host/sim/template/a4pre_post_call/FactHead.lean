import host.sim.template.a4pre_post_call.Run
import host.sim.full.Rel
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full
kernel_rfl PRE_post_call.head_bridge : bridgeOf PRE_post_call.s1.ffi = bridgeOf PRE_post_selector.s0.ffi
end Host.Load.Run.Tpl
