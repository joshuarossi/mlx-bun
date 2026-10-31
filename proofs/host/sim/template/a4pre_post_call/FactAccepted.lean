import host.sim.template.a4pre_post_call.Run
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
kernel_rfl PRE_post_call.accepted_selector :
  (fun bytes : List Byte => PostHeadSmall.ok bytes PRE_post_selector.s0 PRE_post_selector.S0) = fun _ => true
end Host.Load.Run.Tpl
