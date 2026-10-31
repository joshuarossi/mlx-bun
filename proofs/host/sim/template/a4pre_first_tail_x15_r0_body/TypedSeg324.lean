import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H37
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1200
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1201
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg324 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1200).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1201).getD 0)) PRE_first_tail_x15_r0_body.s1200 PRE_first_tail_x15_r0_body.S1200 = some (PRE_first_tail_x15_r0_body.s1202, PRE_first_tail_x15_r0_body.S1202) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1200).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1201).getD 0) PRE_first_tail_x15_r0_body.s1200 PRE_first_tail_x15_r0_body.s1201 PRE_first_tail_x15_r0_body.s1202 PRE_first_tail_x15_r0_body.S1200 PRE_first_tail_x15_r0_body.S1201 PRE_first_tail_x15_r0_body.S1202 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1200 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1201 bytes) rows)
end Host.Load.Run.Tpl
