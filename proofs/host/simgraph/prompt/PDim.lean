import host.simgraph.Match
namespace Host.Mlx.SimGraph

/-! # Dimensions in several symbolic parameters

A multi-row template's dimensions depend on the prompt length, the cache
offset and the row count, each a symbolic position of the template run.
`PDim` is their type: integer literals, affine forms `c + Σ a·x` over the
positions (`lin`), and integer quotients by literals (`fdiv`, `cdiv`) and
round-ups to a multiple of a literal (`rup`; `ceil256` is the KV growth
`256·⌈d/256⌉`). `PDim.eval ν` reads a dimension at the valuation `ν`.

* `Aff`: affine forms with total `add`/`sub`/`scale`; `Aff.toP` is the
  canonical dimension (a literal when no position remains). Builders write
  their dimensions with these, so a builder's dimension and the classifier's
  normal form of the run's number coincide syntactically.
* `PDim.range B`: an interval of a dimension over a box `B` of positions
  (`range_sound`); the classifier uses it to check that the run's binary64
  arithmetic is exact.
* `SDim.toP p`: the decode template's dimensions, with the offset at position
  `p` (`SDim.eval_toP`). -/

/-! ## Affine forms -/

/-- `Σ a·ν x` over the terms `(a, x)`. -/
def termsEval (ν : Nat → Int) : List (Int × Nat) → Int
  | [] => 0
  | t :: ts => t.1 * ν t.2 + termsEval ν ts

/-- Add the term `t` to a term list sorted by position (zero coefficients dropped). -/
def insertTerm (t : Int × Nat) : List (Int × Nat) → List (Int × Nat)
  | [] => if t.1 = 0 then [] else [t]
  | u :: us =>
    if t.2 < u.2 then (if t.1 = 0 then u :: us else t :: u :: us)
    else if t.2 = u.2 then (if t.1 + u.1 = 0 then us else (t.1 + u.1, u.2) :: us)
    else u :: insertTerm t us

theorem termsEval_insert (ν : Nat → Int) (t : Int × Nat) :
    ∀ us, termsEval ν (insertTerm t us) = t.1 * ν t.2 + termsEval ν us
  | [] => by
    unfold insertTerm
    by_cases h : t.1 = 0
    · simp [h, termsEval]
    · simp [h, termsEval]
  | u :: us => by
    unfold insertTerm
    by_cases h1 : t.2 < u.2
    · rw [ite_eq_left h1]
      by_cases h0 : t.1 = 0
      · rw [ite_eq_left h0]; simp [h0]
      · rw [ite_eq_right h0]; simp [termsEval]
    · rw [ite_eq_right h1]
      by_cases h2 : t.2 = u.2
      · rw [ite_eq_left h2]
        by_cases h3 : t.1 + u.1 = 0
        · rw [ite_eq_left h3]
          simp only [termsEval]
          rw [← h2, ← Int.add_assoc, ← Int.add_mul, h3, Int.zero_mul, Int.zero_add]
        · rw [ite_eq_right h3]
          simp only [termsEval]
          rw [h2, Int.add_mul, Int.add_assoc]
      · rw [ite_eq_right h2]
        simp only [termsEval]
        rw [termsEval_insert ν t us]
        omega

/-- An affine form `c + Σ a·x`. -/
structure Aff where
  c : Int
  ts : List (Int × Nat)
deriving DecidableEq, Repr

namespace Aff

def eval (ν : Nat → Int) (a : Aff) : Int := a.c + termsEval ν a.ts

def const (c : Int) : Aff := ⟨c, []⟩

def var (x : Nat) : Aff := ⟨0, [(1, x)]⟩

def add (a b : Aff) : Aff := ⟨a.c + b.c, a.ts.foldr insertTerm b.ts⟩

def scale (k : Int) (a : Aff) : Aff := ⟨k * a.c, if k = 0 then [] else a.ts.map fun t => (k * t.1, t.2)⟩

def sub (a b : Aff) : Aff := add a (scale (-1) b)

theorem eval_const (ν : Nat → Int) (c : Int) : (const c).eval ν = c := by simp [eval, const, termsEval]

theorem eval_var (ν : Nat → Int) (x : Nat) : (var x).eval ν = ν x := by simp [eval, var, termsEval]

theorem termsEval_foldr (ν : Nat → Int) (us : List (Int × Nat)) :
    ∀ ts : List (Int × Nat), termsEval ν (ts.foldr insertTerm us) = termsEval ν ts + termsEval ν us
  | [] => by simp [termsEval]
  | t :: ts => by
    simp only [List.foldr_cons, termsEval_insert, termsEval_foldr ν us ts, termsEval]
    omega

theorem eval_add (ν : Nat → Int) (a b : Aff) : (a.add b).eval ν = a.eval ν + b.eval ν := by
  simp only [eval, add, termsEval_foldr]
  omega

theorem termsEval_scale (ν : Nat → Int) (k : Int) :
    ∀ ts : List (Int × Nat), termsEval ν (ts.map fun t => (k * t.1, t.2)) = k * termsEval ν ts
  | [] => by simp [termsEval]
  | t :: ts => by
    simp only [List.map_cons, termsEval, termsEval_scale ν k ts, Int.mul_add, Int.mul_assoc]

theorem eval_scale (ν : Nat → Int) (k : Int) (a : Aff) : (a.scale k).eval ν = k * a.eval ν := by
  unfold eval scale
  by_cases h : k = 0
  · subst h; simp [termsEval]
  · simp only [h, ↓reduceIte, termsEval_scale, Int.mul_add]

theorem eval_sub (ν : Nat → Int) (a b : Aff) : (a.sub b).eval ν = a.eval ν - b.eval ν := by
  simp only [sub, eval_add, eval_scale]
  omega

end Aff

/-! ## Dimensions -/

/-- Symbolic dimensions of a multi-row template. -/
inductive PDim where
  | lit (i : Int)
  /-- `c + Σ a·x`, the terms sorted by position, no zero coefficient, at least one term. -/
  | lin (c : Int) (ts : List (Int × Nat))
  /-- `⌊d/k⌋`. -/
  | fdiv (d : PDim) (k : Nat)
  /-- `⌈d/k⌉`. -/
  | cdiv (d : PDim) (k : Nat)
  /-- `k·⌈d/k⌉`. -/
  | rup (k : Nat) (d : PDim)
deriving DecidableEq, Repr

/-- `⌈x/k⌉`. -/
def ceilDiv (x : Int) (k : Nat) : Int := (x + (k : Int) - 1) / (k : Int)

def PDim.eval (ν : Nat → Int) : PDim → Int
  | .lit i => i
  | .lin c ts => c + termsEval ν ts
  | .fdiv d k => d.eval ν / (k : Int)
  | .cdiv d k => ceilDiv (d.eval ν) k
  | .rup k d => (k : Int) * ceilDiv (d.eval ν) k

/-- The KV growth `256·⌈d/256⌉`. -/
abbrev PDim.ceil256 (d : PDim) : PDim := .rup 256 d

/-- The canonical dimension of an affine form. -/
def Aff.toP (a : Aff) : PDim :=
  match a.ts with
  | [] => .lit a.c
  | ts => .lin a.c ts

theorem Aff.eval_toP (ν : Nat → Int) (a : Aff) : a.toP.eval ν = a.eval ν := by
  obtain ⟨c, ts⟩ := a
  cases ts <;> simp [Aff.toP, PDim.eval, Aff.eval, termsEval]

/-- The affine form of a literal or affine dimension. -/
def PDim.aff? : PDim → Option Aff
  | .lit i => some (.const i)
  | .lin c ts => some ⟨c, ts⟩
  | _ => none

theorem PDim.eval_aff? (ν : Nat → Int) {d : PDim} {a : Aff} (h : d.aff? = some a) : a.eval ν = d.eval ν := by
  cases d <;> simp only [PDim.aff?, Option.some.injEq, reduceCtorEq] at h <;> subst h <;>
    simp [Aff.eval, Aff.const, PDim.eval, termsEval]

/-- The position `x` as a dimension. -/
def PDim.var (x : Nat) : PDim := (Aff.var x).toP

theorem PDim.eval_var (ν : Nat → Int) (x : Nat) : (PDim.var x).eval ν = ν x := by
  rw [PDim.var, Aff.eval_toP, Aff.eval_var]

/-! ## Ranges over a box of positions -/

/-- Bounds `(x, lo, hi)` on positions. -/
abbrev Box := List (Nat × Int × Int)

def Box.get (B : Box) (x : Nat) : Option (Int × Int) := (B.find? (·.1 = x)).map (·.2)

/-- `ν` lies in the box. -/
def InBox (B : Box) (ν : Nat → Int) : Prop := ∀ x l h, B.get x = some (l, h) → l ≤ ν x ∧ ν x ≤ h

def termsRange (B : Box) : List (Int × Nat) → Option (Int × Int)
  | [] => some (0, 0)
  | t :: ts => match B.get t.2, termsRange B ts with
    | some (l, h), some (lo, hi) => some (min (t.1 * l) (t.1 * h) + lo, max (t.1 * l) (t.1 * h) + hi)
    | _, _ => none

/-- An interval holding the dimension's value over the box. -/
def PDim.range (B : Box) : PDim → Option (Int × Int)
  | .lit i => some (i, i)
  | .lin c ts => (termsRange B ts).map fun r => (c + r.1, c + r.2)
  | .fdiv d k => (d.range B).map fun r => (r.1 / (k : Int), r.2 / (k : Int))
  | .cdiv d k => (d.range B).map fun r => (ceilDiv r.1 k, ceilDiv r.2 k)
  | .rup k d => (d.range B).map fun r => ((k : Int) * ceilDiv r.1 k, (k : Int) * ceilDiv r.2 k)

theorem mul_between (a l h v : Int) (hl : l ≤ v) (hh : v ≤ h) :
    min (a * l) (a * h) ≤ a * v ∧ a * v ≤ max (a * l) (a * h) := by
  rcases Int.le_total 0 a with ha | ha
  · have h1 := Int.mul_le_mul_of_nonneg_left hl ha
    have h2 := Int.mul_le_mul_of_nonneg_left hh ha
    omega
  · have h1 := Int.mul_le_mul_of_nonpos_left ha hl
    have h2 := Int.mul_le_mul_of_nonpos_left ha hh
    omega

theorem termsRange_sound (B : Box) (ν : Nat → Int) (hB : InBox B ν) :
    ∀ (ts : List (Int × Nat)) (lo hi : Int), termsRange B ts = some (lo, hi) →
      lo ≤ termsEval ν ts ∧ termsEval ν ts ≤ hi
  | [], lo, hi, h => by
    simp only [termsRange, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    simp [termsEval]
  | t :: ts, lo, hi, h => by
    unfold termsRange at h
    split at h
    · rename_i l h' lo' hi' hg hr
      simp only [Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      obtain ⟨b1, b2⟩ := hB t.2 l h' hg
      obtain ⟨m1, m2⟩ := mul_between t.1 l h' (ν t.2) b1 b2
      obtain ⟨r1, r2⟩ := termsRange_sound B ν hB ts lo' hi' hr
      simp only [termsEval]
      omega
    · cases h

theorem ediv_mono (a b : Int) (k : Nat) (h : a ≤ b) : a / (k : Int) ≤ b / (k : Int) := by
  rcases Nat.eq_zero_or_pos k with hk | hk
  · subst hk; simp
  · exact Int.ediv_le_ediv (by omega) h

theorem ceilDiv_mono (a b : Int) (k : Nat) (h : a ≤ b) : ceilDiv a k ≤ ceilDiv b k :=
  ediv_mono _ _ k (by omega)

/-- **Ranges are sound.** -/
theorem PDim.range_sound (B : Box) (ν : Nat → Int) (hB : InBox B ν) :
    ∀ (d : PDim) (lo hi : Int), d.range B = some (lo, hi) → lo ≤ d.eval ν ∧ d.eval ν ≤ hi
  | .lit i, lo, hi, h => by
    simp only [PDim.range, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    simp [PDim.eval]
  | .lin c ts, lo, hi, h => by
    obtain ⟨r, hr, e⟩ := Option.map_eq_some_iff.mp h
    simp only [Prod.mk.injEq] at e
    obtain ⟨rfl, rfl⟩ := e
    have := termsRange_sound B ν hB ts r.1 r.2 hr
    simp only [PDim.eval]
    omega
  | .fdiv d k, lo, hi, h => by
    obtain ⟨r, hr, e⟩ := Option.map_eq_some_iff.mp h
    simp only [Prod.mk.injEq] at e
    obtain ⟨rfl, rfl⟩ := e
    obtain ⟨h1, h2⟩ := PDim.range_sound B ν hB d r.1 r.2 hr
    exact ⟨ediv_mono _ _ k h1, ediv_mono _ _ k h2⟩
  | .cdiv d k, lo, hi, h => by
    obtain ⟨r, hr, e⟩ := Option.map_eq_some_iff.mp h
    simp only [Prod.mk.injEq] at e
    obtain ⟨rfl, rfl⟩ := e
    obtain ⟨h1, h2⟩ := PDim.range_sound B ν hB d r.1 r.2 hr
    exact ⟨ceilDiv_mono _ _ k h1, ceilDiv_mono _ _ k h2⟩
  | .rup k d, lo, hi, h => by
    obtain ⟨r, hr, e⟩ := Option.map_eq_some_iff.mp h
    simp only [Prod.mk.injEq] at e
    obtain ⟨rfl, rfl⟩ := e
    obtain ⟨h1, h2⟩ := PDim.range_sound B ν hB d r.1 r.2 hr
    have hk : (0 : Int) ≤ k := Int.natCast_nonneg k
    exact ⟨Int.mul_le_mul_of_nonneg_left (ceilDiv_mono _ _ k h1) hk,
      Int.mul_le_mul_of_nonneg_left (ceilDiv_mono _ _ k h2) hk⟩

/-! ## The decode template's dimensions -/

/-- The decode offset at position `p`: `n ↦ x_p`, `n + 1 ↦ x_p + 1`. -/
def SDim.toP (p : Nat) : SDim → PDim
  | .lit i => .lit i
  | .pos => .lin 0 [(1, p)]
  | .pos1 => .lin 1 [(1, p)]

theorem SDim.eval_toP (ν : Nat → Int) (p n : Nat) (h : ν p = n) (d : SDim) : (d.toP p).eval ν = d.eval n := by
  cases d <;> simp [SDim.toP, PDim.eval, SDim.eval, termsEval, h, Int.add_comm]

theorem SDim.toP_pos (p : Nat) : SDim.pos.toP p = PDim.var p := rfl

theorem SDim.toP_pos1 (p : Nat) : SDim.pos1.toP p = ((Aff.var p).add (.const 1)).toP := rfl

end Host.Mlx.SimGraph
