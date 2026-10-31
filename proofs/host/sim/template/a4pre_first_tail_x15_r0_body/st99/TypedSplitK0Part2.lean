import host.sim.template.a4pre_first_tail_x15_r0_body.st99.TypedSplitK0Data1
import host.sim.template.a4pre_first_tail_x15_r0_body.st99.TypedOk
import host.sim.template.BootAllEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

boot_all_rfl PRE_first_tail_x15_r0_body.st99.typedSplitK0.part2 from PRE_first_tail_x15_r0_body.st99.typedSplitK0.p1.s1 to PRE_first_tail_x15_r0_body.st99.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st99.F (PRE_first_tail_x15_r0_body.st99.bodyOkL bytes rows) 3334 PRE_first_tail_x15_r0_body.st99.typedSplitK0.p1.s1 PRE_first_tail_x15_r0_body.st99.typedSplitK0.originalS2) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.st99.s1, PRE_first_tail_x15_r0_body.st99.S1)

end Host.Load.Run.Tpl
