import host.sim.compose.PreFill
import host.route.LoadCut

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill

/-- Keep the loaded valuation prefix and the emitted-token binding. -/
def setupInputs (T : Nat) (tk : Nat → Nat) (x : SegInst Full.FF) : Prop :=
  (∀ j, j < 9 → x.ν j = Host.Route.machVal T tk j) ∧ x.M.a 2590 = 2590

def withSetupInputs (T : Nat) (tk : Nat → Nat) (A : ICut Full.FF) : ICut Full.FF :=
  { A with B := fun x => A.B x ∧ setupInputs T tk x }

/-- A cut step also exposes the two agreements needed by a retained input layer. -/
def CutStepKeeps {F : Ffi} (A B : ICut F) (n : Nat) : Prop :=
  ∀ x, A.R x A.s0 ⟨A.tab0, []⟩ → A.B x →
    ∃ y, runC F n x.t x.C = some (y.t, y.C) ∧ B.R y B.s0 ⟨B.tab0, []⟩ ∧ B.B y ∧
      (∀ j, j < 9 → y.ν j = x.ν j) ∧ y.M.a 2590 = x.M.a 2590

def CutConvKeeps {F : Ffi} (A B : ICut F) : Prop :=
  ∀ x, A.R x A.s0 ⟨A.tab0, []⟩ → A.B x →
    ∃ y, y.t = x.t ∧ y.C = x.C ∧ B.R y B.s0 ⟨B.tab0, []⟩ ∧ B.B y ∧
      (∀ j, j < 9 → y.ν j = x.ν j) ∧ y.M.a 2590 = x.M.a 2590

theorem CutStepKeeps.step {F : Ffi} {A B : ICut F} {n : Nat} (h : CutStepKeeps A B n) :
    CutStep A B n := by
  rintro t C ⟨x, rfl, rfl, hr, hb⟩
  obtain ⟨y, hrun, hr', hb', _⟩ := h x hr hb
  exact ⟨y.t, y.C, hrun, y, rfl, rfl, hr', hb'⟩

theorem CutConvKeeps.conv {F : Ffi} {A B : ICut F} (h : CutConvKeeps A B) : CutConv A B := by
  intro x hr hb
  obtain ⟨y, ht, hC, hr', hb', _⟩ := h x hr hb
  exact ⟨y, ht, hC, hr', hb'⟩

theorem CutStepKeeps.withInputs {A B : ICut Full.FF} {n : Nat} (h : CutStepKeeps A B n)
    (T : Nat) (tk : Nat → Nat) : CutStep (withSetupInputs T tk A) (withSetupInputs T tk B) n := by
  rintro t C ⟨x, rfl, rfl, hr, hb, hv, ha⟩
  obtain ⟨y, hrun, hr', hb', hν, hA⟩ := h x hr hb
  exact ⟨y.t, y.C, hrun, y, rfl, rfl, hr', hb', fun j hj => (hν j hj).trans (hv j hj), hA.trans ha⟩

theorem CutConvKeeps.withInputs {A B : ICut Full.FF} (h : CutConvKeeps A B)
    (T : Nat) (tk : Nat → Nat) : CutConv (withSetupInputs T tk A) (withSetupInputs T tk B) := by
  rintro x hr ⟨hb, hv, ha⟩
  obtain ⟨y, ht, hC, hr', hb', hν, hA⟩ := h x hr hb
  exact ⟨y, ht, hC, hr', hb', fun j hj => (hν j hj).trans (hv j hj), hA.trans ha⟩

end Host.Ts.Sim.Compose
