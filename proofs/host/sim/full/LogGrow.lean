import host.sim.full.AcceptNESim
import host.sim.full.LogRel
import host.sim.full.BridgeJs

/-! # The target's growth along checked runs of the prefill's relations

`fullStepSimXLBNQ`: a Neural Engine row's one-step theorem with the target's growth from `y0`. `fullStepSimXLBNLQ`,
`fullStepSimXLBXDJSLQ`: the same over a log base, a Neural Engine row's and the prefill's other rows'. -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.FfiAne (Effect)

theorem frl_ninv {L : List Effect} {FR : Map → Nat → FF.S → FF.S → Prop}
    (h : ∀ M n x y, FR M n x y → Host.Mlx.Ffi.NGrowCall.NInv (mlxOf y)) : ∀ M n x y, FRL L FR M n x y → Host.Mlx.Ffi.NGrowCall.NInv (mlxOf y) := by
  rintro M n x y ⟨y0, ps, rfl, -, hr⟩
  exact h M n x y0 hr

section
variable (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (D0 : Nat)
  (hsb : J.smallBackB = smallBackFB VB) (hlo : J.lo = P.lo)
  (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion)
include hsb hlo hh hg

/-- **A Neural Engine row's one-step theorem with the target's growth from `y0`.** -/
theorem fullStepSimXLBNQ (hJ : J.okCall = okCallFND P) (hsm : J.smallB = smallFN2B VB) {W : Nat → Option WFrame}
    (stk : List Frame) (hW : Disp.Wp J W) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (Disp.FRJ (FRQ (FullRXD P NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (Disp.okJSF J (okBackFXS P) D0) (Disp.KpJ J D0) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullRXD P NB) J.okCall smallFN2 := by rw [hJ]; exact fullCallSimND P NB
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  exact Disp.stepSimXLBJF ((fullFfiSimXD P NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS P NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => smallFN2B_sound hν (by rw [hsm] at hb; exact hb))
    (fun _ _ _ _ hν hb => smallBackFB_sound hν (by rw [hsb] at hb; exact hb))
    (fullRXD_laws P NB).liftQ fullLawful (fullNativeFactsXD P NB J hlo hh hg).liftQ hW

/-- **`fullStepSimXLBNL` with the target's growth from `y0`.** -/
theorem fullStepSimXLBNLQ (L : List Effect) (hJ : J.okCall = okCallFND P) (hsm : J.smallB = smallFN2B VB)
    {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (Disp.FRJ (FRQ (FRL L (FullRXD P NB)) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (Disp.okJSF J (okBackFXS P) D0) (Disp.KpJ J D0) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FRL L (FullRXD P NB)) J.okCall smallFN2 := by
    rw [hJ]; exact FfiCallSim.frame (fullCallSimND P NB) (fun _ _ _ h => okCallFND_acc h) L
  have hQ := fullTargetPres (FR := FRL L (FullRXD P NB)) (frl_ninv fullRXD_ninv) y0
  exact Disp.stepSimXLBJF ((FfiSim.frameFalse (fullFfiSimXD P NB) L).liftQ fullLawful hQ)
    (backSimS_liftQ (FfiBackSimS.frame (fullBackSimXDS P NB) L) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => smallFN2B_sound hν (by rw [hsm] at hb; exact hb))
    (fun _ _ _ _ hν hb => smallBackFB_sound hν (by rw [hsb] at hb; exact hb))
    (FRLaws.frame (fullRXD_laws P NB) L).liftQ fullLawful
    (NativeFacts.frame (fullNativeFactsXD P NB J hlo hh hg) L).liftQ hW

/-- **`fullStepSimXLBXDJSL` with the target's growth from `y0`.** -/
theorem fullStepSimXLBXDJSLQ (L : List Effect) (hJ : J.okCall = okCallFXD P) (hsm : J.smallB = smallFX2B VB)
    {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (Disp.FRJ (FRQ (FRL L (FullRXD P NB)) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (Disp.okJSJ J (okBackFXS P) D0) (Disp.KpJ J D0) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FRL L (FullRXD P NB)) J.okCall smallFX2 := by
    rw [hJ]; exact FfiCallSim.frame (fullCallSimXD P NB) (fun _ _ _ h => okCallFXD_acc h) L
  have hQ := fullTargetPres (FR := FRL L (FullRXD P NB)) (frl_ninv fullRXD_ninv) y0
  exact Disp.stepSimXLBJS ((FfiSim.frameFalse (fullFfiSimXD P NB) L).liftQ fullLawful hQ)
    (backSimS_liftQ (FfiBackSimS.frame (fullBackSimXDS P NB) L) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => smallFX2B_sound hν (by rw [hsm] at hb; exact hb))
    (fun _ _ _ _ hν hb => smallBackFB_sound hν (by rw [hsb] at hb; exact hb))
    (FRLaws.frame (fullRXD_laws P NB) L).liftQ fullLawful
    (NativeFacts.frame (fullNativeFactsXD P NB J hlo hh hg) L).liftQ hW

end

end Host.Ts.Sim.Full
