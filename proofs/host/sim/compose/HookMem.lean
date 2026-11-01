import host.sim.compose.NTrack
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill

/-- A chain carrying its start changes the bookkeeping, from what its end knows. -/
theorem hookMem {A B : ICut Full.FF} {n : Nat} {Mem Mem' : SegInst Full.FF → Prop}
    (hstep : ∀ x0, CutStep (withMem (NTrack x0) A) (withMem (NTrack x0) B) n)
    (hook : ∀ x y : SegInst Full.FF, A.R x A.s0 ⟨A.tab0, []⟩ → B.R y B.s0 ⟨B.tab0, []⟩ → B.B y → NTrack x y → Mem x → Mem' y) :
    CutStep (withMem Mem A) (withMem Mem' B) n := by
  rintro t C ⟨x, rfl, rfl, hR, ⟨hB, hm⟩⟩
  obtain ⟨t', C', hrun, y, rfl, rfl, hR', ⟨hB', htr⟩⟩ :=
    hstep x x.t x.C ⟨x, rfl, rfl, hR, ⟨hB, NTrack.refl x⟩⟩
  exact ⟨y.t, y.C, hrun, y, rfl, rfl, hR', ⟨hB', hook x y hR hR' hB' htr hm⟩⟩

end Host.Ts.Sim.Compose
