import host.sim.template.a4pre_first_tail_x15_r0_body.st23.H0
import host.sim.compose.a4b.VWFramesDefs
import host.sim.template.FullOk
import host.sim.template.FastOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st23.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st23.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st23.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st23.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st23.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st23.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st23.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st23.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st23.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st23.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st23.s0 PRE_first_tail_x15_r0_body.st23.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st23.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st23.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st23.s1 PRE_first_tail_x15_r0_body.st23.S1) = fun _ _ => true

end Host.Load.Run.Tpl
