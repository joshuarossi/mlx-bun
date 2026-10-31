import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H24
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK782
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK783
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg211 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 782).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 783).getD 0)) PRE_first_tail_x15_r0_body.s782 PRE_first_tail_x15_r0_body.S782 = some (PRE_first_tail_x15_r0_body.s784, PRE_first_tail_x15_r0_body.S784) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 782).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 783).getD 0) PRE_first_tail_x15_r0_body.s782 PRE_first_tail_x15_r0_body.s783 PRE_first_tail_x15_r0_body.s784 PRE_first_tail_x15_r0_body.S782 PRE_first_tail_x15_r0_body.S783 PRE_first_tail_x15_r0_body.S784 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK782 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK783 bytes) rows)
end Host.Load.Run.Tpl
