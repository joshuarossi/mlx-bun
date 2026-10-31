import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H6
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK214
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK215
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg58 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 214).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 215).getD 0)) PRE_first_tail_x15_r0_body.s214 PRE_first_tail_x15_r0_body.S214 = some (PRE_first_tail_x15_r0_body.s216, PRE_first_tail_x15_r0_body.S216) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 214).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 215).getD 0) PRE_first_tail_x15_r0_body.s214 PRE_first_tail_x15_r0_body.s215 PRE_first_tail_x15_r0_body.s216 PRE_first_tail_x15_r0_body.S214 PRE_first_tail_x15_r0_body.S215 PRE_first_tail_x15_r0_body.S216 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK214 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK215 bytes) rows)
end Host.Load.Run.Tpl
