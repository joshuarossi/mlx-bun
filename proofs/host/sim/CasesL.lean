import host.sim.LinGood
import host.sim.CasesEos
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Lin

/-! # The decode loop's cases after a prompt of length `L`

After a prompt of `L` tokens, the readback cut of iteration `i` sits at cache offset
`p = L + i + 1` with KV capacity `capL p = 256·⌈p/256⌉` (`valL`; the prompt of length 1 is
`val1`, the existing loop valuation: `valL_one`). The cache clear depends on `i` and the KV
branch on `p`, so for a general `L` they combine: six loop cases (`CLEAR` iff `i % 256 = 0`;
`GROWTH` iff `p % 256 = 0`, `FILL` iff `p % 256 = 255`; `CLEARFILL`, `CLEARGROWTH` both).
The two new cases' distinct answers are `fillD`/`growD` with the clear answer true
(`clearFillD`, `clearGrowD`).

Each case's answers are correct at every valuation of its class (`good_*L`), checked once
per class by LinGood (`goodLin_sound`, `decide +kernel`). The final and EOS cases' answers
do not read the offset or the capacity, so the existing lemmas cover every `L`
(`good_finalGL`, `good_eosL`, `good_finalEGL`). `next_valL`: the loop restart's substitution
(`loopTheta`, growing exactly when `p % 256 = 0`) takes iteration `i`'s valuation to
iteration `i + 1`'s. -/

/-! ## The capacity -/

/-- The KV capacity at cache offset `p`: `256·⌈p/256⌉`. -/
def capL (p : Nat) : Nat := 256 * ((p + 255) / 256)

theorem capL_succ (p : Nat) : capL (p + 1) = if p % 256 = 0 then capL p + 256 else capL p := by
  unfold capL; split <;> omega

theorem capL_le (p : Nat) : capL p ≤ p + 255 := by unfold capL; omega

theorem le_capL (p : Nat) : p ≤ capL p := by unfold capL; omega

/-- Away from the capacity boundary the next offset stays below the capacity. -/
theorem capL_room {p : Nat} (h0 : p % 256 ≠ 0) (h255 : p % 256 ≠ 255) : p + 1 < capL p := by
  unfold capL; omega

theorem capL_fill {p : Nat} (h : p % 256 = 255) : p + 1 = capL p := by unfold capL; omega

theorem capL_grow {p : Nat} (h : p % 256 = 0) : p = capL p := by unfold capL; omega

/-- The prompt of length 1: `cap i` is the capacity at offset `i + 2`. -/
theorem capL_cap (i : Nat) : capL (i + 2) = cap i := by unfold capL cap; omega

/-! ## The loop valuation -/

/-- The template's variables at iteration `i` after a prompt of length `L` (offset `L + i + 1`,
capacity `capL (L + i + 1)`, current token `tk (i + 1)`, previous `tk i`), look-ahead `nx`. -/
def valL (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (L i nx : Nat) : Nat → F64 :=
  loopVal ρ T (L + i + 1) i (capL (L + i + 1)) (tk (i + 1)) (tk i) nx

/-- The loop valuation of the existing invariant (`LoopInv`, prompt of length 1). -/
def val1 (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (i nx : Nat) : Nat → F64 :=
  loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx

/-- **The prompt of length 1** is the existing loop valuation. -/
theorem valL_one (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) : valL ρ T tk 1 = val1 ρ T tk := by
  funext i nx
  unfold valL val1
  rw [show 1 + i + 1 = i + 2 by omega, capL_cap]

section
variable {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {L i nx : Nat}

theorem upd_valL (x : Nat) : upd (valL ρ T tk L i nx) 17 (F64.ofNat x) = valL ρ T tk L i x :=
  upd_loopVal ρ T _ i _ _ _ nx x

theorem valL_v9 : valL ρ T tk L i nx 9 = F64.ofNat (L + i + 1) := rfl
theorem valL_v14 : valL ρ T tk L i nx 14 = F64.ofNat (tk (i + 1)) := rfl
theorem valL_v16 : valL ρ T tk L i nx 16 = F64.ofNat (capL (L + i + 1)) := rfl
theorem valL_v17 : valL ρ T tk L i nx 17 = F64.ofNat nx := rfl

/-- **The next iteration's valuation.** A restart whose substitution is `loopTheta grow 17`,
growing exactly when the offset is a multiple of 256, maps iteration `i`'s valuation, with the
next token `tk (i + 2)` bound to `v17`, to iteration `i + 1`'s. -/
theorem next_valL {θ : Nat → SymE} (grow : Bool) (hθ : ∀ j, θ j = loopTheta grow 17 j)
    (hp : L + i + 2 < 2 ^ 30) (hc : capL (L + i + 1) < 2 ^ 30) (hg : grow = decide ((L + i + 1) % 256 = 0)) :
    (fun j => (θ j).eval (upd (valL ρ T tk L i nx) 17 (F64.ofNat (tk (i + 2))))) =
      valL ρ T tk L (i + 1) (tk (i + 2)) := by
  rw [upd_valL]
  have h1 : (fun j => (θ j).eval (valL ρ T tk L i (tk (i + 2)))) =
      (fun j => (loopTheta grow 17 j).eval (valL ρ T tk L i (tk (i + 2)))) := by
    funext j; rw [hθ j]
  rw [h1]
  unfold valL
  rw [loopTheta_step_next grow (by omega) (by omega) hc, show L + (i + 1) + 1 = L + i + 1 + 1 by omega,
    capL_succ (L + i + 1), show tk (i + 1 + 1) = tk (i + 2) from rfl]
  subst hg
  by_cases h : (L + i + 1) % 256 = 0 <;> simp [h]

end

/-! ## The two new cases' answers -/

/-- The cache-clear answer of a loop case. -/
abbrev clearAns (r : Bool) : Ans := ⟨.eq, .bin .rem gen1Prev lit256, litZero, r⟩

/-- `CLEARFILL`: `FILL` with the cache clear. -/
def clearFillD : List Ans := fillD.map fun q => if q = clearAns false then clearAns true else q

/-- `CLEARGROWTH`: `GROWTH` with the cache clear. -/
def clearGrowD : List Ans := growD.map fun q => if q = clearAns false then clearAns true else q

/-! ## The six classes

A class fixes the residues of `i` (`i = 256·a + r`) and of `p = L + i + 1` (`p = 256·b + s`);
the capacity is `256·b + 256` (`s ≠ 0`) or `256·b` (`s = 0`, `b ≥ 1`), the budget
`T = i + 3 + t`. -/

namespace Lin

def tokB : Prm := ⟨0, 4294967295, [248044]⟩

/-- `ORDINARY`: `r ∈ [1, 255]`, `s ∈ [1, 254]`. -/
def ordLB : List Prm :=
  [⟨0, 4194304, []⟩, ⟨1, 255, []⟩, ⟨0, 4194304, []⟩, ⟨1, 254, []⟩, ⟨0, 1073741824, []⟩, tokB]
def ordLV : List (Nat × Aff) :=
  [(0, 256 • P 0 + P 1 + P 4 + 3), (9, 256 • P 2 + P 3), (10, 256 • P 0 + P 1), (11, 256 • P 0 + P 1),
   (12, 256 • P 0 + P 1), (13, 256 • P 0 + P 1 - 1), (14, P 5), (16, 256 • P 2 + 256)]

/-- `CLEAR`: `i = 256·a` (`a ≥ 1`), `s ∈ [1, 254]`. -/
def clearLB : List Prm := [⟨1, 4194304, []⟩, ⟨0, 4194304, []⟩, ⟨1, 254, []⟩, ⟨0, 1073741824, []⟩, tokB]
def clearLV : List (Nat × Aff) :=
  [(0, 256 • P 0 + P 3 + 3), (9, 256 • P 1 + P 2), (10, 256 • P 0), (11, 256 • P 0),
   (12, 256 • P 0), (13, 256 • P 0 - 1), (14, P 4), (16, 256 • P 1 + 256)]

/-- `GROWTH`: `r ∈ [1, 255]`, `p = 256·b` (`b ≥ 1`). -/
def growLB : List Prm := [⟨0, 4194304, []⟩, ⟨1, 255, []⟩, ⟨1, 4194304, []⟩, ⟨0, 1073741824, []⟩, tokB]
def growLV : List (Nat × Aff) :=
  [(0, 256 • P 0 + P 1 + P 3 + 3), (9, 256 • P 2), (10, 256 • P 0 + P 1), (11, 256 • P 0 + P 1),
   (12, 256 • P 0 + P 1), (13, 256 • P 0 + P 1 - 1), (14, P 4), (16, 256 • P 2)]

/-- `FILL`: `r ∈ [1, 255]`, `p = 256·b + 255`. -/
def fillLB : List Prm := [⟨0, 4194304, []⟩, ⟨1, 255, []⟩, ⟨0, 4194304, []⟩, ⟨0, 1073741824, []⟩, tokB]
def fillLV : List (Nat × Aff) :=
  [(0, 256 • P 0 + P 1 + P 3 + 3), (9, 256 • P 2 + 255), (10, 256 • P 0 + P 1),
   (11, 256 • P 0 + P 1), (12, 256 • P 0 + P 1), (13, 256 • P 0 + P 1 - 1), (14, P 4), (16, 256 • P 2 + 256)]

/-- `CLEARFILL`: `i = 256·a` (`a ≥ 1`), `p = 256·b + 255`. -/
def clearFillLB : List Prm := [⟨1, 4194304, []⟩, ⟨0, 4194304, []⟩, ⟨0, 1073741824, []⟩, tokB]
def clearFillLV : List (Nat × Aff) :=
  [(0, 256 • P 0 + P 2 + 3), (9, 256 • P 1 + 255), (10, 256 • P 0), (11, 256 • P 0),
   (12, 256 • P 0), (13, 256 • P 0 - 1), (14, P 3), (16, 256 • P 1 + 256)]

/-- `CLEARGROWTH`: `i = 256·a` (`a ≥ 1`), `p = 256·b` (`b ≥ 1`). -/
def clearGrowLB : List Prm := [⟨1, 4194304, []⟩, ⟨1, 4194304, []⟩, ⟨0, 1073741824, []⟩, tokB]
def clearGrowLV : List (Nat × Aff) :=
  [(0, 256 • P 0 + P 2 + 3), (9, 256 • P 1), (10, 256 • P 0), (11, 256 • P 0),
   (12, 256 • P 0), (13, 256 • P 0 - 1), (14, P 3), (16, 256 • P 1)]

theorem ordL_check : goodLin ordLB ordLV ordD = true := by decide +kernel
theorem clearL_check : goodLin clearLB clearLV clearD = true := by decide +kernel
theorem growL_check : goodLin growLB growLV growD = true := by decide +kernel
theorem fillL_check : goodLin fillLB fillLV fillD = true := by decide +kernel
theorem clearFillL_check : goodLin clearFillLB clearFillLV clearFillD = true := by decide +kernel
theorem clearGrowL_check : goodLin clearGrowLB clearGrowLV clearGrowD = true := by decide +kernel

end Lin

section
variable {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {L i nx : Nat}

/-- `ORDINARY` at any prompt length. -/
theorem good_ordL (hrem : i % 256 ≠ 0) (hs0 : (L + i + 1) % 256 ≠ 0) (hs1 : (L + i + 1) % 256 ≠ 255)
    (hT : i + 2 < T) (hp : L + i + 1 < 2 ^ 30) (hTb : T < 2 ^ 30) (htok : tk (i + 1) ≠ 248044)
    (ht : tk (i + 1) < 2 ^ 32) : Good (valL ρ T tk L i nx) ordD :=
  goodLin_sound Lin.ordL_check
    (x := vx [(i : Int) / 256, (i : Int) % 256, ((L + i + 1 : Nat) : Int) / 256, ((L + i + 1 : Nat) : Int) % 256,
      (T : Int) - i - 3, tk (i + 1)])
    (by lin_mem [Lin.ordLB, Lin.tokB]) (by lin_mem [Lin.ordLV, valL, capL])

/-- `CLEAR` at any prompt length. -/
theorem good_clearL (hi1 : 1 ≤ i) (hrem : i % 256 = 0) (hs0 : (L + i + 1) % 256 ≠ 0)
    (hs1 : (L + i + 1) % 256 ≠ 255) (hT : i + 2 < T) (hp : L + i + 1 < 2 ^ 30) (hTb : T < 2 ^ 30) (htok : tk (i + 1) ≠ 248044)
    (ht : tk (i + 1) < 2 ^ 32) : Good (valL ρ T tk L i nx) clearD :=
  goodLin_sound Lin.clearL_check
    (x := vx [(i : Int) / 256, ((L + i + 1 : Nat) : Int) / 256, ((L + i + 1 : Nat) : Int) % 256,
      (T : Int) - i - 3, tk (i + 1)])
    (by lin_mem [Lin.clearLB, Lin.tokB]) (by lin_mem [Lin.clearLV, valL, capL])

/-- `GROWTH` at any prompt length. -/
theorem good_growL (hrem : i % 256 ≠ 0) (hs : (L + i + 1) % 256 = 0) (hT : i + 2 < T) (hp : L + i + 1 < 2 ^ 30)
    (hTb : T < 2 ^ 30) (htok : tk (i + 1) ≠ 248044) (ht : tk (i + 1) < 2 ^ 32) :
    Good (valL ρ T tk L i nx) growD :=
  goodLin_sound Lin.growL_check
    (x := vx [(i : Int) / 256, (i : Int) % 256, ((L + i + 1 : Nat) : Int) / 256, (T : Int) - i - 3, tk (i + 1)])
    (by lin_mem [Lin.growLB, Lin.tokB]) (by lin_mem [Lin.growLV, valL, capL])

/-- `FILL` at any prompt length. -/
theorem good_fillL (hrem : i % 256 ≠ 0) (hs : (L + i + 1) % 256 = 255) (hT : i + 2 < T) (hp : L + i + 1 < 2 ^ 30)
    (hTb : T < 2 ^ 30) (htok : tk (i + 1) ≠ 248044) (ht : tk (i + 1) < 2 ^ 32) :
    Good (valL ρ T tk L i nx) fillD :=
  goodLin_sound Lin.fillL_check
    (x := vx [(i : Int) / 256, (i : Int) % 256, ((L + i + 1 : Nat) : Int) / 256, (T : Int) - i - 3, tk (i + 1)])
    (by lin_mem [Lin.fillLB, Lin.tokB]) (by lin_mem [Lin.fillLV, valL, capL])

/-- `CLEARFILL` at any prompt length. -/
theorem good_clearFillL (hi1 : 1 ≤ i) (hrem : i % 256 = 0) (hs : (L + i + 1) % 256 = 255) (hT : i + 2 < T)
    (hp : L + i + 1 < 2 ^ 30) (hTb : T < 2 ^ 30) (htok : tk (i + 1) ≠ 248044) (ht : tk (i + 1) < 2 ^ 32) :
    Good (valL ρ T tk L i nx) clearFillD :=
  goodLin_sound Lin.clearFillL_check
    (x := vx [(i : Int) / 256, ((L + i + 1 : Nat) : Int) / 256, (T : Int) - i - 3, tk (i + 1)])
    (by lin_mem [Lin.clearFillLB, Lin.tokB]) (by lin_mem [Lin.clearFillLV, valL, capL])

/-- `CLEARGROWTH` at any prompt length. -/
theorem good_clearGrowL (hi1 : 1 ≤ i) (hrem : i % 256 = 0) (hs : (L + i + 1) % 256 = 0) (hT : i + 2 < T)
    (hp : L + i + 1 < 2 ^ 30) (hTb : T < 2 ^ 30) (htok : tk (i + 1) ≠ 248044) (ht : tk (i + 1) < 2 ^ 32) :
    Good (valL ρ T tk L i nx) clearGrowD :=
  goodLin_sound Lin.clearGrowL_check
    (x := vx [(i : Int) / 256, ((L + i + 1 : Nat) : Int) / 256, (T : Int) - i - 3, tk (i + 1)])
    (by lin_mem [Lin.clearGrowLB, Lin.tokB]) (by lin_mem [Lin.clearGrowLV, valL, capL])

/-! ## The final and EOS cases at any prompt length -/

/-- The final iteration at `i = T - 2`, either cache-clear branch. -/
theorem good_finalGL (hi1 : 1 ≤ i) (hT : T = i + 2) (htok : tk (i + 1) ≠ 248044) (hnext : nx ≠ 248044)
    (hTb : T < 2 ^ 30) (ht : tk (i + 1) < 2 ^ 32) (hn : nx < 2 ^ 32) :
    Good (valL ρ T tk L i nx) (finalDG (decide (i % 256 = 0)) (decide ((i + 1) % 256 = 0))) :=
  good_finalG (by omega) htok rfl rfl (by omega) hnext (by omega) (by omega) ht hn

/-- The EOS exit at the cut of iteration `i`. -/
theorem good_eosL (hi1 : 1 ≤ i) (htok : tk (i + 1) = 248044) (hib : i < 2 ^ 30) :
    Good (valL ρ T tk L i nx) eosD :=
  good_eos (by omega) htok hib

/-- The EOS final iteration at `i = T - 2`, either cache-clear branch of the yielded token. -/
theorem good_finalEGL (hi1 : 1 ≤ i) (hT : T = i + 2) (htok : tk (i + 1) ≠ 248044) (hnext : nx = 248044)
    (hTb : T < 2 ^ 30) (ht : tk (i + 1) < 2 ^ 32) :
    Good (valL ρ T tk L i nx) (finalEDG (decide (i % 256 = 0))) :=
  good_finalEG (by omega) htok rfl (by omega) hnext (by omega) (by omega) ht

end

end Host.Ts.Sim
