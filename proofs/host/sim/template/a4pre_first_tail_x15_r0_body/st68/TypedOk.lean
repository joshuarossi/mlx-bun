import host.sim.template.a4pre_first_tail_x15_r0_body.st68.H0
import host.sim.compose.a4b.VWFramesDefs
import host.sim.template.FullOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st68.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st68.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

kernel_rfl PRE_first_tail_x15_r0_body.st68.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st68.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st68.s0 PRE_first_tail_x15_r0_body.st68.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st68.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st68.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st68.s1 PRE_first_tail_x15_r0_body.st68.S1) = fun _ _ => true

end Host.Load.Run.Tpl
