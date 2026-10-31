import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK3
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg1 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 3).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 4).getD 0)) PRE_first_tail_x15_r0_body.s3 PRE_first_tail_x15_r0_body.S3 = some (PRE_first_tail_x15_r0_body.s5, PRE_first_tail_x15_r0_body.S5) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 3).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 4).getD 0) PRE_first_tail_x15_r0_body.s3 PRE_first_tail_x15_r0_body.s4 PRE_first_tail_x15_r0_body.s5 PRE_first_tail_x15_r0_body.S3 PRE_first_tail_x15_r0_body.S4 PRE_first_tail_x15_r0_body.S5 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK3 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK4 bytes) rows)
end Host.Load.Run.Tpl
