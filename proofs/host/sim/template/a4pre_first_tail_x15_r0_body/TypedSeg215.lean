import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H24
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK797
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK798
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg215 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 797).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 798).getD 0)) PRE_first_tail_x15_r0_body.s797 PRE_first_tail_x15_r0_body.S797 = some (PRE_first_tail_x15_r0_body.s799, PRE_first_tail_x15_r0_body.S799) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 797).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 798).getD 0) PRE_first_tail_x15_r0_body.s797 PRE_first_tail_x15_r0_body.s798 PRE_first_tail_x15_r0_body.s799 PRE_first_tail_x15_r0_body.S797 PRE_first_tail_x15_r0_body.S798 PRE_first_tail_x15_r0_body.S799 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK797 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK798 bytes) rows)
end Host.Load.Run.Tpl
