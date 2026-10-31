import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H27
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK864
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK865
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg233 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 864).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 865).getD 0)) PRE_first_tail_x15_r0_body.s864 PRE_first_tail_x15_r0_body.S864 = some (PRE_first_tail_x15_r0_body.s866, PRE_first_tail_x15_r0_body.S866) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 864).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 865).getD 0) PRE_first_tail_x15_r0_body.s864 PRE_first_tail_x15_r0_body.s865 PRE_first_tail_x15_r0_body.s866 PRE_first_tail_x15_r0_body.S864 PRE_first_tail_x15_r0_body.S865 PRE_first_tail_x15_r0_body.S866 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK864 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK865 bytes) rows)
end Host.Load.Run.Tpl
