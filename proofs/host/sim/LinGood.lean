import host.sim.LinDiv
namespace Host.Ts.Sim.Lin
open Host.Ts

/-! # LinGood: template oracles over a parametric integer class

A template's oracle answers branches on numbers that, at every valuation of a case class, are
integers far below `2^53`. A class is given as integer **parameters** `x 0, x 1, …`, each in a
range `[lo, hi]` minus finitely many excluded values (a box, `List Prm`), and the template's
variables as **affine forms** in them (`List (Nat × Aff)`): congruences become a quotient and a
residue parameter (`p = 256·b + s`, `s ∈ [1, 254]`), definitional equations become shared
parameters (`c = 256·b + 256`), relations become slack parameters (`T = i + 3 + t`, `t ≥ 0`),
and a disequality on a parameter becomes an excluded value.

`goodLin ps V o` abstractly interprets both sides of every answer over the box and decides its
test (`absTest`); `goodLin_sound` proves that a `true` result makes `Good ρ o` hold at every
valuation `ρ` that takes each variable to its form's value at a parameter vector of the box.
The kernel runs the checker (`decide +kernel`); only `Int` arithmetic on a handful of
coefficients is evaluated per term.

Abstract values (`AV`) are exact affine forms with bounds over the box (cancellation is exact:
`int32(v9 + 1) - int32(v9)` is `1`), opaque integers in a range (nonlinear products of
non-negatives, remainders and quotients that do not split, `min`/`max` that the box does not
decide), and `±Infinity` literals. A remainder or a rounded quotient (`Math.floor`, `trunc`,
`ceil` of `a / m`, `host.sim.LinDiv`) by a positive constant `m` stays a form when the form
splits as `m·q + r` with `r ∈ [0, m)` on the box; `int32`/`uint32` stay forms within one
wrapping window. Tests on two forms compare their difference's bounds; an equality is also
refuted by a gcd of the coefficients not dividing the constant, or by an excluded parameter
value.

Interface: state the class as `ps : List Prm` and `V : List (Nat × Aff)` (forms written
`256 • P 0 + P 1 + 3`), check `goodLin ps V o = true` by `decide +kernel`, and apply
`goodLin_sound` with the parameter vector `vx [...]` of the case (integer expressions in the
case's naturals); `lin_mem [defs, hyps]` proves the box and variable side goals by `omega`.
`good_of_rest` leaves the answers the checker cannot decide to the caller. -/

/-- `2^53`: every value the checker tracks lies strictly inside `(-2^53, 2^53)`. -/
local notation "lim" => (9007199254740992 : Int)

/-! ## Classes -/

/-- A parameter: an integer in `[lo, hi]` other than the values `ex`. -/
structure Prm where
  lo : Int
  hi : Int
  ex : List Int := []

/-- `x i, x (i + 1), …` lie in the parameters `ps`. -/
def InBox : List Prm → Nat → (Nat → Int) → Prop
  | [], _, _ => True
  | p :: ps, i, x => (p.lo ≤ x i ∧ x i ≤ p.hi ∧ x i ∉ p.ex) ∧ InBox ps (i + 1) x

/-- An affine form `c + Σ cs[k] · x k` in the parameters. -/
structure Aff where
  c : Int
  cs : List Int

def dot : List Int → Nat → (Nat → Int) → Int
  | [], _, _ => 0
  | a :: as, i, x => a * x i + dot as (i + 1) x

def Aff.eval (f : Aff) (x : Nat → Int) : Int := f.c + dot f.cs 0 x

def addL : List Int → List Int → List Int
  | [], bs => bs
  | a :: as, [] => a :: as
  | a :: as, b :: bs => (a + b) :: addL as bs

instance : Add Aff := ⟨fun f g => ⟨f.c + g.c, addL f.cs g.cs⟩⟩
instance : SMul Int Aff := ⟨fun k f => ⟨k * f.c, f.cs.map (k * ·)⟩⟩
instance : SMul Nat Aff := ⟨fun k f => ((k : Int)) • f⟩
instance : Neg Aff := ⟨fun f => (-1 : Int) • f⟩
instance : Sub Aff := ⟨fun f g => f + -g⟩
instance {n : Nat} : OfNat Aff n := ⟨⟨(n : Int), []⟩⟩

/-- Parameter `i` as a form. -/
def P (i : Nat) : Aff := ⟨0, List.replicate i 0 ++ [1]⟩

/-- The template variables' forms: variable `j` is the first form listed for `j`. -/
def lookup : List (Nat × Aff) → Nat → Option Aff
  | [], _ => none
  | (k, f) :: V, j => if k = j then some f else lookup V j

/-- The valuation `ρ` takes every listed variable to its form's value at `x`. -/
def VarsOk (ρ : Nat → F64) (x : Nat → Int) : List (Nat × Aff) → Prop
  | [] => True
  | (j, f) :: V => ρ j = F64.ofInt (f.eval x) ∧ VarsOk ρ x V

/-- A parameter vector given as a list (`0` past its end). -/
def vx (l : List Int) (i : Nat) : Int := l.getD i 0

/-! ### Forms -/

section
variable {x : Nat → Int}

theorem dot_addL : ∀ (as bs : List Int) (i : Nat), dot (addL as bs) i x = dot as i x + dot bs i x
  | [], bs, i => by simp [addL, dot]
  | a :: as, [], i => by simp [addL, dot]
  | a :: as, b :: bs, i => by
    simp only [addL, dot, dot_addL as bs (i + 1)]
    grind

theorem dot_map_mul (k : Int) : ∀ (as : List Int) (i : Nat), dot (as.map (k * ·)) i x = k * dot as i x
  | [], i => by simp [dot]
  | a :: as, i => by
    simp only [List.map, dot, dot_map_mul k as (i + 1)]
    grind

theorem dot_replicate : ∀ (n i : Nat), dot (List.replicate n 0 ++ [1]) i x = x (i + n)
  | 0, i => by simp [dot]
  | n + 1, i => by
    simp only [List.replicate, List.cons_append, dot, dot_replicate n (i + 1)]
    rw [show i + 1 + n = i + (n + 1) by omega]
    simp

@[simp] theorem eval_add (f g : Aff) : (f + g).eval x = f.eval x + g.eval x := by
  show (f.c + g.c) + dot (addL f.cs g.cs) 0 x = (f.c + dot f.cs 0 x) + (g.c + dot g.cs 0 x)
  rw [dot_addL]; omega

@[simp] theorem eval_smul (k : Int) (f : Aff) : (k • f).eval x = k * f.eval x := by
  show k * f.c + dot (f.cs.map (k * ·)) 0 x = k * (f.c + dot f.cs 0 x)
  rw [dot_map_mul, Int.mul_add]

@[simp] theorem eval_smul_nat (k : Nat) (f : Aff) : (k • f).eval x = (k : Int) * f.eval x :=
  eval_smul (k : Int) f

@[simp] theorem eval_neg (f : Aff) : (-f).eval x = -f.eval x := by
  show ((-1 : Int) • f).eval x = _
  rw [eval_smul]; omega

@[simp] theorem eval_sub (f g : Aff) : (f - g).eval x = f.eval x - g.eval x := by
  show (f + -g).eval x = _
  rw [eval_add, eval_neg]; omega

@[simp] theorem eval_ofNat (n : Nat) : Aff.eval (no_index (OfNat.ofNat n : Aff)) x = (OfNat.ofNat n : Int) := by
  show (n : Int) + dot [] 0 x = _
  simp only [dot, Int.add_zero]; rfl

@[simp] theorem eval_P (i : Nat) : (P i).eval x = x i := by
  show 0 + dot (List.replicate i 0 ++ [1]) 0 x = x i
  rw [dot_replicate]; simp

@[simp] theorem eval_mk (c : Int) (cs : List Int) : (Aff.mk c cs).eval x = c + dot cs 0 x := rfl

@[simp] theorem vx_nil (i : Nat) : vx [] i = 0 := by simp [vx]
@[simp] theorem vx_zero (a : Int) (l : List Int) : vx (a :: l) 0 = a := rfl
@[simp] theorem vx_succ (a : Int) (l : List Int) (i : Nat) : vx (a :: l) (i + 1) = vx l i := rfl

end

/-- All coefficients are zero. -/
def isConst (f : Aff) : Bool := f.cs.all (· == 0)

theorem dot_zero {x : Nat → Int} : ∀ (cs : List Int) (i : Nat), cs.all (· == 0) = true → dot cs i x = 0
  | [], _, _ => rfl
  | a :: as, i, h => by
    simp only [List.all_cons, Bool.and_eq_true, beq_iff_eq] at h
    simp only [dot, h.1, Int.zero_mul, Int.zero_add]
    exact dot_zero as (i + 1) h.2

theorem eval_const {x : Nat → Int} {f : Aff} (h : isConst f = true) : f.eval x = f.c := by
  unfold Aff.eval; rw [dot_zero f.cs 0 h]; omega

/-! ### Bounds over the box -/

/-- Bounds of `dot cs i x` for `x` in the box. -/
def dotRg : List Int → List Prm → Option (Int × Int)
  | [], _ => some (0, 0)
  | a :: as, [] => if a = 0 then dotRg as [] else none
  | a :: as, p :: ps => match dotRg as ps with
    | some (l, h) => if 0 ≤ a then some (a * p.lo + l, a * p.hi + h) else some (a * p.hi + l, a * p.lo + h)
    | none => none

def affRg (ps : List Prm) (f : Aff) : Option (Int × Int) :=
  match dotRg f.cs ps with
  | some (l, h) => some (f.c + l, f.c + h)
  | none => none

theorem dotRg_sound {x : Nat → Int} : ∀ (cs : List Int) (ps : List Prm) (i : Nat) {l h : Int},
    InBox ps i x → dotRg cs ps = some (l, h) → l ≤ dot cs i x ∧ dot cs i x ≤ h
  | [], _, _, l, h, _, hr => by simp only [dotRg, Option.some.injEq, Prod.mk.injEq] at hr; simp [dot]; omega
  | a :: as, [], i, l, h, hb, hr => by
    simp only [dotRg] at hr
    split at hr
    · next ha =>
      subst ha
      have := dotRg_sound (x := x) as [] (i + 1) (l := l) (h := h) trivial hr
      simp only [dot, Int.zero_mul, Int.zero_add]; exact this
    · cases hr
  | a :: as, p :: ps, i, l, h, hb, hr => by
    simp only [dotRg] at hr
    obtain ⟨⟨hlo, hhi, _⟩, hb'⟩ := hb
    split at hr
    · next l' h' hr' =>
      have ih := dotRg_sound (x := x) as ps (i + 1) hb' hr'
      simp only [dot]
      split at hr
      · next ha =>
        simp only [Option.some.injEq, Prod.mk.injEq] at hr
        obtain ⟨rfl, rfl⟩ := hr
        have h1 := Int.mul_le_mul_of_nonneg_left hlo ha
        have h2 := Int.mul_le_mul_of_nonneg_left hhi ha
        omega
      · next ha =>
        simp only [Option.some.injEq, Prod.mk.injEq] at hr
        obtain ⟨rfl, rfl⟩ := hr
        have h1 := Int.mul_le_mul_of_nonpos_left (show a ≤ 0 by omega) hhi
        have h2 := Int.mul_le_mul_of_nonpos_left (show a ≤ 0 by omega) hlo
        omega
    · cases hr

theorem affRg_sound {x : Nat → Int} {ps : List Prm} {f : Aff} {l h : Int} (hb : InBox ps 0 x)
    (hr : affRg ps f = some (l, h)) : l ≤ f.eval x ∧ f.eval x ≤ h := by
  unfold affRg at hr
  split at hr
  · next l' h' hr' =>
    simp only [Option.some.injEq, Prod.mk.injEq] at hr
    obtain ⟨rfl, rfl⟩ := hr
    have := dotRg_sound f.cs ps 0 hb hr'
    unfold Aff.eval; omega
  · cases hr

/-! ## Abstract values -/

/-- An integer bounded by `[lo, hi]`, given exactly by a form (`aff`) or not (`rng`), or an
infinity. -/
inductive AV where
  | aff (f : Aff) (lo hi : Int)
  | rng (lo hi : Int)
  | inf (neg : Bool)

def Safe (lo hi : Int) : Prop := -lim < lo ∧ hi < lim

/-- What an abstract value says of a binary64 value at parameters `x`. -/
def AV.Den (x : Nat → Int) : AV → F64 → Prop
  | .aff f lo hi, y => y = ie (f.eval x) ∧ lo ≤ f.eval x ∧ f.eval x ≤ hi ∧ Safe lo hi
  | .rng lo hi, y => ∃ v, y = ie v ∧ lo ≤ v ∧ v ≤ hi ∧ Safe lo hi
  | .inf s, y => y = .inf s

/-- The bounds of a finite abstract value. -/
def AV.rg : AV → Option (Int × Int)
  | .aff _ lo hi => some (lo, hi)
  | .rng lo hi => some (lo, hi)
  | .inf _ => none

section
variable {x : Nat → Int} {ps : List Prm}

theorem AV.den_rg {a : AV} {y : F64} {lo hi : Int} (h : a.Den x y) (hr : a.rg = some (lo, hi)) :
    ∃ v, y = ie v ∧ lo ≤ v ∧ v ≤ hi ∧ Safe lo hi := by
  cases a with
  | aff f l' h' =>
    simp only [AV.rg, Option.some.injEq, Prod.mk.injEq] at hr
    obtain ⟨rfl, rfl⟩ := hr
    exact ⟨_, h.1, h.2.1, h.2.2.1, h.2.2.2⟩
  | rng l' h' =>
    simp only [AV.rg, Option.some.injEq, Prod.mk.injEq] at hr
    obtain ⟨rfl, rfl⟩ := hr
    exact h
  | inf s => cases hr

def mkAff (ps : List Prm) (f : Aff) : Option AV :=
  match affRg ps f with
  | some (l, h) => if -lim < l ∧ h < lim then some (.aff f l h) else none
  | none => none

def mkRng (lo hi : Int) : Option AV := if -lim < lo ∧ hi < lim then some (.rng lo hi) else none

theorem mkAff_sound {f : Aff} {r : AV} (hb : InBox ps 0 x) (h : mkAff ps f = some r) :
    r.Den x (ie (f.eval x)) ∧ -lim < f.eval x ∧ f.eval x < lim := by
  unfold mkAff at h
  split at h
  · next l h' hr =>
    have hb' := affRg_sound hb hr
    split at h
    · next hs =>
      simp only [Option.some.injEq] at h
      subst h
      exact ⟨⟨rfl, hb'.1, hb'.2, hs⟩, by omega, by omega⟩
    · cases h
  · cases h

theorem mkRng_sound {lo hi v : Int} {r : AV} (h : mkRng lo hi = some r) (h1 : lo ≤ v) (h2 : v ≤ hi) :
    r.Den x (ie v) ∧ -lim < v ∧ v < lim := by
  unfold mkRng at h
  split at h
  · next hs =>
    simp only [Option.some.injEq] at h
    subst h
    exact ⟨⟨v, rfl, h1, h2, hs⟩, by omega, by omega⟩
  · cases h

theorem mkRng_safe {lo hi : Int} {r : AV} (h : mkRng lo hi = some r) : Safe lo hi := by
  unfold mkRng at h
  split at h
  · assumption
  · cases h

end

/-! ## Abstract arithmetic -/

/-- Interval of `b - a` (exact on two forms). -/
def diffRg (ps : List Prm) (a b : AV) : Option (Int × Int) :=
  match a, b with
  | .aff f _ _, .aff g _ _ => affRg ps (g - f)
  | a, b => match a.rg, b.rg with
    | some (l1, h1), some (l2, h2) => some (l2 - h1, h2 - l1)
    | _, _ => none

def absAdd (ps : List Prm) (a b : AV) : Option AV :=
  match a, b with
  | .aff f _ _, .aff g _ _ => mkAff ps (f + g)
  | a, b => match a.rg, b.rg with
    | some (l1, h1), some (l2, h2) => mkRng (l1 + l2) (h1 + h2)
    | _, _ => none

def absSub (ps : List Prm) (a b : AV) : Option AV :=
  match a, b with
  | .aff f _ _, .aff g _ _ => mkAff ps (f - g)
  | a, b => match a.rg, b.rg with
    | some (l1, h1), some (l2, h2) => mkRng (l1 - h2) (h1 - l2)
    | _, _ => none

/-- `v * k` is not a negative zero for `v ∈ [lo, hi]`. -/
def mulOk (k lo hi : Int) : Prop := 0 < k ∨ (k = 0 ∧ 0 ≤ lo) ∨ (k < 0 ∧ (0 < lo ∨ hi < 0))

instance (k lo hi : Int) : Decidable (mulOk k lo hi) := by unfold mulOk; infer_instance

def absMulRng (a b : AV) : Option AV :=
  match a.rg, b.rg with
  | some (l1, h1), some (l2, h2) => if 0 ≤ l1 ∧ 0 ≤ l2 then mkRng (l1 * l2) (h1 * h2) else none
  | _, _ => none

def absMul (ps : List Prm) (a b : AV) : Option AV :=
  match a, b with
  | .aff f lf hf, .aff g lg hg =>
    if isConst g ∧ mulOk g.c lf hf then mkAff ps (g.c • f)
    else if isConst f ∧ mulOk f.c lg hg then mkAff ps (f.c • g)
    else absMulRng (.aff f lf hf) (.aff g lg hg)
  | a, b => absMulRng a b

/-- Exact division of a form by a positive constant dividing all its coefficients. -/
def absDiv (ps : List Prm) (a b : AV) : Option AV :=
  match a, b with
  | .aff f _ _, .aff g _ _ =>
    if isConst g ∧ 0 < g.c ∧ f.c % g.c = 0 ∧ f.cs.all (fun a => a % g.c == 0) then
      mkAff ps ⟨f.c / g.c, f.cs.map (· / g.c)⟩
    else none
  | _, _ => none

/-- The coefficients' remainders after their truncated quotients by `m`. -/
def remL (m : Int) (cs : List Int) : List Int := cs.map (fun a => a - m * a.tdiv m)

/-- `f = m · q + r` with `0 ≤ r < m` on the box: `q` from the coefficients' truncated quotients,
`r` the remainders shifted by the one multiple of `m` that brings their range into `[0, m)`. -/
def split (ps : List Prm) (f : Aff) (m : Int) : Option (Aff × Aff) :=
  match affRg ps ⟨f.c, remL m f.cs⟩ with
  | some (l, h) => if l / m = h / m then some (⟨l / m, f.cs.map (·.tdiv m)⟩, ⟨f.c - l / m * m, remL m f.cs⟩) else none
  | none => none

def absRem (ps : List Prm) (a b : AV) : Option AV :=
  match a.rg, b.rg with
  | some (la, ha), some (lb, hb) =>
    if 0 ≤ la ∧ 0 < lb then
      if ha < lb then some a
      else
        let fallback := mkRng 0 (min ha (hb - 1))
        match a, b with
        | .aff f _ _, .aff g _ _ =>
          if isConst g then
            match split ps f g.c with
            | some (_, r) => mkAff ps r
            | none => fallback
          else fallback
        | _, _ => fallback
    else none
  | _, _ => none

def absMin (ps : List Prm) (a b : AV) : Option AV :=
  match a, b with
  | .inf s, .inf t => some (.inf (s || t))
  | a, .inf s => a.rg.map fun _ => if s then .inf true else a
  | .inf s, b => b.rg.map fun _ => if s then .inf true else b
  | a, b => match diffRg ps a b, a.rg, b.rg with
    | some (l, h), some (l1, h1), some (l2, h2) =>
      if 0 ≤ l then some a else if h ≤ 0 then some b else mkRng (min l1 l2) (min h1 h2)
    | _, _, _ => none

def absMax (ps : List Prm) (a b : AV) : Option AV :=
  match a, b with
  | .inf s, .inf t => some (.inf (s && t))
  | a, .inf s => a.rg.map fun _ => if s then a else .inf false
  | .inf s, b => b.rg.map fun _ => if s then b else .inf false
  | a, b => match diffRg ps a b, a.rg, b.rg with
    | some (l, h), some (l1, h1), some (l2, h2) =>
      if 0 ≤ l then some b else if h ≤ 0 then some a else mkRng (max l1 l2) (max h1 h2)
    | _, _, _ => none

def absBin (ps : List Prm) : NBin → AV → AV → Option AV
  | .add, a, b => absAdd ps a b
  | .sub, a, b => absSub ps a b
  | .mul, a, b => absMul ps a b
  | .div, a, b => absDiv ps a b
  | .rem, a, b => absRem ps a b
  | .min, a, b => absMin ps a b
  | .max, a, b => absMax ps a b
  | _, _, _ => none

/-- Shift into the window `[base, base + 2^32)`, or the whole window. -/
def absWrap (ps : List Prm) (base : Int) (a : AV) : Option AV :=
  match a with
  | .aff f lo hi =>
    if (hi - base) / 4294967296 = (lo - base) / 4294967296 then
      mkAff ps (f + ⟨-((lo - base) / 4294967296 * 4294967296), []⟩)
    else mkRng base (base + 4294967295)
  | .rng lo hi =>
    if (hi - base) / 4294967296 = (lo - base) / 4294967296 then
      mkRng (lo - (lo - base) / 4294967296 * 4294967296) (hi - (lo - base) / 4294967296 * 4294967296)
    else mkRng base (base + 4294967295)
  | .inf _ => none

def absNeg (ps : List Prm) (a : AV) : Option AV :=
  match a with
  | .inf s => some (.inf (!s))
  | .aff f lo hi => if 0 < lo ∨ hi < 0 then mkAff ps (-f) else none
  | .rng lo hi => if 0 < lo ∨ hi < 0 then mkRng (-hi) (-lo) else none

def absUn (ps : List Prm) : NUn → AV → Option AV
  | .neg, a => absNeg ps a
  | .floor, a => some a
  | .ceil, a => some a
  | .trunc, a => some a
  | .int32, a => absWrap ps (-2147483648) a
  | .uint32, a => absWrap ps 0 a
  | _, _ => none

/-! ## Abstract tests -/

def gcdL : List Int → Nat
  | [] => 0
  | a :: as => Nat.gcd a.natAbs (gcdL as)

/-- `cs` is zero but for one coefficient `a` at index `k`. -/
def single : List Int → Nat → Option (Nat × Int)
  | [], _ => none
  | a :: as, j => if a = 0 then single as (j + 1) else if as.all (· == 0) then some (j, a) else none

/-- `d ≠ 0` on the box: the gcd of its coefficients does not divide its constant, or `d` is
`c + a · x k` and `x k` would be an excluded value. -/
def neZero (ps : List Prm) (d : Aff) : Bool :=
  (gcdL d.cs != 0 && d.c % (gcdL d.cs : Int) != 0) ||
  match single d.cs 0 with
  | some (k, a) => (-d.c) % a == 0 && match ps[k]? with
    | some p => p.ex.contains ((-d.c) / a)
    | none => false
  | none => false

def absLt (ps : List Prm) (a b : AV) : Option Bool :=
  match a, b with
  | .inf s, .inf t => some (s && !t)
  | a, .inf t => a.rg.map fun _ => !t
  | .inf s, b => b.rg.map fun _ => s
  | a, b => match diffRg ps a b with
    | some (l, h) => if 0 < l then some true else if h ≤ 0 then some false else none
    | none => none

def absLe (ps : List Prm) (a b : AV) : Option Bool :=
  match a, b with
  | .inf s, .inf t => some (s && !t || s == t)
  | a, .inf t => a.rg.map fun _ => !t
  | .inf s, b => b.rg.map fun _ => s
  | a, b => match diffRg ps a b with
    | some (l, h) => if 0 ≤ l then some true else if h < 0 then some false else none
    | none => none

def absEq (ps : List Prm) (a b : AV) : Option Bool :=
  match a, b with
  | .inf s, .inf t => some (s == t)
  | a, .inf _ => a.rg.map fun _ => false
  | .inf _, b => b.rg.map fun _ => false
  | .aff f _ _, .aff g _ _ =>
    if isConst (g - f) ∧ (g - f).c = 0 then some true
    else match affRg ps (g - f) with
      | some (l, h) => if 0 < l ∨ h < 0 ∨ neZero ps (g - f) then some false else none
      | none => none
  | a, b => match diffRg ps a b with
    | some (l, h) => if 0 < l ∨ h < 0 then some false else if l = 0 ∧ h = 0 then some true else none
    | none => none

def absTruthy (a : AV) : Option Bool :=
  match a with
  | .inf _ => some true
  | .aff f lo hi =>
    if isConst f ∧ f.c = 0 then some false
    else if 0 < lo ∨ hi < 0 then some true else if lo = 0 ∧ hi = 0 then some false else none
  | .rng lo hi => if 0 < lo ∨ hi < 0 then some true else if lo = 0 ∧ hi = 0 then some false else none

def absTest (ps : List Prm) : NTest → AV → AV → Option Bool
  | .lt, a, b => absLt ps a b
  | .le, a, b => absLe ps a b
  | .eq, a, b => absEq ps a b
  | .truthy, a, _ => absTruthy a

/-! ## Terms and the checker -/

/-- An integer literal below `2^53` (the parser's `+0` and `±m·2^0`), or an infinity. -/
def litAV : F64 → Option AV
  | .zero false => some (.aff ⟨0, []⟩ 0 0)
  | .fin s m (.ofNat 0) =>
    if 0 < m ∧ m < 9007199254740992 then
      let v : Int := if s then -(m : Int) else m
      some (.aff ⟨v, []⟩ v v)
    else none
  | .inf s => some (.inf s)
  | _ => none

/-- `0` for `floor`/`trunc`, `m - 1` for `ceil`: `⌈v/m⌉ = ⌊(v + m - 1)/m⌋`. -/
def rdOff (up : Bool) (m : Int) : Int := if up then m - 1 else 0

/-- `Math.floor`/`Math.trunc` (`up = false`) or `Math.ceil` (`up = true`) of `a / b`, for a
non-negative dividend and a positive constant divisor: the quotient form when `a` splits, else
the quotient's range. -/
def absRoundDiv (ps : List Prm) (up : Bool) (a b : AV) : Option AV :=
  match a, b with
  | .aff f lo hi, .aff g _ _ =>
    if isConst g ∧ 0 < g.c ∧ 0 ≤ lo then
      match split ps (f + ⟨rdOff up g.c, []⟩) g.c with
      | some (q, _) => mkAff ps q
      | none => mkRng ((lo + rdOff up g.c) / g.c) ((hi + rdOff up g.c) / g.c)
    else none
  | .rng lo hi, .aff g _ _ =>
    if isConst g ∧ 0 < g.c ∧ 0 ≤ lo then mkRng ((lo + rdOff up g.c) / g.c) ((hi + rdOff up g.c) / g.c)
    else none
  | _, _ => none

def rdOf : NUn → Option Bool
  | .floor => some false
  | .trunc => some false
  | .ceil => some true
  | _ => none

def absVar (ps : List Prm) (V : List (Nat × Aff)) (j : Nat) : Option AV :=
  match lookup V j with
  | some f => mkAff ps f
  | none => none

def absBinO (ps : List Prm) (op : NBin) (oa ob : Option AV) : Option AV :=
  match oa, ob with
  | some u, some w => absBin ps op u w
  | _, _ => none

/-- A unary operation of a term with value `re`; `rd` holds the operands' values when the term
is a quotient, for `Math.floor(a / m)` and kin. -/
def unE (ps : List Prm) (op : NUn) (re : Option AV) (rd : Option (AV × AV)) : Option AV :=
  match rdOf op, rd with
  | some up, some (u, w) =>
    match absRoundDiv ps up u w with
    | some r => some r
    | none => re.bind (absUn ps op)
  | _, _ => re.bind (absUn ps op)

def divArgs : NBin → Option AV → Option AV → Option (AV × AV)
  | .div, some u, some w => some (u, w)
  | _, _, _ => none

/-- The abstract value of a term, and at a quotient its operands' values. -/
def absE2 (ps : List Prm) (V : List (Nat × Aff)) : SymE → Option AV × Option (AV × AV)
  | .lit y => (litAV y, none)
  | .var j => (absVar ps V j, none)
  | .bin op a b =>
    match absE2 ps V a, absE2 ps V b with
    | (ra, _), (rb, _) => (absBinO ps op ra rb, divArgs op ra rb)
  | .un op e =>
    match absE2 ps V e with
    | (re, rd) => (unE ps op re rd, none)

def absE (ps : List Prm) (V : List (Nat × Aff)) (e : SymE) : Option AV := (absE2 ps V e).1

/-- The checker decides answer `q`. -/
def checkAns (ps : List Prm) (V : List (Nat × Aff)) (q : Ans) : Bool :=
  match absE ps V q.a, absE ps V q.b with
  | some u, some w => absTest ps q.op u w == some q.r
  | _, _ => false

/-- The checker decides every answer of `o`. -/
def goodLin (ps : List Prm) (V : List (Nat × Aff)) (o : List Ans) : Bool := o.all (checkAns ps V)

/-! ## Soundness -/

section
variable {x : Nat → Int} {ps : List Prm}

theorem diffRg_sound {a b : AV} {ya yb : F64} {l h : Int} (hb : InBox ps 0 x) (ha : a.Den x ya)
    (hb' : b.Den x yb) (hr : diffRg ps a b = some (l, h)) :
    ∃ v w, ya = ie v ∧ yb = ie w ∧ l ≤ w - v ∧ w - v ≤ h ∧ -lim < v ∧ v < lim ∧ -lim < w ∧ w < lim := by
  have generic : ∀ l1 h1 l2 h2, a.rg = some (l1, h1) → b.rg = some (l2, h2) → l = l2 - h1 → h = h2 - l1 →
      ∃ v w, ya = ie v ∧ yb = ie w ∧ l ≤ w - v ∧ w - v ≤ h ∧ -lim < v ∧ v < lim ∧ -lim < w ∧ w < lim := by
    intro l1 h1 l2 h2 r1 r2 el eh
    obtain ⟨v, hv, v1, v2, sv⟩ := AV.den_rg ha r1
    obtain ⟨w, hw, w1, w2, sw⟩ := AV.den_rg hb' r2
    unfold Safe at sv sw
    exact ⟨v, w, hv, hw, by omega, by omega, by omega, by omega, by omega, by omega⟩
  cases a with
  | aff f lf hf =>
    cases b with
    | aff g lg hg =>
      simp only [diffRg] at hr
      have hd := affRg_sound hb hr
      simp only [eval_sub] at hd
      obtain ⟨e1, s1, s2, ⟨s3, s4⟩⟩ := ha
      obtain ⟨e2, t1, t2, ⟨t3, t4⟩⟩ := hb'
      exact ⟨_, _, e1, e2, hd.1, hd.2, by omega, by omega, by omega, by omega⟩
    | rng lg hg =>
      simp only [diffRg, AV.rg, Option.some.injEq, Prod.mk.injEq] at hr
      exact generic _ _ _ _ rfl rfl hr.1.symm hr.2.symm
    | inf t => simp [diffRg, AV.rg] at hr
  | rng lf hf =>
    cases b with
    | aff g lg hg =>
      simp only [diffRg, AV.rg, Option.some.injEq, Prod.mk.injEq] at hr
      exact generic _ _ _ _ rfl rfl hr.1.symm hr.2.symm
    | rng lg hg =>
      simp only [diffRg, AV.rg, Option.some.injEq, Prod.mk.injEq] at hr
      exact generic _ _ _ _ rfl rfl hr.1.symm hr.2.symm
    | inf t => simp [diffRg, AV.rg] at hr
  | inf s => cases b <;> simp [diffRg, AV.rg] at hr

/-- Arithmetic on ranges: an operation exact on integers maps the ranges' values into a range. -/
theorem rng_op {a b r : AV} {ya yb : F64} {l1 h1 l2 h2 lo hi : Int} (ha : a.Den x ya) (hb : b.Den x yb)
    (r1 : a.rg = some (l1, h1)) (r2 : b.rg = some (l2, h2)) (hm : mkRng lo hi = some r)
    (F : F64 → F64 → F64) (g : Int → Int → Int)
    (hF : ∀ v w, l1 ≤ v → v ≤ h1 → l2 ≤ w → w ≤ h2 → -lim < v → v < lim → -lim < w → w < lim →
      -lim < g v w → g v w < lim → F (ie v) (ie w) = ie (g v w))
    (hg : ∀ v w, l1 ≤ v → v ≤ h1 → l2 ≤ w → w ≤ h2 → lo ≤ g v w ∧ g v w ≤ hi) :
    r.Den x (F ya yb) := by
  obtain ⟨v, rfl, v1, v2, sv⟩ := AV.den_rg ha r1
  obtain ⟨w, rfl, w1, w2, sw⟩ := AV.den_rg hb r2
  have hs := mkRng_safe hm
  unfold Safe at sv sw hs
  have ⟨g1, g2⟩ := hg v w v1 v2 w1 w2
  rw [hF v w v1 v2 w1 w2 (by omega) (by omega) (by omega) (by omega) (by omega) (by omega)]
  exact (mkRng_sound hm g1 g2).1

theorem absAdd_sound {a b r : AV} {ya yb : F64} (hx : InBox ps 0 x) (ha : a.Den x ya) (hb : b.Den x yb)
    (h : absAdd ps a b = some r) : r.Den x (F64.add ya yb) := by
  have generic : ∀ l1 h1 l2 h2, a.rg = some (l1, h1) → b.rg = some (l2, h2) →
      mkRng (l1 + l2) (h1 + h2) = some r → r.Den x (F64.add ya yb) := fun l1 h1 l2 h2 r1 r2 hm =>
    rng_op ha hb r1 r2 hm F64.add (· + ·) (fun v w _ _ _ _ _ _ _ _ g1 g2 => add_ie v w (by omega))
      (fun _ _ _ _ _ _ => ⟨by omega, by omega⟩)
  cases a with
  | aff f lf hf =>
    cases b with
    | aff g lg hg =>
      simp only [absAdd] at h
      obtain ⟨hd, b1, b2⟩ := mkAff_sound hx h
      rw [ha.1, hb.1, add_ie _ _ (by simp only [eval_add] at b1 b2; omega)]
      simpa using hd
    | rng lg hg => exact generic _ _ _ _ rfl rfl h
    | inf t => simp [absAdd, AV.rg] at h
  | rng lf hf =>
    cases b with
    | aff g lg hg => exact generic _ _ _ _ rfl rfl h
    | rng lg hg => exact generic _ _ _ _ rfl rfl h
    | inf t => simp [absAdd, AV.rg] at h
  | inf s => cases b <;> simp [absAdd, AV.rg] at h

theorem absSub_sound {a b r : AV} {ya yb : F64} (hx : InBox ps 0 x) (ha : a.Den x ya) (hb : b.Den x yb)
    (h : absSub ps a b = some r) : r.Den x (F64.sub ya yb) := by
  have generic : ∀ l1 h1 l2 h2, a.rg = some (l1, h1) → b.rg = some (l2, h2) →
      mkRng (l1 - h2) (h1 - l2) = some r → r.Den x (F64.sub ya yb) := fun l1 h1 l2 h2 r1 r2 hm =>
    rng_op ha hb r1 r2 hm F64.sub (· - ·) (fun v w _ _ _ _ _ _ _ _ g1 g2 => sub_ie v w (by omega))
      (fun _ _ _ _ _ _ => ⟨by omega, by omega⟩)
  cases a with
  | aff f lf hf =>
    cases b with
    | aff g lg hg =>
      simp only [absSub] at h
      obtain ⟨hd, b1, b2⟩ := mkAff_sound hx h
      rw [ha.1, hb.1, sub_ie _ _ (by simp only [eval_sub] at b1 b2; omega)]
      simpa using hd
    | rng lg hg => exact generic _ _ _ _ rfl rfl h
    | inf t => simp [absSub, AV.rg] at h
  | rng lf hf =>
    cases b with
    | aff g lg hg => exact generic _ _ _ _ rfl rfl h
    | rng lg hg => exact generic _ _ _ _ rfl rfl h
    | inf t => simp [absSub, AV.rg] at h
  | inf s => cases b <;> simp [absSub, AV.rg] at h

theorem mulOk_sound {k lo hi v : Int} (h : mulOk k lo hi) (h1 : lo ≤ v) (h2 : v ≤ hi) :
    v * k = 0 → 0 ≤ v ∧ 0 ≤ k := by
  intro hz
  rcases Int.mul_eq_zero.mp hz with hv | hk
  · unfold mulOk at h; omega
  · unfold mulOk at h; omega

theorem absMulRng_sound {a b r : AV} {ya yb : F64} (ha : a.Den x ya) (hb : b.Den x yb)
    (h : absMulRng a b = some r) : r.Den x (F64.mul ya yb) := by
  unfold absMulRng at h
  split at h
  · next l1 h1 l2 h2 r1 r2 =>
    split at h
    · next hn =>
      exact rng_op ha hb r1 r2 h F64.mul (· * ·)
        (fun v w v1 _ w1 _ _ _ _ _ g1 g2 => mul_ie v w (by omega) (fun _ => ⟨by omega, by omega⟩))
        (fun v w v1 v2 w1 w2 => ⟨Int.mul_le_mul v1 w1 hn.2 (by omega), Int.mul_le_mul v2 w2 (by omega) (by omega)⟩)
    · cases h
  · cases h

theorem absMul_sound {a b r : AV} {ya yb : F64} (hx : InBox ps 0 x) (ha : a.Den x ya) (hb : b.Den x yb)
    (h : absMul ps a b = some r) : r.Den x (F64.mul ya yb) := by
  cases a with
  | aff f lf hf =>
    cases b with
    | aff g lg hg =>
      simp only [absMul] at h
      split at h
      · next hc =>
        obtain ⟨hd, b1, b2⟩ := mkAff_sound hx h
        have hg' : g.eval x = g.c := eval_const hc.1
        rw [ha.1, hb.1, hg', mul_ie _ _ (by simp only [eval_smul] at b1 b2; rw [Int.mul_comm]; omega)
          (mulOk_sound hc.2 ha.2.1 ha.2.2.1)]
        simpa [Int.mul_comm] using hd
      · split at h
        · next _ hc =>
          obtain ⟨hd, b1, b2⟩ := mkAff_sound hx h
          have hf' : f.eval x = f.c := eval_const hc.1
          rw [ha.1, hb.1, hf', mul_ie _ _ (by simp only [eval_smul] at b1 b2; omega)
            (fun hz => (fun h' => ⟨h'.2, h'.1⟩) (mulOk_sound hc.2 hb.2.1 hb.2.2.1 (by rw [Int.mul_comm]; exact hz)))]
          simpa using hd
        · exact absMulRng_sound ha hb h
    | rng _ _ => exact absMulRng_sound ha hb h
    | inf _ => exact absMulRng_sound ha hb h
  | rng _ _ => exact absMulRng_sound ha hb h
  | inf _ => exact absMulRng_sound ha hb h

theorem dot_div {x : Nat → Int} (m : Int) : ∀ (cs : List Int) (i : Nat), cs.all (fun a => a % m == 0) = true →
    dot cs i x = m * dot (cs.map (· / m)) i x
  | [], _, _ => by simp [dot]
  | a :: as, i, h => by
    simp only [List.all_cons, Bool.and_eq_true, beq_iff_eq] at h
    simp only [List.map, dot, dot_div m as (i + 1) h.2]
    have : a = m * (a / m) := (Int.mul_ediv_cancel' (Int.dvd_of_emod_eq_zero h.1)).symm
    conv => lhs; rw [this]
    grind

theorem absDiv_sound {a b r : AV} {ya yb : F64} (hx : InBox ps 0 x) (ha : a.Den x ya) (hb : b.Den x yb)
    (h : absDiv ps a b = some r) : r.Den x (F64.div ya yb) := by
  cases a with
  | aff f lf hf =>
    cases b with
    | aff g lg hg =>
      simp only [absDiv] at h
      split at h
      · next hc =>
        obtain ⟨hd, -, -⟩ := mkAff_sound hx h
        have hg' : g.eval x = g.c := eval_const hc.1
        have hfe : f.eval x = g.c * (Aff.eval ⟨f.c / g.c, f.cs.map (· / g.c)⟩ x) := by
          simp only [Aff.eval]
          rw [dot_div g.c f.cs 0 hc.2.2.2, Int.mul_add, Int.mul_ediv_cancel' (Int.dvd_of_emod_eq_zero hc.2.2.1)]
        have sa := ha.2.2.2
        unfold Safe at sa
        rw [ha.1, hb.1, hg', div_ie _ _ _ hc.2.1 hfe (by have := ha.2.1; have := ha.2.2.1; omega)]
        exact hd
      · cases h
    | rng _ _ => simp [absDiv] at h
    | inf _ => simp [absDiv] at h
  | rng _ _ => cases b <;> simp [absDiv] at h
  | inf _ => cases b <;> simp [absDiv] at h

theorem dot_split {x : Nat → Int} (m : Int) : ∀ (cs : List Int) (i : Nat),
    dot cs i x = m * dot (cs.map (·.tdiv m)) i x + dot (remL m cs) i x
  | [], _ => by simp [dot, remL]
  | a :: as, i => by
    simp only [remL, List.map, dot] at *
    rw [dot_split m as (i + 1)]
    simp only [remL]
    grind

theorem split_sound {f q r : Aff} {m : Int} (hx : InBox ps 0 x) (hm : 0 < m) (h : split ps f m = some (q, r)) :
    f.eval x = m * q.eval x + r.eval x ∧ 0 ≤ r.eval x ∧ r.eval x < m := by
  unfold split at h
  split at h
  · next l hh hr =>
    split at h
    · next heq =>
      simp only [Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      have hb := affRg_sound hx hr
      simp only [eval_mk] at hb ⊢
      have hk1 : l / m ≤ (f.c + dot (remL m f.cs) 0 x) / m := Int.ediv_le_ediv hm hb.1
      have hk2 : (f.c + dot (remL m f.cs) 0 x) / m ≤ hh / m := Int.ediv_le_ediv hm hb.2
      generalize hR : f.c + dot (remL m f.cs) 0 x = R at hk1 hk2
      have hq : R / m = l / m := by omega
      have e1 := Int.emod_add_mul_ediv R m
      have e2 := Int.emod_nonneg R (show m ≠ 0 by omega)
      have e3 := Int.emod_lt_of_pos R hm
      rw [hq] at e1
      have hfx : f.c + dot f.cs 0 x = m * dot (f.cs.map (·.tdiv m)) 0 x + R := by
        rw [dot_split m f.cs 0] at *; omega
      refine ⟨?_, ?_, ?_⟩
      · show f.c + dot f.cs 0 x = _
        rw [hfx]
        have : f.c - l / m * m + dot (remL m f.cs) 0 x = R - l / m * m := by omega
        rw [this, Int.mul_add]
        grind
      · have : f.c - l / m * m + dot (remL m f.cs) 0 x = R % m := by
          rw [Int.mul_comm] at e1; omega
        omega
      · have : f.c - l / m * m + dot (remL m f.cs) 0 x = R % m := by
          rw [Int.mul_comm] at e1; omega
        omega
    · cases h
  · cases h

theorem ie_inj {v w : Int} (h : ie v = ie w) : v = w := by
  have := congrArg (F64.eq (ie v)) h
  rw [eq_ie, eq_ie] at this
  simp at this; exact this

theorem absRem_sound {a b r : AV} {ya yb : F64} (hx : InBox ps 0 x) (ha : a.Den x ya) (hb : b.Den x yb)
    (h : absRem ps a b = some r) : r.Den x (F64.rem ya yb) := by
  unfold absRem at h
  split at h
  · next la ha' lb hb' r1 r2 =>
    split at h
    · next hn =>
      obtain ⟨v, hv, v1, v2, sv⟩ := AV.den_rg ha r1
      obtain ⟨w, hw, w1, w2, sw⟩ := AV.den_rg hb r2
      have hrem : F64.rem ya yb = ie (v % w) := by rw [hv, hw]; exact rem_ie v w (by omega) (by omega)
      have hw0 : w ≠ 0 := by omega
      have fallback : mkRng 0 (min ha' (hb' - 1)) = some r → r.Den x (F64.rem ya yb) := by
        intro hm
        rw [hrem]
        have e2 := Int.emod_nonneg v hw0
        have e3 := Int.emod_lt_of_pos v (show 0 < w by omega)
        have e4 : v % w ≤ v := by
          have := Int.emod_add_mul_ediv v w
          have : 0 ≤ w * (v / w) := Int.mul_nonneg (by omega) (Int.ediv_nonneg (by omega) (by omega))
          omega
        exact (mkRng_sound hm e2 (by omega)).1
      split at h
      · next hlt =>
        simp only [Option.some.injEq] at h
        subst h
        have : v % w = v := Int.emod_eq_of_lt (by omega) (by omega)
        rw [hrem, this, ← hv]
        exact ha
      · cases a with
        | aff f lf hf =>
          cases b with
          | aff g lg hg =>
            simp only at h
            split at h
            · next hc =>
              split at h
              · next q r' hs =>
                have hg' : g.eval x = g.c := eval_const hc
                have hwv : w = g.c := by
                  have h1 : ie w = ie (g.eval x) := hw.symm.trans hb.1
                  rw [hg'] at h1
                  exact ie_inj h1
                have hm0 : 0 < g.c := by omega
                obtain ⟨e1, e2, e3⟩ := split_sound hx hm0 hs
                obtain ⟨hd, -, -⟩ := mkAff_sound hx h
                have hvf : v = f.eval x := ie_inj (hv.symm.trans ha.1)
                rw [hrem, hwv, hvf, e1]
                have : (g.c * q.eval x + r'.eval x) % g.c = r'.eval x := by
                  rw [Int.add_comm, Int.add_mul_emod_self_left]
                  exact Int.emod_eq_of_lt e2 e3
                rw [this]
                exact hd
              · exact fallback h
            · exact fallback h
          | rng _ _ => exact fallback h
          | inf _ => exact fallback h
        | rng _ _ => exact fallback h
        | inf _ => exact fallback h
    · cases h
  · cases h

theorem absMin_sound {a b r : AV} {ya yb : F64} (hx : InBox ps 0 x) (ha : a.Den x ya) (hb : b.Den x yb)
    (h : absMin ps a b = some r) : r.Den x (F64.min ya yb) := by
  have fin : ∀ l1 h1 l2 h2, a.rg = some (l1, h1) → b.rg = some (l2, h2) → ∀ l h, diffRg ps a b = some (l, h) →
      (if 0 ≤ l then some a else if h ≤ 0 then some b else mkRng (min l1 l2) (min h1 h2)) = some r →
      r.Den x (F64.min ya yb) := by
    intro l1 h1 l2 h2 r1 r2 l h hd hm
    obtain ⟨v, w, hv, hw, d1, d2, -, -, -, -⟩ := diffRg_sound hx ha hb hd
    obtain ⟨v', hv', v1, v2, -⟩ := AV.den_rg ha r1
    obtain ⟨w', hw', w1, w2, -⟩ := AV.den_rg hb r2
    have e1 : v' = v := ie_inj (hv'.symm.trans hv)
    have e2 : w' = w := ie_inj (hw'.symm.trans hw)
    subst e1 e2
    have hmin : F64.min ya yb = ie (min v' w') := by rw [hv, hw]; exact min_ie v' w'
    split at hm
    · simp only [Option.some.injEq] at hm; subst hm
      rw [hmin, Int.min_eq_left (by omega), ← hv]; exact ha
    · split at hm
      · simp only [Option.some.injEq] at hm; subst hm
        rw [hmin, Int.min_eq_right (by omega), ← hw]; exact hb
      · rw [hmin]
        exact (mkRng_sound hm (by omega) (by omega)).1
  have infR : ∀ s l1 h1, a.rg = some (l1, h1) → b = .inf s →
      (if s then AV.inf true else a) = r → r.Den x (F64.min ya yb) := by
    intro s l1 h1 r1 hbs hr
    subst hbs
    obtain ⟨v, hv, -, -, -⟩ := AV.den_rg ha r1
    have hb' : yb = .inf s := hb
    rw [hv, hb', min_ie_inf]
    cases s
    · simp only [Bool.false_eq_true, ↓reduceIte] at hr; subst hr; rw [← hv]; exact ha
    · simp only [↓reduceIte] at hr; subst hr; rfl
  have infL : ∀ s l2 h2, b.rg = some (l2, h2) → a = .inf s →
      (if s then AV.inf true else b) = r → r.Den x (F64.min ya yb) := by
    intro s l2 h2 r2 has hr
    subst has
    obtain ⟨w, hw, -, -, -⟩ := AV.den_rg hb r2
    have ha' : ya = .inf s := ha
    rw [hw, ha', min_inf_ie]
    cases s
    · simp only [Bool.false_eq_true, ↓reduceIte] at hr; subst hr; rw [← hw]; exact hb
    · simp only [↓reduceIte] at hr; subst hr; rfl
  cases a with
  | inf s =>
    cases b with
    | inf t =>
      simp only [absMin, Option.some.injEq] at h; subst h
      have ha' : ya = .inf s := ha
      have hb' : yb = .inf t := hb
      rw [ha', hb']
      cases s <;> cases t <;> rfl
    | aff g lg hg =>
      simp only [absMin, AV.rg, Option.map_some, Option.some.injEq] at h
      exact infL s _ _ rfl rfl h
    | rng lg hg =>
      simp only [absMin, AV.rg, Option.map_some, Option.some.injEq] at h
      exact infL s _ _ rfl rfl h
  | aff f lf hf =>
    cases b with
    | inf t =>
      simp only [absMin, AV.rg, Option.map_some, Option.some.injEq] at h
      exact infR t _ _ rfl rfl h
    | aff g lg hg =>
      simp only [absMin] at h
      split at h
      · next l hh _ _ _ _ hd r1 r2 => exact fin _ _ _ _ r1 r2 _ _ hd h
      · cases h
    | rng lg hg =>
      simp only [absMin] at h
      split at h
      · next l hh _ _ _ _ hd r1 r2 => exact fin _ _ _ _ r1 r2 _ _ hd h
      · cases h
  | rng lf hf =>
    cases b with
    | inf t =>
      simp only [absMin, AV.rg, Option.map_some, Option.some.injEq] at h
      exact infR t _ _ rfl rfl h
    | aff g lg hg =>
      simp only [absMin] at h
      split at h
      · next l hh _ _ _ _ hd r1 r2 => exact fin _ _ _ _ r1 r2 _ _ hd h
      · cases h
    | rng lg hg =>
      simp only [absMin] at h
      split at h
      · next l hh _ _ _ _ hd r1 r2 => exact fin _ _ _ _ r1 r2 _ _ hd h
      · cases h

theorem absMax_sound {a b r : AV} {ya yb : F64} (hx : InBox ps 0 x) (ha : a.Den x ya) (hb : b.Den x yb)
    (h : absMax ps a b = some r) : r.Den x (F64.max ya yb) := by
  have fin : ∀ l1 h1 l2 h2, a.rg = some (l1, h1) → b.rg = some (l2, h2) → ∀ l h, diffRg ps a b = some (l, h) →
      (if 0 ≤ l then some b else if h ≤ 0 then some a else mkRng (max l1 l2) (max h1 h2)) = some r →
      r.Den x (F64.max ya yb) := by
    intro l1 h1 l2 h2 r1 r2 l h hd hm
    obtain ⟨v, w, hv, hw, d1, d2, -, -, -, -⟩ := diffRg_sound hx ha hb hd
    obtain ⟨v', hv', v1, v2, -⟩ := AV.den_rg ha r1
    obtain ⟨w', hw', w1, w2, -⟩ := AV.den_rg hb r2
    have e1 : v' = v := ie_inj (hv'.symm.trans hv)
    have e2 : w' = w := ie_inj (hw'.symm.trans hw)
    subst e1 e2
    have hmax : F64.max ya yb = ie (max v' w') := by rw [hv, hw]; exact max_ie v' w'
    split at hm
    · simp only [Option.some.injEq] at hm; subst hm
      rw [hmax, Int.max_eq_right (by omega), ← hw]; exact hb
    · split at hm
      · simp only [Option.some.injEq] at hm; subst hm
        rw [hmax, Int.max_eq_left (by omega), ← hv]; exact ha
      · rw [hmax]
        exact (mkRng_sound hm (by omega) (by omega)).1
  have infR : ∀ s l1 h1, a.rg = some (l1, h1) → b = .inf s →
      (if s then a else AV.inf false) = r → r.Den x (F64.max ya yb) := by
    intro s l1 h1 r1 hbs hr
    subst hbs
    obtain ⟨v, hv, -, -, -⟩ := AV.den_rg ha r1
    have hb' : yb = .inf s := hb
    rw [hv, hb', max_ie_inf]
    cases s
    · simp only [Bool.false_eq_true, ↓reduceIte] at hr; subst hr; rfl
    · simp only [↓reduceIte] at hr; subst hr; rw [← hv]; exact ha
  have infL : ∀ s l2 h2, b.rg = some (l2, h2) → a = .inf s →
      (if s then b else AV.inf false) = r → r.Den x (F64.max ya yb) := by
    intro s l2 h2 r2 has hr
    subst has
    obtain ⟨w, hw, -, -, -⟩ := AV.den_rg hb r2
    have ha' : ya = .inf s := ha
    rw [hw, ha', max_inf_ie]
    cases s
    · simp only [Bool.false_eq_true, ↓reduceIte] at hr; subst hr; rfl
    · simp only [↓reduceIte] at hr; subst hr; rw [← hw]; exact hb
  cases a with
  | inf s =>
    cases b with
    | inf t =>
      simp only [absMax, Option.some.injEq] at h; subst h
      have ha' : ya = .inf s := ha
      have hb' : yb = .inf t := hb
      rw [ha', hb']
      cases s <;> cases t <;> rfl
    | aff g lg hg =>
      simp only [absMax, AV.rg, Option.map_some, Option.some.injEq] at h
      exact infL s _ _ rfl rfl h
    | rng lg hg =>
      simp only [absMax, AV.rg, Option.map_some, Option.some.injEq] at h
      exact infL s _ _ rfl rfl h
  | aff f lf hf =>
    cases b with
    | inf t =>
      simp only [absMax, AV.rg, Option.map_some, Option.some.injEq] at h
      exact infR t _ _ rfl rfl h
    | aff g lg hg =>
      simp only [absMax] at h
      split at h
      · next l hh _ _ _ _ hd r1 r2 => exact fin _ _ _ _ r1 r2 _ _ hd h
      · cases h
    | rng lg hg =>
      simp only [absMax] at h
      split at h
      · next l hh _ _ _ _ hd r1 r2 => exact fin _ _ _ _ r1 r2 _ _ hd h
      · cases h
  | rng lf hf =>
    cases b with
    | inf t =>
      simp only [absMax, AV.rg, Option.map_some, Option.some.injEq] at h
      exact infR t _ _ rfl rfl h
    | aff g lg hg =>
      simp only [absMax] at h
      split at h
      · next l hh _ _ _ _ hd r1 r2 => exact fin _ _ _ _ r1 r2 _ _ hd h
      · cases h
    | rng lg hg =>
      simp only [absMax] at h
      split at h
      · next l hh _ _ _ _ hd r1 r2 => exact fin _ _ _ _ r1 r2 _ _ hd h
      · cases h

theorem absBin_sound {op : NBin} {a b r : AV} {ya yb : F64} (hx : InBox ps 0 x) (ha : a.Den x ya)
    (hb : b.Den x yb) (h : absBin ps op a b = some r) : r.Den x (F64.bin op ya yb) := by
  cases op with
  | add => exact absAdd_sound hx ha hb h
  | sub => exact absSub_sound hx ha hb h
  | mul => exact absMul_sound hx ha hb h
  | div => exact absDiv_sound hx ha hb h
  | rem => exact absRem_sound hx ha hb h
  | min => exact absMin_sound hx ha hb h
  | max => exact absMax_sound hx ha hb h
  | _ => cases h

theorem absWrap_sound {base : Int} {a r : AV} {y : F64} (hx : InBox ps 0 x) (ha : a.Den x y)
    (h : absWrap ps base a = some r)
    {F : F64 → F64} (hF : ∀ v : Int, -lim < v → v < lim → F (ie v) = ie ((v - base) % 4294967296 + base)) :
    r.Den x (F y) := by
  cases a with
  | aff f lo hi =>
    obtain ⟨hv, v1, v2, sv⟩ := ha
    unfold Safe at sv
    rw [hv, hF _ (by omega) (by omega)]
    simp only [absWrap] at h
    split at h
    · next hk =>
      obtain ⟨hd, -, -⟩ := mkAff_sound hx h
      simp only [eval_add, eval_mk, dot] at hd
      have hwin : (f.eval x - base) % 4294967296 + base =
          f.eval x + (-((lo - base) / 4294967296 * 4294967296) + 0) := by omega
      rw [hwin]; exact hd
    · exact (mkRng_sound h (by omega) (by omega)).1
  | rng lo hi =>
    obtain ⟨v, hv, v1, v2, sv⟩ := ha
    unfold Safe at sv
    rw [hv, hF _ (by omega) (by omega)]
    simp only [absWrap] at h
    split at h
    · next hk => exact (mkRng_sound h (by omega) (by omega)).1
    · exact (mkRng_sound h (by omega) (by omega)).1
  | inf _ => simp [absWrap] at h

theorem absNeg_sound {a r : AV} {y : F64} (hx : InBox ps 0 x) (ha : a.Den x y) (h : absNeg ps a = some r) :
    r.Den x (F64.neg y) := by
  cases a with
  | inf s =>
    simp only [absNeg, Option.some.injEq] at h; subst h
    have : y = .inf s := ha
    rw [this]; rfl
  | aff f lo hi =>
    simp only [absNeg] at h
    split at h
    · next hn =>
      obtain ⟨hd, -, -⟩ := mkAff_sound hx h
      rw [ha.1, neg_ie _ (by have := ha.2.1; have := ha.2.2.1; omega)]
      simpa using hd
    · cases h
  | rng lo hi =>
    simp only [absNeg] at h
    split at h
    · next hn =>
      obtain ⟨v, hv, v1, v2, -⟩ := ha
      rw [hv, neg_ie _ (by omega)]
      exact (mkRng_sound h (by omega) (by omega)).1
    · cases h

theorem absUn_sound {op : NUn} {a r : AV} {y : F64} (hx : InBox ps 0 x) (ha : a.Den x y)
    (h : absUn ps op a = some r) : r.Den x (F64.un op y) := by
  have ident : ∀ (F : F64 → F64), (∀ v, F (ie v) = ie v) → (∀ s, F (.inf s) = .inf s) → some a = some r →
      r.Den x (F y) := by
    intro F h1 h2 he
    simp only [Option.some.injEq] at he; subst he
    cases a with
    | aff f lo hi => rw [ha.1, h1]; exact ⟨rfl, ha.2⟩
    | rng lo hi => obtain ⟨v, hv, hh⟩ := ha; rw [hv, h1]; exact ⟨v, rfl, hh⟩
    | inf s => have : y = .inf s := ha; rw [this, h2]; rfl
  cases op with
  | neg => exact absNeg_sound hx ha h
  | floor => exact ident F64.floor floor_ie (fun _ => rfl) h
  | ceil => exact ident F64.ceil ceil_ie (fun s => by cases s <;> rfl) h
  | trunc => exact ident F64.trunc trunc_ie (fun _ => rfl) h
  | int32 =>
    exact absWrap_sound hx ha h (fun v _ _ => by rw [int32_ie]; exact congrArg ie (by omega))
  | uint32 =>
    exact absWrap_sound hx ha h (fun v _ _ => by rw [uint32_ie]; exact congrArg ie (by omega))
  | _ => cases h

/-! ### Tests -/

theorem dvd_dot {x : Nat → Int} : ∀ (cs : List Int) (i : Nat), (gcdL cs : Int) ∣ dot cs i x
  | [], _ => by simp [dot]
  | a :: as, i => by
    simp only [gcdL, dot]
    apply Int.dvd_add
    · apply Int.dvd_trans _ (Int.dvd_mul_right a (x i))
      exact Int.ofNat_dvd_left.mpr (Nat.gcd_dvd_left _ _)
    · apply Int.dvd_trans _ (dvd_dot as (i + 1))
      exact Int.ofNat_dvd.mpr (Nat.gcd_dvd_right _ _)

theorem single_sound {x : Nat → Int} : ∀ (cs : List Int) (j : Nat) {k : Nat} {a : Int}, single cs j = some (k, a) →
    a ≠ 0 ∧ dot cs j x = a * x k
  | [], _, _, _, h => by simp [single] at h
  | b :: bs, j, k, a, h => by
    simp only [single] at h
    split at h
    · next hb => rw [dot, hb, Int.zero_mul, Int.zero_add]; exact single_sound bs (j + 1) h
    · split at h
      · next hz =>
        simp only [Option.some.injEq, Prod.mk.injEq] at h
        obtain ⟨rfl, rfl⟩ := h
        next hb => exact ⟨hb, by rw [dot, dot_zero bs (j + 1) hz, Int.add_zero]⟩
      · cases h

theorem InBox.get : ∀ {ps : List Prm} {i : Nat} {x : Nat → Int}, InBox ps i x → ∀ {k : Nat} {p : Prm},
    ps[k]? = some p → x (i + k) ∉ p.ex
  | [], _, _, _, _, _, h => by simp at h
  | q :: qs, i, x, hb, 0, p, h => by
    simp only [List.getElem?_cons_zero, Option.some.injEq] at h; subst h
    exact hb.1.2.2
  | q :: qs, i, x, hb, k + 1, p, h => by
    simp only [List.getElem?_cons_succ] at h
    have := InBox.get hb.2 h
    rwa [show i + 1 + k = i + (k + 1) by omega] at this

theorem neZero_sound {d : Aff} (hx : InBox ps 0 x) (h : neZero ps d = true) : d.eval x ≠ 0 := by
  unfold neZero at h
  simp only [Bool.or_eq_true, Bool.and_eq_true, bne_iff_ne, ne_eq] at h
  intro hz
  rcases h with ⟨hg, hc⟩ | h
  · apply hc
    have hd := dvd_dot (x := x) d.cs 0
    unfold Aff.eval at hz
    have : (gcdL d.cs : Int) ∣ d.c := by
      have : d.c = -(dot d.cs 0 x) := by omega
      rw [this]; exact Int.dvd_neg.mpr hd
    exact Int.emod_eq_zero_of_dvd this
  · split at h
    · next k a hs =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨hm, hp⟩ := h
      split at hp
      · next p hpk =>
        have hex := InBox.get hx hpk
        rw [Nat.zero_add] at hex
        obtain ⟨ha0, hdot⟩ := single_sound (x := x) d.cs 0 hs
        unfold Aff.eval at hz
        rw [hdot] at hz
        have hxk : x k = -d.c / a := by
          have : a * x k = -d.c := by omega
          rw [← this, Int.mul_ediv_cancel_left _ ha0]
        rw [← hxk] at hp
        exact hex (List.contains_iff_mem.mp hp)
      · cases hp
    · cases h

theorem absLt_sound {a b : AV} {ya yb : F64} {t : Bool} (hx : InBox ps 0 x) (ha : a.Den x ya) (hb : b.Den x yb)
    (h : absLt ps a b = some t) : F64.test .lt ya yb = t := by
  have fin : ∀ l h, diffRg ps a b = some (l, h) →
      (if 0 < l then some true else if h ≤ 0 then some false else none) = some t → F64.test .lt ya yb = t := by
    intro l hh hd hm
    obtain ⟨v, w, hv, hw, d1, d2, -⟩ := diffRg_sound hx ha hb hd
    change F64.lt ya yb = t
    rw [hv, hw, lt_ie]
    split at hm
    · simp only [Option.some.injEq] at hm; subst hm; exact decide_eq_true (by omega)
    · split at hm
      · simp only [Option.some.injEq] at hm; subst hm; exact decide_eq_false (by omega)
      · cases hm
  cases a with
  | inf s =>
    have ha' : ya = .inf s := ha
    cases b with
    | inf t' =>
      simp only [absLt, Option.some.injEq] at h; subst h
      rw [ha', show yb = .inf t' from hb]; cases s <;> cases t' <;> rfl
    | aff g _ _ =>
      simp only [absLt, AV.rg, Option.map_some, Option.some.injEq] at h; subst h
      rw [ha', hb.1]; exact lt_inf_ie _ _
    | rng _ _ =>
      simp only [absLt, AV.rg, Option.map_some, Option.some.injEq] at h; subst h
      obtain ⟨w, hw, -⟩ := hb
      rw [ha', hw]; exact lt_inf_ie _ _
  | aff f _ _ =>
    cases b with
    | inf t' =>
      simp only [absLt, AV.rg, Option.map_some, Option.some.injEq] at h; subst h
      rw [ha.1, show yb = .inf t' from hb]; exact lt_ie_inf _ _
    | aff _ _ _ =>
      simp only [absLt] at h; split at h
      · next l hh hd => exact fin _ _ hd h
      · cases h
    | rng _ _ =>
      simp only [absLt] at h; split at h
      · next l hh hd => exact fin _ _ hd h
      · cases h
  | rng _ _ =>
    cases b with
    | inf t' =>
      simp only [absLt, AV.rg, Option.map_some, Option.some.injEq] at h; subst h
      obtain ⟨v, hv, -⟩ := ha
      rw [hv, show yb = .inf t' from hb]; exact lt_ie_inf _ _
    | aff _ _ _ =>
      simp only [absLt] at h; split at h
      · next l hh hd => exact fin _ _ hd h
      · cases h
    | rng _ _ =>
      simp only [absLt] at h; split at h
      · next l hh hd => exact fin _ _ hd h
      · cases h

theorem absLe_sound {a b : AV} {ya yb : F64} {t : Bool} (hx : InBox ps 0 x) (ha : a.Den x ya) (hb : b.Den x yb)
    (h : absLe ps a b = some t) : F64.test .le ya yb = t := by
  have fin : ∀ l h, diffRg ps a b = some (l, h) →
      (if 0 ≤ l then some true else if h < 0 then some false else none) = some t → F64.test .le ya yb = t := by
    intro l hh hd hm
    obtain ⟨v, w, hv, hw, d1, d2, -⟩ := diffRg_sound hx ha hb hd
    change F64.le ya yb = t
    rw [hv, hw, le_ie]
    split at hm
    · simp only [Option.some.injEq] at hm; subst hm; exact decide_eq_true (by omega)
    · split at hm
      · simp only [Option.some.injEq] at hm; subst hm; exact decide_eq_false (by omega)
      · cases hm
  have leI : ∀ (p q : F64), F64.le p q = (F64.lt p q || F64.eq p q) := fun _ _ => rfl
  cases a with
  | inf s =>
    have ha' : ya = .inf s := ha
    cases b with
    | inf t' =>
      simp only [absLe, Option.some.injEq] at h; subst h
      rw [ha', show yb = .inf t' from hb]; cases s <;> cases t' <;> rfl
    | aff g _ _ =>
      simp only [absLe, AV.rg, Option.map_some, Option.some.injEq] at h; subst h
      change F64.le _ _ = _
      rw [ha', hb.1, leI, lt_inf_ie, eq_inf_ie, Bool.or_false]
    | rng _ _ =>
      simp only [absLe, AV.rg, Option.map_some, Option.some.injEq] at h; subst h
      obtain ⟨w, hw, -⟩ := hb
      change F64.le _ _ = _
      rw [ha', hw, leI, lt_inf_ie, eq_inf_ie, Bool.or_false]
  | aff f _ _ =>
    cases b with
    | inf t' =>
      simp only [absLe, AV.rg, Option.map_some, Option.some.injEq] at h; subst h
      change F64.le _ _ = _
      rw [ha.1, show yb = .inf t' from hb, leI, lt_ie_inf, eq_ie_inf, Bool.or_false]
    | aff _ _ _ =>
      simp only [absLe] at h; split at h
      · next l hh hd => exact fin _ _ hd h
      · cases h
    | rng _ _ =>
      simp only [absLe] at h; split at h
      · next l hh hd => exact fin _ _ hd h
      · cases h
  | rng _ _ =>
    cases b with
    | inf t' =>
      simp only [absLe, AV.rg, Option.map_some, Option.some.injEq] at h; subst h
      obtain ⟨v, hv, -⟩ := ha
      change F64.le _ _ = _
      rw [hv, show yb = .inf t' from hb, leI, lt_ie_inf, eq_ie_inf, Bool.or_false]
    | aff _ _ _ =>
      simp only [absLe] at h; split at h
      · next l hh hd => exact fin _ _ hd h
      · cases h
    | rng _ _ =>
      simp only [absLe] at h; split at h
      · next l hh hd => exact fin _ _ hd h
      · cases h

theorem absEq_sound {a b : AV} {ya yb : F64} {t : Bool} (hx : InBox ps 0 x) (ha : a.Den x ya) (hb : b.Den x yb)
    (h : absEq ps a b = some t) : F64.test .eq ya yb = t := by
  have fin : ∀ l h, diffRg ps a b = some (l, h) →
      (if 0 < l ∨ h < 0 then some false else if l = 0 ∧ h = 0 then some true else none) = some t →
      F64.test .eq ya yb = t := by
    intro l hh hd hm
    obtain ⟨v, w, hv, hw, d1, d2, -⟩ := diffRg_sound hx ha hb hd
    change F64.eq ya yb = t
    rw [hv, hw, eq_ie]
    split at hm
    · simp only [Option.some.injEq] at hm; subst hm; exact decide_eq_false (by omega)
    · split at hm
      · simp only [Option.some.injEq] at hm; subst hm; exact decide_eq_true (by omega)
      · cases hm
  cases a with
  | inf s =>
    have ha' : ya = .inf s := ha
    cases b with
    | inf t' =>
      simp only [absEq, Option.some.injEq] at h; subst h
      rw [ha', show yb = .inf t' from hb]; cases s <;> cases t' <;> rfl
    | aff g _ _ =>
      simp only [absEq, AV.rg, Option.map_some, Option.some.injEq] at h; subst h
      rw [ha', hb.1]; exact eq_inf_ie _ _
    | rng _ _ =>
      simp only [absEq, AV.rg, Option.map_some, Option.some.injEq] at h; subst h
      obtain ⟨w, hw, -⟩ := hb
      rw [ha', hw]; exact eq_inf_ie _ _
  | aff f _ _ =>
    cases b with
    | inf t' =>
      simp only [absEq, AV.rg, Option.map_some, Option.some.injEq] at h; subst h
      rw [ha.1, show yb = .inf t' from hb]; exact eq_ie_inf _ _
    | aff g _ _ =>
      simp only [absEq] at h
      change F64.eq ya yb = t
      rw [ha.1, hb.1, eq_ie]
      split at h
      · next hc =>
        simp only [Option.some.injEq] at h; subst h
        have := eval_const (x := x) hc.1
        simp only [eval_sub] at this
        exact decide_eq_true (by omega)
      · split at h
        · next l hh hr =>
          split at h
          · next hn =>
            simp only [Option.some.injEq] at h; subst h
            have hb' := affRg_sound hx hr
            simp only [eval_sub] at hb'
            apply decide_eq_false
            rcases hn with hn | hn | hn
            · omega
            · omega
            · have := neZero_sound hx hn
              simp only [eval_sub] at this
              omega
          · cases h
        · cases h
    | rng _ _ =>
      simp only [absEq] at h; split at h
      · next l hh hd => exact fin _ _ hd h
      · cases h
  | rng _ _ =>
    cases b with
    | inf t' =>
      simp only [absEq, AV.rg, Option.map_some, Option.some.injEq] at h; subst h
      obtain ⟨v, hv, -⟩ := ha
      rw [hv, show yb = .inf t' from hb]; exact eq_ie_inf _ _
    | aff _ _ _ =>
      simp only [absEq] at h; split at h
      · next l hh hd => exact fin _ _ hd h
      · cases h
    | rng _ _ =>
      simp only [absEq] at h; split at h
      · next l hh hd => exact fin _ _ hd h
      · cases h

theorem absTruthy_sound {a : AV} {y z : F64} {t : Bool} (ha : a.Den x y) (h : absTruthy a = some t) :
    F64.test .truthy y z = t := by
  change F64.truthy y = t
  have rng : ∀ lo hi v, y = ie v → lo ≤ v → v ≤ hi →
      (if 0 < lo ∨ hi < 0 then some true else if lo = 0 ∧ hi = 0 then some false else none) = some t →
      F64.truthy y = t := by
    intro lo hi v hv v1 v2 hm
    rw [hv, truthy_ie]
    split at hm
    · simp only [Option.some.injEq] at hm; subst hm; exact decide_eq_true (by omega)
    · split at hm
      · simp only [Option.some.injEq] at hm; subst hm; exact decide_eq_false (by omega)
      · cases hm
  cases a with
  | inf s =>
    simp only [absTruthy, Option.some.injEq] at h; subst h
    rw [show y = .inf s from ha]; rfl
  | aff f lo hi =>
    simp only [absTruthy] at h
    split at h
    · next hc =>
      simp only [Option.some.injEq] at h; subst h
      rw [ha.1, truthy_ie, eval_const hc.1, hc.2]; rfl
    · exact rng lo hi _ ha.1 ha.2.1 ha.2.2.1 h
  | rng lo hi =>
    obtain ⟨v, hv, v1, v2, -⟩ := ha
    exact rng lo hi v hv v1 v2 h

theorem absTest_sound {op : NTest} {a b : AV} {ya yb : F64} {t : Bool} (hx : InBox ps 0 x) (ha : a.Den x ya)
    (hb : b.Den x yb) (h : absTest ps op a b = some t) : F64.test op ya yb = t := by
  cases op with
  | lt => exact absLt_sound hx ha hb h
  | le => exact absLe_sound hx ha hb h
  | eq => exact absEq_sound hx ha hb h
  | truthy => exact absTruthy_sound ha h

/-! ### Terms -/

theorem litAV_sound {y : F64} {r : AV} (h : litAV y = some r) : r.Den x y := by
  unfold litAV at h
  split at h
  · simp only [Option.some.injEq] at h; subst h
    exact ⟨rfl, by simp [Aff.eval, dot], by simp [Aff.eval, dot], by unfold Safe; omega⟩
  · next s m =>
    split at h
    · next hm =>
      simp only [Option.some.injEq] at h; subst h
      cases s
      · have ev : Aff.eval ⟨(m : Int), []⟩ x = m := by simp [Aff.eval, dot]
        simp only [Bool.false_eq_true, ↓reduceIte]
        refine ⟨?_, by rw [ev]; omega, by rw [ev]; omega, by unfold Safe; omega⟩
        rw [ev]
        exact fin_ie (v := (m : Int)) (by omega) (by simp) (by simp)
      · have ev : Aff.eval ⟨-(m : Int), []⟩ x = -(m : Int) := by simp [Aff.eval, dot]
        simp only [↓reduceIte]
        refine ⟨?_, by rw [ev]; omega, by rw [ev]; omega, by unfold Safe; omega⟩
        rw [ev]
        exact fin_ie (v := -(m : Int)) (by omega) (by simp; omega) (by simp)
    · cases h
  · simp only [Option.some.injEq] at h; subst h; rfl
  · cases h

theorem lookup_ok {ρ : Nat → F64} : ∀ {V : List (Nat × Aff)} {j : Nat} {f : Aff}, VarsOk ρ x V →
    lookup V j = some f → ρ j = F64.ofInt (f.eval x)
  | [], _, _, _, h => by simp [lookup] at h
  | (k, g) :: V, j, f, hv, h => by
    simp only [lookup] at h
    split at h
    · next hk => simp only [Option.some.injEq] at h; subst h hk; exact hv.1
    · exact lookup_ok hv.2 h

theorem absRoundDiv_sound {up : Bool} {a b r : AV} {ya yb : F64} (hx : InBox ps 0 x) (ha : a.Den x ya)
    (hb : b.Den x yb) (h : absRoundDiv ps up a b = some r) {F : F64 → F64}
    (hF : ∀ v m : Int, 0 ≤ v → v < lim → 0 < m → m < lim → F (F64.div (ie v) (ie m)) = ie ((v + rdOff up m) / m)) :
    r.Den x (F (F64.div ya yb)) := by
  have quot : ∀ (v lo hi m : Int), ya = ie v → yb = ie m → lo ≤ v → v ≤ hi → Safe lo hi → 0 ≤ lo → 0 < m →
      m < lim → mkRng ((lo + rdOff up m) / m) ((hi + rdOff up m) / m) = some r → r.Den x (F (F64.div ya yb)) := by
    intro v lo hi m hv hm v1 v2 sv hl hm0 hm1 hr
    unfold Safe at sv
    rw [hv, hm, hF v m (by omega) (by omega) hm0 hm1]
    exact (mkRng_sound hr (Int.ediv_le_ediv hm0 (by omega)) (Int.ediv_le_ediv hm0 (by omega))).1
  cases a with
  | aff f lo hi =>
    cases b with
    | aff g lg hg =>
      simp only [absRoundDiv] at h
      split at h
      · next hc =>
        have hg' : g.eval x = g.c := eval_const hc.1
        have hm : yb = ie g.c := by rw [hb.1, hg']
        have sb := hb.2.2.2
        unfold Safe at sb
        have hm1 : g.c < lim := by have := hb.2.2.1; omega
        split at h
        · next q r' hs =>
          obtain ⟨e1, e2, e3⟩ := split_sound hx hc.2.1 hs
          obtain ⟨hd, -, -⟩ := mkAff_sound hx h
          have sa := ha.2.2.2
          unfold Safe at sa
          rw [ha.1, hm, hF _ _ (by have := ha.2.1; omega) (by have := ha.2.2.1; omega) hc.2.1 hm1]
          simp only [eval_add, eval_mk, dot, Int.add_zero] at e1
          rw [e1, Int.add_comm, Int.add_mul_ediv_left _ _ (by omega), Int.ediv_eq_zero_of_lt e2 e3, Int.zero_add]
          exact hd
        · exact quot _ lo hi g.c ha.1 hm ha.2.1 ha.2.2.1 ha.2.2.2 hc.2.2 hc.2.1 hm1 h
      · cases h
    | rng _ _ => simp [absRoundDiv] at h
    | inf _ => simp [absRoundDiv] at h
  | rng lo hi =>
    cases b with
    | aff g lg hg =>
      simp only [absRoundDiv] at h
      split at h
      · next hc =>
        have hg' : g.eval x = g.c := eval_const hc.1
        have hm : yb = ie g.c := by rw [hb.1, hg']
        have hm1 : g.c < lim := by have := hb.2.2.1; have := hb.2.2.2; unfold Safe at this; omega
        obtain ⟨v, hv, v1, v2, sv⟩ := ha
        exact quot v lo hi g.c hv hm v1 v2 sv hc.2.2 hc.2.1 hm1 h
      · cases h
    | rng _ _ => simp [absRoundDiv] at h
    | inf _ => simp [absRoundDiv] at h
  | inf _ => cases b <;> simp [absRoundDiv] at h

theorem rdOf_sound {op : NUn} {up : Bool} (h : rdOf op = some up) :
    ∀ v m : Int, 0 ≤ v → v < lim → 0 < m → m < lim →
      F64.un op (F64.div (ie v) (ie m)) = ie ((v + rdOff up m) / m) := by
  intro v m h1 h2 h3 h4
  cases op <;> simp only [rdOf, Option.some.injEq, reduceCtorEq] at h <;> subst h
  · simp only [rdOff, Bool.false_eq_true, ↓reduceIte, Int.add_zero]
    exact floor_div_ie v m h1 (by omega) h3 (by omega)
  · simp only [rdOff, ↓reduceIte]
    rw [show v + (m - 1) = v + m - 1 by omega]
    exact ceil_div_ie v m h1 (by omega) h3 (by omega)
  · simp only [rdOff, Bool.false_eq_true, ↓reduceIte, Int.add_zero]
    exact trunc_div_ie v m h1 (by omega) h3 (by omega)

theorem absVar_sound {V : List (Nat × Aff)} {ρ : Nat → F64} (hx : InBox ps 0 x) (hρ : VarsOk ρ x V) {j : Nat}
    {r : AV} (h : absVar ps V j = some r) : r.Den x (ρ j) := by
  unfold absVar at h
  split at h
  · next f hf =>
    obtain ⟨hd, b1, b2⟩ := mkAff_sound hx h
    rw [lookup_ok hρ hf, ofInt_ie _ (by omega)]
    exact hd
  · cases h

theorem absBinO_sound {op : NBin} {oa ob : Option AV} {ya yb : F64} {r : AV} (hx : InBox ps 0 x)
    (ha : ∀ u, oa = some u → u.Den x ya) (hb : ∀ w, ob = some w → w.Den x yb) (h : absBinO ps op oa ob = some r) :
    r.Den x (F64.bin op ya yb) := by
  unfold absBinO at h
  split at h
  · next u w => exact absBin_sound hx (ha u rfl) (hb w rfl) h
  · cases h

theorem bindUn_sound {op : NUn} {o : Option AV} {y : F64} {r : AV} (hx : InBox ps 0 x)
    (ho : ∀ u, o = some u → u.Den x y) (h : o.bind (absUn ps op) = some r) : r.Den x (F64.un op y) := by
  cases hu : o with
  | none => rw [hu] at h; cases h
  | some u => rw [hu] at h; exact absUn_sound hx (ho u hu) h

theorem unE_sound {op : NUn} {re : Option AV} {rd : Option (AV × AV)} {y : F64} {r : AV} (hx : InBox ps 0 x)
    (hre : ∀ u, re = some u → u.Den x y)
    (hrd : ∀ u w, rd = some (u, w) → ∃ ya yb, y = F64.div ya yb ∧ u.Den x ya ∧ w.Den x yb)
    (h : unE ps op re rd = some r) : r.Den x (F64.un op y) := by
  unfold unE at h
  split at h
  · next up u w hup =>
    split at h
    · next r' hr =>
      simp only [Option.some.injEq] at h; subst h
      obtain ⟨ya, yb, hy, hu, hw⟩ := hrd u w rfl
      rw [hy]
      exact absRoundDiv_sound hx hu hw hr (rdOf_sound hup)
    · exact bindUn_sound hx hre h
  · exact bindUn_sound hx hre h

theorem absE2_sound {V : List (Nat × Aff)} {ρ : Nat → F64} (hx : InBox ps 0 x) (hρ : VarsOk ρ x V) (e : SymE) :
    (∀ r, (absE2 ps V e).1 = some r → r.Den x (e.eval ρ)) ∧
    (∀ u w, (absE2 ps V e).2 = some (u, w) → ∃ ya yb, e.eval ρ = F64.div ya yb ∧ u.Den x ya ∧ w.Den x yb) := by
  induction e with
  | lit y => exact ⟨fun r h => litAV_sound h, fun u w h => by simp [absE2] at h⟩
  | var j => exact ⟨fun r h => absVar_sound hx hρ h, fun u w h => by simp [absE2] at h⟩
  | bin op a b iha ihb =>
    refine ⟨fun r h => ?_, fun u w h => ?_⟩
    · simp only [absE2] at h
      exact absBinO_sound hx iha.1 ihb.1 h
    · simp only [absE2] at h
      cases op <;> simp only [divArgs, reduceCtorEq] at h
      split at h
      · next u' w' hu hw =>
        simp only [Option.some.injEq, Prod.mk.injEq] at h
        obtain ⟨rfl, rfl⟩ := h
        exact ⟨_, _, rfl, iha.1 _ hu, ihb.1 _ hw⟩
      · cases h
  | un op e ih =>
    refine ⟨fun r h => ?_, fun u w h => by simp [absE2] at h⟩
    simp only [absE2] at h
    exact unE_sound hx ih.1 ih.2 h

theorem absE_sound {V : List (Nat × Aff)} {ρ : Nat → F64} (hx : InBox ps 0 x) (hρ : VarsOk ρ x V)
    (e : SymE) {r : AV} (h : absE ps V e = some r) : r.Den x (e.eval ρ) :=
  (absE2_sound hx hρ e).1 r h

theorem checkAns_sound {V : List (Nat × Aff)} {ρ : Nat → F64} (hx : InBox ps 0 x) (hρ : VarsOk ρ x V)
    {q : Ans} (h : checkAns ps V q = true) : F64.test q.op (q.a.eval ρ) (q.b.eval ρ) = q.r := by
  unfold checkAns at h
  split at h
  · next u w hu hw =>
    have ht : absTest ps q.op u w = some q.r := by simpa using h
    exact absTest_sound hx (absE_sound hx hρ _ hu) (absE_sound hx hρ _ hw) ht
  · cases h

end

/-- **LinGood.** If the checker decides every answer of `o` over the class `(ps, V)`, the
oracle is correct at every valuation of the class. -/
theorem goodLin_sound {ps : List Prm} {V : List (Nat × Aff)} {o : List Ans} (h : goodLin ps V o = true)
    {x : Nat → Int} (hx : InBox ps 0 x) {ρ : Nat → F64} (hρ : VarsOk ρ x V) : Good ρ o := by
  intro q hq
  exact checkAns_sound hx hρ (List.all_eq_true.mp h q hq)

/-- The answers the checker decides are correct; the rest (`o.filter (!checkAns ps V ·)`) are
left to the caller. -/
theorem good_of_rest {ps : List Prm} {V : List (Nat × Aff)} {o : List Ans} {x : Nat → Int}
    (hx : InBox ps 0 x) {ρ : Nat → F64} (hρ : VarsOk ρ x V) (hr : Good ρ (o.filter fun q => !checkAns ps V q)) :
    Good ρ o := by
  intro q hq
  cases hc : checkAns ps V q
  · exact hr q (List.mem_filter.mpr ⟨hq, by simp [hc]⟩)
  · exact checkAns_sound hx hρ hc

/-! ## Class membership

`lin_mem` proves the side goals `InBox ps 0 (vx [...])` and `VarsOk ρ (vx [...]) V` of
`goodLin_sound` for a valuation `ρ` that reduces, at each listed variable, to `F64.ofNat n` or
`F64.ofInt a`: the bounds, exclusions and variable equations become linear facts closed by
`omega` from the hypotheses in context. -/

theorem ofNat_ofInt {n : Nat} {a : Int} (h : (n : Int) = a) : F64.ofNat n = F64.ofInt a := by
  rw [← h]; rfl

theorem ofInt_ofInt {b a : Int} (h : b = a) : F64.ofInt b = F64.ofInt a := by rw [h]

syntax "lin_mem" (" [" Lean.Parser.Tactic.simpLemma,* "]")? : tactic

macro_rules
  | `(tactic| lin_mem $[[$ls,*]]?) => do
    let ls := ls.getD ⟨#[]⟩
    `(tactic| (
      simp only [InBox, VarsOk, vx_zero, vx_succ, vx_nil, eval_add, eval_sub, eval_neg, eval_smul,
        eval_smul_nat, eval_ofNat, eval_P, eval_mk, List.mem_cons, List.not_mem_nil, or_false, and_true,
        true_and, not_false_eq_true, $ls,*]
      repeat' apply And.intro
      all_goals first
        | (apply ofNat_ofInt; omega)
        | (apply ofInt_ofInt; omega)
        | omega))

end Host.Ts.Sim.Lin
