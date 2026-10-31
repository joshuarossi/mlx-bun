import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H39
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1257
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1258
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg339 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1257).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1258).getD 0)) PRE_first_tail_x15_r0_body.s1257 PRE_first_tail_x15_r0_body.S1257 = some (PRE_first_tail_x15_r0_body.s1259, PRE_first_tail_x15_r0_body.S1259) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1257).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1258).getD 0) PRE_first_tail_x15_r0_body.s1257 PRE_first_tail_x15_r0_body.s1258 PRE_first_tail_x15_r0_body.s1259 PRE_first_tail_x15_r0_body.S1257 PRE_first_tail_x15_r0_body.S1258 PRE_first_tail_x15_r0_body.S1259 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1257 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1258 bytes) rows)
end Host.Load.Run.Tpl
