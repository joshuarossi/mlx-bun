import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H23
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK765
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg226 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 765).getD 0) PRE_first_tail_x15_r0_body.s765 PRE_first_tail_x15_r0_body.S765 = some (PRE_first_tail_x15_r0_body.s766, PRE_first_tail_x15_r0_body.S766) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK765 bytes) rows)
end Host.Load.Run.Tpl
