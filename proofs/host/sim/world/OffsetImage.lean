import host.sim.world.Offset
import host.sim.dispatch.OkJsImage
import host.sim.conv.RunAccept
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-- A checked family budget fits the uniform larger-image transfer allowance. -/
theorem prefill_image_allowance_by_class {base dDrain dTail dFinal L oldD : Nat}
    {c : SetupClass} (hL : L ≤ 262143) (ha : c.Applies L)
    (hbudget : base + c.maxDrains * dDrain + dTail + dFinal ≤ oldD + Disp.lim29) :
    prefillOffsetBudget base dDrain dTail dFinal L ≤ oldD + Disp.lim29 :=
  Nat.le_trans (prefill_offset_budget_le_class hL ha) hbudget

theorem SetupClass.maxDrains_le_nonH5 {c : SetupClass} (hc : c ≠ .h5) :
    c.maxDrains ≤ 1365 := by
  cases c <;> simp only [SetupClass.maxDrains] <;> try decide
  exact False.elim (hc rfl)

/-- Classes before H5 require at most 1365 whole-drain increments. -/
theorem prefill_image_allowance_nonH5 {base dDrain dTail dFinal L oldD : Nat}
    {c : SetupClass} (hL : L ≤ 262143) (ha : c.Applies L) (hc : c ≠ .h5)
    (hbudget : base + 1365 * dDrain + dTail + dFinal ≤ oldD + Disp.lim29) :
    prefillOffsetBudget base dDrain dTail dFinal L ≤ oldD + Disp.lim29 := by
  apply prefill_image_allowance_by_class hL ha
  have hm := Nat.mul_le_mul_right dDrain (SetupClass.maxDrains_le_nonH5 hc)
  omega

section
variable {F : Ffi} {J : Disp.JSP F} {okBack : F.S → Arg → Bool}
  {base dDrain dTail dFinal L oldD : Nat} {c : SetupClass}

/-- Retain a local-state guard while transferring an old checked run. -/
theorem prefill_image_run (hL : L ≤ 262143) (ha : c.Applies L)
    (hbudget : base + c.maxDrains * dDrain + dTail + dFinal ≤ oldD + Disp.lim29)
    (localGuard : St F.S → Bool) {n : Nat} {s s1 : St F.S} {S S1 : SSrv}
    (hr : runOk F (fun s S => Disp.okJSJ J okBack oldD s S && localGuard s) n s S = some (s1, S1)) :
    runOk F (fun s S => Disp.okJSJImage J (prefillOffsetBudget base dDrain dTail dFinal L)
      okBack s S && localGuard s) n s S = some (s1, S1) := by
  apply runOk_mono (ok := fun s S => Disp.okJSJ J okBack oldD s S && localGuard s) _ hr
  intro u U hu
  simp only [Bool.and_eq_true] at hu ⊢
  exact ⟨Disp.okJSJImage_of_allowance (prefill_image_allowance_by_class hL ha hbudget) hu.1, hu.2⟩

/-- The checked template retains all states, servers and step counts under the family allowance. -/
def prefill_image_stage (hL : L ≤ 262143) (ha : c.Applies L)
    (hbudget : base + c.maxDrains * dDrain + dTail + dFinal ≤ oldD + Disp.lim29)
    (localGuard : St F.S → Bool)
    (T : Stage.StageTpl F (fun s S => Disp.okJSJ J okBack oldD s S && localGuard s)) :
    Stage.StageTpl F (fun s S => Disp.okJSJImage J (prefillOffsetBudget base dDrain dTail dFinal L)
      okBack s S && localGuard s) :=
  T.mapOk fun _ _ h => by
    simp only [Bool.and_eq_true] at h ⊢
    exact ⟨Disp.okJSJImage_of_allowance (prefill_image_allowance_by_class hL ha hbudget) h.1, h.2⟩

end
end Host.Ts.Sim.Prefill
