import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H31
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1008
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1009
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg272 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1008).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1009).getD 0)) PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.S1008 = some (PRE_first_tail_x15_r0_body.s1010, PRE_first_tail_x15_r0_body.S1010) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1008).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1009).getD 0) PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.s1009 PRE_first_tail_x15_r0_body.s1010 PRE_first_tail_x15_r0_body.S1008 PRE_first_tail_x15_r0_body.S1009 PRE_first_tail_x15_r0_body.S1010 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1008 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1009 bytes) rows)
end Host.Load.Run.Tpl
