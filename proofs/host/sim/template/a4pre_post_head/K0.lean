import host.sim.template.a4pre_post_head.H0
import host.sim.template.a4pre_post_head.Small
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_post_head.typedChecked from PRE_post_head.s0 to PRE_post_head.s1 :
  (fun bytes : List Byte => runOk PRE_post_head.F (PostHeadSmall.ok bytes) 809 PRE_post_head.s0 PRE_post_head.S0) =
    fun _ => some (PRE_post_head.s1, PRE_post_head.S1)
end Host.Load.Run.Tpl
