import host.simgraph.prompt.Normalize
namespace Host.Mlx.SimGraph
open Host.Ts Host.Ts.Sim.Lin

/-! # The normalizer with exact quotients

The forward's row counts are computed by the array shapes' arithmetic: `(1·(n·5120))/5120`. `normP` leaves a quotient
for `Math.floor`/`Math.ceil` to consume, so such an entry has no normal form. `normX` is `normP` where a quotient by a
divisor of every coefficient is the integer quotient (`Sim.Lin.div_ie`). It is a layer: `normP` stays as the decode
templates read it. `clsOfX`, `clsOfX_sound`: the classifier at `normX`. -/

/-- The candidate quotient by `k`. -/
def divCand (k : Nat) : PDim → PDim
  | .lit i => .lit (i / (k : Int))
  | .lin c ts => Aff.toP ⟨c / (k : Int), ts.map fun t => (t.1 / (k : Int), t.2)⟩
  | other => other

/-- The exact quotient by `k`, checked by scaling back. -/
def divExactP (k : Nat) (d : PDim) : Option PDim :=
  if scaleP k (divCand k d) = some d then some (divCand k d) else none

theorem divExactP_eval (ν : Nat → Int) {k : Nat} (hk : 0 < k) {d r : PDim} (h : divExactP k d = some r) :
    d.eval ν = (k : Int) * r.eval ν := by
  unfold divExactP at h
  by_cases hs : scaleP k (divCand k d) = some d
  · rw [ite_eq_left hs] at h
    cases h
    exact scaleP_eval ν hk hs
  · rw [ite_eq_right hs] at h
    cases h

/-- `normR`, with the exact quotient. -/
def normRX (B : Box) : SymE → Option NormR
  | .lit x => (litP x).map .int
  | .var x => (ok B (PDim.var x)).map .int
  | .bin op a b =>
    match op, normRX B a, normRX B b with
    | .add, some (.int x), some (.int y) => (addP x y).bind (ok B) |>.map .int
    | .sub, some (.int x), some (.int y) => (subP x y).bind (ok B) |>.map .int
    | .mul, some (.int x), some (.int y) => (mulP x y).bind (ok B) |>.map .int
    | .div, some (.int x), some (.int y) =>
      (posLit? y).bind fun k => match divExactP k x with
        | some r => (ok B r).map .int
        | none => if nonneg B x then some (.quot x k) else none
    | _, _, _ => none
  | .un op a =>
    match op, normRX B a with
    | .int32, some (.int d) => if in32 B d then some (.int d) else none
    | .floor, some (.int d) => some (.int d)
    | .ceil, some (.int d) => some (.int d)
    | .trunc, some (.int d) => some (.int d)
    | .floor, some (.quot d k) => (ok B (.fdiv d k)).map .int
    | .ceil, some (.quot d k) => (ok B (.cdiv d k)).map .int
    | _, _ => none

/-- A table entry as a dimension. -/
def normX (B : Box) (e : SymE) : Option PDim :=
  match normRX B e with
  | some (.int d) => some d
  | _ => none

section Sound
variable (B : Box) (ν : Nat → Int) (ρ : Nat → F64) (hB : InBox B ν)
  (hρ : ∀ x l h, B.get x = some (l, h) → ρ x = F64.ofInt (ν x))
include hB hρ

/-- **The normal form holds of the entry's value** (`normRX_sound`, with the exact quotient). -/
theorem normRX_sound : ∀ (e : SymE) (n : NormR), normRX B e = some n → n.Holds B ν (e.eval ρ)
  | .lit x, n, h => by
    obtain ⟨d, hd, rfl⟩ := Option.map_eq_some_iff.mp h
    exact litP_sound B ν hd
  | .var x, n, h => by
    obtain ⟨d, hd, rfl⟩ := Option.map_eq_some_iff.mp h
    exact var_sound B ν ρ hB hρ x hd
  | .bin op a b, n, h => by
    have iha := normRX_sound a
    have ihb := normRX_sound b
    simp only [normRX] at h
    split at h
    · rename_i x y ha hb
      obtain ⟨r, hr, rfl, hs⟩ := int_result B h
      obtain ⟨va, _⟩ := iha _ ha
      obtain ⟨vb, _⟩ := ihb _ hb
      have hbd := safe_bound hB hs
      have he := addP_eval ν hr
      refine ⟨?_, hs⟩
      simp only [SymE.eval, F64.bin, va, vb]
      rw [add_ie _ _ (by omega), he]
    · rename_i x y ha hb
      obtain ⟨r, hr, rfl, hs⟩ := int_result B h
      obtain ⟨va, _⟩ := iha _ ha
      obtain ⟨vb, _⟩ := ihb _ hb
      have hbd := safe_bound hB hs
      have he := subP_eval ν hr
      refine ⟨?_, hs⟩
      simp only [SymE.eval, F64.bin, va, vb]
      rw [sub_ie _ _ (by omega), he]
    · rename_i x y ha hb
      obtain ⟨r, hr, rfl, hs⟩ := int_result B h
      obtain ⟨va, _⟩ := iha _ ha
      obtain ⟨vb, _⟩ := ihb _ hb
      have hbd := safe_bound hB hs
      refine ⟨?_, hs⟩
      simp only [SymE.eval, F64.bin, va, vb]
      unfold mulP at hr
      split at hr
      · rename_i k hk
        obtain ⟨rfl, hk0⟩ := posLit_eval hk
        have he := scaleP_eval ν hk0 hr
        simp only [PDim.eval] at he ⊢
        rw [he] at hbd ⊢
        rw [mul_ie _ _ (by omega) (fun hz => by
          rcases Int.mul_eq_zero.mp hz with h0 | h0 <;> omega)]
      · split at hr
        · rename_i k _ hk
          obtain ⟨rfl, hk0⟩ := posLit_eval hk
          have he := scaleP_eval ν hk0 hr
          simp only [PDim.eval] at he ⊢
          rw [he] at hbd ⊢
          rw [mul_ie _ _ (by rw [Int.mul_comm]; omega) (fun hz => by
            rcases Int.mul_eq_zero.mp hz with h0 | h0 <;> omega), Int.mul_comm]
        · cases hr
    · rename_i x y ha hb
      obtain ⟨k, hk, hq⟩ := Option.bind_eq_some_iff.mp h
      obtain ⟨va, hsa⟩ := iha _ ha
      obtain ⟨vb, hsb⟩ := ihb _ hb
      obtain ⟨rfl, hk0⟩ := posLit_eval hk
      have hya := safe_bound hB hsa
      have hyb := safe_bound hB hsb
      simp only [PDim.eval] at hyb
      cases hx : divExactP k x with
      | some r =>
        rw [hx] at hq
        obtain ⟨r', hr', rfl⟩ := Option.map_eq_some_iff.mp hq
        obtain ⟨rfl, hs⟩ := ok_some hr'
        refine ⟨?_, hs⟩
        simp only [SymE.eval, F64.bin, va, vb, PDim.eval]
        exact div_ie _ _ _ (by omega) (divExactP_eval ν hk0 hx) (by omega)
      | none =>
        rw [hx] at hq
        dsimp only at hq
        split at hq
        · rename_i hn
          cases hq
          have hn' := nonneg_bound hB hn
          refine ⟨?_, hn', by omega, hk0, by omega⟩
          simp only [SymE.eval, F64.bin, va, vb, PDim.eval]
        · cases hq
    · cases h
  | .un op a, n, h => by
    have iha := normRX_sound a
    simp only [normRX] at h
    split at h
    · rename_i d ha
      split at h
      · rename_i h32
        cases h
        obtain ⟨va, hs⟩ := iha _ ha
        have := in32_bound hB h32
        refine ⟨?_, hs⟩
        simp only [SymE.eval, va]
        rw [int32_ie]
        congr 1
        omega
      · cases h
    · rename_i d ha
      cases h
      obtain ⟨va, hs⟩ := iha _ ha
      exact ⟨by simp only [SymE.eval, F64.un, va, floor_ie], hs⟩
    · rename_i d ha
      cases h
      obtain ⟨va, hs⟩ := iha _ ha
      exact ⟨by simp only [SymE.eval, F64.un, va, ceil_ie], hs⟩
    · rename_i d ha
      cases h
      obtain ⟨va, hs⟩ := iha _ ha
      exact ⟨by simp only [SymE.eval, F64.un, va, trunc_ie], hs⟩
    · rename_i d k ha
      obtain ⟨r, hr, rfl⟩ := Option.map_eq_some_iff.mp h
      obtain ⟨rfl, hs⟩ := ok_some hr
      obtain ⟨va, h0, h1, hk0, hk1⟩ := iha _ ha
      refine ⟨?_, hs⟩
      simp only [SymE.eval, F64.un, va, PDim.eval]
      exact floor_div_ie _ _ h0 h1 (by omega) (by omega)
    · rename_i d k ha
      obtain ⟨r, hr, rfl⟩ := Option.map_eq_some_iff.mp h
      obtain ⟨rfl, hs⟩ := ok_some hr
      obtain ⟨va, h0, h1, hk0, hk1⟩ := iha _ ha
      refine ⟨?_, hs⟩
      simp only [SymE.eval, F64.un, va, PDim.eval, ceilDiv]
      exact ceil_div_ie _ _ h0 h1 (by omega) (by omega)
    · cases h

theorem normX_sound (e : SymE) (d : PDim) (h : normX B e = some d) : F64.toInt? (e.eval ρ) = some (d.eval ν) := by
  unfold normX at h
  split at h
  · rename_i d' he
    cases h
    obtain ⟨hv, _⟩ := normRX_sound B ν ρ hB hρ e _ he
    rw [hv, toInt_ie]
  · cases h

end Sound

/-- The classifier of table `S` over the box `B`, at `normX`. -/
def clsOfX (S : SSrv) (B : Box) : NumV → Option PDim
  | .lit f => (F64.toInt? f).map PDim.lit
  | .ref i => (nth? S.tab i).bind (normX B)

/-- **The classifier is sound** at every valuation in the box. -/
theorem clsOfX_sound (S : SSrv) (B : Box) (ν : Nat → Int) (ρ : Nat → F64) (hB : InBox B ν)
    (hρ : ∀ x l h, B.get x = some (l, h) → ρ x = F64.ofInt (ν x)) :
    ClsSoundD (clsOfX S B) (νsOf S ρ) (PDim.eval ν) := by
  intro x d hx
  cases x with
  | lit f =>
    obtain ⟨i, hi, rfl⟩ := Option.map_eq_some_iff.mp hx
    show (some f).bind F64.toInt? = some i
    exact hi
  | ref i =>
    obtain ⟨e, he, hd⟩ := Option.bind_eq_some_iff.mp hx
    show ((nth? S.tab i).map (SymE.eval ρ)).bind F64.toInt? = _
    rw [he]
    exact normX_sound B ν ρ hB hρ e d hd

end Host.Mlx.SimGraph
