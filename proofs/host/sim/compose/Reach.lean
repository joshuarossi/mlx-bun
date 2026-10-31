import host.sim.compose.Shape
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill

/-- A local template cut with the actual run from its incoming cut retained. -/
def reached {F : Ffi} (A B : ICut F) (n : Nat) : ICut F :=
  { B with R := fun x s S => B.R x s S ∧
      ∃ t0 C0, A.Inv t0 C0 ∧ runC F n t0 C0 = some (x.t, x.C) }

theorem CutStep.record {F : Ffi} {A B : ICut F} {n : Nat} (h : CutStep A B n) :
    CutStep A (reached A B n) n := by
  intro t C hi
  obtain ⟨t', C', hr, x, ht, hc, hR, hB⟩ := h t C hi
  exact ⟨t', C', hr, x, ht, hc, ⟨hR, t, C, hi, by simpa only [ht, hc] using hr⟩, hB⟩

theorem CutStep.reached {F : Ffi} {A B D : ICut F} {k n : Nat} (h : CutStep B D n) :
    CutStep (Compose.reached A B k) (Compose.reached A D (k + n)) n := by
  rintro t C ⟨x, ht, hc, ⟨hR, t0, C0, h0, hr0⟩, hB⟩
  obtain ⟨t', C', hr, y, hyt, hyc, hyR, hyB⟩ := h t C ⟨x, ht, hc, hR, hB⟩
  have hr0' : runC F k t0 C0 = some (t, C) := by simpa only [ht, hc] using hr0
  exact ⟨t', C', hr, y, hyt, hyc,
    ⟨hyR, t0, C0, h0, by simpa only [hyt, hyc] using runC_trans hr0' hr⟩, hyB⟩

/-- Equal-length executions from the same start yield the same target pair. -/
theorem reached_convert {F : Ffi} {A B D : ICut F} {n : Nat} (h : CutStep A D n) :
    CutConv (reached A B n) D := by
  rintro x ⟨_, t0, C0, hi, hr⟩ _
  obtain ⟨t', C', hd, y, hyt, hyc, hyR, hyB⟩ := h t0 C0 hi
  rw [hr] at hd
  cases hd
  exact ⟨y, hyt, hyc, hyR, hyB⟩

end Host.Ts.Sim.Compose
