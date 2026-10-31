import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H56
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1817
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1818
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg490 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1817).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1818).getD 0)) PRE_first_tail_x15_r0_body.s1817 PRE_first_tail_x15_r0_body.S1817 = some (PRE_first_tail_x15_r0_body.s1819, PRE_first_tail_x15_r0_body.S1819) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1817).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1818).getD 0) PRE_first_tail_x15_r0_body.s1817 PRE_first_tail_x15_r0_body.s1818 PRE_first_tail_x15_r0_body.s1819 PRE_first_tail_x15_r0_body.S1817 PRE_first_tail_x15_r0_body.S1818 PRE_first_tail_x15_r0_body.S1819 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1817 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1818 bytes) rows)
end Host.Load.Run.Tpl
