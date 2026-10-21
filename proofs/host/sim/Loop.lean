import host.ts.Chunk
namespace Host.Ts.Sim
open Host.Ts

/-! # Induction over loop iterations

`Inv k t C` relates the target at the start of iteration `k`. An iteration that
continues the loop (`loopAt k`) takes `len k` target steps to a state satisfying
`Inv (k + 1)`. Then `m` such iterations take the sum of their lengths. -/

section
variable {F : Ffi}

theorem runC_add (m n : Nat) (t : St F.S) (C : CSrv) :
    runC F (m + n) t C = (runC F m t C).bind fun p => runC F n p.1 p.2 :=
  runWith_add F interpC m n t C

theorem runC_trans {m n : Nat} {t t1 t2 : St F.S} {C C1 C2 : CSrv} (h1 : runC F m t C = some (t1, C1))
    (h2 : runC F n t1 C1 = some (t2, C2)) : runC F (m + n) t C = some (t2, C2) := by
  rw [runC_add, h1]
  exact h2

/-- A halted run stays put. -/
theorem runC_halted_add {n : Nat} {t t1 : St F.S} {C C1 : CSrv} (h : runC F n t C = some (t1, C1))
    (hh : isHalt t1.ctl = true) (m : Nat) : runC F (n + m) t C = some (t1, C1) := by
  rw [runC_add, h]
  exact runWith_halted F interpC t1 C1 hh m

/-- After `N` steps reach a halted state, every longer run ends there. -/
theorem runC_halted_le {N n : Nat} {t t1 : St F.S} {C C1 : CSrv} (h : runC F N t C = some (t1, C1))
    (hh : isHalt t1.ctl = true) (hn : N ≤ n) : runC F n t C = some (t1, C1) := by
  obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hn
  exact runC_halted_add h hh m

/-- The total length of iterations `k, k+1, …, k+m-1`. -/
def iterSteps (len : Nat → Nat) (k : Nat) : Nat → Nat
  | 0 => 0
  | m + 1 => len k + iterSteps len (k + 1) m

theorem loop_induct (Inv : Nat → St F.S → CSrv → Prop) (loopAt : Nat → Prop) (len : Nat → Nat)
    (hstep : ∀ k t C, Inv k t C → loopAt k → ∃ t' C', runC F (len k) t C = some (t', C') ∧ Inv (k + 1) t' C') :
    ∀ m k t C, Inv k t C → (∀ j, j < m → loopAt (k + j)) →
      ∃ t' C', runC F (iterSteps len k m) t C = some (t', C') ∧ Inv (k + m) t' C'
  | 0, k, t, C, h, _ => ⟨t, C, rfl, h⟩
  | m + 1, k, t, C, h, hl => by
    obtain ⟨t1, C1, hr1, h1⟩ := hstep k t C h (by simpa using hl 0 (Nat.succ_pos m))
    obtain ⟨t2, C2, hr2, h2⟩ := loop_induct Inv loopAt len hstep m (k + 1) t1 C1 h1
      (fun j hj => by simpa [Nat.add_assoc, Nat.add_comm 1 j] using hl (j + 1) (by omega))
    refine ⟨t2, C2, runC_trans hr1 hr2, ?_⟩
    simpa [Nat.add_assoc, Nat.add_comm 1 m] using h2
end

end Host.Ts.Sim
