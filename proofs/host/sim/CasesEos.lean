import host.sim.Cases
namespace Host.Ts.Sim
open Host.Ts

/-! # The EOS cases' oracles at every loop state

The EOS exit at a loop cut answers two tests (not the first iteration, the cut's token is
EOS: `eosD`); the EOS final case answers the final iteration's tests up to the look-ahead
token's EOS test, which is true (`finalEDG`; the second cache-clear test is never reached).
`good_*_at` decide them at the loop valuation of iteration `i`. -/

/-- The distinct answers of the exit case `EOSX`. -/
def eosD : List Ans :=
  [⟨.eq, .var 10, litZero, false⟩,
   ⟨.eq, litEos, .var 14, true⟩]

/-- The EOS final iteration's answers; `r3` is the cache-clear test of the yielded token
(`FINALE`: false, `FINALEC0`: true). -/
def finalEDG (r3 : Bool) : List Ans :=
  [⟨.eq, .var 10, litZero, false⟩,
   ⟨.eq, litEos, .var 14, false⟩,
   ⟨.eq, .bin .rem gen1Prev lit256, litZero, r3⟩,
   ⟨.eq, gen1, litZero, false⟩,
   ⟨.lt, gen2, .var 0, false⟩,
   ⟨.eq, litEos, .var 17, true⟩]

section
variable {rest : Nat → F64} {T p i c tok ptok next : Nat}

theorem good_eos (hi0 : i ≠ 0) (htok : tok = 248044) (hi : i < 2 ^ 30) :
    Good (loopVal rest T p i c tok ptok next) eosD := by
  intro q hq
  simp only [eosD, List.mem_cons, List.mem_nil_iff, or_false] at hq
  rcases hq with rfl | rfl
  · exact (test_gen_zero hi).trans (decide_eq_false hi0)
  · exact (test_eos_tok (by rw [htok]; decide)).trans (decide_eq_true htok)

theorem good_finalEG {r3 : Bool} (hi0 : i ≠ 0) (htok : tok ≠ 248044) (hrem : decide (i % 256 = 0) = r3)
    (hT : T ≤ i + 2) (hnext : next = 248044) (hi : i < 2 ^ 30) (hTb : T < 2 ^ 30) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T p i c tok ptok next) (finalEDG r3) := by
  intro q hq
  simp only [finalEDG, List.mem_cons, List.mem_nil_iff, or_false] at hq
  rcases hq with rfl | rfl | rfl | rfl | rfl | rfl
  · exact (test_gen_zero hi).trans (decide_eq_false hi0)
  · exact (test_eos_tok ht).trans (decide_eq_false htok)
  · exact (test_gen1Prev_rem hi).trans hrem
  · exact test_gen1_zero hi
  · exact (test_gen2_budget hi hTb).trans (decide_eq_false (by omega))
  · exact (test_eos_next (by rw [hnext]; decide)).trans (decide_eq_true hnext)

/-- The EOS exit at the cut of iteration `i`. -/
theorem good_eos_at (hi1 : 1 ≤ i) (htok : tok = 248044) (hib : i < 2 ^ 30) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) eosD :=
  good_eos (by omega) htok hib

/-- The EOS final iteration at `i = T - 2`, either cache-clear branch of the yielded token. -/
theorem good_finalE_at (hi1 : 1 ≤ i) (hT : T = i + 2) (htok : tok ≠ 248044) (hnext : next = 248044)
    (hTb : T < 2 ^ 29) (ht : tok < 2 ^ 32) :
    Good (loopVal rest T (i + 2) i (cap i) tok ptok next) (finalEDG (decide (i % 256 = 0))) :=
  good_finalEG (by omega) htok rfl (by omega) hnext (by omega) (by omega) ht

end

/-- A token whose EOS test is true is EOS. -/
theorem eos_tok {n : Nat} (hn : n < 2 ^ 53) (h : F64.test .eq (.fin false 248044 0) (F64.ofNat n) = true) :
    n = 248044 := by
  rw [fin_eq_ofNat 248044 (by decide) (by decide), test_eq_ofNat 248044 n (by decide) hn] at h
  exact (of_decide_eq_true h).symm

end Host.Ts.Sim
