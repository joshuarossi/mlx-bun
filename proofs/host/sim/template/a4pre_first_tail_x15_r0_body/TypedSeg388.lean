import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H41
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1314
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg388 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1314).getD 0) PRE_first_tail_x15_r0_body.s1314 PRE_first_tail_x15_r0_body.S1314 = some (PRE_first_tail_x15_r0_body.s1315, PRE_first_tail_x15_r0_body.S1315) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1314 bytes) rows)
end Host.Load.Run.Tpl
