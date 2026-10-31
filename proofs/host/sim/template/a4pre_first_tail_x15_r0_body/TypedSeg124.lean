import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H14
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK461
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK462
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg124 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 461).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 462).getD 0)) PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.S461 = some (PRE_first_tail_x15_r0_body.s463, PRE_first_tail_x15_r0_body.S463) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 461).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 462).getD 0) PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.s462 PRE_first_tail_x15_r0_body.s463 PRE_first_tail_x15_r0_body.S461 PRE_first_tail_x15_r0_body.S462 PRE_first_tail_x15_r0_body.S463 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK461 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK462 bytes) rows)
end Host.Load.Run.Tpl
