import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H28
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK921
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK922
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg248 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 921).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 922).getD 0)) PRE_first_tail_x15_r0_body.s921 PRE_first_tail_x15_r0_body.S921 = some (PRE_first_tail_x15_r0_body.s923, PRE_first_tail_x15_r0_body.S923) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 921).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 922).getD 0) PRE_first_tail_x15_r0_body.s921 PRE_first_tail_x15_r0_body.s922 PRE_first_tail_x15_r0_body.s923 PRE_first_tail_x15_r0_body.S921 PRE_first_tail_x15_r0_body.S922 PRE_first_tail_x15_r0_body.S923 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK921 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK922 bytes) rows)
end Host.Load.Run.Tpl
