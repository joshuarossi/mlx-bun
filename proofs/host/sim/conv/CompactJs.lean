import host.sim.conv.Compact
import host.sim.BigJsRel
import host.sim.template.Sigma

namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim

/-- With no result addresses, a growing compaction moves exactly the addresses at or above
`n0`. When its bigint map fixes JS pointer integers, those are exactly the bad JS pointers. -/
theorem jsShiftBadB_compact_nil {n0 n1 nS : Nat} {nr : List NumV} {big : Int → Int}
    {region node : Nat → Nat} (hn : n0 < n1)
    (hbig : ∀ i, jsPtrOf i ≠ none → big i = i) (i : Int) :
    jsShiftBadB (Map.compact n0 n1 nS [] nr big region node) i =
      match jsPtrOf i with
      | some (b, _) => decide (n0 ≤ b)
      | none => false := by
  unfold jsShiftBadB
  cases hp : jsPtrOf i with
  | none => rfl
  | some p =>
    obtain ⟨b, off⟩ := p
    obtain ⟨hi, hb, _⟩ := jsPtrOf_some hp
    have hfix := hbig i (by rw [hp]; exact Option.some_ne_none _)
    change (!(decide (big i = ptrInt (.js ((Map.compact n0 n1 nS [] nr big region node).a b)) off) &&
      Nat.blt ((Map.compact n0 n1 nS [] nr big region node).a b) 536870912)) = decide (n0 ≤ b)
    rw [hfix, hi]
    by_cases hbn : b < n0
    · rw [Map.compact_lt hbn]
      have hb' : Nat.blt b 536870912 = true := Nat.blt_eq.mpr hb
      simp [hb', show ¬ n0 ≤ b by omega]
    · have ha : (Map.compact n0 n1 nS [] nr big region node).a b = n1 + (b - n0) := by
        simp [Map.compact, hbn]
      have hne : ptrInt (.js b) off ≠ ptrInt (.js (n1 + (b - n0))) off := by
        simp only [ptrInt_js, jsBase, jsOff]
        omega
      rw [ha]
      simp [hne, show n0 ≤ b by omega]

/-- The JS pointer check is independent of the growing return counter, number map, native
regions and nodes when there are no result addresses and both bigint maps fix the JS band. -/
theorem jsShiftBadB_compact_nil_eq {n0 n1 n2 nS1 nS2 : Nat} {nr1 nr2 : List NumV}
    {big1 big2 : Int → Int} {region1 region2 node1 node2 : Nat → Nat}
    (hn1 : n0 < n1) (hn2 : n0 < n2)
    (hb1 : ∀ i, jsPtrOf i ≠ none → big1 i = i)
    (hb2 : ∀ i, jsPtrOf i ≠ none → big2 i = i) :
    jsShiftBadB (Map.compact n0 n1 nS1 [] nr1 big1 region1 node1) =
      jsShiftBadB (Map.compact n0 n2 nS2 [] nr2 big2 region2 node2) := by
  funext i
  rw [jsShiftBadB_compact_nil hn1 hb1, jsShiftBadB_compact_nil hn2 hb2]

/-- Every explicit native renaming fixes the JS pointer band. -/
theorem rdata_big_js (D : Template.RData) (i : Int) (hi : jsPtrOf i ≠ none) : D.big i = i := by
  cases hp : jsPtrOf i with
  | none => exact (hi hp).elim
  | some p =>
    obtain ⟨b, off⟩ := p
    obtain ⟨hlo, hhi⟩ := jsPtrOf_ge hp
    cases i with
    | negSucc _ => simp [jsPtrOf] at hp
    | ofNat k =>
      simp only [Int.ofNat_eq_natCast] at hlo hhi
      have hk : 131072 ≤ k ∧ k < 2 ^ 62 := by omega
      simp only [Template.RData.big, Template.RData.bigN, Template.RData.bigHi,
        Template.RData.ble_false hk.2, Bool.cond_false]
      rw [show Nat.blt k 131072 = false from by rw [Bool.eq_false_iff, ne_eq, Nat.blt_eq]; omega]
      rfl

/-- Compactions built from explicit native renamings share the check solely from their common
address prefix and empty result-address list. -/
theorem jsShiftBadB_compact_nil_rdata_eq {n0 n1 n2 nS1 nS2 : Nat} {nr1 nr2 : List NumV}
    (D1 D2 : Template.RData) {region1 region2 node1 node2 : Nat → Nat}
    (hn1 : n0 < n1) (hn2 : n0 < n2) :
    jsShiftBadB (Map.compact n0 n1 nS1 [] nr1 D1.big region1 node1) =
      jsShiftBadB (Map.compact n0 n2 nS2 [] nr2 D2.big region2 node2) :=
  jsShiftBadB_compact_nil_eq hn1 hn2 (rdata_big_js D1) (rdata_big_js D2)

end Host.Ts.Sim.Conv
