import host.sim.template.a4pre_first_tail_x15_r0_body.st30.TypedSplitK0Part0
import host.sim.template.a4pre_first_tail_x15_r0_body.st30.TypedSplitK0Part1
import host.sim.template.a4pre_first_tail_x15_r0_body.st30.TypedSplitK0Part2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

theorem PRE_first_tail_x15_r0_body.st30.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st30.F (PRE_first_tail_x15_r0_body.st30.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st30.ks 0).getD 0) PRE_first_tail_x15_r0_body.st30.s0 PRE_first_tail_x15_r0_body.st30.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st30.s1, PRE_first_tail_x15_r0_body.st30.S1) := by
  funext bytes rows
  change runOk PRE_first_tail_x15_r0_body.st30.F (PRE_first_tail_x15_r0_body.st30.bodyOkL bytes rows) 10000 PRE_first_tail_x15_r0_body.st30.s0 PRE_first_tail_x15_r0_body.st30.S0 = _
  exact runOk_trans PRE_first_tail_x15_r0_body.st30.F (PRE_first_tail_x15_r0_body.st30.bodyOkL bytes rows) 6666 3334 PRE_first_tail_x15_r0_body.st30.s0 PRE_first_tail_x15_r0_body.st30.typedSplitK0.p1.s1 PRE_first_tail_x15_r0_body.st30.s1 PRE_first_tail_x15_r0_body.st30.S0 PRE_first_tail_x15_r0_body.st30.typedSplitK0.originalS2 PRE_first_tail_x15_r0_body.st30.S1 (runOk_trans PRE_first_tail_x15_r0_body.st30.F (PRE_first_tail_x15_r0_body.st30.bodyOkL bytes rows) 3333 3333 PRE_first_tail_x15_r0_body.st30.s0 PRE_first_tail_x15_r0_body.st30.typedSplitK0.p0.s1 PRE_first_tail_x15_r0_body.st30.typedSplitK0.p1.s1 PRE_first_tail_x15_r0_body.st30.S0 PRE_first_tail_x15_r0_body.st30.typedSplitK0.originalS1 PRE_first_tail_x15_r0_body.st30.typedSplitK0.originalS2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st30.typedSplitK0.part0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st30.typedSplitK0.part1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st30.typedSplitK0.part2 bytes) rows)

end Host.Load.Run.Tpl
