import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H36
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1180
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1181
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg318 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1180).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1181).getD 0)) PRE_first_tail_x15_r0_body.s1180 PRE_first_tail_x15_r0_body.S1180 = some (PRE_first_tail_x15_r0_body.s1182, PRE_first_tail_x15_r0_body.S1182) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1180).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1181).getD 0) PRE_first_tail_x15_r0_body.s1180 PRE_first_tail_x15_r0_body.s1181 PRE_first_tail_x15_r0_body.s1182 PRE_first_tail_x15_r0_body.S1180 PRE_first_tail_x15_r0_body.S1181 PRE_first_tail_x15_r0_body.S1182 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1180 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1181 bytes) rows)
end Host.Load.Run.Tpl
