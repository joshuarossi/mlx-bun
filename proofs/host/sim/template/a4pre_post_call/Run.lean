import host.sim.template.a4pre_post_call.H0
import host.sim.template.a4pre_post_selector.Run
import host.sim.template.a4pre_post_head.Small
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_post_call.checked from PRE_post_call.s0 to PRE_post_call.s1 :
  (fun bytes : List Byte => runOk PRE_post_call.F (PostHeadSmall.ok bytes) 3 PRE_post_call.s0 PRE_post_call.S0) =
    fun _ => some (PRE_post_call.s1, PRE_post_call.S1)
kernel_rfl PRE_post_call.s0_eq : PRE_post_call.s0 = PRE_post_selector.s1
kernel_rfl PRE_post_call.s0_srv : PRE_post_call.S0 = PRE_post_selector.S1
kernel_rfl PRE_post_call.head_call : PRE_post_call.s1.ctl = .call (.obj 2671946) .undef [.obj 2826838]

theorem PRE_post_call.selectorRun (bytes : List Byte) :
    runOk PRE_post_selector.F (PostHeadSmall.ok bytes) 131 PRE_post_selector.s0 PRE_post_selector.S0 =
      some (PRE_post_call.s1, PRE_post_call.S1) := by
  have h3 := congrFun PRE_post_call.checked bytes
  rw [PRE_post_call.s0_eq, PRE_post_call.s0_srv] at h3
  exact runOk_trans _ _ 128 3 _ _ _ _ _ _ (congrFun PRE_post_selector.checked bytes) h3
end Host.Load.Run.Tpl
