import host.sim.compose.JsImage
import host.sim.compose.a4b.VWSim
import host.sim.full.JsImage
set_option Elab.async false
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose.SetupEarly

theorem typedImageSimAt (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n D0 : Nat)
    (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (Disp.okJSJImage (VWFrames.typedJ bytes n) D0 (okBackFXS setupP))
      (Disp.KpJ (VWFrames.typedJ bytes n) D0) (VWFrames.typedW bytes n) stk (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (VWFrames.typedJ bytes n).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJSImage P NB loopVB (VWFrames.typedJ bytes n) D0 hj rfl rfl rfl rfl rfl stk
    (VWFrames.typed_wp bytes n)
  simpa only [P, backRest] using hs

theorem bodyImageLocalSim (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n : Nat)
    (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (okLocal (Disp.okJSJImage (VWFrames.typedJ bytes n) VWFrames.bodyD0 (okBackFXS setupP)))
      (Disp.KpJ (VWFrames.typedJ bytes n) VWFrames.bodyD0) (VWFrames.typedW bytes n) stk (VBOkF loopVB) := by
  apply (typedImageSimAt NB T tk bytes n VWFrames.bodyD0 stk).mono
  intro s S h
  simp only [okLocal, Bool.and_eq_true] at h
  exact h.1

end Host.Ts.Sim.Compose.VWFirst
