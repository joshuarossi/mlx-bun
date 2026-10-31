import host.sim.template.a4pre_post_selector.H0
import host.sim.template.a4pre_post_head.Small
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_post_selector.checked from PRE_post_selector.s0 to PRE_post_selector.s1 :
  (fun bytes : List Byte => runOk PRE_post_selector.F (PostHeadSmall.ok bytes) 128 PRE_post_selector.s0 PRE_post_selector.S0) =
    fun _ => some (PRE_post_selector.s1, PRE_post_selector.S1)
kernel_rfl PRE_post_selector.s0_eq : PRE_post_selector.s0 = PRE_post_head.s1
kernel_rfl PRE_post_selector.s0_tab : PRE_post_selector.S0.tab = PRE_post_head.S1.tab
kernel_rfl PRE_post_selector.head_value : PRE_post_selector.s1.ctl = .ret (.obj 2671946)
end Host.Load.Run.Tpl
