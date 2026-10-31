import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H45
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1468
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1469
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg396 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1468).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1469).getD 0)) PRE_first_tail_x15_r0_body.s1468 PRE_first_tail_x15_r0_body.S1468 = some (PRE_first_tail_x15_r0_body.s1470, PRE_first_tail_x15_r0_body.S1470) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1468).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1469).getD 0) PRE_first_tail_x15_r0_body.s1468 PRE_first_tail_x15_r0_body.s1469 PRE_first_tail_x15_r0_body.s1470 PRE_first_tail_x15_r0_body.S1468 PRE_first_tail_x15_r0_body.S1469 PRE_first_tail_x15_r0_body.S1470 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1468 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1469 bytes) rows)
end Host.Load.Run.Tpl
