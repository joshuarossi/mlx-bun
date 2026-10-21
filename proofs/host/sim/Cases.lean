import host.sim.LoopArith
import host.sim.Upd
namespace Host.Ts.Sim
open Host.Ts

/-! # The template cases' oracles at every loop state

Each case's oracle has a few distinct answers (`ordD`, …). `good_of_mem` reduces a
case oracle to its distinct answers (a kernel check that every answer is among
them); the `good_*` lemmas decide the distinct answers at the loop valuation
from the loop state's arithmetic conditions. -/

theorem good_of_mem {ν : Nat → F64} {o D : List Ans} (hD : Good ν D) (h : o.all (fun q => D.contains q) = true) :
    Good ν o := by
  intro q hq
  simp only [List.all_eq_true, List.contains_iff_mem] at h
  exact hD q (h q hq)

/-- The distinct answers of case `ORDINARY`. -/
def ordD : List Ans :=
  [⟨.eq, .var 10, litZero, false⟩,
   ⟨.eq, litEos, .var 14, false⟩,
   ⟨.eq, .bin .rem gen1Prev lit256, litZero, false⟩,
   ⟨.eq, gen1, litZero, false⟩,
   ⟨.lt, gen2, .var 0, true⟩,
   ⟨.lt, .var 16, off1, false⟩,
   ⟨.lt, off32, litZero, false⟩,
   ⟨.lt, off1I32, litZero, false⟩,
   ⟨.lt, off32, .var 16, true⟩,
   ⟨.lt, litZero, off32, true⟩,
   ⟨.lt, off1I32, .var 16, true⟩,
   ⟨.lt, litZero, off1I32, true⟩,
   ⟨.lt, off1I32, off32, false⟩,
   ⟨.eq, litOne, .bin .sub off1I32 off32, true⟩,
   ⟨.lt, litZero, .var 16, true⟩,
   ⟨.eq, .bin .sub off1I32 litZero, .var 16, false⟩]

section
variable {rest : Nat → F64} {T p i c tok ptok next : Nat}

/-- `ORDINARY`: not the first or the last iteration, not EOS, no cache clear, and the
next offset stays strictly below the capacity. -/
theorem good_ord (hi0 : i ≠ 0) (htok : tok ≠ 248044) (hrem : i % 256 ≠ 0) (hT : i + 2 < T)
    (hpc : p + 1 < c) (hp0 : 0 < p) (hi : i < 2 ^ 30) (hTb : T < 2 ^ 30) (hp : p < 2 ^ 30) (hc : c < 2 ^ 30)
    (ht : tok < 2 ^ 32) : Good (loopVal rest T p i c tok ptok next) ordD := by
  intro q hq
  simp only [ordD, List.mem_cons, List.mem_nil_iff, or_false] at hq
  rcases hq with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact (test_gen_zero hi).trans (decide_eq_false hi0)
  · exact (test_eos_tok ht).trans (decide_eq_false htok)
  · exact (test_gen1Prev_rem hi).trans (decide_eq_false hrem)
  · exact test_gen1_zero hi
  · exact (test_gen2_budget hi hTb).trans (decide_eq_true hT)
  · exact (test_cap_off1_c hc hp).trans (decide_eq_false (by omega))
  · exact test_off32_neg hp
  · exact test_off1I32_neg hp
  · exact (test_off32_cap_c hc hp).trans (decide_eq_true (by omega))
  · exact (test_zero_off32 hp).trans (decide_eq_true hp0)
  · exact (test_off1I32_cap_c hc hp).trans (decide_eq_true hpc)
  · exact test_zero_off1I32 hp
  · exact test_off1I32_off32 hp
  · exact test_one_offDelta hp
  · exact (test_zero_cap_c hc).trans (decide_eq_true (by omega))
  · exact (test_off1I32_sub0_cap_c hc hp).trans (decide_eq_false (by omega))

end

/-! ## The loop schedule

At iteration `i ≥ 1` (the `i`-th readback cut) the cache offset is `i + 2` and the
KV capacity is `cap i`: it starts at 256 and grows by 256 at the iteration whose
next offset would exceed it (`i % 256 = 254`). -/

def cap (i : Nat) : Nat := 256 * ((i + 1) / 256 + 1)

/-- Capacity after an iteration. -/
theorem cap_succ (i : Nat) : cap (i + 1) = if i % 256 = 254 then cap i + 256 else cap i := by
  unfold cap
  split <;> omega

/-- Away from the capacity boundary the next offset stays below the capacity. -/
theorem cap_room {i : Nat} (h253 : i % 256 ≠ 253) (h254 : i % 256 ≠ 254) : i + 3 < cap i := by
  unfold cap; omega

theorem cap_fill {i : Nat} (h : i % 256 = 253) : i + 3 = cap i := by
  unfold cap; omega

theorem cap_grow {i : Nat} (h : i % 256 = 254) : i + 2 = cap i := by
  unfold cap; omega

theorem cap_pos (i : Nat) : 0 < cap i := by unfold cap; omega

theorem cap_le (i : Nat) : cap i ≤ i + 257 := by unfold cap; omega

theorem upd_loopVal (rest : Nat → F64) (T p i c tok ptok next x : Nat) :
    upd (loopVal rest T p i c tok ptok next) 17 (F64.ofNat x) = loopVal rest T p i c tok ptok x := by
  funext j
  by_cases h : j = 17
  · subst h; simp [upd, loopVal]
  · rw [upd_other _ _ h]
    match j, h with
    | 0, _ | 1, _ | 2, _ | 3, _ | 4, _ | 5, _ | 6, _ | 7, _ | 8, _ | 9, _ | 10, _ | 11, _ | 12, _ | 13, _
    | 14, _ | 15, _ | 16, _ => rfl
    | j + 18, _ => rfl

/-- `ORDINARY` at iteration `i`. -/
theorem good_ord_at {rest : Nat → F64} {T i tok ptok next : Nat} (hi1 : 1 ≤ i) (hT : i + 2 < T)
    (hrem : i % 256 ≠ 0) (h253 : i % 256 ≠ 253) (h254 : i % 256 ≠ 254) (htok : tok ≠ 248044)
    (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) ordD :=
  good_ord (by omega) htok hrem hT (cap_room h253 h254) (by omega) (by omega) (by omega) (by omega)
    (by have := cap_le i; omega) ht


/-! ## The other cases -/

def clearD : List Ans :=
  [⟨.eq, .var 10, litZero, false⟩,
   ⟨.eq, litEos, .var 14, false⟩,
   ⟨.eq, .bin .rem gen1Prev lit256, litZero, true⟩,
   ⟨.eq, gen1, litZero, false⟩,
   ⟨.lt, gen2, .var 0, true⟩,
   ⟨.lt, .var 16, off1, false⟩,
   ⟨.lt, off32, litZero, false⟩,
   ⟨.lt, off1I32, litZero, false⟩,
   ⟨.lt, off32, .var 16, true⟩,
   ⟨.lt, litZero, off32, true⟩,
   ⟨.lt, off1I32, .var 16, true⟩,
   ⟨.lt, litZero, off1I32, true⟩,
   ⟨.lt, off1I32, off32, false⟩,
   ⟨.eq, litOne, .bin .sub off1I32 off32, true⟩,
   ⟨.lt, litZero, .var 16, true⟩,
   ⟨.eq, .bin .sub off1I32 litZero, .var 16, false⟩]

def growD : List Ans :=
  [⟨.eq, .var 10, litZero, false⟩,
   ⟨.eq, litEos, .var 14, false⟩,
   ⟨.eq, .bin .rem gen1Prev lit256, litZero, false⟩,
   ⟨.eq, gen1, litZero, false⟩,
   ⟨.lt, gen2, .var 0, true⟩,
   ⟨.lt, .var 16, off1, true⟩,
   ⟨.eq, .bin .rem (.var 9) lit256, litZero, true⟩,
   ⟨.lt, off32, litZero, false⟩,
   ⟨.lt, off1I32, litZero, false⟩,
   ⟨.lt, off32, capGrow, true⟩,
   ⟨.lt, litZero, off32, true⟩,
   ⟨.lt, off1I32, capGrow, true⟩,
   ⟨.lt, litZero, off1I32, true⟩,
   ⟨.lt, off1I32, off32, false⟩,
   ⟨.eq, litOne, .bin .sub off1I32 off32, true⟩,
   ⟨.lt, litZero, capGrow, true⟩,
   ⟨.eq, .bin .sub off1I32 litZero, capGrow, false⟩]

def fillD : List Ans :=
  [⟨.eq, .var 10, litZero, false⟩,
   ⟨.eq, litEos, .var 14, false⟩,
   ⟨.eq, .bin .rem gen1Prev lit256, litZero, false⟩,
   ⟨.eq, gen1, litZero, false⟩,
   ⟨.lt, gen2, .var 0, true⟩,
   ⟨.lt, .var 16, off1, false⟩,
   ⟨.lt, off32, litZero, false⟩,
   ⟨.lt, off1I32, litZero, false⟩,
   ⟨.lt, off32, .var 16, true⟩,
   ⟨.lt, litZero, off32, true⟩,
   ⟨.lt, off1I32, .var 16, false⟩,
   ⟨.lt, litZero, .var 16, true⟩,
   ⟨.lt, .var 16, off32, false⟩,
   ⟨.eq, litOne, .bin .sub (.var 16) off32, true⟩,
   ⟨.lt, .var 16, litZero, false⟩,
   ⟨.eq, .bin .sub (.var 16) litZero, .var 16, true⟩]

/-- The final iteration's answers; `r3`/`r7` are the two cache-clear tests
(`FINAL`: both false, `FINALC0`: the first, `FINALC1`: the second). -/
def finalDG (r3 r7 : Bool) : List Ans :=
  [⟨.eq, .var 10, litZero, false⟩,
   ⟨.eq, litEos, .var 14, false⟩,
   ⟨.eq, .bin .rem gen1Prev lit256, litZero, r3⟩,
   ⟨.eq, gen1, litZero, false⟩,
   ⟨.lt, gen2, .var 0, false⟩,
   ⟨.eq, litEos, .var 17, false⟩,
   ⟨.eq, .bin .rem gen2Prev lit256, litZero, r7⟩]

abbrev finalD : List Ans := finalDG false false

section
variable {rest : Nat → F64} {T p i c tok ptok next : Nat}

theorem good_clear (hi0 : i ≠ 0) (htok : tok ≠ 248044) (hrem : i % 256 = 0) (hT : i + 2 < T)
    (hpc : p + 1 < c) (hp0 : 0 < p) (hi : i < 2 ^ 30) (hTb : T < 2 ^ 30) (hp : p < 2 ^ 30) (hc : c < 2 ^ 30)
    (ht : tok < 2 ^ 32) : Good (loopVal rest T p i c tok ptok next) clearD := by
  intro q hq
  simp only [clearD, List.mem_cons, List.mem_nil_iff, or_false] at hq
  rcases hq with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact (test_gen_zero hi).trans (decide_eq_false hi0)
  · exact (test_eos_tok ht).trans (decide_eq_false htok)
  · exact (test_gen1Prev_rem hi).trans (decide_eq_true hrem)
  · exact test_gen1_zero hi
  · exact (test_gen2_budget hi hTb).trans (decide_eq_true hT)
  · exact (test_cap_off1_c hc hp).trans (decide_eq_false (by omega))
  · exact test_off32_neg hp
  · exact test_off1I32_neg hp
  · exact (test_off32_cap_c hc hp).trans (decide_eq_true (by omega))
  · exact (test_zero_off32 hp).trans (decide_eq_true hp0)
  · exact (test_off1I32_cap_c hc hp).trans (decide_eq_true hpc)
  · exact test_zero_off1I32 hp
  · exact test_off1I32_off32 hp
  · exact test_one_offDelta hp
  · exact (test_zero_cap_c hc).trans (decide_eq_true (by omega))
  · exact (test_off1I32_sub0_cap_c hc hp).trans (decide_eq_false (by omega))

theorem good_grow (hi0 : i ≠ 0) (htok : tok ≠ 248044) (hrem : i % 256 ≠ 0) (hT : i + 2 < T)
    (hcp : c ≤ p) (hpc : p + 1 < c + 256) (hpr : p % 256 = 0) (hp0 : 0 < p) (hi : i < 2 ^ 30)
    (hTb : T < 2 ^ 30) (hp : p < 2 ^ 30) (hc : c < 2 ^ 30) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T p i c tok ptok next) growD := by
  intro q hq
  simp only [growD, List.mem_cons, List.mem_nil_iff, or_false] at hq
  rcases hq with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact (test_gen_zero hi).trans (decide_eq_false hi0)
  · exact (test_eos_tok ht).trans (decide_eq_false htok)
  · exact (test_gen1Prev_rem hi).trans (decide_eq_false hrem)
  · exact test_gen1_zero hi
  · exact (test_gen2_budget hi hTb).trans (decide_eq_true hT)
  · exact (test_cap_off1_c hc hp).trans (decide_eq_true (by omega))
  · exact (test_off_rem hp).trans (decide_eq_true hpr)
  · exact test_off32_neg hp
  · exact test_off1I32_neg hp
  · exact (test_off32_cap_c256 hc hp).trans (decide_eq_true (by omega))
  · exact (test_zero_off32 hp).trans (decide_eq_true hp0)
  · exact (test_off1I32_cap_c256 hc hp).trans (decide_eq_true hpc)
  · exact test_zero_off1I32 hp
  · exact test_off1I32_off32 hp
  · exact test_one_offDelta hp
  · exact test_zero_cap_c256 hc
  · exact (test_off1I32_sub0_cap_c256 hc hp).trans (decide_eq_false (by omega))

theorem good_fill (hi0 : i ≠ 0) (htok : tok ≠ 248044) (hrem : i % 256 ≠ 0) (hT : i + 2 < T)
    (hpc : p + 1 = c) (hp0 : 0 < p) (hi : i < 2 ^ 30) (hTb : T < 2 ^ 30) (hp : p < 2 ^ 30)
    (hc : c < 2 ^ 30) (ht : tok < 2 ^ 32) : Good (loopVal rest T p i c tok ptok next) fillD := by
  intro q hq
  simp only [fillD, List.mem_cons, List.mem_nil_iff, or_false] at hq
  rcases hq with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact (test_gen_zero hi).trans (decide_eq_false hi0)
  · exact (test_eos_tok ht).trans (decide_eq_false htok)
  · exact (test_gen1Prev_rem hi).trans (decide_eq_false hrem)
  · exact test_gen1_zero hi
  · exact (test_gen2_budget hi hTb).trans (decide_eq_true hT)
  · exact (test_cap_off1_c hc hp).trans (decide_eq_false (by omega))
  · exact test_off32_neg hp
  · exact test_off1I32_neg hp
  · exact (test_off32_cap_c hc hp).trans (decide_eq_true (by omega))
  · exact (test_zero_off32 hp).trans (decide_eq_true hp0)
  · exact (test_off1I32_cap_c hc hp).trans (decide_eq_false (by omega))
  · exact (test_zero_cap_c hc).trans (decide_eq_true (by omega))
  · exact (test_cap_off32_c hc hp).trans (decide_eq_false (by omega))
  · exact (test_one_cap_sub_off32_c hc hp).trans (decide_eq_true hpc.symm)
  · exact test_cap_neg_c hc
  · exact test_cap_sub0_c hc

theorem good_finalG {r3 r7 : Bool} (hi0 : i ≠ 0) (htok : tok ≠ 248044) (hrem : decide (i % 256 = 0) = r3)
    (hrem1 : decide ((i + 1) % 256 = 0) = r7)
    (hT : T ≤ i + 2) (hnext : next ≠ 248044) (hi : i < 2 ^ 30) (hTb : T < 2 ^ 30)
    (ht : tok < 2 ^ 32) (hn : next < 2 ^ 32) : Good (loopVal rest T p i c tok ptok next) (finalDG r3 r7) := by
  intro q hq
  simp only [finalDG, List.mem_cons, List.mem_nil_iff, or_false] at hq
  rcases hq with rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact (test_gen_zero hi).trans (decide_eq_false hi0)
  · exact (test_eos_tok ht).trans (decide_eq_false htok)
  · exact (test_gen1Prev_rem hi).trans hrem
  · exact test_gen1_zero hi
  · exact (test_gen2_budget hi hTb).trans (decide_eq_false (by omega))
  · exact (test_eos_next hn).trans (decide_eq_false hnext)
  · exact (test_gen2Prev_rem hi).trans hrem1

theorem good_final (hi0 : i ≠ 0) (htok : tok ≠ 248044) (hrem : i % 256 ≠ 0) (hrem1 : (i + 1) % 256 ≠ 0)
    (hT : T ≤ i + 2) (hnext : next ≠ 248044) (hi : i < 2 ^ 30) (hTb : T < 2 ^ 30)
    (ht : tok < 2 ^ 32) (hn : next < 2 ^ 32) : Good (loopVal rest T p i c tok ptok next) finalD :=
  good_finalG hi0 htok (decide_eq_false hrem) (decide_eq_false hrem1) hT hnext hi hTb ht hn

end

/-! ## The cases at iteration `i` -/

section
variable {rest : Nat → F64} {T i tok ptok next : Nat}

theorem good_clear_at (hi1 : 1 ≤ i) (hT : i + 2 < T) (hrem : i % 256 = 0) (htok : tok ≠ 248044)
    (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) clearD :=
  good_clear (by omega) htok hrem hT (cap_room (by omega) (by omega)) (by omega) (by omega) (by omega)
    (by omega) (by have := cap_le i; omega) ht

theorem good_grow_at (hi1 : 1 ≤ i) (hT : i + 2 < T) (h254 : i % 256 = 254) (htok : tok ≠ 248044)
    (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) growD := by
  have hc := cap_grow h254
  exact good_grow (by omega) htok (by omega) hT (by omega) (by omega) (by omega) (by omega) (by omega)
    (by omega) (by omega) (by omega) ht

theorem good_fill_at (hi1 : 1 ≤ i) (hT : i + 2 < T) (h253 : i % 256 = 253) (htok : tok ≠ 248044)
    (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) fillD := by
  have hc := cap_fill h253
  exact good_fill (by omega) htok (by omega) hT (by omega) (by omega) (by omega) (by omega) (by omega)
    (by omega) ht

theorem good_final_at (hi1 : 1 ≤ i) (hT : T = i + 2) (hrem : i % 256 ≠ 0) (hrem1 : (i + 1) % 256 ≠ 0)
    (htok : tok ≠ 248044) (hnext : next ≠ 248044) (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) (hn : next < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) finalD :=
  good_final (by omega) htok hrem hrem1 (by omega) hnext (by omega) (by omega) ht hn

end

/-! ## The next iteration's valuation -/

/-- A template restart whose substitution is `loopTheta grow 17` maps iteration `i`'s
valuation, with the next token `x` bound to `v17`, to iteration `i + 1`'s. -/
theorem next_loopVal {θ : Nat → SymE} (grow : Bool) (hθ : ∀ j, θ j = loopTheta grow 17 j)
    {rest : Nat → F64} {T i tok ptok next x : Nat} (hi : i + 3 < 2 ^ 30) (hc : cap i < 2 ^ 30)
    (hg : grow = decide (i % 256 = 254)) :
    (fun j => (θ j).eval (upd (loopVal rest T (i + 2) i (cap i) tok ptok next) 17 (F64.ofNat x))) =
      loopVal rest T (i + 1 + 2) (i + 1) (cap (i + 1)) x tok x := by
  rw [upd_loopVal]
  have h1 : (fun j => (θ j).eval (loopVal rest T (i + 2) i (cap i) tok ptok x)) =
      (fun j => (loopTheta grow 17 j).eval (loopVal rest T (i + 2) i (cap i) tok ptok x)) := by
    funext j; rw [hθ j]
  rw [h1, loopTheta_step_next grow (by omega) (by omega) hc, cap_succ]
  subst hg
  by_cases h : i % 256 = 254 <;> simp [h, Nat.add_right_comm]


section
variable {rest : Nat → F64} {T i tok ptok next : Nat}

/-- The final iteration at `i = T - 2`, any cache-clear branch. -/
theorem good_finalG_at (hi1 : 1 ≤ i) (hT : T = i + 2) (htok : tok ≠ 248044) (hnext : next ≠ 248044)
    (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) (hn : next < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next)
      (finalDG (decide (i % 256 = 0)) (decide ((i + 1) % 256 = 0))) :=
  good_finalG (by omega) htok rfl rfl (by omega) hnext (by omega) (by omega) ht hn
end

end Host.Ts.Sim
