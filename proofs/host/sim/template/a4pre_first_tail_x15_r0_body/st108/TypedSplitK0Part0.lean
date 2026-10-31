import host.sim.template.a4pre_first_tail_x15_r0_body.st108.TypedSplitK0Data0
import host.sim.template.a4pre_first_tail_x15_r0_body.st108.TypedOk
import host.sim.template.BootAllEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

boot_all_rfl PRE_first_tail_x15_r0_body.st108.typedSplitK0.part0 from PRE_first_tail_x15_r0_body.st108.s0 to PRE_first_tail_x15_r0_body.st108.typedSplitK0.p0.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows) 3333 PRE_first_tail_x15_r0_body.st108.s0 PRE_first_tail_x15_r0_body.st108.S0) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.st108.typedSplitK0.p0.s1, PRE_first_tail_x15_r0_body.st108.typedSplitK0.originalS1)

end Host.Load.Run.Tpl
