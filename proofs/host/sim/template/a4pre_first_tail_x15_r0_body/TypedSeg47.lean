import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H5
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK174
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK175
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg47 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 174).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 175).getD 0)) PRE_first_tail_x15_r0_body.s174 PRE_first_tail_x15_r0_body.S174 = some (PRE_first_tail_x15_r0_body.s176, PRE_first_tail_x15_r0_body.S176) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 174).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 175).getD 0) PRE_first_tail_x15_r0_body.s174 PRE_first_tail_x15_r0_body.s175 PRE_first_tail_x15_r0_body.s176 PRE_first_tail_x15_r0_body.S174 PRE_first_tail_x15_r0_body.S175 PRE_first_tail_x15_r0_body.S176 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK174 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK175 bytes) rows)
end Host.Load.Run.Tpl
