import host.sim.template.a4pre_post_head.K0
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

theorem PRE_post_head.typedRun (bytes : List Byte) :
    runOk PRE_post_head.F (PostHeadSmall.ok bytes) 809 PRE_post_head.s0 PRE_post_head.S0 =
      some (PRE_post_head.s1, PRE_post_head.S1) := congrFun PRE_post_head.typedChecked bytes

kernel_rfl PRE_post_head.typedAccepted0 :
  (fun bytes : List Byte => PostHeadSmall.ok bytes PRE_post_head.s0 PRE_post_head.S0) = fun _ => true
kernel_rfl PRE_post_head.typedAccepted1 :
  (fun bytes : List Byte => PostHeadSmall.ok bytes PRE_post_head.s1 PRE_post_head.S1) = fun _ => true
end Host.Load.Run.Tpl
