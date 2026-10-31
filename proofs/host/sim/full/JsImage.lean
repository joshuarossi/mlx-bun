import host.sim.full.BridgeJs
import host.sim.dispatch.JsImageSim
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim

section
variable (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (D0 : Nat)
  (hJ : J.okCall = okCallFXD P) (hsm : J.smallB = smallFX2B VB)
  (hsb : J.smallBackB = smallBackFB VB) (hlo : J.lo = P.lo)
  (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion)
include hJ hsm hsb hlo hh hg

/-- The active bridge simulation with the larger target-image acceptance layer. -/
theorem fullStepSimXLBXDJSImage {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD P NB)) (Disp.okJSJImage J D0 (okBackFXS P))
      (Disp.KpJ J D0) W stk (VBOkF VB) :=
  Disp.stepSimXLBJSImage (fullFfiSimXD P NB) (fullBackSimXDS P NB) (by rw [hJ]; exact fullCallSimXD P NB)
    (fun _ _ _ _ _ hν hb => smallFX2B_sound hν (by rw [hsm] at hb; exact hb))
    (fun _ _ _ _ hν hb => smallBackFB_sound hν (by rw [hsb] at hb; exact hb))
    (fullRXD_laws P NB) fullLawful (fullNativeFactsXD P NB J hlo hh hg) hW

theorem fullStepSimXBXDJSImage {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXVB FF (Disp.FRJ (FullRXD P NB)) (Disp.okJSJImage J D0 (okBackFXS P))
      (Disp.KpJ J D0) W stk (VBOkF VB) :=
  (fullStepSimXLBXDJSImage P NB VB J D0 hJ hsm hsb hlo hh hg stk hW).xv

theorem fullStepSimXLXDJSImage :
    Disp.StepSimXL FF (Disp.FRJ (FullRXD P NB)) (Disp.okJSJImage J D0 (okBackFXS P))
      (Disp.KpJ J D0) (VBOkF VB) :=
  (fullStepSimXLBXDJSImage P NB VB J D0 hJ hsm hsb hlo hh hg [] Disp.Wp.free).nil

theorem fullStepSimXLBXDJSImageQ {W : Nat → Option WFrame} (stk : List Frame)
    (hW : Disp.Wp J W) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (Disp.FRJ (FRQ (FullRXD P NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (Disp.okJSJImage J D0 (okBackFXS P)) (Disp.KpJ J D0) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullRXD P NB) J.okCall smallFX2 := by rw [hJ]; exact fullCallSimXD P NB
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  exact Disp.stepSimXLBJSImage ((fullFfiSimXD P NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS P NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => smallFX2B_sound hν (by rw [hsm] at hb; exact hb))
    (fun _ _ _ _ hν hb => smallBackFB_sound hν (by rw [hsb] at hb; exact hb))
    (fullRXD_laws P NB).liftQ fullLawful
    (fullNativeFactsXD P NB J hlo hh hg).liftQ hW
end

end Host.Ts.Sim.Full
