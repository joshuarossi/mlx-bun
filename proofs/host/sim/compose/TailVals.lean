import host.sim.compose.PostCut
import host.sim.LoopArith
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Run.Tpl

/-! # What a link's map gives the tail's variables

The tail's book holds the row's dimensions and the hand-off's values, and the map must keep the valuation in the loop's box. A variable's
image is a literal, a variable, or the one sum the trace counter's image is. -/

/-- A checked variable's image: the literal it must hold. -/
def litAt (θ : Nat → SymE) (v k : Nat) : Bool :=
  match θ v with
  | .lit f => f == F64.ofNat k
  | _ => false

theorem litAt_eval {θ : Nat → SymE} {v k : Nat} (h : litAt θ v k = true) (ν : Nat → F64) :
    Shift.valuation θ ν v = F64.ofNat k := by
  unfold litAt at h
  cases e : θ v with
  | lit f =>
    rw [e] at h
    have hf : f = F64.ofNat k := beq_iff_eq.mp h
    change (θ v).eval ν = _
    rw [e, hf]
    rfl
  | _ => rw [e] at h; cases h

/-- The tail's dimensions all image to literals. -/
def dimsLitB (θ : Nat → SymE) : Bool :=
  (List.range 257).all fun v =>
    match tailVal v with
    | some k => litAt θ v k
    | none => true

theorem tailVal_lt {v k : Nat} (h : tailVal v = some k) : v < 257 := by
  by_cases h1 : v < 257
  · exact h1
  · exfalso
    unfold tailVal at h
    have h2 : Nat.ble v 248 = false := by
      cases e : Nat.ble v 248 with
      | false => rfl
      | true => have := Nat.le_of_ble_eq_true e; omega
    have h3 : Nat.ble v 255 = false := by
      cases e : Nat.ble v 255 with
      | false => rfl
      | true => have := Nat.le_of_ble_eq_true e; omega
    have h4 : Nat.beq v 256 = false := by
      cases e : Nat.beq v 256 with
      | false => rfl
      | true => have := Nat.eq_of_beq_eq_true e; omega
    simp [h2, h3, h4] at h

theorem dimsLit {θ : Nat → SymE} (h : dimsLitB θ = true) (ν : Nat → F64) : tail.dims (Shift.valuation θ ν) := by
  intro v k hv
  have hc := List.all_eq_true.mp h v (List.mem_range.mpr (tailVal_lt hv))
  simp only [hv] at hc
  exact litAt_eval hc ν

/-- An image in the loop's box whatever the valuation in it: a variable, or a small literal of those listed. -/
def imgSmall (cand : List Nat) : SymE → Bool
  | .var _ => true
  | .lit f => cand.any fun n => Nat.ble n (2 ^ 20) && f == F64.ofNat n
  | _ => false

theorem imgSmall_sound {cand : List Nat} {ν : Nat → F64} (hv : VBOkF loopVB ν) {e : SymE} (h : imgSmall cand e = true) :
    ∃ n ≤ 2 ^ 20, e.eval ν = F64.ofNat n := by
  cases e with
  | var j => exact hv j
  | lit f =>
    obtain ⟨n, -, hn⟩ := List.any_eq_true.mp h
    simp only [Bool.and_eq_true] at hn
    exact ⟨n, Nat.le_of_ble_eq_true hn.1, beq_iff_eq.mp hn.2⟩
  | bin _ _ _ => cases h
  | un _ _ => cases h

/-- The valuation stays in the box: each key's image is small, but the listed few that are shown otherwise. -/
theorem valOf {θ : Nat → SymE} {ν : Nat → F64} {cand keys off : List Nat} (hv : VBOkF loopVB ν)
    (hoff : ∀ j, j ∉ keys → θ j = .var j)
    (hk : (keys.all fun j => off.contains j || imgSmall cand (θ j)) = true)
    (ho : ∀ j ∈ off, ∃ n ≤ 2 ^ 20, (θ j).eval ν = F64.ofNat n) : VBOkF loopVB (Shift.valuation θ ν) := by
  intro j
  change ∃ n ≤ 2 ^ 20, (θ j).eval ν = F64.ofNat n
  by_cases hj : j ∈ keys
  · have hc := List.all_eq_true.mp hk j hj
    cases hc' : off.contains j with
    | true => exact ho j (List.contains_iff_mem.mp hc')
    | false =>
      rw [hc', Bool.false_or] at hc
      exact imgSmall_sound hv hc
  · rw [hoff j hj]
    exact hv j

/-- The hand-off's values of a short row, a pair each. -/
def shortVals : List (Nat × Nat) := [(20, 6), (22, 4), (23, 5), (24, 4), (25, 5), (26, 1), (200, 5)]

theorem handVal_short {L v k : Nat} (hL : L ≤ 2) (h : handVal L v = some k) : (v, k) ∈ shortVals := by
  have hb : Nat.ble L 2 = true := Nat.ble_eq_true_of_le hL
  unfold handVal at h
  rw [hb] at h
  simp only [cond_true] at h
  split at h <;> first
    | (cases h; simp [shortVals])
    | cases h

/-- What a short row's class holds on entering POST: the variables the tail's images read. -/
structure ShortVals (ν : Nat → F64) : Prop where
  v21 : ν 21 = F64.ofNat 4
  v22 : ν 22 = F64.ofNat 4
  v24 : ν 24 = F64.ofNat 4
  v26 : ν 26 = F64.ofNat 1

/-- A short row's link: where the hand-off's variables go. -/
structure ShortImg (θ : Nat → SymE) : Prop where
  i20 : litAt θ 20 6 = true
  i22 : θ 22 = .var 22
  i23 : litAt θ 23 5 = true
  i24 : θ 24 = .var 24
  i25 : litAt θ 25 5 = true
  i26 : θ 26 = .var 26
  i200 : θ 200 = .bin .add (.var 21) (.lit (F64.ofNat 1))

theorem ShortImg.v200 {θ : Nat → SymE} {ν : Nat → F64} (i : ShortImg θ) (h : ShortVals ν) :
    (θ 200).eval ν = F64.ofNat 5 := by
  rw [i.i200]
  change F64.bin .add (ν 21) (F64.ofNat 1) = _
  rw [h.v21]
  exact bin_add_ofNat 4 1 (by omega)

theorem handShort {θ : Nat → SymE} {ν : Nat → F64} {L : Nat} (hL : L ≤ 2) (i : ShortImg θ) (h : ShortVals ν) :
    tail.hand L (Shift.valuation θ ν) := by
  intro v k hv
  have hm := handVal_short hL hv
  simp only [shortVals, List.mem_cons, List.not_mem_nil, or_false, Prod.mk.injEq] at hm
  rcases hm with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · exact litAt_eval i.i20 ν
  · change (θ 22).eval ν = _
    rw [i.i22]
    exact h.v22
  · exact litAt_eval i.i23 ν
  · change (θ 24).eval ν = _
    rw [i.i24]
    exact h.v24
  · exact litAt_eval i.i25 ν
  · change (θ 26).eval ν = _
    rw [i.i26]
    exact h.v26
  · exact i.v200 h

end Host.Ts.Sim.Compose.Post
