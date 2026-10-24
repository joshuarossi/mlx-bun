import host.sim.world.World
namespace Host.Ts.Sim
open Host.Ts

/-! # The decode cases' oracles over their parameter boxes

A regenerated decode piece answers its own questions, not today's distinct-answer lists (`ordD`,
`finalDG`, `eosD`, …). Its oracle is correct at every valuation of its class when `goodLin`
decides it over the class's box (`host.sim.LinGood`), as the prefill classes are checked
(`host.sim.lin.Classes`, `good_of_row`). The boxes:

* the six loop classes: `Lin.ordLB`/`Lin.ordLV` … (`host.sim.CasesL`); `good_ordW` … give the
  oracle's correctness at `valL` from `goodLin … o = true`;
* the final iteration (`FinalOk r3 r7 o`: `i = T - 2`, the cache-clear tests `r3`, `r7`, the
  look-ahead token not EOS), the EOS final iteration (`FinalEOk r3 o`: the look-ahead token EOS),
  the EOS exit at a loop cut (`ExitOk o`: the cut's token EOS, `T ≥ i + 2`), each over the residue
  rows of `i = 256 a + r` (`IRes`) and the two capacity rows of `p = L + i + 1 = 256 b + s` (`s ≠ 0`:
  capacity `256 b + 256`; `s = 0`: `256 b`); `good_finalW`, `good_finalEW`, `good_exitW`.

The old containment in a distinct-answer list implies the new form (`goodLin_sub`, `FinalOk.of_sub`,
`FinalEOk.of_sub`, `ExitOk.of_sub`: the lists themselves are checked over the boxes). -/

/-- **An oracle among answers that `goodLin` decides is decided by it.** -/
theorem goodLin_sub {ps : List Lin.Prm} {V : List (Nat × Lin.Aff)} {D o : List Ans} (hD : Lin.goodLin ps V D = true)
    (h : o.all (fun q => D.contains q) = true) : Lin.goodLin ps V o = true := by
  unfold Lin.goodLin at hD ⊢
  simp only [List.all_eq_true, List.contains_iff_mem] at hD h ⊢
  exact fun q hq => hD q (h q hq)

/-! ## The loop classes -/

section Loop
variable {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {L i nx : Nat} {o : List Ans}

/-- `ORDINARY`'s box decides the oracle at any prompt length. -/
theorem good_ordW (hc : Lin.goodLin Lin.ordLB Lin.ordLV o = true) (hrem : i % 256 ≠ 0) (hs0 : (L + i + 1) % 256 ≠ 0)
    (hs1 : (L + i + 1) % 256 ≠ 255) (hT : i + 2 < T) (hp : L + i + 1 < 2 ^ 30) (hTb : T < 2 ^ 30)
    (htok : tk (i + 1) ≠ 248044) (ht : tk (i + 1) < 2 ^ 32) : Good (valL ρ T tk L i nx) o :=
  Lin.goodLin_sound hc
    (x := Lin.vx [(i : Int) / 256, (i : Int) % 256, ((L + i + 1 : Nat) : Int) / 256, ((L + i + 1 : Nat) : Int) % 256,
      (T : Int) - i - 3, tk (i + 1)])
    (by lin_mem [Lin.ordLB, Lin.tokB]) (by lin_mem [Lin.ordLV, valL, capL])

/-- `CLEAR`'s box. -/
theorem good_clearW (hc : Lin.goodLin Lin.clearLB Lin.clearLV o = true) (hi1 : 1 ≤ i) (hrem : i % 256 = 0)
    (hs0 : (L + i + 1) % 256 ≠ 0) (hs1 : (L + i + 1) % 256 ≠ 255) (hT : i + 2 < T) (hp : L + i + 1 < 2 ^ 30)
    (hTb : T < 2 ^ 30) (htok : tk (i + 1) ≠ 248044) (ht : tk (i + 1) < 2 ^ 32) : Good (valL ρ T tk L i nx) o :=
  Lin.goodLin_sound hc
    (x := Lin.vx [(i : Int) / 256, ((L + i + 1 : Nat) : Int) / 256, ((L + i + 1 : Nat) : Int) % 256,
      (T : Int) - i - 3, tk (i + 1)])
    (by lin_mem [Lin.clearLB, Lin.tokB]) (by lin_mem [Lin.clearLV, valL, capL])

/-- `GROWTH`'s box. -/
theorem good_growW (hc : Lin.goodLin Lin.growLB Lin.growLV o = true) (hrem : i % 256 ≠ 0) (hs : (L + i + 1) % 256 = 0)
    (hT : i + 2 < T) (hp : L + i + 1 < 2 ^ 30) (hTb : T < 2 ^ 30) (htok : tk (i + 1) ≠ 248044)
    (ht : tk (i + 1) < 2 ^ 32) : Good (valL ρ T tk L i nx) o :=
  Lin.goodLin_sound hc
    (x := Lin.vx [(i : Int) / 256, (i : Int) % 256, ((L + i + 1 : Nat) : Int) / 256, (T : Int) - i - 3, tk (i + 1)])
    (by lin_mem [Lin.growLB, Lin.tokB]) (by lin_mem [Lin.growLV, valL, capL])

/-- `FILL`'s box. -/
theorem good_fillW (hc : Lin.goodLin Lin.fillLB Lin.fillLV o = true) (hrem : i % 256 ≠ 0) (hs : (L + i + 1) % 256 = 255)
    (hT : i + 2 < T) (hp : L + i + 1 < 2 ^ 30) (hTb : T < 2 ^ 30) (htok : tk (i + 1) ≠ 248044)
    (ht : tk (i + 1) < 2 ^ 32) : Good (valL ρ T tk L i nx) o :=
  Lin.goodLin_sound hc
    (x := Lin.vx [(i : Int) / 256, (i : Int) % 256, ((L + i + 1 : Nat) : Int) / 256, (T : Int) - i - 3, tk (i + 1)])
    (by lin_mem [Lin.fillLB, Lin.tokB]) (by lin_mem [Lin.fillLV, valL, capL])

/-- `CLEARFILL`'s box. -/
theorem good_clearFillW (hc : Lin.goodLin Lin.clearFillLB Lin.clearFillLV o = true) (hi1 : 1 ≤ i)
    (hrem : i % 256 = 0) (hs : (L + i + 1) % 256 = 255) (hT : i + 2 < T) (hp : L + i + 1 < 2 ^ 30)
    (hTb : T < 2 ^ 30) (htok : tk (i + 1) ≠ 248044) (ht : tk (i + 1) < 2 ^ 32) : Good (valL ρ T tk L i nx) o :=
  Lin.goodLin_sound hc
    (x := Lin.vx [(i : Int) / 256, ((L + i + 1 : Nat) : Int) / 256, (T : Int) - i - 3, tk (i + 1)])
    (by lin_mem [Lin.clearFillLB, Lin.tokB]) (by lin_mem [Lin.clearFillLV, valL, capL])

/-- `CLEARGROWTH`'s box. -/
theorem good_clearGrowW (hc : Lin.goodLin Lin.clearGrowLB Lin.clearGrowLV o = true) (hi1 : 1 ≤ i)
    (hrem : i % 256 = 0) (hs : (L + i + 1) % 256 = 0) (hT : i + 2 < T) (hp : L + i + 1 < 2 ^ 30)
    (hTb : T < 2 ^ 30) (htok : tk (i + 1) ≠ 248044) (ht : tk (i + 1) < 2 ^ 32) : Good (valL ρ T tk L i nx) o :=
  Lin.goodLin_sound hc
    (x := Lin.vx [(i : Int) / 256, ((L + i + 1 : Nat) : Int) / 256, (T : Int) - i - 3, tk (i + 1)])
    (by lin_mem [Lin.clearGrowLB, Lin.tokB]) (by lin_mem [Lin.clearGrowLV, valL, capL])

end Loop

/-! ## The final and EOS boxes -/

namespace Lin

/-- The residue rows of `i = 256 a + r`: `r ∈ [1, 254]`, `r ∈ [1, 255]`, `r = 0` with `a ≥ 1`,
`r = 255` (a fixed residue is a constant of the form, so remainders split exactly). -/
inductive IRes where
  | mid
  | pos
  | zero
  | top

def IRes.a : IRes → Prm
  | .zero => ⟨1, 4194304, []⟩
  | _ => ⟨0, 4194304, []⟩

def IRes.r : IRes → Prm
  | .mid => ⟨1, 254, []⟩
  | .pos => ⟨1, 255, []⟩
  | _ => ⟨0, 0, []⟩

def IRes.f : IRes → Aff
  | .mid => 256 • P 0 + P 1
  | .pos => 256 • P 0 + P 1
  | .zero => 256 • P 0
  | .top => 256 • P 0 + 255

/-- The capacity rows of `p = 256 b + s`: `s ∈ [1, 255]` (capacity `256 b + 256`), or `s = 0` with
`b ≥ 1` (`cz`, capacity `256 b`). -/
def pBox : Bool → Prm
  | true => ⟨1, 4194304, []⟩
  | false => ⟨0, 4194304, []⟩

def sBox : Bool → Prm
  | true => ⟨0, 0, []⟩
  | false => ⟨1, 255, []⟩

def pF : Bool → Aff
  | true => 256 • P 2
  | false => 256 • P 2 + P 3

def capF : Bool → Aff
  | true => 256 • P 2
  | false => 256 • P 2 + 256

/-- The look-ahead token: not EOS (a parameter), or EOS. -/
def nxBox : Bool → Prm
  | true => ⟨0, 0, []⟩
  | false => tokB

def nxF : Bool → Aff
  | true => 248044
  | false => P 5

/-- **The final iteration's box** (`i = T - 2`): residue row `ir`, capacity row `cz`, the look-ahead
token EOS (`ex`) or not. Parameters `a, r, b, s, tok, nx`. -/
def finB (ir : IRes) (cz ex : Bool) : List Prm := [ir.a, ir.r, pBox cz, sBox cz, tokB, nxBox ex]

def finV (ir : IRes) (cz ex : Bool) : List (Nat × Aff) :=
  [(0, ir.f + 2), (9, pF cz), (10, ir.f), (11, ir.f), (12, ir.f), (13, ir.f - 1), (14, P 4), (16, capF cz),
   (17, nxF ex)]

/-- **The EOS exit's box** at the cut of iteration `i` (`T = i + 2 + t`, the cut's token EOS):
parameters `a, r, b, s, t, nx`. -/
def exitB (ir : IRes) (cz : Bool) : List Prm := [ir.a, ir.r, pBox cz, sBox cz, ⟨0, 1073741824, []⟩, ⟨0, 1048576, []⟩]

def exitV (ir : IRes) (cz : Bool) : List (Nat × Aff) :=
  [(0, ir.f + P 4 + 2), (9, pF cz), (10, ir.f), (11, ir.f), (12, ir.f), (13, ir.f - 1), (14, 248044),
   (16, capF cz), (17, P 5)]

/-- The EOS final iteration's residue row by its cache-clear test. -/
def eosRes : Bool → IRes
  | true => .zero
  | false => .pos

/-- The final iteration's residue row by its cache-clear tests. -/
def finRes : Bool → Bool → IRes
  | true, _ => .zero
  | false, true => .top
  | false, false => .mid

end Lin

open Lin in
/-- **The final chain's oracle over its class** (its cache-clear tests `r3`, `r7`; the look-ahead
token not EOS): `goodLin` decides it over both capacity rows. -/
def FinalOk (r3 r7 : Bool) (o : List Ans) : Prop :=
  goodLin (finB (finRes r3 r7) false false) (finV (finRes r3 r7) false false) o = true ∧
    goodLin (finB (finRes r3 r7) true false) (finV (finRes r3 r7) true false) o = true

open Lin in
/-- **The EOS final chain's oracle over its class** (the cache-clear test `r3`; the look-ahead token
EOS). -/
def FinalEOk (r3 : Bool) (o : List Ans) : Prop :=
  goodLin (finB (eosRes r3) false true) (finV (eosRes r3) false true) o = true ∧
    goodLin (finB (eosRes r3) true true) (finV (eosRes r3) true true) o = true

open Lin in
/-- **The EOS exit's oracle over its class** (every residue of `i ≥ 1`, both capacity rows). -/
def ExitOk (o : List Ans) : Prop :=
  goodLin (exitB .pos false) (exitV .pos false) o = true ∧ goodLin (exitB .pos true) (exitV .pos true) o = true ∧
    goodLin (exitB .zero false) (exitV .zero false) o = true ∧ goodLin (exitB .zero true) (exitV .zero true) o = true

section Halts
variable {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {L i nx : Nat} {o : List Ans}
open Lin

/-- **The final iteration's oracle at any prompt length** from its boxes. -/
theorem good_finalW {r3 r7 : Bool} (hc : FinalOk r3 r7 o) (hi1 : 1 ≤ i) (hT : T = i + 2)
    (htok : tk (i + 1) ≠ 248044) (hnext : nx ≠ 248044) (hp : L + i + 1 < 2 ^ 30) (ht : tk (i + 1) < 2 ^ 32)
    (hn : nx < 2 ^ 32) (h3 : decide (i % 256 = 0) = r3) (h7 : decide ((i + 1) % 256 = 0) = r7) :
    Good (valL ρ T tk L i nx) o := by
  subst hT h3 h7
  by_cases hz : i % 256 = 0
  · have e3 : decide (i % 256 = 0) = true := decide_eq_true hz
    rw [e3] at hc
    by_cases hcz : (L + i + 1) % 256 = 0
    · exact goodLin_sound hc.2 (x := vx [(i : Int) / 256, 0, ((L + i + 1 : Nat) : Int) / 256, 0, tk (i + 1), nx])
        (by lin_mem [finB, finRes, IRes.a, IRes.r, pBox, sBox, nxBox, tokB])
        (by lin_mem [finV, finRes, IRes.f, pF, capF, nxF, valL, capL])
    · exact goodLin_sound hc.1 (x := vx [(i : Int) / 256, 0, ((L + i + 1 : Nat) : Int) / 256,
          ((L + i + 1 : Nat) : Int) % 256, tk (i + 1), nx])
        (by lin_mem [finB, finRes, IRes.a, IRes.r, pBox, sBox, nxBox, tokB])
        (by lin_mem [finV, finRes, IRes.f, pF, capF, nxF, valL, capL])
  · have e3 : decide (i % 256 = 0) = false := decide_eq_false hz
    rw [e3] at hc
    by_cases h255 : (i + 1) % 256 = 0
    · have e7 : decide ((i + 1) % 256 = 0) = true := decide_eq_true h255
      rw [e7] at hc
      by_cases hcz : (L + i + 1) % 256 = 0
      · exact goodLin_sound hc.2 (x := vx [(i : Int) / 256, 0, ((L + i + 1 : Nat) : Int) / 256, 0, tk (i + 1), nx])
          (by lin_mem [finB, finRes, IRes.a, IRes.r, pBox, sBox, nxBox, tokB])
          (by lin_mem [finV, finRes, IRes.f, pF, capF, nxF, valL, capL])
      · exact goodLin_sound hc.1 (x := vx [(i : Int) / 256, 0, ((L + i + 1 : Nat) : Int) / 256,
            ((L + i + 1 : Nat) : Int) % 256, tk (i + 1), nx])
          (by lin_mem [finB, finRes, IRes.a, IRes.r, pBox, sBox, nxBox, tokB])
          (by lin_mem [finV, finRes, IRes.f, pF, capF, nxF, valL, capL])
    · have e7 : decide ((i + 1) % 256 = 0) = false := decide_eq_false h255
      rw [e7] at hc
      by_cases hcz : (L + i + 1) % 256 = 0
      · exact goodLin_sound hc.2 (x := vx [(i : Int) / 256, (i : Int) % 256, ((L + i + 1 : Nat) : Int) / 256, 0,
            tk (i + 1), nx])
          (by lin_mem [finB, finRes, IRes.a, IRes.r, pBox, sBox, nxBox, tokB])
          (by lin_mem [finV, finRes, IRes.f, pF, capF, nxF, valL, capL])
      · exact goodLin_sound hc.1 (x := vx [(i : Int) / 256, (i : Int) % 256, ((L + i + 1 : Nat) : Int) / 256,
            ((L + i + 1 : Nat) : Int) % 256, tk (i + 1), nx])
          (by lin_mem [finB, finRes, IRes.a, IRes.r, pBox, sBox, nxBox, tokB])
          (by lin_mem [finV, finRes, IRes.f, pF, capF, nxF, valL, capL])

/-- **The EOS final iteration's oracle at any prompt length** from its boxes. -/
theorem good_finalEW {r3 : Bool} (hc : FinalEOk r3 o) (hi1 : 1 ≤ i) (hT : T = i + 2)
    (htok : tk (i + 1) ≠ 248044) (hnext : nx = 248044) (hp : L + i + 1 < 2 ^ 30) (ht : tk (i + 1) < 2 ^ 32)
    (h3 : decide (i % 256 = 0) = r3) : Good (valL ρ T tk L i nx) o := by
  subst hT h3 hnext
  by_cases hz : i % 256 = 0
  · have e3 : decide (i % 256 = 0) = true := decide_eq_true hz
    rw [e3] at hc
    by_cases hcz : (L + i + 1) % 256 = 0
    · exact goodLin_sound hc.2 (x := vx [(i : Int) / 256, 0, ((L + i + 1 : Nat) : Int) / 256, 0, tk (i + 1), 0])
        (by lin_mem [finB, eosRes, IRes.a, IRes.r, pBox, sBox, nxBox, tokB])
        (by lin_mem [finV, eosRes, IRes.f, pF, capF, nxF, valL, capL])
    · exact goodLin_sound hc.1 (x := vx [(i : Int) / 256, 0, ((L + i + 1 : Nat) : Int) / 256,
          ((L + i + 1 : Nat) : Int) % 256, tk (i + 1), 0])
        (by lin_mem [finB, eosRes, IRes.a, IRes.r, pBox, sBox, nxBox, tokB])
        (by lin_mem [finV, eosRes, IRes.f, pF, capF, nxF, valL, capL])
  · have e3 : decide (i % 256 = 0) = false := decide_eq_false hz
    rw [e3] at hc
    by_cases hcz : (L + i + 1) % 256 = 0
    · exact goodLin_sound hc.2 (x := vx [(i : Int) / 256, (i : Int) % 256, ((L + i + 1 : Nat) : Int) / 256, 0,
          tk (i + 1), 0])
        (by lin_mem [finB, eosRes, IRes.a, IRes.r, pBox, sBox, nxBox, tokB])
        (by lin_mem [finV, eosRes, IRes.f, pF, capF, nxF, valL, capL])
    · exact goodLin_sound hc.1 (x := vx [(i : Int) / 256, (i : Int) % 256, ((L + i + 1 : Nat) : Int) / 256,
          ((L + i + 1 : Nat) : Int) % 256, tk (i + 1), 0])
        (by lin_mem [finB, eosRes, IRes.a, IRes.r, pBox, sBox, nxBox, tokB])
        (by lin_mem [finV, eosRes, IRes.f, pF, capF, nxF, valL, capL])

/-- **The EOS exit's oracle at the cut of iteration `i`** from its boxes. -/
theorem good_exitW (hc : ExitOk o) (hi1 : 1 ≤ i) (hT : i + 2 ≤ T) (htok : tk (i + 1) = 248044)
    (hnx : nx ≤ 2 ^ 20) (hp : L + i + 1 < 2 ^ 30) (hTb : T < 2 ^ 30) : Good (valL ρ T tk L i nx) o := by
  by_cases hz : i % 256 = 0
  · by_cases hcz : (L + i + 1) % 256 = 0
    · exact goodLin_sound hc.2.2.2 (x := vx [(i : Int) / 256, 0, ((L + i + 1 : Nat) : Int) / 256, 0,
          (T : Int) - i - 2, nx])
        (by lin_mem [exitB, IRes.a, IRes.r, pBox, sBox])
        (by lin_mem [exitV, IRes.f, pF, capF, valL, capL, htok])
    · exact goodLin_sound hc.2.2.1 (x := vx [(i : Int) / 256, 0, ((L + i + 1 : Nat) : Int) / 256,
          ((L + i + 1 : Nat) : Int) % 256, (T : Int) - i - 2, nx])
        (by lin_mem [exitB, IRes.a, IRes.r, pBox, sBox])
        (by lin_mem [exitV, IRes.f, pF, capF, valL, capL, htok])
  · by_cases hcz : (L + i + 1) % 256 = 0
    · exact goodLin_sound hc.2.1 (x := vx [(i : Int) / 256, (i : Int) % 256, ((L + i + 1 : Nat) : Int) / 256, 0,
          (T : Int) - i - 2, nx])
        (by lin_mem [exitB, IRes.a, IRes.r, pBox, sBox])
        (by lin_mem [exitV, IRes.f, pF, capF, valL, capL, htok])
    · exact goodLin_sound hc.1 (x := vx [(i : Int) / 256, (i : Int) % 256, ((L + i + 1 : Nat) : Int) / 256,
          ((L + i + 1 : Nat) : Int) % 256, (T : Int) - i - 2, nx])
        (by lin_mem [exitB, IRes.a, IRes.r, pBox, sBox])
        (by lin_mem [exitV, IRes.f, pF, capF, valL, capL, htok])

end Halts

/-! ## The distinct-answer lists over the boxes -/

namespace Lin

theorem fin00_check : FinalOk false false (finalDG false false) := by unfold FinalOk; decide +kernel
theorem fin10_check : FinalOk true false (finalDG true false) := by unfold FinalOk; decide +kernel
theorem fin01_check : FinalOk false true (finalDG false true) := by unfold FinalOk; decide +kernel
theorem finE0_check : FinalEOk false (finalEDG false) := by unfold FinalEOk; decide +kernel
theorem finE1_check : FinalEOk true (finalEDG true) := by unfold FinalEOk; decide +kernel
theorem exit_check : ExitOk eosD := by unfold ExitOk; decide +kernel

end Lin

/-- **The old containment implies the new form** (the final chains). -/
theorem FinalOk.of_sub {r3 r7 : Bool} {o : List Ans} (hD : FinalOk r3 r7 (finalDG r3 r7))
    (h : o.all (fun q => (finalDG r3 r7).contains q) = true) : FinalOk r3 r7 o :=
  ⟨goodLin_sub hD.1 h, goodLin_sub hD.2 h⟩

theorem FinalEOk.of_sub {r3 : Bool} {o : List Ans} (hD : FinalEOk r3 (finalEDG r3))
    (h : o.all (fun q => (finalEDG r3).contains q) = true) : FinalEOk r3 o :=
  ⟨goodLin_sub hD.1 h, goodLin_sub hD.2 h⟩

theorem ExitOk.of_sub {o : List Ans} (h : o.all (fun q => eosD.contains q) = true) : ExitOk o :=
  ⟨goodLin_sub Lin.exit_check.1 h, goodLin_sub Lin.exit_check.2.1 h, goodLin_sub Lin.exit_check.2.2.1 h,
    goodLin_sub Lin.exit_check.2.2.2 h⟩

end Host.Ts.Sim
