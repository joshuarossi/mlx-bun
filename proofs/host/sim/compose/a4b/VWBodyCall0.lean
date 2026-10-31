import host.sim.compose.a4b.VWBodySite0
import host.sim.compose.a4b.VWSim
set_option Elab.async false
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

noncomputable def bodySite0 (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (rows : Nat) :
    PrefillSite (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (Disp.KpJ (VWFrames.typedJ bytes rows) VWFrames.bodyD0) (VWFrames.typedW bytes rows)
      (PRE_first_tail_x15_r0_body.st0.bodyOkL bytes rows)
      PRE_first_tail_x15_r0_body.s14 PRE_first_tail_x15_r0_body.s15 PRE_first_tail_x15_r0_body.S14
      PRE_first_tail_x15_r0_body.ws0 :=
  Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site0 bytes rows (bodyLocalSim NB T tk bytes rows)

end Host.Ts.Sim.Compose.VWFirst
