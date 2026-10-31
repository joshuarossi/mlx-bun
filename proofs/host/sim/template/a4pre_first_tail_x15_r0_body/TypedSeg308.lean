import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1142
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1143
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg308 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1142).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1143).getD 0)) PRE_first_tail_x15_r0_body.s1142 PRE_first_tail_x15_r0_body.S1142 = some (PRE_first_tail_x15_r0_body.s1144, PRE_first_tail_x15_r0_body.S1144) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1142).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1143).getD 0) PRE_first_tail_x15_r0_body.s1142 PRE_first_tail_x15_r0_body.s1143 PRE_first_tail_x15_r0_body.s1144 PRE_first_tail_x15_r0_body.S1142 PRE_first_tail_x15_r0_body.S1143 PRE_first_tail_x15_r0_body.S1144 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1142 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1143 bytes) rows)
end Host.Load.Run.Tpl
