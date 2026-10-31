import host.sim.world.Offset
import host.sim.dispatch.OkJsLimit
import host.sim.conv.RunAccept
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-- The signed-cell image limit covers a checked weighted schedule budget. -/
theorem prefill_signed_allowance {base dDrain dTail dFinal L oldD : Nat}
    (hL : L ≤ 262143)
    (hbudget : base + 4095 * dDrain + dTail + dFinal ≤ oldD + 1593835520) :
    prefillOffsetBudget base dDrain dTail dFinal L ≤ oldD + 1593835520 :=
  Nat.le_trans (prefill_offset_budget_le hL) hbudget

theorem prefill_signed_allowance_by_class {base dDrain dTail dFinal L oldD : Nat}
    {c : SetupClass} (hL : L ≤ 262143) (ha : c.Applies L)
    (hbudget : base + c.maxDrains * dDrain + dTail + dFinal ≤ oldD + 1593835520) :
    prefillOffsetBudget base dDrain dTail dFinal L ≤ oldD + 1593835520 :=
  Nat.le_trans (prefill_offset_budget_le_class hL ha) hbudget

section
variable {F : Ffi} {J : Disp.JSP F} {okBack : F.S → Arg → Bool}
  {base dDrain dTail dFinal L oldD : Nat}

/-- Transfer the same run and local guard under the signed-cell allowance. -/
theorem prefill_signed_run
    (hcap : prefillOffsetBudget base dDrain dTail dFinal L ≤ oldD + 1593835520)
    (localGuard : St F.S → Bool) {n : Nat} {s s1 : St F.S} {S S1 : SSrv}
    (hr : runOk F (fun s S => Disp.okJSJ J okBack oldD s S && localGuard s) n s S = some (s1, S1)) :
    runOk F (fun s S => Disp.okJSJLimit J jsSignedLimit
      (prefillOffsetBudget base dDrain dTail dFinal L) okBack s S && localGuard s) n s S = some (s1, S1) := by
  apply runOk_mono (ok := fun s S => Disp.okJSJ J okBack oldD s S && localGuard s) _ hr
  intro u U hu
  simp only [Bool.and_eq_true] at hu ⊢
  exact ⟨Disp.okJSJLimit_signed_of_allowance hcap hu.1, hu.2⟩

/-- States, servers and checked length remain those of the original template. -/
def prefill_signed_stage
    (hcap : prefillOffsetBudget base dDrain dTail dFinal L ≤ oldD + 1593835520)
    (localGuard : St F.S → Bool)
    (T : Stage.StageTpl F (fun s S => Disp.okJSJ J okBack oldD s S && localGuard s)) :
    Stage.StageTpl F (fun s S => Disp.okJSJLimit J jsSignedLimit
      (prefillOffsetBudget base dDrain dTail dFinal L) okBack s S && localGuard s) :=
  T.mapOk fun _ _ h => by
    simp only [Bool.and_eq_true] at h ⊢
    exact ⟨Disp.okJSJLimit_signed_of_allowance hcap h.1, h.2⟩

end
end Host.Ts.Sim.Prefill
