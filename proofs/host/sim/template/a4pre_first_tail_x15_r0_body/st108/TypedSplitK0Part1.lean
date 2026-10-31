import host.sim.template.a4pre_first_tail_x15_r0_body.st108.TypedSplitK0Data1
import host.sim.template.a4pre_first_tail_x15_r0_body.st108.TypedOk
import host.sim.template.BootAllEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

boot_all_rfl PRE_first_tail_x15_r0_body.st108.typedSplitK0.part1 from PRE_first_tail_x15_r0_body.st108.typedSplitK0.p0.s1 to PRE_first_tail_x15_r0_body.st108.typedSplitK0.p1.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st108.F (PRE_first_tail_x15_r0_body.st108.bodyOkL bytes rows) 3333 PRE_first_tail_x15_r0_body.st108.typedSplitK0.p0.s1 PRE_first_tail_x15_r0_body.st108.typedSplitK0.originalS1) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.st108.typedSplitK0.p1.s1, PRE_first_tail_x15_r0_body.st108.typedSplitK0.originalS2)

end Host.Load.Run.Tpl
