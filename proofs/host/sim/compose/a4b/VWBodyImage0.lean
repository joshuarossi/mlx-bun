import host.sim.compose.a4b.VWBodyCall0
import host.sim.compose.a4b.VWImage
set_option Elab.async false
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

noncomputable def bodyImageSite0 (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (rows : Nat) :
    PrefillSite (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (Disp.KpJ (VWFrames.typedJ bytes rows) VWFrames.bodyD0) (VWFrames.typedW bytes rows)
      (okLocal (Disp.okJSJImage (VWFrames.typedJ bytes rows) VWFrames.bodyD0 (okBackFXS setupP)))
      PRE_first_tail_x15_r0_body.s14 PRE_first_tail_x15_r0_body.s15 PRE_first_tail_x15_r0_body.S14
      PRE_first_tail_x15_r0_body.ws0 :=
  (bodySite0 NB T tk bytes rows).withJsImage (bodyImageLocalSim NB T tk bytes rows)

end Host.Ts.Sim.Compose.VWFirst
