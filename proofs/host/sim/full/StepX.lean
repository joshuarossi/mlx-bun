import host.sim.full.CallSym
import host.sim.full.Step
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim

/-! # The one-step theorem of the full world with symbolic shapes

`host.sim.full.Step`'s theorems at the native-call simulation with the forward's operations over
symbolic shapes and the calls the symbolic-shape layer completes (`fullCallSimS`, numeric premise decided
by `smallFSB`). -/

/-- The full world's acceptance parameters with symbolic shapes and the bridge inactive. -/
abbrev fullJSPX (P : LoadP) (VB : Nat → Nat) (framed : List Nat) (wide : List (Nat × WFrame) := []) : Disp.JSP FF :=
  { okCall := okCallFS P, smallB := smallFSB VB, lo := P.lo, hi := P.E, framed := framed,
    isHandle := fullIsHandle, isRegion := fullIsRegion, wide := wide }

section
variable {P : LoadP} {NB : Nat} {VB : Nat → Nat} {J : Disp.JSP FF}

/-- **The one-step theorem of the full world with symbolic shapes** under frames `W` and a
target-only stack base `stk`. -/
theorem fullStepSimXB (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXVB FF (FullR P NB) (Disp.okJS J) (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullR P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimS P NB
  exact Disp.stepSimXVB (fullFfiSim P NB) hC
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws bridgeI_stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- The one-step theorem with symbolic shapes under frames `W`. -/
theorem fullStepSimXW (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (hW : Disp.Wp J W) :
    Disp.StepSimXVW FF (FullR P NB) (Disp.okJS J) (Disp.Kp J) W (VBOkF VB) :=
  (fullStepSimXB P NB VB J hJ hsm hlo hh hg [] hW).nil

/-- **The one-step theorem of the full world with symbolic shapes** (`fullStepSimX`). -/
theorem fullStepSimX (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) :
    Disp.StepSimXV FF (FullR P NB) (Disp.okJS J) (Disp.Kp J) (VBOkF VB) :=
  (fullStepSimXW P NB VB J hJ hsm hlo hh hg Disp.Wp.free).free

/-- The one-step theorem with symbolic shapes for any reached state, under frames and a stack base. -/
theorem fullStepSimXLB (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (FullR P NB) (Disp.okJS J) (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullR P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimS P NB
  exact Disp.stepSimXLB (fullFfiSim P NB) hC
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws bridgeI_stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg) hW

/-- The one-step theorem with symbolic shapes for any reached state. -/
theorem fullStepSimXL (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) :
    Disp.StepSimXL FF (FullR P NB) (Disp.okJS J) (Disp.Kp J) (VBOkF VB) :=
  Disp.stepSimXL (fullFfiSim P NB) (by rw [hJ]; exact fullCallSimS P NB)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws bridgeI_stable P NB) fullLawful (fullNativeFacts P NB J hlo hh hg)

/-- `fullStepSimX` at `fullJSPX`, for the relation with the target's remaining readbacks `r`. -/
theorem fullJSPXStepSim (P : LoadP) (NB : Nat) (VB : Nat → Nat) (framed : List Nat) (r : List NumV) :
    Disp.StepSimXV FF (FLR P NB r) (Disp.okJS (fullJSPX P VB framed)) (Disp.Kp (fullJSPX P VB framed))
      (VBOkF VB) :=
  fullStepSimX { P with rest := r } NB VB (fullJSPX P VB framed) (okCallFS_rest P r).symm rfl rfl rfl rfl

end

end Host.Ts.Sim.Full
