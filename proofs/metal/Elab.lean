import metal.Builtins
import metal.Value

namespace Metal.Elab
open Core Builtins

/-! # Elaboration

From the parsed unit (proofs/metal/Syntax.lean) to the typed core
(proofs/metal/Core.lean) of the instantiated kernel, as Apple's Metal
compiler (metalfe-32023.921.6, `-std=metal4.1 -fmetal-math-mode=safe`, the
default optimization level MLX compiles at) builds it. Everything outside
the rules below is rejected (`none`). Kernel-reducible: every recursion runs
on structural fuel.

* The kernel is the unit's `[[kernel]]` function, instantiated at MLX's
  explicit instantiation (or the only untemplated kernel). Buffer `i` is
  region `i` (pointer parameters hold `⟨i, 0, elem⟩`, `constant` references
  the value loaded there); attribute parameters are `coord`s. A kernel-level
  `return;` leaves the scope the body is then wrapped in.
* Header functions are inlined at each call into a `scope`: parameters get
  fresh slots (by value; pointer parameters are local pointers), `return e`
  sets a result slot and `leave`s. Only called functions are elaborated, and
  only those defined before the kernel; explicit template arguments bind the
  template parameters. Arguments are evaluated left to right; an operand
  evaluated before a call's statements is first saved to a slot when it reads
  memory (assignments evaluate their right side first, as clang does).
* Types: usual arithmetic conversions per Types.lean `common`; implicit
  conversions on initialization, assignment, argument passing and return;
  `float` → `bfloat` only explicitly (implicitly it is a compile error,
  probed), `half` only `float(h)` and `half(x)`, no `half` arithmetic; no float →
  integer conversion. Conditions are converted to `bool`. Vectors convert only
  explicitly and componentwise between floating element types (`float4(v)`,
  AIR `air.convert.f.v4f32.f.v4bf16`, an exact widening); `vec<T, n>(x)`
  fills every component; `metal::vec<T, n>` names a vector type.
* Memory: arrays may have any number of dimensions (`a[i][j][k]`: base plus
  each leading index times its stride in 64 bits, then the last), may hold
  pointers (a thread array; an element reads as a pointer to `const`, and a
  pointer to pointers is never reinterpreted), and `&` takes an element's
  address; `p - i` is `p` offset by `-(long)i`. A vector or SIMD-group matrix
  declared without initializer is an object in this thread's memory (a
  one-element thread array), so its unwritten elements are undefined; `v[i]`
  of a vector object is its element `i`. An access through a declared array
  element's address cast to a wider vector pointer has the element's alignment
  (clang keeps a `Decl`-sourced alignment through explicit casts:
  `*(threadgroup vec<T, 4>*)&xs[r][c] = v` is `store <4 x T> … align 2`) and is
  made component by component, the same bytes.
* SIMD-group matrices (`simdgroup_float8x8`, `simdgroup_half8x8`): each lane's
  `thread_elements()`, a `.vec s 2` (Builtins.lean). With an initializer a
  matrix is a slot, otherwise or in an array thread memory;
  `m.thread_elements()[i]` reads at any `i` (none past the lane's two) and is
  written at a constant 0 or 1 of a matrix in memory;
  `make_filled_simdgroup_matrix<T, 8, 8>(v)` is `[T(v), T(v)]`;
  `simdgroup_multiply_accumulate(d, a, b, c)` evaluates `d`'s place, then `a`,
  `b`, `c`, then is the SIMD-group collective `.mma` on each lane's
  `[a, b, c]` (float `d` and `c`; `a`, `b` float or half, not both half: the
  contract's `simdMma`, `simdMmaHalfA`, `simdMmaHalfB`), its result stored to
  `d`.
* `if constexpr` with a constant condition elaborates only the branch it
  selects; a `for` step may be two expressions joined by the comma operator;
  template parameters may be `uint`.
* Constants: literals, template arguments, `constexpr` values and every
  operation on constants are folded (clang folds them even at -O0):
  integers exactly as Value.lean computes (undefined → rejected), floating
  operations and conversions by exact rational arithmetic rounded to nearest
  even (rejected when an operand or result is subnormal, infinite or NaN).
  A floating literal, suffixed or not, rounds directly from its decimal
  value to binary32 (probed: `1.00000005960464477539062500001` →
  `0x3F800001`, not the double-rounded `0x3F800000`). An `if`/`?:`/`&&`/`||`
  with a constant condition keeps only the live operand (the dead one is
  still elaborated); a loop with a constant false condition is dropped.
* Contraction (clang's `tryEmitFMulAdd`, `-ffp-contract=on`): an `f32` `+`/`-`
  (compound included) with an operand that is an `f32` `*` of the same
  expression gets a fresh site; Run.lean then fuses it like `llvm.fmuladd`
  (left product preferred, `c - a*b` → `fma(-a, b, c)`, `a*b - c` →
  `fma(a, b, -c)`). A `bfloat` one would be `llvm.fmuladd.bf16`, which the
  semantics lacks: rejected. A product is a contraction operand only as the
  multiplication the frontend emitted (through same-type casts; not through
  `-`, a slot, a call, or a `?:`).
* Default-level peepholes (`opt`; `elaborateO0` turns them off for the
  static source-site inventory):
  - division by a constant ±2^k whose reciprocal is a normal number is a
    multiplication by the reciprocal (InstCombine; `x / 8.0f` → `fmul
    0.125`, `/3.0f` stays `fdiv`). It is not a contraction operand: at f32
    the product is wrapped in the identity `conv f32` so Run never fuses an
    add over it.
  - `bfloat(op(float(a), float(b)))` for `bfloat` `a`, `b` and `op` ∈ `+ - * /`
    is the `bfloat` operation (InstCombine `visitFPTrunc`; the f32 width 24 ≥
    2·8+1 makes it legal). Any other conversion to `bfloat` of an operation
    that might be narrowed (operands widened `bfloat`s, or float constants
    that are not exactly `half`s, directly or through a slot that may hold
    one) is rejected, since whether the optimizer narrows it depends on use
    counts (probed: `const float p = float(x) * float(y); bfloat(p)` is
    `fmul bfloat`) and constant types (`bfloat(float(x) * 2.0f)` is not
    narrowed: the constant's minimal type is `half`).
    A comparison of widened `bfloat`s is also narrowed by the optimizer;
    the semantics compares `bfloat` through widening, so the core keeps it.
  - Likewise `half(op(x, y))` is rejected when `x` and `y` may both be
    16-bit floats widened or constants (`EV.hcand`, through slots), since
    the optimizer may compute it in `half`.
* Sites: one counter, 1, 2, …, in elaboration order (source order, an
  inlined body at each call, dead branches included), shared by contraction
  sites, barriers and collectives; other `bin` nodes carry site 0. -/

/-! ## Compile-time constants -/

/-- A scalar constant: its type and its word (two's complement, float bits). -/
structure K where
  s : Scalar
  w : Nat
deriving DecidableEq, Repr, Inhabited

def K.val (k : K) : Val := Val.ofWord k.s k.w
def K.int (k : K) : Int := Val.signed k.s k.w
def kbool (b : Bool) : K := ⟨.bool, if b then 1 else 0⟩

def isIntLike (s : Scalar) : Bool := s.isInt || s == .bool

/-- A binary floating format: significand bits (with the hidden bit) and
exponent bits. -/
structure Fmt where
  p : Nat
  ebits : Nat

namespace Fmt
def bias (F : Fmt) : Nat := 2 ^ (F.ebits - 1) - 1
def half (F : Fmt) : Nat := 2 ^ (F.p - 1)
def sign (F : Fmt) : Nat := 2 ^ (F.ebits + F.p - 1)
def inf (F : Fmt) : Nat := (2 ^ F.ebits - 1) * F.half
end Fmt

def f32Fmt : Fmt := ⟨24, 8⟩

def fmt : Scalar → Option Fmt
  | .f32 => some f32Fmt
  | .bf16 => some ⟨8, 8⟩
  | .f16 => some ⟨11, 5⟩
  | _ => none

def isFloat (s : Scalar) : Bool := (fmt s).isSome

/-- `n / d ≥ 2 ^ e`. -/
def atLeast (n d : Nat) (e : Int) : Bool :=
  if 0 ≤ e then Nat.ble (d * 2 ^ e.toNat) n else Nat.ble d (n * 2 ^ (-e).toNat)

/-- Bits (sign clear) of the value of `F` nearest `n / d > 0`, ties to even,
subnormals kept; ∞ beyond the largest finite value. -/
def roundPos (F : Fmt) (n d : Nat) : Nat :=
  let e0 : Int := (Nat.log2 n : Int) - (Nat.log2 d : Int)
  let e : Int := if atLeast n d e0 then e0 else e0 - 1
  let emin : Int := 1 - (F.bias : Int)
  let E : Int := if e < emin then emin else e
  let q : Int := E - ((F.p : Int) - 1)
  let num := if 0 ≤ q then n else n * 2 ^ (-q).toNat
  let den := if 0 ≤ q then d * 2 ^ q.toNat else d
  let i := num / den
  let r := num % den
  let m := if Nat.blt den (2 * r) || (Nat.beq (2 * r) den && Nat.beq (i % 2) 1) then i + 1 else i
  let up := Nat.beq m (2 * F.half)
  let m := if up then F.half else m
  let E := if up then E + 1 else E
  if (F.bias : Int) < E then F.inf
  else if Nat.blt m F.half then m
  else (E + F.bias).toNat * F.half + (m - F.half)

/-- Bits of the value of `F` nearest `±n / d`. -/
def round (F : Fmt) (neg : Bool) (n d : Nat) : Nat :=
  (if neg then F.sign else 0) + (if n == 0 then 0 else roundPos F n d)

/-- A decimal literal `m · 10^e`, rounded to `F`. -/
def decimal (F : Fmt) (m : Nat) (e : Int) : Nat :=
  if 0 ≤ e then round F false (m * 10 ^ e.toNat) 1 else round F false m (10 ^ (-e).toNat)

/-- The value of finite bits: sign, numerator, denominator (`none`: ∞, NaN). -/
def exact (F : Fmt) (b : Nat) : Option (Bool × Nat × Nat) :=
  let mag := b % F.sign
  let biased := mag / F.half
  let frac := mag % F.half
  if biased == 2 ^ F.ebits - 1 then none else
  let m := if biased == 0 then frac else F.half + frac
  let e : Int := (if biased == 0 then 1 else (biased : Int)) - (F.bias : Int) - ((F.p : Int) - 1)
  some (Nat.ble F.sign b, if 0 ≤ e then m * 2 ^ e.toNat else m, if 0 ≤ e then 1 else 2 ^ (-e).toNat)

def subnormal (F : Fmt) (b : Nat) : Bool :=
  let mag := b % F.sign
  mag / F.half == 0 && mag % F.half != 0

def infinite (F : Fmt) (b : Nat) : Bool := b % F.sign == F.inf

/-- A floating operation on constants (APFloat: exact, rounded to nearest
even), defined only on normal or zero operands with a normal or zero result. -/
def fbin (F : Fmt) (op : Core.BinOp) (x y : Nat) : Option Nat := do
  if subnormal F x || subnormal F y then none
  let (sx, nx, dx) ← exact F x
  let (sy, ny, dy) ← exact F y
  let r ← match op with
    | .add | .sub =>
      let sy := if op == .sub then !sy else sy
      let a : Int := (if sx then -1 else 1) * ((nx * dy : Nat) : Int)
      let b : Int := (if sy then -1 else 1) * ((ny * dx : Nat) : Int)
      if a + b == 0 then some (if sx && sy then F.sign else 0)
      else some (round F (decide (a + b < 0)) (a + b).natAbs (dx * dy))
    | .mul => some (round F (sx != sy) (nx * ny) (dx * dy))
    | .div => if ny == 0 then none else some (round F (sx != sy) (nx * dy) (dx * ny))
    | _ => none
  if subnormal F r || infinite F r then none else some r

/-- The reciprocal of a constant divisor `±2^k` when it is a normal number
(InstCombine's `fdiv X, C` → `fmul X, 1/C`). -/
def reciprocal (F : Fmt) (y : Nat) : Option Nat := do
  if subnormal F y then none
  let (s, n, d) ← exact F y
  if n == 0 || n &&& (n - 1) != 0 then none
  let r := round F s d n
  if subnormal F r || infinite F r || r % F.sign == 0 then none else some r

/-- Conversion of a constant (Value.lean `convert` on integers; floats exactly,
rounded to nearest even). -/
def convK (t : Scalar) (k : K) : Option K :=
  if k.s == t then some k else
  match fmt k.s, fmt t with
  | none, none =>
    if !isIntLike k.s || !isIntLike t then none
    else if t == .bool then some (kbool (k.w != 0))
    else some ⟨t, (k.int % 2 ^ t.width).toNat⟩
  | none, some F =>
    if !isIntLike k.s || t == .f16 then none
    else some ⟨t, round F (decide (k.int < 0)) k.int.natAbs 1⟩
  | some F, some G =>
    if subnormal F k.w || t == .f16 then none
    else if infinite F k.w then some ⟨t, (if Nat.ble F.sign k.w then G.sign else 0) + G.inf⟩
    else do
      let (neg, n, d) ← exact F k.w
      let r := round G neg n d
      if subnormal G r || infinite G r then none else some ⟨t, r⟩
  | some _, none => none

/-- An integer operation on constants, exactly as Value.lean `binary`. -/
def ibin (op : Core.BinOp) (s : Scalar) (x y : Nat) : Option K :=
  let a := Val.signed s x
  let b := Val.signed s y
  let int (v : Int) : Option K := (Val.wrap s v).map (K.mk s)
  match op with
  | .add => int (a + b)
  | .sub => int (a - b)
  | .mul => int (a * b)
  | .div => if b = 0 then none else int (a.tdiv b)
  | .rem => if b = 0 then none else int (a.tmod b)
  | .bitAnd => some ⟨s, x &&& y⟩
  | .bitOr => some ⟨s, x ||| y⟩
  | .bitXor => some ⟨s, x ^^^ y⟩
  | .shl =>
    if b < 0 ∨ s.width ≤ b.toNat then none
    else if s.isSigned ∧ (a < 0 ∨ 2 ^ s.width ≤ a.toNat * 2 ^ b.toNat) then none
    else some ⟨s, x * 2 ^ b.toNat % 2 ^ s.width⟩
  | .shr => if b < 0 ∨ s.width ≤ b.toNat then none else int (a / 2 ^ b.toNat)
  | .min => int (min a b)
  | .max => int (max a b)
  | .lt => some (kbool (decide (a < b)))
  | .le => some (kbool (decide (a ≤ b)))
  | .gt => some (kbool (decide (a > b)))
  | .ge => some (kbool (decide (a ≥ b)))
  | .eq => some (kbool (decide (a = b)))
  | .ne => some (kbool (decide (a ≠ b)))

def kneg (k : K) : Option K :=
  match fmt k.s with
  | some F => some ⟨k.s, if Nat.ble F.sign k.w then k.w - F.sign else k.w + F.sign⟩
  | none => (Val.wrap k.s (-k.int)).map (K.mk k.s)

/-! ## Types and environments -/

/-- Types of values during elaboration: a pointer records its address space
and whether its pointee is `const`; a SIMD-group matrix of element type `s` is
held as the lane's `thread_elements()`, a `.vec s 2`. -/
inductive ETy where
  | scalar (s : Scalar)
  | vec (s : Scalar) (n : Nat)
  | ptr (space : Space) (const : Bool) (elem : Ty)
  | void
  | mat (s : Scalar)
deriving DecidableEq, Repr, Inhabited

/-- The type of a value read from memory of type `t`. A pointer kept in memory
(an array of pointers) is read as a pointer to `const`: the element's own
qualifier is not kept, so writes through it are rejected. -/
def ETy.ofTy : Ty → ETy
  | .scalar s => .scalar s
  | .vec s n => .vec s n
  | .ptr sp e => .ptr sp true e

/-- The memory layout of a value of elaboration type `t`. -/
def ETy.ty : ETy → Option Ty
  | .scalar s => some (.scalar s)
  | .vec s n => some (.vec s n)
  | .ptr sp _ e => some (.ptr sp e)
  | .mat s => some (.vec s 2)
  | .void => none

/-- Natural alignment (Run.lean `alignment`). -/
def natAlign : Ty → Nat
  | .scalar s => s.bytes
  | t => t.bytes

inductive Bind where
  /-- A local in `slot`. -/
  | var (slot : Nat) (t : ETy) (mutable : Bool)
  /-- An array: `slot` holds the pointer to its first element. -/
  | array (slot : Nat) (space : Space) (elem : Ty) (extents : List Nat)
  /-- A `constexpr` value or template argument. -/
  | const (t : ETy) (k : K)
  | coord (c : Coord) (t : ETy)
  /-- A template type parameter. -/
  | type (s : Scalar)
  /-- A vector or matrix declared without initializer: an object of type `t` in
  this thread's memory (a one-element thread array), `slot` its address. -/
  | obj (slot : Nat) (t : ETy)
  /-- An array of matrices (thread memory, `.vec s 2` elements). -/
  | matArray (slot : Nat) (s : Scalar) (extents : List Nat)
deriving Inhabited

abbrev Env := List (List Char × Bind)

def find : Env → List Char → Option Bind
  | [], _ => none
  | (m, b) :: rest, n => if same m n then some b else find rest n

/-- A type name: scalar, vector or template type parameter. -/
def elemTy (env : Env) (n : List Char) : Option Ty :=
  match scalarOfName n with
  | some s => some (.scalar s)
  | none =>
    match vectorName n with
    | some (s, k) => some (.vec s k)
    | none =>
      match find env n with
      | some (.type s) => some (.scalar s)
      | _ => none

/-- The value type a type spec names (its pointer declarator aside):
`metal::vec<T, k>` a vector, a SIMD-group matrix name a matrix. -/
def valTy (env : Env) (ts : TypeSpec) : Option ETy :=
  match ts.vec with
  | some k =>
    match elemTy env ts.name with
    | some (.scalar s) => if 2 ≤ k ∧ k ≤ 4 then some (.vec s k) else none
    | _ => none
  | none =>
    match Builtins.matrixOfName ts.name with
    | some s => some (.mat s)
    | none => (elemTy env ts.name).map ETy.ofTy

/-- The element type of a pointer or array a type spec names: a scalar or vector. -/
def ptrElem (env : Env) (ts : TypeSpec) : Option Ty :=
  match valTy env ts with
  | some (.scalar s) => some (.scalar s)
  | some (.vec s k) => some (.vec s k)
  | _ => none

inductive Decl where
  | auto
  | ty (t : ETy)

/-- A declared type (a non-pointer's address space is checked by the caller). -/
def declTy (env : Env) (ts : TypeSpec) : Option Decl :=
  if ts.pointer then do
    let sp ← ts.space
    let e ← ptrElem env ts
    pure (.ty (.ptr sp ts.const e))
  else if ts.vec.isNone && same ts.name chars!"auto" then (if ts.space.isNone then some .auto else none)
  else if ts.vec.isNone && same ts.name chars!"void" then some (.ty .void)
  else (valTy env ts).map .ty

def component (f : List Char) : Option Nat :=
  if same f ['x'] then some 0 else if same f ['y'] then some 1
  else if same f ['z'] then some 2 else if same f ['w'] then some 3 else none

/-! ## The elaboration monad -/

structure Ctx where
  /-- Functions defined before the kernel. -/
  funcs : List Func
  /-- Inside an inlined function: its result slot and type. -/
  ret : Option (Nat × ETy) := none
  loop : Bool := false
  /-- Default-level peepholes. -/
  opt : Bool

structure St where
  next : Nat := 0
  site : Nat := 1
  group : List (Ty × Nat) := []
  thread : List (Ty × Nat) := []
  /-- Slots that may hold a widened `bfloat` or a narrowing candidate
  (sticky, in elaboration order). -/
  wide : List Nat := []
  cand : List Nat := []
  /-- Slots that may hold a value the optimizer may narrow to `half` (below). -/
  hwide : List Nat := []
  hcand : List Nat := []
  /-- The kernel body returns (a kernel-level `return`). -/
  kret : Bool := false

abbrev M := StateT St Option

def lift {α : Type} : Option α → M α
  | some a => pure a
  | none => failure

def fresh : M Nat := modifyGet fun s => (s.next, { s with next := s.next + 1 })
def freshSite : M Nat := modifyGet fun s => (s.site, { s with site := s.site + 1 })

def memNat (n : Nat) : List Nat → Bool
  | [] => false
  | m :: ms => Nat.beq n m || memNat n ms

/-- An elaborated expression: statements to run first, then the value. -/
structure EV where
  pre : List CStmt := []
  e : CExpr
  t : ETy
  /-- The compile-time value (then `e` is its literal). -/
  k : Option K := none
  /-- `e` is a multiplication the frontend emits (a contraction operand). -/
  mul : Bool := false
  /-- `e` is `conv f32 a` for the `bfloat` `a`. -/
  wide : Option CExpr := none
  /-- To the optimizer `e` may be a widened `bfloat` (an `fpext`, possibly
  through a slot, or a float constant that is not exactly a `half`: probed,
  `bfloat(float(x) * 2.0f)` stays `fmul float`, as `getMinimumFPType` gives
  such a constant type `half`). -/
  maybeWide : Bool := false
  /-- `e` is `op f32 (conv f32 a) (conv f32 b)` for `bfloat` `a`, `b`. -/
  narrow : Option (Core.BinOp × CExpr × CExpr) := none
  /-- The optimizer might narrow a conversion of `e` to `bfloat`. -/
  cand : Bool := false
  /-- To the optimizer `e` may be a 16-bit float widened to `float`, or a constant
  (whose minimal type may be `half`). -/
  hwide : Bool := false
  /-- The optimizer might narrow a conversion of `e` to `half` (an operation on
  two `hwide` operands). -/
  hcand : Bool := false
  /-- A pointer to an element of a declared array (or one cast from it): accesses
  through it are aligned only to this many bytes (clang's alignment of a
  `Decl`-sourced address, kept through explicit casts). -/
  declAlign : Option Nat := none
deriving Inhabited

/-- A binary32 constant that is exactly a binary16 value. -/
def fitsHalf (w : Nat) : Bool :=
  match exact f32Fmt w with
  | some (s, n, d) =>
    let h : Fmt := ⟨11, 5⟩
    match exact h (round h s n d) with
    | some (s', n', d') => s == s' && n * d' == n' * d
    | none => false
  | none => false

def ofK (k : K) : EV :=
  { e := .lit k.val, t := .scalar k.s, k := some k, maybeWide := k.s == .f32 && !fitsHalf k.w,
    hwide := k.s == .f32 }

/-- `slot := v`, noting what the slot may hold. -/
def assign (slot : Nat) (v : EV) : M (List CStmt) := do
  modify fun s => { s with
    wide := if v.maybeWide then slot :: s.wide else s.wide
    cand := if v.cand then slot :: s.cand else s.cand
    hwide := if v.hwide then slot :: s.hwide else s.hwide
    hcand := if v.hcand then slot :: s.hcand else s.hcand }
  pure (v.pre ++ [.set slot v.e])

def readVar (slot : Nat) (t : ETy) : M EV := do
  let s ← get
  pure { e := .local slot, t, maybeWide := memNat slot s.wide, cand := memNat slot s.cand,
         hwide := memNat slot s.hwide, hcand := memNat slot s.hcand }

/-- No memory read in `e`: its value cannot change under other statements
(those of calls write only fresh slots and memory). -/
def noLoad : Nat → CExpr → Bool
  | 0, _ => false
  | _ + 1, .lit _ | _ + 1, .local _ | _ + 1, .coord _ => true
  | f + 1, .un _ _ e | f + 1, .conv _ e | f + 1, .bitcast _ e | f + 1, .ptrCast _ e => noLoad f e
  | f + 1, .bin _ _ _ a b | f + 1, .and a b | f + 1, .or a b | f + 1, .offset a b
  | f + 1, .component a b => noLoad f a && noLoad f b
  | f + 1, .fma a b c | f + 1, .cond a b c => noLoad f a && noLoad f b && noLoad f c
  | _ + 1, .load .. | _ + 1, .vector .. => false

def stable (e : CExpr) : Bool := noLoad 1000 e

/-- Save `v` to a fresh slot. -/
def spill (v : EV) : M EV := do
  let slot ← fresh
  let ss ← assign slot v
  pure { pre := ss, e := .local slot, t := v.t, maybeWide := v.maybeWide, cand := v.cand, hwide := v.hwide,
         hcand := v.hcand }

/-! ## Conversions -/

/-- Scalar conversions: integers and `bool` among themselves and to `float`
and `bfloat`; `bfloat` → `float`; explicitly also `float` → `bfloat` and
`half` → `float`. -/
def convOk (implicit : Bool) (a b : Scalar) : Bool :=
  if a == b then true
  else if isIntLike a then isIntLike b || b == .f32 || b == .bf16
  else if a == .bf16 then b == .f32
  else if a == .f32 then !implicit && (b == .bf16 || b == .f16)
  else if a == .f16 then !implicit && b == .f32
  else false

def convScalar (opt : Bool) (t : Scalar) (v : EV) : M EV := do
  let .scalar s := v.t | failure
  if s == t then return v
  match v.k with
  | some k => return { ofK (← lift (convK t k)) with pre := v.pre }
  | none => pure ()
  if s == .bf16 && t == .f32 then
    return { pre := v.pre, e := .conv .f32 v.e, t := .scalar .f32, wide := some v.e, maybeWide := true, hwide := true }
  if s == .f16 && t == .f32 then
    return { pre := v.pre, e := .conv .f32 v.e, t := .scalar .f32, hwide := true }
  if s == .f32 && t == .bf16 && opt then
    match v.narrow with
    | some (op, a, b) => return { pre := v.pre, e := .bin op .bf16 0 a b, t := .scalar .bf16 }
    | none => if v.cand then failure
  -- Narrowing to `half` of an operation the optimizer might narrow: rejected.
  if s == .f32 && t == .f16 && opt && v.hcand then failure
  return { pre := v.pre, e := .conv t v.e, t := .scalar t }

def isPtrTy : Ty → Bool
  | .ptr .. => true
  | _ => false

/-- Conversion of `v` to `t`: scalars per `convOk`; vectors explicitly
componentwise (`float4(h4)`, AIR `air.convert`) and a scalar explicitly to every
component (`vec<T, 4>(0)`); pointers within an address space (a pointer
reinterpretation only explicitly, never of a pointer to pointers). -/
def convTo (opt implicit : Bool) (t : ETy) (v : EV) : M EV :=
  match t, v.t with
  | .scalar b, .scalar a => if convOk implicit a b then convScalar opt b v else failure
  | .vec s n, .vec s' n' =>
    if s == s' && n == n' then pure v
    else if n == n' && !implicit && convOk false s' s && (isFloat s && isFloat s') then
      pure { pre := v.pre, e := .conv s v.e, t := t }
    else failure
  | .vec s n, .scalar a => do
    if implicit || !convOk false a s then failure
    let x ← convScalar opt s v
    let x ← if stable x.e then pure x else spill x
    pure { pre := x.pre, e := .vector s (List.replicate n x.e), t := t }
  | .mat s, .mat s' => if s == s' then pure v else failure
  | .ptr sp c e, .ptr sp' c' e' =>
    if sp != sp' then failure
    else if e == e' then
      (if implicit && c' && !c then failure else pure { pre := v.pre, e := v.e, t := t, declAlign := v.declAlign })
    else if implicit || isPtrTy e || isPtrTy e' then failure
    else pure { pre := v.pre, e := .ptrCast e v.e, t := t, declAlign := v.declAlign }
  | _, _ => failure

def toBool (opt : Bool) (v : EV) : M EV :=
  match v.t with
  | .scalar s => if isIntLike s then convScalar opt .bool v else failure
  | _ => failure

/-! ## Operators -/

def binOpOf : Metal.BinOp → Option Core.BinOp
  | .mul => some .mul | .div => some .div | .mod => some .rem
  | .add => some .add | .sub => some .sub | .shl => some .shl | .shr => some .shr
  | .lt => some .lt | .le => some .le | .gt => some .gt | .ge => some .ge
  | .eq => some .eq | .ne => some .ne
  | .bitAnd => some .bitAnd | .bitXor => some .bitXor | .bitOr => some .bitOr
  | .and | .or => none

def isCompare : Core.BinOp → Bool
  | .lt | .le | .gt | .ge | .eq | .ne => true
  | _ => false

/-- `a op b` for operands converted to the computation type `c`. -/
def scalarBin (opt : Bool) (op : Core.BinOp) (c : Scalar) (a b : EV) : M EV := do
  let pre := a.pre ++ b.pre
  let rt : ETy := if isCompare op then .scalar .bool else .scalar c
  match fmt c with
  | none =>
    if !c.isInt then failure
    match a.k, b.k with
    | some x, some y => return { ofK (← lift (ibin op c x.w y.w)) with pre }
    | _, _ => return { pre, e := .bin op c 0 a.e b.e, t := rt }
  | some F =>
    if c == .f16 then failure
    match op with
    | .rem | .shl | .shr | .bitAnd | .bitOr | .bitXor | .min | .max => failure
    | _ => pure ()
    if isCompare op then
      if a.k.isSome && b.k.isSome then failure
      return { pre, e := .bin op c 0 a.e b.e, t := rt }
    match a.k, b.k with
    | some x, some y => do
      let r ← lift (fbin F op x.w y.w)
      return { ofK ⟨c, r⟩ with pre }
    | _, _ => pure ()
    if op == .div && opt then
      match b.k.bind fun y => reciprocal F y.w with
      | some r =>
        let m : CExpr := .bin .mul c 0 a.e (.lit (K.val ⟨c, r⟩))
        return { pre, e := if c == .f32 then .conv .f32 m else m, t := rt,
                 cand := c == .f32 && a.maybeWide && !fitsHalf r, hcand := c == .f32 && a.hwide }
      | none => pure ()
    let contract := (op == .add || op == .sub) && (a.mul || b.mul)
    if contract && c == .bf16 then failure
    let site ← if contract then freshSite else pure 0
    let narrow := if c == .f32 then
        (match a.wide, b.wide with
         | some x, some y => some (op, x, y)
         | _, _ => none)
      else none
    return { pre, e := .bin op c site a.e b.e, t := rt, mul := op == .mul, narrow,
             cand := c == .f32 && a.maybeWide && b.maybeWide, hcand := c == .f32 && a.hwide && b.hwide }

/-- A binary operator other than `&&`, `||`: pointer arithmetic, shifts
(operands promoted separately), the usual arithmetic conversions. -/
def arith (opt : Bool) (op : Metal.BinOp) (a b : EV) : M EV := do
  let some cop := binOpOf op | failure
  match a.t, b.t with
  | .ptr .., .scalar s =>
    if cop == .add && s.isInt then return { pre := a.pre ++ b.pre, e := .offset a.e b.e, t := a.t }
    -- `p - i`: `p` offset by `-(i64)i` (clang: `sub i64 0, ext i`, then the element pointer).
    if cop == .sub && s.isInt then
      let x ← convScalar opt .i64 b
      let nx ← match x.k with
        | some k => do pure (ofK (← lift (kneg k))).e
        | none => pure (CExpr.un .neg .i64 x.e)
      return { pre := a.pre ++ x.pre, e := .offset a.e nx, t := a.t }
    failure
  | .scalar s, .ptr .. =>
    if cop == .add && s.isInt then return { pre := a.pre ++ b.pre, e := .offset b.e a.e, t := b.t }
    failure
  | .scalar sa, .scalar sb =>
    if cop == .shl || cop == .shr then
      let pa := promote sa
      let pb := promote sb
      if !(pa.isInt && pb.isInt) || rank pa < rank pb then failure
      let a ← convScalar opt pa a
      let b ← convScalar opt pa b
      scalarBin opt cop pa a b
    else
      let some c := common sa sb | failure
      let a ← convTo opt true (.scalar c) a
      let b ← convTo opt true (.scalar c) b
      scalarBin opt cop c a b
  | _, _ => failure

def neg (opt : Bool) (v : EV) : M EV := do
  let .scalar s := v.t | failure
  let v ← if isFloat s then (if s == .f16 then failure else pure v) else convScalar opt (promote s) v
  let .scalar p := v.t | failure
  if !(isFloat p || p.isInt) then failure
  match v.k with
  | some k => return { ofK (← lift (kneg k)) with pre := v.pre }
  | none => return { pre := v.pre, e := .un .neg p v.e, t := .scalar p }

def bitNot (opt : Bool) (v : EV) : M EV := do
  let .scalar s := v.t | failure
  let p := promote s
  if !p.isInt then failure
  let v ← convScalar opt p v
  match v.k with
  | some k => return { ofK ⟨p, 2 ^ p.width - 1 - k.w⟩ with pre := v.pre }
  | none => return { pre := v.pre, e := .un .bitNot p v.e, t := .scalar p }

/-- The type of `c ? a : b`. -/
def condType : ETy → ETy → Option ETy
  | .scalar a, .scalar b => if a == b then some (.scalar a) else (common a b).map .scalar
  | .ptr sp c e, .ptr sp' c' e' => if sp == sp' && e == e' then some (.ptr sp (c || c') e) else none
  | .vec s n, .vec s' n' => if s == s' && n == n' then some (.vec s n) else none
  | _, _ => none

/-! ## Places -/

/-- What an expression designates. -/
inductive Place where
  | var (slot : Nat) (t : ETy) (mutable : Bool)
  /-- Memory at pointer `p` (after `pre`) in `space`; accesses aligned to
  `align` when the address is a declared array element's (`EV.declAlign`). -/
  | mem (pre : List CStmt) (p : CExpr) (elem : Ty) (const : Bool) (space : Space) (align : Option Nat)
  /-- A SIMD-group matrix in this thread's memory at `p` (a `.vec s 2`). -/
  | mat (pre : List CStmt) (p : CExpr) (s : Scalar)
  | value (v : EV)

/-- Element `i` of the vector or matrix of element type `s` at `p`. -/
def elemAt (s : Scalar) (p : CExpr) (i : Nat) : CExpr := .offset (.ptrCast (.scalar s) p) (.lit (.int .i32 i))
def compAt (e : CExpr) (i : Nat) : CExpr := .component e (.lit (.int .u32 i))

/-- How an access of `elem` aligned to `align` happens: whole (`none`), or a
vector below its natural alignment component by component (clang's access of
an under-aligned vector; the same bytes). -/
def splitOf (elem : Ty) (align : Option Nat) : M (Option (Scalar × Nat)) :=
  match align with
  | some a =>
    if a < natAlign elem then
      match elem with
      | .vec s n => if s.bytes ≤ a then pure (some (s, n)) else failure
      | _ => failure
    else pure none
  | none => pure none

def readMem (p : CExpr) (elem : Ty) (align : Option Nat) : M CExpr := do
  match ← splitOf elem align with
  | none => pure (.load elem p)
  | some (s, n) => pure (.vector s ((List.range n).map fun i => .load (.scalar s) (elemAt s p i)))

def write (opt : Bool) (pl : Place) (v : EV) : M (List CStmt) :=
  match pl with
  | .var slot t m => do
    if !m then failure
    assign slot (← convTo opt true t v)
  | .mem pre p elem c _ al => do
    if c then failure
    let v ← convTo opt true (ETy.ofTy elem) v
    match ← splitOf elem al with
    | none =>
      let v ← if !pre.isEmpty && !stable v.e then spill v else pure v
      pure (v.pre ++ pre ++ [.store elem p v.e])
    | some (s, n) =>
      let v ← if !stable v.e then spill v else pure v
      pure (v.pre ++ pre ++ (List.range n).map fun i => .store (.scalar s) (elemAt s p i) (compAt v.e i))
  | .mat pre p s => do
    let v ← convTo opt true (.mat s) v
    let v ← if !pre.isEmpty && !stable v.e then spill v else pure v
    pure (v.pre ++ pre ++ [.store (.vec s 2) p v.e])
  | .value _ => failure

/-- `place op= v` (C++: computed in the common type, converted back). -/
def compound (opt : Bool) (pl : Place) (op : Metal.BinOp) (v : EV) : M (List CStmt) :=
  match pl with
  | .var slot t m => do
    if !m then failure
    let cur ← readVar slot t
    let r ← arith opt op { cur with pre := v.pre } { v with pre := [] }
    assign slot (← convTo opt true t r)
  | .mem pre p elem c _ al => do
    if c || al.any (· < natAlign elem) then failure
    let v ← if !pre.isEmpty && !stable v.e then spill v else pure v
    let cur : EV := { pre := v.pre ++ pre, e := .load elem p, t := ETy.ofTy elem }
    let r ← arith opt op cur { v with pre := [] }
    let r ← convTo opt true (ETy.ofTy elem) r
    pure (r.pre ++ [.store elem p r.e])
  | .mat .. | .value _ => failure

def findFunc (fs : List Func) (n : List Char) : Option Func :=
  match fs.filter fun f => same f.name n with
  | [f] => some f
  | _ => none

def tparamName : TParam → List Char
  | .type n | .int n | .bool n | .uint n => n

/-- An array access `a[i₁]…[iₖ]`: the array's name and the indices. -/
def indexChain : Nat → Expr → Option (List Char × List Expr)
  | 0, _ => none
  | f + 1, .index a i => (indexChain f a).map fun (n, is) => (n, is ++ [i])
  | _ + 1, .name [n] => some (n, [])
  | _ + 1, _ => none

/-- The strides of an array's leading dimensions: each the product of the extents after it. -/
def strides : List Nat → List Nat
  | [] | [_] => []
  | _ :: ds => ds.foldl (· * ·) 1 :: strides ds

/-- `base` offset by `i₁·stride₁ + … + iₖ` (array indices `vs`): each of the
first k-1 indices converted to 64 bits and multiplied by its stride. -/
def rowsOffset (opt : Bool) (base : CExpr) : List Nat → List EV → M (List CStmt × CExpr)
  | [], [v] => do
    let .scalar si := v.t | failure
    if !si.isInt then failure
    pure (v.pre, .offset base v.e)
  | st :: sts, v :: vs => do
    let .scalar su := v.t | failure
    if !su.isInt then failure
    let w : Scalar := if su.isSigned then .i64 else .u64
    let row ← scalarBin opt .mul w (← convScalar opt w v) (ofK ⟨w, st⟩)
    let (pre, p) ← rowsOffset opt (.offset base row.e) sts vs
    if !pre.isEmpty && !stable row.e then failure
    pure (row.pre ++ pre, p)
  | _, _ => failure

/-! ## Expressions and statements -/

mutual

def expr (fuel : Nat) (ctx : Ctx) (env : Env) (x : Expr) : M EV :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  match x with
  | .int v u l h => do
    let s ← lift (intLiteral v u l h)
    pure (ofK ⟨s, v⟩)
  | .float m e _ => pure (ofK ⟨.f32, decimal f32Fmt m e⟩)
  | .bool b => pure (ofK (kbool b))
  | .name [n] =>
    if same n chars!"INFINITY" then pure (ofK ⟨.f32, infinityBits⟩) else
    match find env n with
    | some (.var slot t _) => readVar slot t
    | some (.array slot sp elem [_]) =>
      pure { e := .local slot, t := .ptr sp false elem, declAlign := some (natAlign elem) }
    | some (.obj slot t) => do pure { e := .load (← lift t.ty) (.local slot), t }
    | some (.const t k) => pure { ofK k with t }
    | some (.coord c t) => pure { e := .coord c, t }
    | _ => failure
  | .unary .neg a => do neg ctx.opt (← expr fuel ctx env a)
  | .unary .not a => do
    let v ← toBool ctx.opt (← expr fuel ctx env a)
    match v.k with
    | some k => pure { ofK (kbool (k.w == 0)) with pre := v.pre }
    | none => pure { pre := v.pre, e := .un .not .bool v.e, t := .scalar .bool }
  | .unary .bitNot a => do bitNot ctx.opt (← expr fuel ctx env a)
  | .unary .addr a => do
    match ← place fuel ctx env a with
    | .mem pre p elem c sp al => pure { pre, e := p, t := .ptr sp c elem, declAlign := al }
    | _ => failure
  | .binary .and a b => logic fuel ctx env true a b
  | .binary .or a b => logic fuel ctx env false a b
  | .binary op a b => do
    let va ← expr fuel ctx env a
    let vb ← expr fuel ctx env b
    let va ← if !vb.pre.isEmpty && !stable va.e then (if va.mul then failure else spill va) else pure va
    arith ctx.opt op va vb
  | .cond c a b => ternary fuel ctx env c a b
  | .call f ts args => call fuel ctx env f ts args
  | .cast _ t a => do
    let v ← expr fuel ctx env a
    match declTy env t with
    | some (.ty ty) => convTo ctx.opt false ty v
    | _ => failure
  | .member v f => do
    let v ← expr fuel ctx env v
    let .vec s n := v.t | failure
    let i ← lift (component f)
    if n ≤ i then failure
    pure { pre := v.pre, e := .component v.e (.lit (.int .u32 i)), t := .scalar s }
  | .index .. | .unary .deref _ => do
    match ← place fuel ctx env x with
    | .var slot t _ => readVar slot t
    | .mem pre p elem _ _ al => do pure { pre, e := ← readMem p elem al, t := ETy.ofTy elem }
    | .mat pre p s => pure { pre, e := .load (.vec s 2) p, t := .mat s }
    | .value v => pure v
  | _ => failure

/-- `a && b` (`isAnd`) or `a || b`: short-circuit. -/
def logic (fuel : Nat) (ctx : Ctx) (env : Env) (isAnd : Bool) (a b : Expr) : M EV :=
  match fuel with
  | 0 => failure
  | fuel + 1 => do
  let va ← toBool ctx.opt (← expr fuel ctx env a)
  let vb ← toBool ctx.opt (← expr fuel ctx env b)
  match va.k with
  | some k =>
    if (k.w == 1) == isAnd then pure { vb with pre := va.pre ++ vb.pre }
    else pure { ofK k with pre := va.pre }
  | none =>
    if vb.pre.isEmpty then
      pure { pre := va.pre, e := if isAnd then .and va.e vb.e else .or va.e vb.e, t := .scalar .bool }
    else do
      let t ← fresh
      let rest := vb.pre ++ [.set t vb.e]
      pure { pre := va.pre ++ [.set t va.e, if isAnd then .ite (.local t) rest [] else .ite (.local t) [] rest],
             e := .local t, t := .scalar .bool }

/-- `c ? a : b`: only the chosen operand is evaluated. -/
def ternary (fuel : Nat) (ctx : Ctx) (env : Env) (c a b : Expr) : M EV :=
  match fuel with
  | 0 => failure
  | fuel + 1 => do
  let vc ← toBool ctx.opt (← expr fuel ctx env c)
  let va ← expr fuel ctx env a
  let vb ← expr fuel ctx env b
  let t ← lift (condType va.t vb.t)
  let va ← convTo ctx.opt true t va
  let vb ← convTo ctx.opt true t vb
  match vc.k with
  | some k =>
    let v := if k.w == 1 then va else vb
    pure { v with pre := vc.pre ++ v.pre }
  | none =>
    if va.pre.isEmpty && vb.pre.isEmpty then pure { pre := vc.pre, e := .cond vc.e va.e vb.e, t }
    else do
      let s ← fresh
      pure { pre := vc.pre ++ [.ite vc.e (va.pre ++ [.set s va.e]) (vb.pre ++ [.set s vb.e])], e := .local s, t }

/-- What `x` designates: a local, memory (`p[i]`, `a[u][i]`, `*p`), or a value. -/
def place (fuel : Nat) (ctx : Ctx) (env : Env) (x : Expr) : M Place :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  match x with
  | .name [n] =>
    match find env n with
    | some (.var slot t m) => pure (.var slot t m)
    | some (.obj slot (.mat s)) => pure (.mat [] (.local slot) s)
    | some (.obj slot t) => do pure (.mem [] (.local slot) (← lift t.ty) false .thread none)
    | _ => do pure (.value (← expr fuel ctx env x))
  | .unary .deref p => do
    let v ← expr fuel ctx env p
    let .ptr sp c e := v.t | failure
    pure (.mem v.pre v.e e c sp v.declAlign)
  | .index (.call (.member m f) [] []) i =>
    if same f chars!"thread_elements" then elements fuel ctx env m i
    else subscript fuel ctx env (.call (.member m f) [] []) i
  | .index a i =>
    match indexChain 1000 x with
    | some (n, is) =>
      match find env n with
      | some (.array slot sp elem ns) =>
        -- `a[i₁]…[iₖ]` of `T a[d₁]…[dₖ]` (k ≥ 2): base + iⱼ·strideⱼ (in 64 bits) for j < k, + iₖ.
        if 2 ≤ ns.length && is.length == ns.length then do
          let (pre, p) ← rowsOffset ctx.opt (.local slot) (strides ns) (← exprList fuel ctx env is)
          pure (.mem pre p elem false sp (some (natAlign elem)))
        else subscript fuel ctx env a i
      | some (.matArray slot s ns) =>
        if is.length == ns.length then do
          let (pre, p) ← rowsOffset ctx.opt (.local slot) (strides ns) (← exprList fuel ctx env is)
          pure (.mat pre p s)
        else failure
      | some (.obj slot (.vec s _)) =>
        if is.length == 1 then do
          -- Component `i` of a vector in thread memory: past the object no access is defined.
          let vi ← expr fuel ctx env i
          let .scalar si := vi.t | failure
          if !si.isInt then failure
          pure (.mem vi.pre (.offset (.ptrCast (.scalar s) (.local slot)) vi.e) (.scalar s) false .thread none)
        else failure
      | _ => subscript fuel ctx env a i
    | none => subscript fuel ctx env a i
  | _ => do pure (.value (← expr fuel ctx env x))

/-- `m.thread_elements()[i]`: of a matrix in a slot, a value; of one in thread
memory, the element (a place) for a constant `i` ∈ {0, 1}, else the value
(no element past the lane's two). -/
def elements (fuel : Nat) (ctx : Ctx) (env : Env) (m i : Expr) : M Place :=
  match fuel with
  | 0 => failure
  | fuel + 1 => do
  let pl ← place fuel ctx env m
  let vi ← expr fuel ctx env i
  let .scalar si := vi.t | failure
  if !si.isInt then failure
  match pl with
  | .var slot (.mat s) _ => pure (.value { pre := vi.pre, e := .component (.local slot) vi.e, t := .scalar s })
  | .mat pre p s =>
    if !vi.pre.isEmpty && !stable p then failure
    match vi.k with
    | some k =>
      if k.int = 0 ∨ k.int = 1 then pure (.mem (pre ++ vi.pre) (elemAt s p k.int.toNat) (.scalar s) false .thread none)
      else failure
    | none => pure (.value { pre := pre ++ vi.pre, e := .component (.load (.vec s 2) p) vi.e, t := .scalar s })
  | _ => failure

/-- Expressions, left to right. -/
def exprList (fuel : Nat) (ctx : Ctx) (env : Env) (xs : List Expr) : M (List EV) :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  match xs with
  | [] => pure []
  | x :: rest => do
    let v ← expr fuel ctx env x
    let vs ← exprList fuel ctx env rest
    pure (v :: vs)

/-- `a[i]`: a pointer (or decayed array) element, or a vector component. -/
def subscript (fuel : Nat) (ctx : Ctx) (env : Env) (a i : Expr) : M Place :=
  match fuel with
  | 0 => failure
  | fuel + 1 => do
  let va ← expr fuel ctx env a
  let vi ← expr fuel ctx env i
  let va ← if !vi.pre.isEmpty && !stable va.e then spill va else pure va
  match va.t, vi.t with
  | .ptr sp c e, .scalar s =>
    if s.isInt then pure (.mem (va.pre ++ vi.pre) (.offset va.e vi.e) e c sp va.declAlign) else failure
  | .vec s _, .scalar si =>
    if si.isInt then pure (.value { pre := va.pre ++ vi.pre, e := .component va.e vi.e, t := .scalar s })
    else failure
  | _, _ => failure

/-- Arguments, left to right; an earlier argument that reads memory is saved
when a later one has statements. -/
def argList (fuel : Nat) (ctx : Ctx) (env : Env) (xs : List Expr) : M (List EV) :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  match xs with
  | [] => pure []
  | a :: rest => do
    let v ← expr fuel ctx env a
    let vs ← argList fuel ctx env rest
    let v ← if vs.any (fun w => !w.pre.isEmpty) && !stable v.e then spill v else pure v
    pure (v :: vs)

def call (fuel : Nat) (ctx : Ctx) (env : Env) (f : Expr) (ts : List TArg) (args : List Expr) : M EV :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  match f with
  | .name [n] =>
    if same n chars!"as_type" then
      match ts, args with
      | [.type t], [a] => do
        -- `as_type<T>(e)`: the same bits at type `T` (sizes must agree).
        let v ← expr fuel ctx env a
        let some (.ty (.scalar s)) := declTy env t | failure
        let .scalar s' := v.t | failure
        if s.bytes != s'.bytes || s == .bool || s' == .bool then failure
        match v.k with
        | some k => pure { ofK ⟨s, k.w⟩ with pre := v.pre }
        | none => pure { pre := v.pre, e := .bitcast s v.e, t := .scalar s }
      | _, _ => failure
    else builtinOrInline fuel ctx env [n] ts args
  | .name path => builtinOrInline fuel ctx env path ts args
  | _ => failure

def builtinOrInline (fuel : Nat) (ctx : Ctx) (env : Env) (path : List (List Char)) (ts : List TArg)
    (args : List Expr) : M EV :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  match Builtins.matFn path with
  | some .fill => do
    -- `make_filled_simdgroup_matrix<T, 8, 8>(v)`: both of the lane's elements `T(v)`.
    let [.type t, .expr r, .expr c] := ts | failure
    let some (.ty (.scalar s)) := declTy env t | failure
    let vr ← expr fuel ctx env r
    let vc ← expr fuel ctx env c
    if !(vr.pre.isEmpty && vc.pre.isEmpty && vr.k.map K.int == some 8 && vc.k.map K.int == some 8) then failure
    let [a] := args | failure
    let v ← convTo ctx.opt true (.scalar s) (← expr fuel ctx env a)
    let v ← if stable v.e then pure v else spill v
    pure { pre := v.pre, e := .vector s [v.e, v.e], t := .mat s }
  | some .mma => do
    -- `simdgroup_multiply_accumulate(d, a, b, c)`: `d`'s address, then `a`, `b`, `c`; the
    -- collective over the lanes' `[a, b, c]`; its result stored to `d`.
    if !ts.isEmpty then failure
    let [d, a, b, c] := args | failure
    let pd ← place fuel ctx env d
    let vs ← argList fuel ctx env [a, b, c]
    let [va, vb, vc] := vs | failure
    let .mat sa := va.t | failure
    let .mat sb := vb.t | failure
    let .mat .f32 := vc.t | failure
    if !((sa == .f32 && (sb == .f32 || sb == .f16)) || (sa == .f16 && sb == .f32)) then failure
    let pre := va.pre ++ vb.pre ++ vc.pre
    let slot ← fresh
    let site ← freshSite
    let coll := CStmt.collective site slot (.mma sa sb) .f32 (.vector .f32 [va.e, vb.e, vc.e]) (.lit (.int .u16 0))
    match pd with
    | .var ds (.mat .f32) true => pure { pre := pre ++ [coll, .set ds (.local slot)], e := .lit (.bool true), t := .void }
    | .mat dpre p .f32 =>
      if !pre.isEmpty && !stable p then failure
      pure { pre := dpre ++ pre ++ [coll, .store (.vec .f32 2) p (.local slot)], e := .lit (.bool true), t := .void }
    | _ => failure
  | none =>
  match Builtins.fn path with
  | some .threadgroupBarrier => do
    if !ts.isEmpty then failure
    let [flags] := args | failure
    let (d, g) ← lift (memFlags 100 flags)
    let site ← freshSite
    pure { pre := [.barrier site d g], e := .lit (.bool true), t := .void }
  | some b => do
    if !ts.isEmpty then failure
    let vs ← argList fuel ctx env args
    let ss ← vs.mapM fun v => match v.t with | .scalar s => pure s | _ => failure
    let o ← lift (resolve b ss)
    let cs ← (vs.zip o.params).mapM fun (v, s) => convTo ctx.opt true (.scalar s) v
    if cs.length != vs.length then failure
    let pre := (cs.map (·.pre)).flatten
    match ← lift (o.lower (cs.map (·.e))) with
    | .value e => pure { pre, e, t := .scalar o.result }
    | .collective op s arg delta narrow => do
      let slot ← fresh
      let site ← freshSite
      pure { pre := pre ++ [.collective site slot op s arg delta],
             e := if narrow then .conv .bf16 (.local slot) else .local slot, t := .scalar o.result }
  | none =>
    match path with
    | [n] =>
      match findFunc ctx.funcs n with
      | some fn => inline fuel ctx env fn ts args
      | none => failure
    | _ => failure

/-- A call of a header function, inlined. -/
def inline (fuel : Nat) (ctx : Ctx) (env : Env) (fn : Func) (ts : List TArg) (args : List Expr) : M EV :=
  match fuel with
  | 0 => failure
  | fuel + 1 => do
  let tenv ← bindTemplate fuel ctx env fn.tparams ts
  let rt ← match declTy tenv fn.result with
    | some (.ty t) => pure t
    | _ => failure
  let (penv, sets) ← params fuel ctx env tenv fn.params args
  let rslot ← fresh
  let (_, body) ← stmts fuel { ctx with ret := some (rslot, rt), loop := false } penv fn.body
  let s ← get
  pure { pre := sets ++ [.scope body], e := .local rslot, t := rt,
         maybeWide := memNat rslot s.wide, cand := memNat rslot s.cand }

/-- Template parameters bound to explicit arguments (types and integer or
`bool` constants, in the caller's environment). -/
def bindTemplate (fuel : Nat) (ctx : Ctx) (env : Env) (ps : List TParam) (as : List TArg) : M Env :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  match ps, as with
  | [], [] => pure []
  | p :: ps, a :: as => do
    let b ← match p, a with
      | .type _, .type t => do
        let some (.ty (.scalar s)) := declTy env t | failure
        pure (Bind.type s)
      | .int _, .expr e => do
        let v ← expr fuel ctx env e
        if !v.pre.isEmpty then failure
        let k ← lift (v.k.bind (convK .i32))
        pure (Bind.const (.scalar .i32) k)
      | .uint _, .expr e => do
        let v ← expr fuel ctx env e
        if !v.pre.isEmpty then failure
        let k ← lift (v.k.bind (convK .u32))
        pure (Bind.const (.scalar .u32) k)
      | .bool _, .expr e => do
        let v ← expr fuel ctx env e
        if !v.pre.isEmpty then failure
        let k ← lift (v.k.bind (convK .bool))
        pure (Bind.const (.scalar .bool) k)
      | _, _ => failure
    let rest ← bindTemplate fuel ctx env ps as
    pure ((tparamName p, b) :: rest)
  | _, _ => failure

/-- Parameters: each argument (in the caller's `env`), converted, stored. -/
def params (fuel : Nat) (ctx : Ctx) (env tenv : Env) (ps : List Param) (as : List Expr) : M (Env × List CStmt) :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  match ps, as with
  | [], [] => pure (tenv, [])
  | p :: ps, a :: as => do
    if p.reference || p.attr.isSome then failure
    let some (.ty t) := declTy tenv p.t | failure
    if t == .void then failure
    let v ← convTo ctx.opt true t (← expr fuel ctx env a)
    let slot ← fresh
    let set ← assign slot v
    let (env', rest) ← params fuel ctx env ((p.name, .var slot t (p.t.pointer || !p.t.const)) :: tenv) ps as
    pure (env', set ++ rest)
  | _, _ => failure

/-- An expression statement: assignment, compound assignment, `++`/`--`, call. -/
def exprStmt (fuel : Nat) (ctx : Ctx) (env : Env) (x : Expr) : M (List CStmt) :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  match x with
  | .assign none target value => do
    let v ← expr fuel ctx env value
    write ctx.opt (← place fuel ctx env target) v
  | .assign (some op) target value => do
    let v ← expr fuel ctx env value
    compound ctx.opt (← place fuel ctx env target) op v
  | .step inc _ target => do
    compound ctx.opt (← place fuel ctx env target) (if inc then .add else .sub) (ofK ⟨.i32, 1⟩)
  | .call f ts args => do pure (← call fuel ctx env f ts args).pre
  | .comma a b => do pure ((← exprStmt fuel ctx env a) ++ (← exprStmt fuel ctx env b))
  | _ => failure

def extents (fuel : Nat) (ctx : Ctx) (env : Env) (xs : List Expr) : M (List Nat) :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  match xs with
  | [] => pure []
  | x :: rest => do
    let v ← expr fuel ctx env x
    let some k := v.k | failure
    if !v.pre.isEmpty || !k.s.isInt || k.int ≤ 0 then failure
    pure (k.int.toNat :: (← extents fuel ctx env rest))

/-- One declarator. -/
def decl (fuel : Nat) (ctx : Ctx) (env : Env) (cx : Bool) (ts : TypeSpec) (d : Declarator) :
    M (Env × List CStmt) :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  if cx then do
    -- `constexpr`: a folded constant.
    let some (.expr e) := d.init | failure
    if !d.extents.isEmpty then failure
    let v ← expr fuel ctx env e
    if !v.pre.isEmpty then failure
    let t ← match declTy env ts with
      | some .auto => pure v.t
      | some (.ty t) => pure t
      | none => failure
    let v ← convTo ctx.opt true t v
    pure ((d.name, .const t (← lift v.k)) :: env, [])
  else if !d.extents.isEmpty then do
    -- An array: a numbered allocation (thread or threadgroup), `= {…}` zero-filled; of
    -- pointers or of SIMD-group matrices, a thread array without initializer.
    let mat := if ts.pointer || ts.vec.isSome then none else Builtins.matrixOfName ts.name
    let elem ← if ts.pointer then do
        let sp ← lift ts.space
        pure (Ty.ptr sp (← lift (ptrElem env ts)))
      else if ts.const then failure
      else match mat with
        | some s => pure (.vec s 2)
        | none => lift (ptrElem env ts)
    let group ← if ts.pointer then pure false else match ts.space with
      | some .threadgroup => pure true
      | none | some .thread => pure false
      | _ => failure
    if (ts.pointer || mat.isSome) && (group || d.init.isSome) then failure
    let ns ← extents fuel ctx env d.extents
    let count := ns.foldl (· * ·) 1
    let st ← get
    let index := if group then st.group.length else st.thread.length
    set { st with
      group := if group then st.group ++ [(elem, count)] else st.group
      thread := if group then st.thread else st.thread ++ [(elem, count)] }
    let slot ← fresh
    let inits ← match d.init with
      | none => pure []
      | some (.braces es) => do
        if group || count < es.length then failure
        let .scalar s := elem | failure
        let vs ← (← argList fuel ctx env es).mapM (convTo ctx.opt true (.scalar s))
        let zero ← lift (convK s ⟨.i32, 0⟩)
        pure ((vs.map (·.pre)).flatten ++ (List.range count).map fun i =>
          CStmt.store (.scalar s) (.offset (.local slot) (.lit (.int .i32 i)))
            ((vs[i]?.map (·.e)).getD (.lit zero.val)))
      | some (.expr _) => failure
    let b : Bind := match mat with
      | some s => .matArray slot s ns
      | none => .array slot (if group then .threadgroup else .thread) elem ns
    pure ((d.name, b) :: env, .array slot group index elem :: inits)
  else do
    let dt ← lift (declTy env ts)
    if !ts.pointer && !(ts.space.isNone || ts.space == some .thread) then failure
    match d.init with
    | some (.expr e) =>
      let v ← expr fuel ctx env e
      let t ← match dt with
        | .auto => pure v.t
        | .ty t => pure t
      if t == .void then failure
      let v ← convTo ctx.opt true t v
      let slot ← fresh
      let ss ← assign slot v
      pure ((d.name, .var slot t (ts.pointer || !ts.const)) :: env, ss)
    | none =>
      let .ty t := dt | failure
      if t == .void || ts.const then failure
      match t with
      | .vec _ _ | .mat _ => do
        -- Without initializer a vector or matrix is an object in this thread's memory
        -- (a one-element thread array), so that its unwritten elements are undefined.
        let ty ← lift t.ty
        let st ← get
        let index := st.thread.length
        set { st with thread := st.thread ++ [(ty, 1)] }
        let slot ← fresh
        pure ((d.name, .obj slot t) :: env, [.array slot false index ty])
      | _ => do
        let slot ← fresh
        modify fun s => { s with
          wide := slot :: s.wide
          cand := slot :: s.cand
          hwide := slot :: s.hwide
          hcand := slot :: s.hcand }
        pure ((d.name, .var slot t true) :: env, [])
    | some (.braces _) => failure

def decls (fuel : Nat) (ctx : Ctx) (env : Env) (cx : Bool) (ts : TypeSpec) (ds : List Declarator) :
    M (Env × List CStmt) :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  match ds with
  | [] => pure (env, [])
  | d :: ds => do
    let (env, a) ← decl fuel ctx env cx ts d
    let (env, b) ← decls fuel ctx env cx ts ds
    pure (env, a ++ b)

def stmt (fuel : Nat) (ctx : Ctx) (env : Env) (s : Stmt) : M (Env × List CStmt) :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  match s with
  | .decl cx t ds => decls fuel ctx env cx t ds
  | .expr e => do pure (env, ← exprStmt fuel ctx env e)
  | .block b => do
    let (_, ss) ← stmts fuel ctx env b
    pure (env, ss)
  | .ite c th el => do
    let vc ← toBool ctx.opt (← expr fuel ctx env c)
    let (_, ts) ← stmt fuel ctx env th
    let (_, es) ← match el with
      | some e => stmt fuel ctx env e
      | none => pure (env, [])
    match vc.k with
    | some k => pure (env, vc.pre ++ (if k.w == 1 then ts else es))
    | none => pure (env, vc.pre ++ [.ite vc.e ts es])
  | .loop init cond step body => do
    let (env1, is) ← match init with
      | some i => stmt fuel ctx env i
      | none => pure (env, [])
    let vc ← match cond with
      | some c => do toBool ctx.opt (← expr fuel ctx env1 c)
      | none => pure (ofK (kbool true))
    if !vc.pre.isEmpty then failure
    let ss ← match step with
      | some e => exprStmt fuel ctx env1 e
      | none => pure []
    let (_, bs) ← stmt fuel { ctx with loop := true } env1 body
    match vc.k with
    | some k => pure (env, if k.w == 0 then is else is ++ [.loop vc.e ss bs])
    | none => pure (env, is ++ [.loop vc.e ss bs])
  | .continue_ => if ctx.loop then pure (env, [.continue_]) else failure
  | .break_ => if ctx.loop then pure (env, [.break_]) else failure
  | .ret v => do
    -- A `return;` of the kernel body leaves the scope the kernel's body is wrapped in.
    let some (slot, t) := ctx.ret | (if v.isNone then do modify fun s => { s with kret := true }; pure (env, [.leave])
                                    else failure)
    match v with
    | none => if t == .void then pure (env, [.leave]) else failure
    | some e => do
      let ss ← assign slot (← convTo ctx.opt true t (← expr fuel ctx env e))
      pure (env, ss ++ [.leave])
  | .pragma _ b => stmt fuel ctx env b
  | .ifConstexpr c th el => do
    -- Only the selected branch is instantiated.
    let vc ← toBool ctx.opt (← expr fuel ctx env c)
    let some k := vc.k | failure
    if !vc.pre.isEmpty then failure
    if k.w == 1 then do
      let (_, ts) ← stmt fuel ctx env th
      pure (env, ts)
    else match el with
      | some e => do
        let (_, es) ← stmt fuel ctx env e
        pure (env, es)
      | none => pure (env, [])
  | .empty => pure (env, [])

def stmts (fuel : Nat) (ctx : Ctx) (env : Env) (ss : List Stmt) : M (Env × List CStmt) :=
  match fuel with
  | 0 => failure
  | fuel + 1 =>
  match ss with
  | [] => pure (env, [])
  | s :: rest => do
    let (env, a) ← stmt fuel ctx env s
    let (env, b) ← stmts fuel ctx env rest
    pure (env, a ++ b)

end

/-! ## The kernel -/

/-- Kernel parameters: buffer `i` (in order from 0) is region `i`; attributes
are coordinates of the type MLX declares. Returns the buffer count. -/
def kernelParams : Env → Nat → List Param → M (Env × List CStmt × Nat)
  | env, n, [] => pure (env, [], n)
  | env, n, p :: ps =>
    match p.attr with
    | some (.buffer i) => do
      if i != n || p.t.vec.isSome then failure
      let elem ← lift (elemTy env p.t.name)
      let slot ← fresh
      if p.t.pointer then
        let some sp := p.t.space | failure
        if !(sp == .device || sp == .constant) || p.reference then failure
        let (env', rest, m) ← kernelParams ((p.name, .var slot (.ptr sp p.t.const elem) true) :: env) (n + 1) ps
        pure (env', .set slot (.lit (.ptr ⟨i, 0, elem⟩)) :: rest, m)
      else if p.reference && p.t.space == some .constant then
        let (env', rest, m) ← kernelParams ((p.name, .var slot (ETy.ofTy elem) false) :: env) (n + 1) ps
        pure (env', .set slot (.load elem (.lit (.ptr ⟨i, 0, elem⟩))) :: rest, m)
      else failure
    | some (.builtin a) => do
      let (c, ty) ← lift (coord a)
      if p.t.pointer || p.reference || p.t.space.isSome then failure
      if p.t.vec.isSome || elemTy env p.t.name != some ty then failure
      kernelParams ((p.name, .coord c (ETy.ofTy ty)) :: env) n ps
    | none => failure

def fuel : Nat := 100000

/-- Functions defined before the kernel `name`, and the kernel. -/
def split (name : List Char) : List Top → List Func → Option (List Func × Func)
  | [], _ => none
  | .func f :: rest, before =>
    if f.kernel then (if same f.name name then some (before.reverse, f) else split name rest before)
    else split name rest (f :: before)
  | _ :: rest, before => split name rest before

/-- The kernel to elaborate: the name and template arguments of MLX's explicit
instantiation, or the only untemplated kernel. -/
def instanceOf (unit : List Top) : Option (List Char × List TArg) :=
  match unit.filterMap (fun | .instantiate _ n ts => some (n, ts) | _ => none),
      unit.filterMap (fun | .func f => if f.kernel then some f.name else none | _ => none) with
  | [(n, ts)], _ => some (n, ts)
  | [], [n] => some (n, [])
  | _, _ => none

/-- The kernel `k` (after the functions `funcs`) with its template parameters
bound in `tenv`: its parameters, then its body (wrapped in a scope when it
returns). -/
def kernelBody (opt : Bool) (funcs : List Func) (k : Func) (tenv : Env) : M (List CStmt × Nat) := do
  let (env, ps, buffers) ← kernelParams tenv 0 k.params
  let (_, body) ← stmts fuel { funcs, opt } env k.body
  let st ← get
  pure (ps ++ (if st.kret then [.scope body] else body), buffers)

def kernelOf (opt : Bool) (unit : List Top) : Option Kernel := do
  let (name, targs) ← instanceOf unit
  let (funcs, k) ← split name unit []
  if !same k.result.name chars!"void" || k.result.pointer then none
  let run : M (List CStmt × Nat) := do
    let tenv ← bindTemplate fuel { funcs, opt } [] k.tparams targs
    kernelBody opt funcs k tenv
  let ((body, buffers), st) ← run.run {}
  pure { buffers, threadgroupArrays := st.group, threadArrays := st.thread, body }

end Metal.Elab

namespace Metal

/-- The core of the unit's instantiated kernel as the GPU runs it (the
default optimization level's peepholes applied). -/
def elaborate (unit : List Top) : Option Core.Kernel := Elab.kernelOf true unit

/-- The same without the default-level peepholes: the static source sites
(`-O0`), for comparison with the compiler's -O0 inventory. -/
def elaborateO0 (unit : List Top) : Option Core.Kernel := Elab.kernelOf false unit

end Metal

namespace Metal.Inventory
open Core Elab

/-! # Floating-operation inventory

The static floating operations of a core (each node once, so an inlined
body once per call site and a loop body once), named as
proofs/metal/AirInventory.ts names the compiler's LLVM operations:
`fadd.f32`, `fsub.bf16`, `fcmp.olt.f32` (`<`; `ole`, `ogt`, `oge`, `oeq`,
`une`), `llvm.fmuladd.f32` (a contraction site; its product is not counted
again, and a subtracting one also counts the `fneg.f32` of its negated
operand), `air.fma.f32`, `air.fast_exp.f32`, `air.exp.f32`,
`air.fast_fabs.f32`, `air.rsqrt.f32`, `air.fast_fmax.f32`, `fpext bf16→f32`,
`fptrunc f32→bf16`, `fpext f16→f32`, `bitcast i32→f32` (`as_type`; `isnan` is
the bit test `bitcast f32→i32`), `air.convert.f.f32.s.i32` (a run-time
integer → float conversion; constant ones are folded), `air.simd_sum.f32`,
`air.simd_shuffle_down.f32`/`.u.i32`, `air.wg.barrier`, `air.min.u.i32`,
`fptrunc f32→f16`, `air.convert.f.v4f32.f.v4bf16` (a vector conversion) and
`air.simdgroup_matrix_8x8_multiply_accumulate.v64f32.<A>.<B>.v64f32` (a `.mma`
collective). `make_filled_simdgroup_matrix`'s `air.simdgroup_matrix_8x8_init_filled`
is a register fill, no floating operation: not counted. Integer operations are
not counted. The default-level view (`canon`) also
counts `x - c` for a constant `c` as `fadd` (InstCombine's `fsub X, C` →
`fadd X, -C`). -/

def coordTy : Coord → Ty
  | .threadPositionInGrid | .threadPositionInThreadgroup | .threadgroupPositionInGrid
  | .threadsPerThreadgroup | .threadgroupsPerGrid | .threadsPerGrid => .vec .u32 3
  | _ => .scalar .u32

def litTy : Val → Option Ty
  | .bool _ => some (.scalar .bool)
  | .int s _ => some (.scalar s)
  | .f32 _ => some (.scalar .f32)
  | .bf16 _ => some (.scalar .bf16)
  | .f16 _ => some (.scalar .f16)
  | .vec s xs => some (.vec s xs.length)
  | .ptr _ => none

def lookupTy : List (Nat × Ty) → Nat → Option Ty
  | [], _ => none
  | (m, t) :: rest, n => if Nat.beq m n then some t else lookupTy rest n

/-- The type of a core expression, given the types of slots. -/
def tyOf (slots : List (Nat × Ty)) : Nat → CExpr → Option Ty
  | 0, _ => none
  | f + 1, e =>
    match e with
    | .lit v => litTy v
    | .local n => lookupTy slots n
    | .coord c => some (coordTy c)
    | .un op s _ => some (.scalar (if op == .isnan then .bool else s))
    | .bin op s _ _ _ => some (.scalar (if isCompare op then .bool else s))
    | .fma .. => some (.scalar .f32)
    | .conv t a =>
      match tyOf slots f a with
      | some (.vec _ n) => some (.vec t n)
      | _ => some (.scalar t)
    | .bitcast t _ => some (.scalar t)
    | .and .. | .or .. => some (.scalar .bool)
    | .cond _ a b =>
      match tyOf slots f a with
      | some t => some t
      | none => tyOf slots f b
    | .load t _ => some t
    | .component v _ =>
      match tyOf slots f v with
      | some (.vec s _) => some (.scalar s)
      | _ => none
    | .vector s es => some (.vec s es.length)
    | .offset .. | .ptrCast .. => none

/-- Slot types, from the statements that set the slots. -/
def scan : Nat → List (Nat × Ty) → List CStmt → List (Nat × Ty)
  | 0, acc, _ => acc
  | _ + 1, acc, [] => acc
  | f + 1, acc, st :: rest =>
    let acc := match st with
      | .set slot e =>
        match tyOf acc 1000 e with
        | some t => (slot, t) :: acc
        | none => acc
      | .collective _ slot op s _ _ => (slot, match op with | .mma .. => .vec s 2 | _ => .scalar s) :: acc
      | .ite _ a b => scan f (scan f acc a) b
      | .loop _ step b => scan f (scan f acc step) b
      | .scope b => scan f acc b
      | _ => acc
    scan f acc rest

def scalarIndex : Scalar → Nat
  | .bool => 0 | .i8 => 1 | .u8 => 2 | .i16 => 3 | .u16 => 4 | .i32 => 5
  | .u32 => 6 | .i64 => 7 | .u64 => 8 | .f16 => 9 | .bf16 => 10 | .f32 => 11

def scalarOfIndex : Nat → Scalar
  | 0 => .bool | 1 => .i8 | 2 => .u8 | 3 => .i16 | 4 => .u16 | 5 => .i32
  | 6 => .u32 | 7 => .i64 | 8 => .u64 | 9 => .f16 | 10 => .bf16 | _ => .f32

/-- An operation kind (`op`, below) at operand type `a` (and result type `b`). -/
def key (op : Nat) (a b : Scalar) : Nat := op * 256 + scalarIndex a * 16 + scalarIndex b

def llvmTy : Scalar → String
  | .f32 => "f32" | .bf16 => "bf16" | .f16 => "f16" | .bool => "i1"
  | .i8 | .u8 => "i8" | .i16 | .u16 => "i16" | .i32 | .u32 => "i32" | .i64 | .u64 => "i64"

def airTy (s : Scalar) : String :=
  if isFloat s then "f." ++ llvmTy s else (if s.isSigned then "s." else "u.") ++ llvmTy s

def name (k : Nat) : String :=
  let a := scalarOfIndex (k / 16 % 16)
  let b := scalarOfIndex (k % 16)
  match k / 256 with
  | 0 => "fadd." ++ llvmTy a
  | 1 => "fsub." ++ llvmTy a
  | 2 => "fmul." ++ llvmTy a
  | 3 => "fdiv." ++ llvmTy a
  | 4 => "fneg." ++ llvmTy a
  | 5 => "llvm.fmuladd." ++ llvmTy a
  | 6 => "air.fma." ++ llvmTy a
  | 7 => "air.fast_exp." ++ llvmTy a
  | 8 => "air.exp." ++ llvmTy a
  | 9 => "air.fast_fabs." ++ llvmTy a
  | 10 => "air.fabs." ++ llvmTy a
  | 11 => "air.rsqrt." ++ llvmTy a
  | 12 => "air.fast_fmax." ++ llvmTy a
  | 13 => "air.simd_sum." ++ llvmTy a
  | 14 => "air.simd_shuffle_down." ++ (if isFloat a then llvmTy a else airTy a)
  | 15 => "air.wg.barrier"
  | 16 => "air.min." ++ airTy a
  | 17 => "air.max." ++ airTy a
  | 18 => "fcmp.olt." ++ llvmTy a
  | 19 => "fcmp.ole." ++ llvmTy a
  | 20 => "fcmp.ogt." ++ llvmTy a
  | 21 => "fcmp.oge." ++ llvmTy a
  | 22 => "fcmp.oeq." ++ llvmTy a
  | 23 => "fcmp.une." ++ llvmTy a
  | 24 => "fpext " ++ llvmTy a ++ "→" ++ llvmTy b
  | 25 => "fptrunc " ++ llvmTy a ++ "→" ++ llvmTy b
  | 26 => "bitcast " ++ llvmTy a ++ "→" ++ llvmTy b
  | 27 => "air.convert." ++ airTy b ++ "." ++ airTy a
  | 29 => "air.simdgroup_matrix_8x8_multiply_accumulate.v64f32.v64" ++ llvmTy a ++ ".v64" ++ llvmTy b ++ ".v64f32"
  | 30 => "air.convert.f.v2" ++ llvmTy b ++ ".f.v2" ++ llvmTy a
  | 31 => "air.convert.f.v3" ++ llvmTy b ++ ".f.v3" ++ llvmTy a
  | 32 => "air.convert.f.v4" ++ llvmTy b ++ ".f.v4" ++ llvmTy a
  | _ => "?"

def unCode : Core.UnOp → Option Nat
  | .neg => some 4 | .fastExp => some 7 | .exp => some 8 | .fastFabs => some 9
  | .fabs => some 10 | .rsqrt => some 11
  | _ => none

def cmpCode : Core.BinOp → Nat
  | .lt => 18 | .le => 19 | .gt => 20 | .ge => 21 | .eq => 22 | _ => 23

abbrev Counts := List (Nat × Nat)

/-- One more of kind `k` (kinds kept in increasing order). -/
def bump (k : Nat) : Counts → Counts
  | [] => [(k, 1)]
  | (m, n) :: rest =>
    if Nat.beq m k then (m, n + 1) :: rest
    else if Nat.blt k m then (k, 1) :: (m, n) :: rest
    else (m, n) :: bump k rest

def isMulF32 : CExpr → Bool
  | .bin .mul .f32 _ _ _ => true
  | _ => false

def isLit : CExpr → Bool
  | .lit _ => true
  | _ => false

def countE (canon : Bool) (slots : List (Nat × Ty)) : Nat → Counts → CExpr → Counts
  | 0, c, _ => c
  | f + 1, c, e =>
    let go := countE canon slots f
    match e with
    | .lit _ | .local _ | .coord _ => c
    | .un op s a =>
      let c := go c a
      if !isFloat s then c
      else if op == .isnan then bump (key 26 s .i32) c
      else match unCode op with
        | some o => bump (key o s s) c
        | none => c
    | .bin op s site a b =>
      if !isFloat s then
        let c := go (go c a) b
        if op == .min then bump (key 16 s s) c else if op == .max then bump (key 17 s s) c else c
      else if isCompare op then bump (key (cmpCode op) s s) (go (go c a) b)
      else if op == .max then bump (key 12 s s) (go (go c a) b)
      else if s == .f32 && site != 0 && (op == .add || op == .sub) && (isMulF32 a || isMulF32 b) then
        -- `llvm.fmuladd` of the product's operands and the addend (Run.lean's choice).
        let (m, z) := if isMulF32 a then (a, b) else (b, a)
        let c := match m with
          | .bin _ _ _ x y => go (go c x) y
          | _ => c
        let c := bump (key 5 .f32 .f32) (go c z)
        if op == .sub then bump (key 4 .f32 .f32) c else c
      else
        let o := match op with
          | .add => 0
          | .sub => if canon && isLit b then 0 else 1
          | .mul => 2
          | _ => 3
        bump (key o s s) (go (go c a) b)
    | .fma a b d => bump (key 6 .f32 .f32) (go (go (go c a) b) d)
    | .conv t a =>
      let c := go c a
      match tyOf slots 1000 a with
      | some (.scalar s) =>
        if s == t then c
        else match fmt s, fmt t with
          | some F, some G => bump (key (if F.p < G.p then 24 else 25) s t) c
          | none, none => c
          | _, _ => bump (key 27 s t) c
      | some (.vec s n) => if s != t && isFloat s && isFloat t then bump (key (28 + n) s t) c else c
      | _ => c
    | .bitcast t a =>
      let c := go c a
      match tyOf slots 1000 a with
      | some (.scalar s) => if isFloat s || isFloat t then bump (key 26 s t) c else c
      | _ => c
    | .and a b | .or a b | .offset a b | .component a b => go (go c a) b
    | .cond x a b => go (go (go c x) a) b
    | .load _ p | .ptrCast _ p => go c p
    | .vector _ es => es.foldl go c

def countS (canon : Bool) (slots : List (Nat × Ty)) : Nat → Counts → List CStmt → Counts
  | 0, c, _ => c
  | _ + 1, c, [] => c
  | f + 1, c, st :: rest =>
    let ce := countE canon slots 1000
    let c := match st with
      | .set _ e => ce c e
      | .store _ p v => ce (ce c p) v
      | .ite x a b => countS canon slots f (countS canon slots f (ce c x) a) b
      | .loop x step b => countS canon slots f (countS canon slots f (ce c x) step) b
      | .scope b => countS canon slots f c b
      | .barrier .. => bump (key 15 .bool .bool) c
      | .collective _ _ op s e d =>
        let k := match op with
          | .sum => key 13 s s
          | .shuffleDown => key 14 s s
          | .mma a b => key 29 a b
        bump k (ce (ce c e) d)
      | .array .. | .continue_ | .break_ | .leave => c
    countS canon slots f c rest

def inventoryWith (canon : Bool) (k : Kernel) : List (String × Nat) :=
  let slots := scan 100000 (scan 100000 [] k.body) k.body
  (countS canon slots 100000 [] k.body).map fun (code, n) => (name code, n)

end Metal.Inventory

namespace Metal

/-- The static floating-operation inventory of a core (Inventory above),
in the compiler's `-O0` names: compare `inventory` of `elaborateO0` with
AirInventory.ts's `-O0` column. -/
def inventory (k : Core.Kernel) : List (String × Nat) := Inventory.inventoryWith false k

/-- The default-level view: compare `inventoryDefault` of `elaborate` with
AirInventory.ts's `default` column. -/
def inventoryDefault (k : Core.Kernel) : List (String × Nat) := Inventory.inventoryWith true k

end Metal
