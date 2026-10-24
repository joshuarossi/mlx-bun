import host.sim.full.Call
import host.sim.dispatch.OkLast
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim

/-! # The one-step theorem of the full world

The dispatcher's one-step theorems are generic in the FFI (`Disp.stepSimXVB`, `Disp.stepSimXLB`);
the full world's are their instances at `FullR` with the full world's native interface: reads
(`fullFfiSim`), calls (`fullCallSim`), laws (`fullR_laws`), lawfulness (`fullLawful`) and the map
facts (`fullNativeFacts`). No interpreter case is proven again. -/

/-- Valuations within the bound `VB`. -/
def VBOkF (VB : Nat → Nat) (ν : Nat → F64) : Prop := ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k

/-- The full world's acceptance parameters with the bridge inactive (the load world's handle band,
the template's end counter as the band's top). -/
abbrev fullJSP (P : LoadP) (VB : Nat → Nat) (framed : List Nat) (wide : List (Nat × WFrame) := []) : Disp.JSP FF :=
  { okCall := okCallF P, smallB := smallFB VB, lo := P.lo, hi := P.E, framed := framed,
    isHandle := fullIsHandle, isRegion := fullIsRegion, wide := wide }

/-- The accepted calls do not depend on the target's remaining readbacks. -/
theorem okCallF_rest (P : LoadP) (r : List NumV) : okCallF { P with rest := r } = okCallF P := by
  funext x name args
  unfold okCallF
  rw [G.okCallSG_rest]

section
variable {P : LoadP} {NB : Nat} {VB : Nat → Nat} {J : Disp.JSP FF}

/-- **The one-step theorem of the full world** under frames `W` and a target-only stack base `stk`. -/
theorem fullStepSimB (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallF P)
    (hsm : J.smallB = smallFB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXVB FF (FullR P NB) (Disp.okJS J) (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullR P NB) J.okCall smallF := by rw [hJ]; exact fullCallSim P NB
  exact Disp.stepSimXVB (fullFfiSim P NB) hC
    (fun _ _ _ _ _ hν hb => smallFB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws bridgeI_stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- The one-step theorem under frames `W`. -/
theorem fullStepSimW (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallF P)
    (hsm : J.smallB = smallFB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (hW : Disp.Wp J W) :
    Disp.StepSimXVW FF (FullR P NB) (Disp.okJS J) (Disp.Kp J) W (VBOkF VB) :=
  (fullStepSimB P NB VB J hJ hsm hlo hh hg [] hW).nil

/-- **The one-step theorem of the full world** (`fullStepSim`). -/
theorem fullStepSim (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallF P)
    (hsm : J.smallB = smallFB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) :
    Disp.StepSimXV FF (FullR P NB) (Disp.okJS J) (Disp.Kp J) (VBOkF VB) :=
  (fullStepSimW P NB VB J hJ hsm hlo hh hg Disp.Wp.free).free

/-- The one-step theorem for any reached state, under frames and a stack base. -/
theorem fullStepSimLB (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallF P)
    (hsm : J.smallB = smallFB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (FullR P NB) (Disp.okJS J) (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullR P NB) J.okCall smallF := by rw [hJ]; exact fullCallSim P NB
  exact Disp.stepSimXLB (fullFfiSim P NB) hC
    (fun _ _ _ _ _ hν hb => smallFB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws bridgeI_stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- The one-step theorem for any reached state. -/
theorem fullStepSimL (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallF P)
    (hsm : J.smallB = smallFB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) :
    Disp.StepSimXL FF (FullR P NB) (Disp.okJS J) (Disp.Kp J) (VBOkF VB) :=
  Disp.stepSimXL (fullFfiSim P NB) (by rw [hJ]; exact fullCallSim P NB)
    (fun _ _ _ _ _ hν hb => smallFB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws bridgeI_stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg)

/-- `fullStepSim` at `fullJSP`, for the relation with the target's remaining readbacks `r`. -/
theorem fullJSPStepSim (P : LoadP) (NB : Nat) (VB : Nat → Nat) (framed : List Nat) (r : List NumV) :
    Disp.StepSimXV FF (FLR P NB r) (Disp.okJS (fullJSP P VB framed)) (Disp.Kp (fullJSP P VB framed)) (VBOkF VB) :=
  fullStepSim { P with rest := r } NB VB (fullJSP P VB framed) (okCallF_rest P r).symm rfl rfl rfl rfl

end

end Host.Ts.Sim.Full
