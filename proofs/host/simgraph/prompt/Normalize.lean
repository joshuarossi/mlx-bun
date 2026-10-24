import host.simgraph.prompt.PDim
import host.sim.LinDiv
import host.simgraph.Classify
namespace Host.Mlx.SimGraph
open Host.Ts Host.Ts.Sim.Lin

/-! # Classifying a template's numbers as multi-parameter dimensions

The template is a symbolic run; its dimensions are table entries, expressions
over the run's symbolic positions. `normP B` is a checked normalizer from an
entry to a `PDim`: literals, positions, `+`, `-`, products with a positive
literal, `int32`, `Math.floor`/`Math.ceil` of a quotient by a positive literal
(and of an integer). Every intermediate value is checked, through
`PDim.range` over the box `B` bounding the positions, to stay an integer
below `2^53` (and `int32` arguments in the `int32` range), so the run's
binary64 arithmetic is the integer arithmetic (`Sim.LinExact`, `Sim.LinDiv`).

* `normP_sound`: at every valuation `ν` in the box (the positions' binary64
  values `ρ x = ofInt (ν x)`), the entry denotes the dimension's value:
  `toInt? (e.eval ρ) = some (d.eval ν)`.
* `clsOfP S B`: the classifier of table `S` (`clsOf` generalized);
  `ClsSoundD cls ν ev` is `ClsSound` at any dimension type (`clsSound_eq`);
  `clsOfP_sound`: `ClsSoundD (clsOfP S B) (νsOf S ρ) (PDim.eval ν)`.
* `normP_entryDim`: the decode classifier's entries normalize to their
  `SDim.toP` images, so today's offset dimensions embed. -/

/-- An integer's binary64 form reads back as the integer. -/
theorem toInt_ie (v : Int) : F64.toInt? (ie v) = some v := by
  by_cases h : v = 0
  · subst h; rfl
  · rw [ie_ne h]
    change some (bif decide (v < 0) then -((v.natAbs * 2 ^ 0 : Nat) : Int) else ((v.natAbs * 2 ^ 0 : Nat) : Int)) = _
    rcases Int.lt_or_gt_of_ne h with h' | h'
    · rw [decide_eq_true h']; simp only [Bool.cond_true, Nat.pow_zero, Nat.mul_one, Option.some.injEq]; omega
    · rw [decide_eq_false (by omega)]; simp only [Bool.cond_false, Nat.pow_zero, Nat.mul_one, Option.some.injEq]; omega

/-! ## Checks -/

/-- The dimension's range over `B` is within `(-2^53, 2^53)`. -/
def safe (B : Box) (d : PDim) : Bool :=
  match d.range B with
  | some r => decide (-(2 ^ 53) < r.1) && decide (r.2 < 2 ^ 53)
  | none => false

/-- The range is within `int32`. -/
def in32 (B : Box) (d : PDim) : Bool :=
  match d.range B with
  | some r => decide (-(2 ^ 31) ≤ r.1) && decide (r.2 < 2 ^ 31)
  | none => false

/-- The range is non-negative. -/
def nonneg (B : Box) (d : PDim) : Bool :=
  match d.range B with
  | some r => decide (0 ≤ r.1)
  | none => false

def ok (B : Box) (d : PDim) : Option PDim := if safe B d then some d else none

theorem safe_bound {B : Box} {ν : Nat → Int} (hB : InBox B ν) {d : PDim} (h : safe B d = true) :
    -(2 ^ 53) < d.eval ν ∧ d.eval ν < 2 ^ 53 := by
  unfold safe at h
  split at h
  · rename_i r hr
    simp only [Bool.and_eq_true, decide_eq_true_eq] at h
    have := d.range_sound B ν hB r.1 r.2 hr
    omega
  · cases h

theorem in32_bound {B : Box} {ν : Nat → Int} (hB : InBox B ν) {d : PDim} (h : in32 B d = true) :
    -(2 ^ 31) ≤ d.eval ν ∧ d.eval ν < 2 ^ 31 := by
  unfold in32 at h
  split at h
  · rename_i r hr
    simp only [Bool.and_eq_true, decide_eq_true_eq] at h
    have := d.range_sound B ν hB r.1 r.2 hr
    omega
  · cases h

theorem nonneg_bound {B : Box} {ν : Nat → Int} (hB : InBox B ν) {d : PDim} (h : nonneg B d = true) :
    0 ≤ d.eval ν := by
  unfold nonneg at h
  split at h
  · rename_i r hr
    simp only [decide_eq_true_eq] at h
    have := d.range_sound B ν hB r.1 r.2 hr
    omega
  · cases h

theorem ok_some {B : Box} {d r : PDim} (h : ok B d = some r) : r = d ∧ safe B d = true := by
  unfold ok at h
  split at h
  · rename_i hs; cases h; exact ⟨rfl, hs⟩
  · cases h

/-! ## Arithmetic on dimensions -/

def addP (a b : PDim) : Option PDim := do
  let x ← a.aff?
  let y ← b.aff?
  pure (x.add y).toP

def subP (a b : PDim) : Option PDim := do
  let x ← a.aff?
  let y ← b.aff?
  pure (x.sub y).toP

/-- A positive literal. -/
def posLit? : PDim → Option Nat
  | .lit i => if 0 < i then some i.toNat else none
  | _ => none

/-- `k·d` for a positive literal `k`: affine forms scale; `k·⌊d/k⌋` is `rup k (d - (k-1))`,
`k·⌈d/k⌉` is `rup k d`. -/
def scaleP (k : Nat) : PDim → Option PDim
  | .lit i => some (.lit ((k : Int) * i))
  | .lin c ts => some ((Aff.scale k ⟨c, ts⟩).toP)
  | .fdiv d k' => if k' = k then d.aff?.map fun a => .rup k (a.sub (.const ((k : Int) - 1))).toP else none
  | .cdiv d k' => if k' = k then some (.rup k d) else none
  | .rup _ _ => none

def mulP (a b : PDim) : Option PDim :=
  match posLit? a with
  | some k => scaleP k b
  | none => match posLit? b with
    | some k => scaleP k a
    | none => none

/-- A binary64 literal that is an integer below `2^53`, in canonical form. -/
def litP (x : F64) : Option PDim :=
  match F64.toInt? x with
  | some i => if x = ie i ∧ i.natAbs < 2 ^ 53 then some (.lit i) else none
  | none => none

theorem addP_eval (ν : Nat → Int) {a b r : PDim} (h : addP a b = some r) : r.eval ν = a.eval ν + b.eval ν := by
  simp only [addP, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def, Option.some.injEq] at h
  obtain ⟨x, hx, y, hy, rfl⟩ := h
  rw [Aff.eval_toP, Aff.eval_add, PDim.eval_aff? ν hx, PDim.eval_aff? ν hy]

theorem subP_eval (ν : Nat → Int) {a b r : PDim} (h : subP a b = some r) : r.eval ν = a.eval ν - b.eval ν := by
  simp only [subP, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def, Option.some.injEq] at h
  obtain ⟨x, hx, y, hy, rfl⟩ := h
  rw [Aff.eval_toP, Aff.eval_sub, PDim.eval_aff? ν hx, PDim.eval_aff? ν hy]

theorem posLit_eval {d : PDim} {k : Nat} (h : posLit? d = some k) : d = .lit k ∧ 0 < k := by
  cases d with
  | lit i =>
    simp only [posLit?] at h
    split at h
    · cases h; exact ⟨by congr; omega, by omega⟩
    · cases h
  | _ => cases h

/-- `k·⌈(x - (k-1))/k⌉ = k·⌊x/k⌋`. -/
theorem ceilDiv_sub (x : Int) (k : Nat) : ceilDiv (x - ((k : Int) - 1)) k = x / (k : Int) := by
  unfold ceilDiv
  congr 1
  omega

theorem scaleP_eval (ν : Nat → Int) {k : Nat} (hk : 0 < k) :
    ∀ {d r : PDim}, scaleP k d = some r → r.eval ν = (k : Int) * d.eval ν
  | .lit i, r, h => by cases h; rfl
  | .lin c ts, r, h => by
    cases h
    rw [Aff.eval_toP, Aff.eval_scale]; rfl
  | .fdiv d k', r, h => by
    simp only [scaleP] at h
    split at h
    · rename_i he
      subst he
      obtain ⟨a, ha, rfl⟩ := Option.map_eq_some_iff.mp h
      simp only [PDim.eval]
      rw [Aff.eval_toP, Aff.eval_sub, Aff.eval_const, PDim.eval_aff? ν ha, ceilDiv_sub _ _]
    · cases h
  | .cdiv d k', r, h => by
    simp only [scaleP] at h
    split at h
    · rename_i he
      subst he; cases h; rfl
    · cases h
  | .rup _ _, _, h => by cases h


/-! ## The normalizer

`normR` returns an integer dimension, or a quotient `d / k` by a positive
literal (not an integer: only `Math.floor`/`Math.ceil` consume it). -/

inductive NormR where
  | int (d : PDim)
  | quot (d : PDim) (k : Nat)

def normR (B : Box) : SymE → Option NormR
  | .lit x => (litP x).map .int
  | .var x => (ok B (PDim.var x)).map .int
  | .bin op a b =>
    match op, normR B a, normR B b with
    | .add, some (.int x), some (.int y) => (addP x y).bind (ok B) |>.map .int
    | .sub, some (.int x), some (.int y) => (subP x y).bind (ok B) |>.map .int
    | .mul, some (.int x), some (.int y) => (mulP x y).bind (ok B) |>.map .int
    | .div, some (.int x), some (.int y) =>
      (posLit? y).bind fun k => if nonneg B x then some (.quot x k) else none
    | _, _, _ => none
  | .un op a =>
    match op, normR B a with
    | .int32, some (.int d) => if in32 B d then some (.int d) else none
    | .floor, some (.int d) => some (.int d)
    | .ceil, some (.int d) => some (.int d)
    | .trunc, some (.int d) => some (.int d)
    | .floor, some (.quot d k) => (ok B (.fdiv d k)).map .int
    | .ceil, some (.quot d k) => (ok B (.cdiv d k)).map .int
    | _, _ => none

/-- A table entry as a dimension, if every step is exact integer arithmetic over `B`. -/
def normP (B : Box) (e : SymE) : Option PDim :=
  match normR B e with
  | some (.int d) => some d
  | _ => none

/-- What a normal form says about the entry's binary64 value `x` at `ν`. -/
def NormR.Holds (B : Box) (ν : Nat → Int) (x : F64) : NormR → Prop
  | .int d => x = ie (d.eval ν) ∧ safe B d = true
  | .quot d k => x = F64.div (ie (d.eval ν)) (ie k) ∧ 0 ≤ d.eval ν ∧ d.eval ν < 2 ^ 53 ∧ 0 < k ∧ k < 2 ^ 53

theorem litP_sound (B : Box) (ν : Nat → Int) {x : F64} {d : PDim} (h : litP x = some d) :
    x = ie (d.eval ν) ∧ safe B d = true := by
  unfold litP at h
  split at h
  · rename_i i hi
    split at h
    · rename_i hc
      cases h
      refine ⟨hc.1, ?_⟩
      simp only [safe, PDim.range, Bool.and_eq_true, decide_eq_true_eq]
      omega
    · cases h
  · cases h

/-- An integer result `ok B r` of an operation. -/
theorem int_result (B : Box) {o : Option PDim} {n : NormR} (h : (o.bind (ok B)).map NormR.int = some n) :
    ∃ r, o = some r ∧ n = .int r ∧ safe B r = true := by
  obtain ⟨r, hr, rfl⟩ := Option.map_eq_some_iff.mp h
  obtain ⟨d, hd, hk⟩ := Option.bind_eq_some_iff.mp hr
  obtain ⟨he, hs⟩ := ok_some hk
  subst he
  exact ⟨_, hd, rfl, hs⟩

section Sound
variable (B : Box) (ν : Nat → Int) (ρ : Nat → F64) (hB : InBox B ν)
  (hρ : ∀ x l h, B.get x = some (l, h) → ρ x = F64.ofInt (ν x))
include hB hρ

theorem var_sound (x : Nat) {d : PDim} (h : ok B (PDim.var x) = some d) :
    ρ x = ie (d.eval ν) ∧ safe B d = true := by
  obtain ⟨rfl, hs⟩ := ok_some h
  refine ⟨?_, hs⟩
  have hb := safe_bound hB hs
  rw [PDim.eval_var] at hb ⊢
  have hg : ∃ l h, B.get x = some (l, h) := by
    unfold safe at hs
    split at hs
    · rename_i r hr
      simp only [PDim.var, Aff.var, Aff.toP, PDim.range, termsRange] at hr
      revert hr
      cases hx : B.get x with
      | none => intro hr; cases hr
      | some lh => intro _; exact ⟨lh.1, lh.2, rfl⟩
    · cases hs
  obtain ⟨l, hh, hx⟩ := hg
  rw [hρ x l hh hx, ofInt_ie _ (by omega)]

/-- **The normal form holds of the entry's value.** -/
theorem normR_sound : ∀ (e : SymE) (n : NormR), normR B e = some n → n.Holds B ν (e.eval ρ)
  | .lit x, n, h => by
    obtain ⟨d, hd, rfl⟩ := Option.map_eq_some_iff.mp h
    exact litP_sound B ν hd
  | .var x, n, h => by
    obtain ⟨d, hd, rfl⟩ := Option.map_eq_some_iff.mp h
    exact var_sound B ν ρ hB hρ x hd
  | .bin op a b, n, h => by
    have iha := normR_sound a
    have ihb := normR_sound b
    simp only [normR] at h
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
      split at hq
      · rename_i hn
        cases hq
        obtain ⟨va, hsa⟩ := iha _ ha
        obtain ⟨vb, hsb⟩ := ihb _ hb
        obtain ⟨rfl, hk0⟩ := posLit_eval hk
        have hya := safe_bound hB hsa
        have hyb := safe_bound hB hsb
        have hn' := nonneg_bound hB hn
        simp only [PDim.eval] at hyb
        refine ⟨?_, hn', by omega, hk0, by omega⟩
        simp only [SymE.eval, F64.bin, va, vb, PDim.eval]
      · cases hq
    · cases h
  | .un op a, n, h => by
    have iha := normR_sound a
    simp only [normR] at h
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

/-- **The normalizer is sound**: an entry with a normal form denotes its value. -/
theorem normP_sound (e : SymE) (d : PDim) (h : normP B e = some d) : F64.toInt? (e.eval ρ) = some (d.eval ν) := by
  unfold normP at h
  split at h
  · rename_i d' he
    cases h
    obtain ⟨hv, _⟩ := normR_sound B ν ρ hB hρ e _ he
    rw [hv, toInt_ie]
  · cases h

end Sound

/-! ## The classifier -/

/-- Numbers classified as dimensions in `δ` are read correctly at `ν` through `ev`. -/
def ClsSoundD {δ : Type} (cls : NumV → Option δ) (ν : NumV → Option F64) (ev : δ → Int) : Prop :=
  ∀ x d, cls x = some d → ((ν x).bind F64.toInt?) = some (ev d)

theorem clsSound_eq (cls : NumV → Option SDim) (ν : NumV → Option F64) (n : Nat) :
    ClsSound cls ν n ↔ ClsSoundD cls ν (SDim.eval n) := Iff.rfl

/-- The multi-row classifier of table `S` over the box `B`: literals by value,
references by the normal form of their entry. -/
def clsOfP (S : SSrv) (B : Box) : NumV → Option PDim
  | .lit f => (F64.toInt? f).map PDim.lit
  | .ref i => (nth? S.tab i).bind (normP B)

/-- **The classifier is sound** at every valuation in the box. -/
theorem clsOfP_sound (S : SSrv) (B : Box) (ν : Nat → Int) (ρ : Nat → F64) (hB : InBox B ν)
    (hρ : ∀ x l h, B.get x = some (l, h) → ρ x = F64.ofInt (ν x)) :
    ClsSoundD (clsOfP S B) (νsOf S ρ) (PDim.eval ν) := by
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
    exact normP_sound B ν ρ hB hρ e d hd

/-! ## The decode offset dimensions embed -/

set_option linter.unusedSimpArgs false in
/-- **The decode classifier's dimensions are normal forms**: an entry `entryDim p`
classifies normalizes to its `SDim.toP p` image, whenever the box bounds the offset
position within `int32`. -/
theorem normP_entryDim (B : Box) (p : Nat) (l h : Int) (hg : B.get p = some (l, h)) (hl : 0 ≤ l) (hlh : l ≤ h)
    (hh : h + 1 < 2 ^ 31) (e : SymE) (d : SDim) (he : entryDim p e = some d) : normP B e = some (d.toP p) := by
  have hr0 : PDim.range B (.lin 0 [(1, p)]) = some (l, h) := by
    simp only [PDim.range, termsRange, hg, Int.one_mul, Option.map_some, Int.add_zero, Int.zero_add]
    congr 2 <;> omega
  have hr1 : PDim.range B (.lin 1 [(1, p)]) = some (1 + l, 1 + h) := by
    simp only [PDim.range, termsRange, hg, Int.one_mul, Option.map_some, Int.add_zero]
    congr 2 <;> omega
  have hok0 : ok B (PDim.var p) = some (.lin 0 [(1, p)]) := by
    have : safe B (.lin 0 [(1, p)]) = true := by
      simp only [safe, hr0, Bool.and_eq_true, decide_eq_true_eq]; omega
    simp only [ok, PDim.var, Aff.var, Aff.toP, this, ↓reduceIte]
  have hok1 : ok B (.lin 1 [(1, p)]) = some (.lin 1 [(1, p)]) := by
    have : safe B (.lin 1 [(1, p)]) = true := by
      simp only [safe, hr1, Bool.and_eq_true, decide_eq_true_eq]; omega
    simp only [ok, this, ↓reduceIte]
  have hi0 : in32 B (.lin 0 [(1, p)]) = true := by
    simp only [in32, hr0, Bool.and_eq_true, decide_eq_true_eq]; omega
  have hi1 : in32 B (.lin 1 [(1, p)]) = true := by
    simp only [in32, hr1, Bool.and_eq_true, decide_eq_true_eq]; omega
  have hlitP : litP (F64.ofNat 1) = some (.lit 1) := rfl
  have hadd : addP (.lin 0 [(1, p)]) (.lit 1) = some (.lin 1 [(1, p)]) := rfl
  have hadd' : addP (.lit 1) (.lin 0 [(1, p)]) = some (.lin 1 [(1, p)]) := rfl
  unfold entryDim at he
  split at he <;> (try split at he) <;> simp only [Option.some.injEq, reduceCtorEq] at he <;> subst he <;>
    rename_i hq <;>
    first
      | (subst hq
         simp only [normP, normR, hok0, hlitP, Option.map_some, hadd, hadd', Option.bind_some, hok1, hi0, hi1,
           ↓reduceIte, SDim.toP])
      | (obtain ⟨hq, ho⟩ := hq
         subst hq ho
         simp only [normP, normR, hok0, hlitP, Option.map_some, hadd, hadd', Option.bind_some, hok1, hi0, hi1,
           ↓reduceIte, SDim.toP])

end Host.Mlx.SimGraph
