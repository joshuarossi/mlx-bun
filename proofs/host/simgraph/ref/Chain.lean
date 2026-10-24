import host.sim.PrefillSched
namespace Host.Mlx.SimGraph.Ref
open Host.Ts.Sim.Prefill (PStep Phase nextStep chunkC drains tailRows drains_tail chunkC_cases nextStep_drain
  nextStep_tail nextStep_final)

/-! # The prefill's value chain along the schedule

The route's prefill loop (generation/autoregressive.ts:490-514) runs `nextPrefillStep` (`nextStep`)
from position 0 and executes each step's forward on the step's rows and the state it carries (the
caches; the Neural Engine surfaces), until the final step `[L - 1, L)`; drains and tails compute no
logits. Here the same loop on values: a step's value semantics `f : StepSem S` (the state after the
step from the state before; for the route, the forward families' value instances,
`host.simgraph.ref.Route`) chained along `nextStep` from the state after the load.

* `prefillFrom`, `prefillState`: the loop (fuel `L + 1`, one more than its steps); its result is
  the state at the final step's start, offset `L - 1`.
* `afterDrains f L k`: the state after the first `k` whole chunks (the drain cut after `k` drains,
  offset `k·C`); `afterDrains_succ`: one more drain. `preFinal`: then the tail, if any (the
  pre-final cut, offset `L - 1`).
* `prefillState_eq`: **the loop is the drains, then the tail** — the chain of cuts
  `host.sim.Prefill` composes (`PrefillInv k`, `PreFinalInv`). -/

variable {S : Type}

/-- A prefill step's value semantics: the state after the step from the state before it. -/
abbrev StepSem (S : Type) := PStep → S → Option S

/-- The prefill loop from position `pos` (with fuel): each step's semantics until the final step;
the state at its start. -/
def prefillFrom (f : StepSem S) (L C : Nat) : Nat → Nat → S → Option S
  | 0, _, _ => none
  | fuel + 1, pos, hs =>
    if (nextStep L pos C).final then some hs
    else (f (nextStep L pos C) hs).bind (prefillFrom f L C fuel (nextStep L pos C).stop)

/-- **The prefill's state** for a prompt of `L` tokens from the state `s0`: at offset `L - 1`. -/
def prefillState (f : StepSem S) (L : Nat) (s0 : S) : Option S :=
  prefillFrom f L (chunkC L) (L + 1) 0 s0

/-- The `j`-th whole chunk. -/
def drainStep (C j : Nat) : PStep := ⟨j * C, (j + 1) * C, false, .chunk⟩

/-- The tail `[k·C, L - 1)` after the `k` whole chunks (phase `decode` for one row). -/
def tailStep (L : Nat) : PStep :=
  ⟨drains L * chunkC L, L - 1, false, if tailRows L = 1 then .decode else .tail⟩

/-- `m` whole chunks from the `j`-th. -/
def drainsFrom (f : StepSem S) (C : Nat) : Nat → Nat → S → Option S
  | _, 0, hs => some hs
  | j, m + 1, hs => (f (drainStep C j) hs).bind (drainsFrom f C (j + 1) m)

/-- **The state after the first `k` drains** (offset `k·C`). -/
def afterDrains (f : StepSem S) (L k : Nat) (s0 : S) : Option S :=
  drainsFrom f (chunkC L) 0 k s0

/-- After the drains: the tail, if any. -/
def tailThen (f : StepSem S) (L : Nat) (hs : S) : Option S :=
  if tailRows L = 0 then some hs else f (tailStep L) hs

/-- **The state at the pre-final cut** (offset `L - 1`): the drains, then the tail. -/
def preFinal (f : StepSem S) (L : Nat) (s0 : S) : Option S :=
  (afterDrains f L (drains L) s0).bind (tailThen f L)

theorem drainsFrom_snoc (f : StepSem S) (C : Nat) :
    ∀ (m j : Nat) (hs : S),
      drainsFrom f C j (m + 1) hs = (drainsFrom f C j m hs).bind (f (drainStep C (j + m)))
  | 0, j, hs => by simp [drainsFrom]
  | m + 1, j, hs => by
    show (f (drainStep C j) hs).bind (drainsFrom f C (j + 1) (m + 1)) =
      ((f (drainStep C j) hs).bind (drainsFrom f C (j + 1) m)).bind (f (drainStep C (j + (m + 1))))
    rw [Option.bind_assoc]
    congr 1; funext hs'
    rw [drainsFrom_snoc f C m (j + 1) hs', show j + 1 + m = j + (m + 1) by omega]

/-- **One more drain** (`k → k + 1`). -/
theorem afterDrains_succ (f : StepSem S) (L k : Nat) (s0 : S) :
    afterDrains f L (k + 1) s0 = (afterDrains f L k s0).bind (f (drainStep (chunkC L) k)) := by
  unfold afterDrains
  rw [drainsFrom_snoc, Nat.zero_add]

theorem chunkC_two {L : Nat} (h2 : L ≤ 349525) : 2 ≤ chunkC L := by
  rcases chunkC_cases h2 with h | h | h | h | h | h <;> omega

/-- The loop from the `j`-th drain, with `m` drains left. -/
theorem prefillFrom_drains (f : StepSem S) {L : Nat} (hL1 : 1 ≤ L) (hL2 : L ≤ 349525) :
    ∀ (m j : Nat) (hs : S) (fuel : Nat), j + m = drains L → m + 2 ≤ fuel →
      prefillFrom f L (chunkC L) fuel (j * chunkC L) hs = (drainsFrom f (chunkC L) j m hs).bind (tailThen f L)
  | 0, j, hs, fuel, hj, hf => by
    obtain ⟨fuel, rfl⟩ : ∃ k, fuel = k + 2 := ⟨fuel - 2, by omega⟩
    have hk := drains_tail L
    have hpos : 0 < chunkC L := by have := chunkC_two hL2; omega
    simp only [Nat.add_zero] at hj
    subst hj
    simp only [drainsFrom, Option.bind_some, tailThen]
    by_cases ht : tailRows L = 0
    · rw [ite_eq_left ht]
      have hp : drains L * chunkC L = L - 1 := by omega
      simp only [prefillFrom, hp, nextStep_final hL1, ↓reduceIte]
    · rw [ite_eq_right ht]
      have htC : tailRows L < chunkC L := Nat.mod_lt _ hpos
      have hn := nextStep_tail hk (by omega) htC
      have hfin := nextStep_final (C := chunkC L) hL1
      simp only [prefillFrom, hn, Bool.false_eq_true, ↓reduceIte, hfin]
      show (f (tailStep L) hs).bind some = f (tailStep L) hs
      cases f (tailStep L) hs <;> rfl
  | m + 1, j, hs, fuel, hj, hf => by
    obtain ⟨fuel, rfl⟩ : ∃ k, fuel = k + 1 := ⟨fuel - 1, by omega⟩
    have hC := chunkC_two hL2
    have hle : (j + 1) * chunkC L ≤ L - 1 := by
      have h1 : j + 1 ≤ drains L := by omega
      have h2 : (j + 1) * chunkC L ≤ drains L * chunkC L := Nat.mul_le_mul_right _ h1
      have := drains_tail L
      omega
    have hn := nextStep_drain (L := L) hC hle
    simp only [prefillFrom, hn, Bool.false_eq_true, ↓reduceIte]
    show (f (drainStep (chunkC L) j) hs).bind (prefillFrom f L (chunkC L) fuel ((j + 1) * chunkC L)) =
      ((f (drainStep (chunkC L) j) hs).bind (drainsFrom f (chunkC L) (j + 1) m)).bind (tailThen f L)
    rw [Option.bind_assoc]
    congr 1; funext hs'
    exact prefillFrom_drains f hL1 hL2 m (j + 1) hs' fuel (by omega) (by omega)

/-- **The loop is the drains, then the tail.** -/
theorem prefillState_eq (f : StepSem S) {L : Nat} (hL1 : 1 ≤ L) (hL2 : L ≤ 349525) (s0 : S) :
    prefillState f L s0 = preFinal f L s0 := by
  unfold prefillState preFinal afterDrains
  have hd : drains L ≤ L - 1 := Nat.div_le_self _ _
  have := prefillFrom_drains f hL1 hL2 (drains L) 0 s0 (L + 1) (by omega) (by omega)
  rw [Nat.zero_mul] at this
  exact this

/-- At one token the prefill is empty. -/
theorem prefillState_one (f : StepSem S) (s0 : S) : prefillState f 1 s0 = some s0 := rfl

end Host.Mlx.SimGraph.Ref
