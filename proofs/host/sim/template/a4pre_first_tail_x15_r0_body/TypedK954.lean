import host.sim.template.a4pre_first_tail_x15_r0_body.H29
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.bodyK954F from PRE_first_tail_x15_r0_body.s954 to PRE_first_tail_x15_r0_body.s955 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.F (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 954).getD 0) PRE_first_tail_x15_r0_body.s954 PRE_first_tail_x15_r0_body.S954) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.s955, PRE_first_tail_x15_r0_body.S955)
theorem PRE_first_tail_x15_r0_body.bodyK954 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 954).getD 0) PRE_first_tail_x15_r0_body.s954 PRE_first_tail_x15_r0_body.S954) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.s955, PRE_first_tail_x15_r0_body.S955) :=
  runOk_fun_of_runOkS Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok PRE_first_tail_x15_r0_body.bodyK954F
end Host.Load.Run.Tpl
