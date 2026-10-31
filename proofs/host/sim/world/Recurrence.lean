import host.sim.world.OffsetLimit
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! # The growth recurrence over a prompt's schedule

A `PieceCounter` is one counter's checked growth over each generated prefill piece, by schedule class. Its
cumulative value at the cuts of a prompt (`atDrain`, `atPre`, `atExit`) follows the schedule's recurrence, and
every such value is bounded by its setup class's `budget`, a closed form over the finite classes. A budget
checked at the seven setup classes therefore holds at every cut of every prompt length. -/

theorem iterSteps_snoc (len : Nat → Nat) (k m : Nat) :
    iterSteps len k (m + 1) = iterSteps len k m + len (k + m) := by
  induction m generalizing k with
  | zero => simp [iterSteps]
  | succ m ih =>
    show len k + iterSteps len (k + 1) (m + 1) = len k + iterSteps len (k + 1) m + len (k + (m + 1))
    rw [ih (k + 1), show k + 1 + m = k + (m + 1) by omega]
    omega

theorem iterSteps_le {len : Nat → Nat} {B : Nat} (k m : Nat) (h : ∀ j, len j ≤ B) :
    iterSteps len k m ≤ m * B := by
  induction m generalizing k with
  | zero => simp [iterSteps]
  | succ m ih =>
    have := ih (k + 1)
    have := h k
    rw [iterSteps, Nat.succ_mul]
    omega

/-- The largest value of `f` over a finite class list. -/
def listMax {α : Type} (f : α → Nat) : List α → Nat
  | [] => 0
  | x :: xs => max (f x) (listMax f xs)

theorem le_listMax {α : Type} {f : α → Nat} {x : α} : ∀ {xs : List α}, x ∈ xs → f x ≤ listMax f xs
  | _ :: xs, h => by
    rcases List.mem_cons.mp h with rfl | h
    · exact Nat.le_max_left _ _
    · exact Nat.le_trans (le_listMax h) (Nat.le_max_right _ _)

/-- One counter's checked growth over each generated piece of the prefill. -/
structure PieceCounter where
  setup : SetupClass → Nat
  first : FirstClass → Nat
  drain : DrainClass → Nat
  tail : TailClass → Nat
  final : PFSrc → FinalClass → Nat

namespace PieceCounter
variable (W : PieceCounter)

/-- The cumulative value at the drain cut `pc L k`, `1 ≤ k`. -/
def atDrain (L k : Nat) : Nat :=
  W.setup (setupOf L) + W.first (.drain (chunkC L)) +
    iterSteps (fun j => W.drain (drainOf L j)) 1 (k - 1)

/-- The cumulative value at the pre-final cut. -/
def atPre (L : Nat) : Nat :=
  if 1 ≤ drains L then
    W.atDrain L (drains L) + (if 1 ≤ tailRows L then W.tail (tailOf L) else 0)
  else if 2 ≤ L then W.setup (setupOf L) + W.first (.tail (rowClass (L - 1)))
  else W.setup (setupOf L)

/-- The cumulative value at the prefill's exit cut. -/
def atExit (L : Nat) : Nat := W.atPre L + W.final (pfSrcOf L) (finalOf L)

/-- **The recurrence**: a later drain adds its class's checked growth. -/
theorem atDrain_succ {L k : Nat} (hk : 1 ≤ k) :
    W.atDrain L (k + 1) = W.atDrain L k + W.drain (drainOf L k) := by
  obtain ⟨m, rfl⟩ : ∃ m, k = m + 1 := ⟨k - 1, by omega⟩
  simp only [atDrain, Nat.add_sub_cancel]
  rw [iterSteps_snoc, Nat.add_comm 1 m]
  omega

/-- A chunk's largest later-drain growth, over both cache-growth flags. -/
def stride (C : Nat) : Nat := max (W.drain ⟨C, true⟩) (W.drain ⟨C, false⟩)

theorem drain_le_stride (L j : Nat) : W.drain (drainOf L j) ≤ W.stride (chunkC L) := by
  unfold drainOf stride
  cases decide (j * chunkC L % 256 = 0)
  · exact Nat.le_max_right _ _
  · exact Nat.le_max_left _ _

def firstMax : Nat := listMax W.first firstClasses
def tailMax : Nat := listMax W.tail tailClasses
def finalMax : Nat :=
  listMax (fun c => max (W.final .first c) (max (W.final .drained c) (W.final .tailed c))) finalClasses

/-- **A setup class's budget**: every cut of every prompt of the class is within it. -/
def budget (c : SetupClass) : Nat :=
  W.setup c + W.firstMax + c.maxDrains * W.stride c.chunk + W.tailMax + W.finalMax

section
variable {L : Nat}

theorem setupOf_applies (h1 : 1 ≤ L) (h2 : L ≤ 262143) : (setupOf L).Applies L :=
  (chain_cover L h1 h2).1.2.1

theorem first_drain_le (h2 : L ≤ 262143) : W.first (.drain (chunkC L)) ≤ W.firstMax := by
  apply le_listMax
  have hc : chunkC L ∈ chunkSizes := by
    rcases chunkC_cases (by omega : L ≤ 349525) with h | h | h | h | h | h <;> rw [h] <;> decide
  exact List.mem_append_left _ (List.mem_append_left _ (List.mem_map.mpr ⟨_, hc, rfl⟩))

theorem first_tail_le (h2 : L ≤ 262143) (h0 : drains L = 0) (hL : 2 ≤ L) :
    W.first (.tail (rowClass (L - 1))) ≤ W.firstMax := by
  apply le_listMax
  obtain ⟨hlt, -, -⟩ := rowClass_spec (t := L - 1) (by omega)
    (by have := drains_zero_le (by omega) h0; omega)
  exact List.mem_append_left _ (List.mem_append_right _
    (List.mem_map.mpr ⟨_, List.mem_range.mpr hlt, rfl⟩))

theorem final_le (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    W.final (pfSrcOf L) (finalOf L) ≤ W.finalMax := by
  have hc : finalOf L ∈ finalClasses := (chain_cover L h1 h2).2.2.2.2.2.1.1
  have hm := le_listMax
    (f := fun c => max (W.final .first c) (max (W.final .drained c) (W.final .tailed c))) hc
  refine Nat.le_trans ?_ hm
  cases pfSrcOf L
  · exact Nat.le_max_left _ _
  · exact Nat.le_trans (Nat.le_max_left _ _) (Nat.le_max_right _ _)
  · exact Nat.le_trans (Nat.le_max_right _ _) (Nat.le_max_right _ _)

theorem atDrain_le_budget (h1 : 1 ≤ L) (h2 : L ≤ 262143) {k : Nat} (hk : k ≤ drains L) :
    W.atDrain L k ≤ W.budget (setupOf L) := by
  have ha := setupOf_applies h1 h2
  have hd := prefill_drains_le_class h2 ha
  have hit := iterSteps_le (len := fun j => W.drain (drainOf L j)) 1 (k - 1)
    (fun j => W.drain_le_stride L j)
  have hm : (k - 1) * W.stride (chunkC L) ≤ (setupOf L).maxDrains * W.stride (chunkC L) :=
    Nat.mul_le_mul_right _ (by omega)
  have hf := W.first_drain_le h2
  have hb : W.budget (setupOf L) = W.setup (setupOf L) + W.firstMax +
      (setupOf L).maxDrains * W.stride (chunkC L) + W.tailMax + W.finalMax := by
    rw [budget, setup_chunk (by omega)]
  simp only [atDrain]
  omega

theorem atPre_le_budget_sub_final (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    W.atPre L + W.finalMax ≤ W.budget (setupOf L) := by
  have ha := setupOf_applies h1 h2
  have hb : W.budget (setupOf L) = W.setup (setupOf L) + W.firstMax +
      (setupOf L).maxDrains * W.stride (chunkC L) + W.tailMax + W.finalMax := by
    rw [budget, setup_chunk (by omega)]
  unfold atPre
  by_cases hd : 1 ≤ drains L
  · rw [ite_eq_left hd]
    have hdm := prefill_drains_le_class h2 ha
    have hit := iterSteps_le (len := fun j => W.drain (drainOf L j)) 1 (drains L - 1)
      (fun j => W.drain_le_stride L j)
    have hm : (drains L - 1) * W.stride (chunkC L) ≤ (setupOf L).maxDrains * W.stride (chunkC L) :=
      Nat.mul_le_mul_right _ (by omega)
    have hf := W.first_drain_le h2
    have ht : (if 1 ≤ tailRows L then W.tail (tailOf L) else 0) ≤ W.tailMax := by
      split
      · exact le_listMax (tail_cover (by omega) hd (by assumption)).1
      · exact Nat.zero_le _
    simp only [atDrain]
    omega
  · rw [ite_eq_right hd]
    by_cases hL : 2 ≤ L
    · rw [ite_eq_left hL]
      have := W.first_tail_le (L := L) h2 (by omega) hL
      omega
    · rw [ite_eq_right hL]
      omega

theorem atPre_le_budget (h1 : 1 ≤ L) (h2 : L ≤ 262143) : W.atPre L ≤ W.budget (setupOf L) := by
  have := W.atPre_le_budget_sub_final h1 h2
  omega

theorem atExit_le_budget (h1 : 1 ≤ L) (h2 : L ≤ 262143) : W.atExit L ≤ W.budget (setupOf L) := by
  have := W.atPre_le_budget_sub_final h1 h2
  have := W.final_le h1 h2
  unfold atExit
  omega

/-- **A limit checked at the seven setup classes holds at every cut of every prompt.** -/
theorem budget_le_of_classes {limit : Nat} (h : ∀ c ∈ setupClasses, W.budget c ≤ limit)
    (h1 : 1 ≤ L) (h2 : L ≤ 262143) : W.budget (setupOf L) ≤ limit :=
  h _ (chain_cover L h1 h2).1.1

theorem cuts_within {limit : Nat} (h : ∀ c ∈ setupClasses, W.budget c ≤ limit)
    (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    (∀ k, k ≤ drains L → W.atDrain L k ≤ limit) ∧ W.atPre L ≤ limit ∧ W.atExit L ≤ limit :=
  have hb := W.budget_le_of_classes h h1 h2
  ⟨fun _ hk => Nat.le_trans (W.atDrain_le_budget h1 h2 hk) hb,
    Nat.le_trans (W.atPre_le_budget h1 h2) hb, Nat.le_trans (W.atExit_le_budget h1 h2) hb⟩

end

/-- The same schedule counts a prefill's steps: its pieces' lengths are a `PieceCounter`. -/
def ofSteps {F : Ffi} {I : PrefInvsW F} (S : PrefStepsPW I) : PieceCounter :=
  ⟨S.nSetup, S.nFirst, S.nDrain, S.nTail, S.nFinal⟩

theorem ofSteps_atExit {F : Ffi} {I : PrefInvsW F} (S : PrefStepsPW I) (L : Nat) :
    (ofSteps S).atExit L = S.n L := by
  simp only [atExit, atPre, atDrain, ofSteps, PrefStepsPW.n]
  by_cases hd : 1 ≤ drains L
  · rw [ite_eq_left hd, ite_eq_left hd]
    omega
  · rw [ite_eq_right hd, ite_eq_right hd]
    by_cases hL : 2 ≤ L
    · rw [ite_eq_left hL, ite_eq_left hL]
    · rw [ite_eq_right hL, ite_eq_right hL]
      omega

end PieceCounter

/-- A prompt's three counters: the JS heap offset, the MLX handles, the nodes. -/
structure PieceCounters where
  J : PieceCounter
  H : PieceCounter
  N : PieceCounter

/-- A setup class's uniform drain counters: the first forward's cumulative value and the chunk's stride. -/
def PieceCounters.ctr (P : PieceCounters) (c : SetupClass) : PrefCtr :=
  ⟨P.J.setup c + P.J.first (.drain c.chunk), P.H.setup c + P.H.first (.drain c.chunk),
    P.N.setup c + P.N.first (.drain c.chunk), P.J.stride c.chunk, P.H.stride c.chunk, P.N.stride c.chunk⟩

/-- The uniform drain cut's numbers stay within the class's budget at every drain of the class's prompts. -/
theorem PieceCounter.stride_within (W : PieceCounter) {c : SetupClass} {L k : Nat} (ha : c.Applies L)
    (hL : L ≤ 262143) (hk : k ≤ drains L) (h2 : c.chunk = chunkC L) :
    W.setup c + W.first (.drain c.chunk) + k * W.stride c.chunk ≤ W.budget c := by
  have hd := prefill_drains_le_class hL ha
  have hm : k * W.stride c.chunk ≤ c.maxDrains * W.stride c.chunk :=
    Nat.mul_le_mul_right _ (by omega)
  have hf : W.first (.drain c.chunk) ≤ W.firstMax := by
    rw [h2]
    exact W.first_drain_le hL
  simp only [PieceCounter.budget]
  omega

section
variable {Wd : World}

/-- **The recurrence on the actual states**: a restart whose source growth is within the drain class's
counters advances the cumulative book from `pc L k` to `pc L (k + 1)`. -/
theorem CutBookW.restart_counters {Q : PrefPW Wd} {sA sF sB : St Wd.F.S} {frsA frsB : List Nat}
    (P : PieceCounters) {L k : Nat} {x x1 x' : SegInst Wd.F} (hk : 1 ≤ k)
    (hb : CutBookW Wd Q sA frsA (P.J.atDrain L k) (P.H.atDrain L k) (P.N.atDrain L k) x)
    (hp : LoadPostW Wd sA sF sB Q.aP frsB Q.fixA x x1 x')
    (hJ : sF.next - sB.next ≤ P.J.drain (drainOf L k))
    (hH : (Wd.toMlx sF.ffi).next - (Wd.toMlx sB.ffi).next ≤ P.H.drain (drainOf L k))
    (hN : (Wd.toMlx sF.ffi).nnext - (Wd.toMlx sB.ffi).nnext ≤ P.N.drain (drainOf L k)) :
    CutBookW Wd Q sB frsB (P.J.atDrain L (k + 1)) (P.H.atDrain L (k + 1)) (P.N.atDrain L (k + 1)) x' := by
  rw [P.J.atDrain_succ hk, P.H.atDrain_succ hk, P.N.atDrain_succ hk]
  exact (hb.restart hp).mono (by omega) (by omega) (by omega)

end

section
variable {F : Ffi} {J : Disp.JSP F} {okBack : F.S → Arg → Bool} {cap oldD : Nat}

/-- An offset within the signed allowance transfers a chain's run, whatever the chain's position. -/
theorem signed_run_of_cap (hcap : cap ≤ oldD + 1593835520) (localGuard : St F.S → Bool)
    {n : Nat} {s s1 : St F.S} {S S1 : SSrv}
    (hr : runOk F (fun s S => Disp.okJSJ J okBack oldD s S && localGuard s) n s S = some (s1, S1)) :
    runOk F (fun s S => Disp.okJSJLimit J jsSignedLimit cap okBack s S && localGuard s) n s S =
      some (s1, S1) := by
  apply runOk_mono (ok := fun s S => Disp.okJSJ J okBack oldD s S && localGuard s) _ hr
  intro u U hu
  simp only [Bool.and_eq_true] at hu ⊢
  exact ⟨Disp.okJSJLimit_signed_of_allowance hcap hu.1, hu.2⟩

end

/-- **The JS image limit for every prompt**: a heap budget checked at the seven setup classes admits every
drain, pre-final and exit cut of every prompt length under the signed-cell allowance. -/
theorem prefill_signed_recurrence (W : PieceCounter) {oldD L : Nat}
    (h : ∀ c ∈ setupClasses, W.budget c ≤ oldD + 1593835520) (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    (∀ k, k ≤ drains L → W.atDrain L k ≤ oldD + 1593835520) ∧
      W.atPre L ≤ oldD + 1593835520 ∧ W.atExit L ≤ oldD + 1593835520 :=
  W.cuts_within h h1 h2

end Host.Ts.Sim.Prefill
