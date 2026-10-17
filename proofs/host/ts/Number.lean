namespace Host.Ts

/-! # IEEE binary64 numbers, exactly

A finite nonzero number is `±m·2^e` in canonical form: an integer below
`2^53` is `(|v|, 0)`, any other value has `m` odd. The representation is
unique, so structural equality is numeric equality (apart from `±0`), and
integer arithmetic (shapes, offsets, counters) takes one accelerated `Nat`
operation.
Arithmetic is exact on dyadic rationals followed by one round-to-nearest-
even (`round`), which is what IEEE 754 prescribes for `+ - * /`, `%` (exact)
and conversions. Operations whose exact result we do not compute (non-exact
`pow`, `sqrt`) return `none`: the run gets stuck rather than guess.

Everything is `Nat`/`Int` arithmetic with kernel-accelerated primitives
(`Nat.log2`, `Nat.pow`, `Nat.div`, shifts); no `Float`, no well-founded
recursion. -/

inductive F64 where
  | nan
  | inf (neg : Bool)
  | zero (neg : Bool)
  | fin (neg : Bool) (m : Nat) (e : Int)
deriving Inhabited, DecidableEq, Repr

namespace F64

/-- Precision, least unit exponent and the exclusive magnitude bound `2^top`. -/
structure Fmt where
  prec : Nat
  unit : Int
  top : Int

def b64 : Fmt := ⟨53, -1074, 1024⟩
def b32 : Fmt := ⟨24, -149, 128⟩

def ilt : Int → Int → Bool
  | .ofNat a, .ofNat b => Nat.blt a b
  | .ofNat _, .negSucc _ => false
  | .negSucc _, .ofNat _ => true
  | .negSucc a, .negSucc b => Nat.blt b a

def ile (a b : Int) : Bool := !ilt b a
def imin (a b : Int) : Int := bif ilt a b then a else b

/-- `2^k` for an integer `k`, as numerator and denominator. -/
def pow2 (k : Int) : Nat × Nat :=
  match k with
  | .ofNat k => (2 ^ k, 1)
  | .negSucc k => (1, 2 ^ (k + 1))

def small : Nat := 9007199254740992

/-- Strip trailing zero bits (`m ^^^ (m-1)` is `2^(tz+1) - 1`), then the
small-integer form if it applies. -/
def odd (neg : Bool) (m : Nat) (e : Int) : F64 :=
  let tz := Nat.log2 (Nat.xor m (Nat.sub m 1))
  let m' := Nat.shiftRight m tz
  let e' := Int.add e (Int.ofNat tz)
  match e' with
  | .ofNat k => let v := Nat.shiftLeft m' k; bif Nat.blt v small then fin neg v 0 else fin neg m' e'
  | .negSucc _ => fin neg m' e'

/-- Canonical form of `±m·2^e`. -/
def norm (neg : Bool) (m : Nat) (e : Int) : F64 :=
  bif Nat.beq m 0 then zero neg else
  match e with
  | .ofNat 0 => bif Nat.blt m small then fin neg m 0 else odd neg m 0
  | e => odd neg m e

/-- `±(p/q)·2^e` (`p, q > 0`) rounded to nearest-even in `f`. -/
def round (f : Fmt) (neg : Bool) (p q : Nat) (e : Int) : F64 :=
  bif Nat.beq q 1 && Nat.blt p (Nat.pow 2 f.prec) && ile f.unit e && ilt (Int.add (Nat.log2 p : Int) e) f.top then norm neg p e else
  let t : Int := (Nat.log2 p : Int) - (Nat.log2 q : Int)
  let scaled (k : Int) : Nat × Nat :=
    let (a, b) := pow2 k
    (p * a, q * b)
  let k0 : Int := (f.prec : Int) - t
  let k1 : Int :=
    let (n, d) := scaled k0
    bif Nat.ble (2 ^ f.prec) (n / d) then k0 - 1 else k0
  -- the unit 2^(e-k) is at least 2^f.unit
  let k : Int := bif ilt (e - k1) f.unit then e - f.unit else k1
  let (n, d) := scaled k
  let q0 := n / d
  let r2 := 2 * (n % d)
  let up := bif Nat.blt d r2 then true else bif Nat.beq r2 d then q0 % 2 == 1 else false
  let m := bif up then q0 + 1 else q0
  bif Nat.beq m 0 then zero neg else
  bif ile f.top ((Nat.log2 m : Int) + (e - k)) then inf neg else
  norm neg m (e - k)

def ofInt (i : Int) : F64 :=
  match i with
  | .ofNat n => round b64 false n 1 0
  | .negSucc n => round b64 true (n + 1) 1 0

def ofNat (n : Nat) : F64 := round b64 false n 1 0

/-- Signed integer numerator of a finite value scaled to unit `2^u` (`u ≤ e`). -/
def scaledAt (neg : Bool) (m : Nat) (e u : Int) : Int :=
  let v : Int := (m * 2 ^ (e - u).toNat : Nat)
  bif neg then -v else v

def ofSigned (f : Fmt) (s : Int) (e : Int) : F64 :=
  match s with
  | .ofNat 0 => zero false
  | .ofNat n => round f false n 1 e
  | .negSucc n => round f true (n + 1) 1 e

def neg : F64 → F64
  | nan => nan
  | inf s => inf (!s)
  | zero s => zero (!s)
  | fin s m e => fin (!s) m e

def add : F64 → F64 → F64
  | nan, _ => nan
  | _, nan => nan
  | inf a, inf b => bif a == b then inf a else nan
  | inf a, _ => inf a
  | _, inf b => inf b
  | zero a, zero b => zero (a && b)
  | zero _, x => x
  | x, zero _ => x
  | fin a m (.ofNat 0), fin b n (.ofNat 0) =>
    bif a == b then (let t := Nat.add m n; bif Nat.blt t small then fin a t 0 else round b64 a t 1 0)
    else bif Nat.blt n m then fin a (Nat.sub m n) 0 else bif Nat.blt m n then fin b (Nat.sub n m) 0 else zero false
  | fin a m e, fin b n d =>
    let u := imin e d
    ofSigned b64 (scaledAt a m e u + scaledAt b n d u) u

def sub (x y : F64) : F64 := add x (neg y)

def mul : F64 → F64 → F64
  | nan, _ => nan
  | _, nan => nan
  | inf a, inf b => inf (a != b)
  | inf _, zero _ => nan
  | zero _, inf _ => nan
  | inf a, fin b _ _ => inf (a != b)
  | fin a _ _, inf b => inf (a != b)
  | zero a, zero b => zero (a != b)
  | zero a, fin b _ _ => zero (a != b)
  | fin a _ _, zero b => zero (a != b)
  | fin a m (.ofNat 0), fin b n (.ofNat 0) =>
    let p := Nat.mul m n
    bif Nat.blt p small then fin (a != b) p 0 else round b64 (a != b) p 1 0
  | fin a m e, fin b n d => round b64 (a != b) (m * n) 1 (e + d)

def div : F64 → F64 → F64
  | nan, _ => nan
  | _, nan => nan
  | inf _, inf _ => nan
  | zero _, zero _ => nan
  | inf a, zero b => inf (a != b)
  | inf a, fin b _ _ => inf (a != b)
  | zero a, inf b => zero (a != b)
  | fin a _ _, inf b => zero (a != b)
  | zero a, fin b _ _ => zero (a != b)
  | fin a _ _, zero b => inf (a != b)
  | fin a m (.ofNat 0), fin b n (.ofNat 0) =>
    bif Nat.beq (Nat.mod m n) 0 then fin (a != b) (Nat.div m n) 0 else round b64 (a != b) m n 0
  | fin a m e, fin b n d => round b64 (a != b) m n (e - d)

/-- `%`: truncating remainder with the dividend's sign; always exact. -/
def rem : F64 → F64 → F64
  | nan, _ => nan
  | _, nan => nan
  | inf _, _ => nan
  | _, zero _ => nan
  | zero a, _ => zero a
  | fin a m e, inf _ => fin a m e
  | fin a m (.ofNat 0), fin _ n (.ofNat 0) =>
    let r := Nat.mod m n
    bif Nat.beq r 0 then zero a else fin a r 0
  | fin a m e, fin _ n d =>
    let u := imin e d
    let r := (m * 2 ^ (e - u).toNat) % (n * 2 ^ (d - u).toNat)
    bif Nat.beq r 0 then zero a else round b64 a r 1 u

def isNaN : F64 → Bool | nan => true | _ => false

/-- Strict order of non-NaN values; `none` if either is NaN. -/
def lt : F64 → F64 → Bool
  | nan, _ => false
  | _, nan => false
  | inf a, inf b => a && !b
  | inf a, _ => a
  | _, inf b => !b
  | zero _, zero _ => false
  | zero _, fin b _ _ => !b
  | fin a _ _, zero _ => a
  | fin a m (.ofNat 0), fin b n (.ofNat 0) =>
    bif a then (bif b then Nat.blt n m else true) else (bif b then false else Nat.blt m n)
  | fin a m e, fin b n d =>
    let u := imin e d
    ilt (scaledAt a m e u) (scaledAt b n d u)

/-- `===` on numbers: NaN is unequal to itself, `+0 = -0`. -/
def eq : F64 → F64 → Bool
  | nan, _ => false
  | _, nan => false
  | inf a, inf b => a == b
  | zero _, zero _ => true
  | fin a m e, fin b n d => a == b && Nat.beq m n && e == d
  | _, _ => false

def le (x y : F64) : Bool := lt x y || eq x y

def isZero : F64 → Bool | zero _ => true | _ => false

def truthy : F64 → Bool | nan => false | zero _ => false | _ => true

/-- Integer part (truncation toward zero), `none` for NaN and infinities. -/
def truncInt : F64 → Option Int
  | zero _ => some 0
  | fin s m e =>
    let v : Int := match e with
      | .ofNat k => (m * 2 ^ k : Nat)
      | .negSucc k => (m / 2 ^ (k + 1) : Nat)
    some (bif s then -v else v)
  | _ => none

/-- Exact integer value, if integral. -/
def toInt? : F64 → Option Int
  | zero _ => some 0
  | fin s m e => match e with
    | .ofNat k => some (bif s then -((m * 2 ^ k : Nat) : Int) else ((m * 2 ^ k : Nat) : Int))
    | .negSucc _ => none
  | _ => none

def isInt (x : F64) : Bool := (toInt? x).isSome

/-- A non-negative integer index below `2^53`. -/
def toIndex? (x : F64) : Option Nat :=
  match toInt? x with
  | some (.ofNat n) => bif Nat.blt n (2 ^ 53) then some n else none
  | _ => none

def modNat (i : Int) (m : Nat) : Nat := (i % (m : Int)).toNat

def toUint32 (x : F64) : Nat := match truncInt x with | some i => modNat i (2 ^ 32) | none => 0

def toInt32 (x : F64) : Int :=
  let u := toUint32 x
  bif Nat.blt u (2 ^ 31) then (u : Int) else (u : Int) - (2 ^ 32 : Nat)

def toUint8 (x : F64) : Nat := match truncInt x with | some i => modNat i 256 | none => 0
def toUint16 (x : F64) : Nat := match truncInt x with | some i => modNat i 65536 | none => 0

def floor (x : F64) : F64 :=
  match x with
  | fin s m e => match e with
    | .ofNat _ => x
    | .negSucc k =>
      let q := m / 2 ^ (k + 1)
      bif s then (bif Nat.beq q 0 then ofSigned b64 (-1) 0 else ofSigned b64 (-((q + 1 : Nat) : Int)) 0)
      else (bif Nat.beq q 0 then zero false else ofNat q)
  | _ => x

def ceil (x : F64) : F64 := neg (floor (neg x))

def trunc (x : F64) : F64 :=
  match x with
  | fin s m e => match e with
    | .ofNat _ => x
    | .negSucc k =>
      let q := m / 2 ^ (k + 1)
      bif Nat.beq q 0 then zero s else round b64 s q 1 0
  | _ => x

/-- `Math.min`/`Math.max` of two values: NaN wins, `-0 < +0`. -/
def min (x y : F64) : F64 :=
  match x, y with
  | nan, _ => nan
  | _, nan => nan
  | zero a, zero b => zero (a || b)
  | _, _ => bif lt y x then y else x

def max (x y : F64) : F64 :=
  match x, y with
  | nan, _ => nan
  | _, nan => nan
  | zero a, zero b => zero (a && b)
  | _, _ => bif lt x y then y else x

/-- Integer square root by Newton iteration from above. -/
def isqrtLoop : Nat → Nat → Nat → Nat
  | 0, _, x => x
  | f + 1, n, x => let y := (x + n / x) / 2; bif Nat.blt y x then isqrtLoop f n y else x

def isqrt (n : Nat) : Nat := bif Nat.beq n 0 then 0 else isqrtLoop 2000 n (2 ^ (Nat.log2 n / 2 + 1))

/-- `√(m·2^e)` when it is a dyadic rational (then exact). -/
def sqrtExact : F64 → Option F64
  | zero s => some (zero s)
  | inf false => some (inf false)
  | fin false m e =>
    let r := isqrt m
    bif Nat.beq (r * r) m && (e % 2 == 0) then some (round b64 false r 1 (e / 2)) else none
  | _ => some nan

/-- `x^k` for an integer `k`, exact then rounded once. -/
def powInt (x : F64) (k : Int) : F64 :=
  match x, k with
  | _, .ofNat 0 => fin false 1 0
  | fin s m e, .ofNat k => round b64 (s && k % 2 == 1) (m ^ k) 1 (e * k)
  | fin s m e, .negSucc k => round b64 (s && (k + 1) % 2 == 1) 1 (m ^ (k + 1)) (-(e * (k + 1 : Nat)))
  | zero s, .ofNat k => zero (s && k % 2 == 1)
  | zero s, .negSucc k => inf (s && (k + 1) % 2 == 1)
  | inf s, .ofNat k => inf (s && k % 2 == 1)
  | inf s, .negSucc k => zero (s && (k + 1) % 2 == 1)
  | nan, _ => nan

def half : F64 := fin false 1 (-1)

/-- Correctly rounded square root of `m·2^e`, `m > 0` (IEEE `squareRoot`): with
`n = p·4^56` (`p` the significand made to carry an even exponent), `r = ⌊√n⌋ ≥ 2^56`
and the exact root lies in `[r, r+1)`, which holds no rounding boundary (they are
integers at this scale); `round` of `r` or of `r + ½` is the rounded root. -/
def sqrtRN (m : Nat) (e : Int) : F64 :=
  let odd := !(e % 2 == 0)
  let p := bif odd then 2 * m else m
  let e2 : Int := bif odd then e - 1 else e
  let n := p * 4 ^ 56
  let r := isqrt n
  round b64 false (2 * r + bif Nat.beq (r * r) n then 0 else 1) 2 (e2 / 2 - 56)

/-- `Math.sqrt`: IEEE square root. -/
def sqrt : F64 → F64
  | zero s => zero s
  | inf false => inf false
  | fin false m e => sqrtRN m e
  | _ => nan

/-- `Math.pow`/`**`: integer exponents exactly rounded once, and `±0.5` as Bun's
JavaScriptCore computes them: `√x` and `1 / √x` (two roundings; measured equal on
Bun 1.4, unlike a correctly rounded `x^-0.5`), with the specification's zeros and
infinities. Other exponents are not modelled. -/
def pow (x y : F64) : Option F64 :=
  match toInt? y with
  | some k => some (powInt x k)
  | none =>
    match y with
    | fin s 1 (.negSucc 0) => match x with
      | nan => some nan
      | zero _ => some (bif s then inf false else zero false)
      | inf _ => some (bif s then zero false else inf false)
      | fin true _ _ => some nan
      | fin false m e => some (bif s then div (fin false 1 0) (sqrtRN m e) else sqrtRN m e)
    | nan => some nan
    | _ => none

/-! ## Binary32 -/

/-- Round to binary32 (as a binary64 value): `Math.fround`, f32 stores. -/
def toF32 : F64 → F64
  | fin s m e => round b32 s m 1 e
  | x => x

/-- Binary32 bit pattern of a binary32-representable value. -/
def f32Bits : F64 → Nat
  | nan => 0x7fc00000
  | inf s => (bif s then 0x80000000 else 0) + 0x7f800000
  | zero s => bif s then 0x80000000 else 0
  | fin s m0 e0 =>
    let tz := Nat.log2 (Nat.xor m0 (Nat.sub m0 1))
    let m := Nat.shiftRight m0 tz
    let e : Int := e0 + tz
    let sign := bif s then 0x80000000 else 0
    -- m·2^e = 1.f·2^E with E = e + log2 m
    let l := Nat.log2 m
    let E : Int := e + l
    bif ilt E (-126) then sign + m * 2 ^ (e + 149).toNat
    else sign + (E + 127).toNat * 2 ^ 23 + (m * 2 ^ (23 - l) - 2 ^ 23)

def ofF32Bits (b : Nat) : F64 :=
  let s := Nat.ble 0x80000000 b
  let ex := (b / 2 ^ 23) % 256
  let fr := b % 2 ^ 23
  bif Nat.beq ex 255 then (bif Nat.beq fr 0 then inf s else nan)
  else bif Nat.beq ex 0 then (bif Nat.beq fr 0 then zero s else round b64 s fr 1 (-149))
  else round b64 s (fr + 2 ^ 23) 1 ((ex : Int) - 150)

/-! ## Literals and strings -/

def digitVal (c : Char) : Option Nat :=
  let n := c.toNat
  bif Nat.ble 48 n && Nat.ble n 57 then some (n - 48)
  else bif Nat.ble 97 n && Nat.ble n 102 then some (n - 87)
  else bif Nat.ble 65 n && Nat.ble n 70 then some (n - 55)
  else none

/-- Digits in radix `r`, skipping `_` separators: value and digit count. -/
def digitsLoop (r : Nat) : List Char → Nat → Nat → Nat × Nat × List Char
  | [], v, k => (v, k, [])
  | c :: cs, v, k =>
    bif c == '_' then digitsLoop r cs v k else
    match digitVal c with
    | some d => bif Nat.blt d r then digitsLoop r cs (v * r + d) (k + 1) else (v, k, c :: cs)
    | none => (v, k, c :: cs)

/-- `D·10^E` rounded to binary64. -/
def ofDecimal (d : Nat) (e : Int) : F64 :=
  bif Nat.beq d 0 then zero false else
  match e with
  | .ofNat k => round b64 false (d * 10 ^ k) 1 0
  | .negSucc k => round b64 false d (10 ^ (k + 1)) 0

/-- Decimal literal text `int[.frac][e±exp]` (the lexer's raw number text). -/
def parseDecimal (cs : List Char) : Option F64 :=
  let (i, ni, cs) := digitsLoop 10 cs 0 0
  let (f, nf, cs) := match cs with
    | '.' :: cs => let (f, nf, cs) := digitsLoop 10 cs 0 0; (f, nf, cs)
    | cs => (0, 0, cs)
  let mant := i * 10 ^ nf + f
  let exp : Option (Int × List Char) := match cs with
    | c :: cs => bif c == 'e' || c == 'E' then
        match cs with
        | '-' :: cs => let (x, n, cs) := digitsLoop 10 cs 0 0; bif Nat.beq n 0 then none else some (-(x : Int), cs)
        | '+' :: cs => let (x, n, cs) := digitsLoop 10 cs 0 0; bif Nat.beq n 0 then none else some ((x : Int), cs)
        | cs => let (x, n, cs) := digitsLoop 10 cs 0 0; bif Nat.beq n 0 then none else some ((x : Int), cs)
      else some (0, c :: cs)
    | [] => some (0, [])
  match exp with
  | some (x, []) => bif Nat.beq (ni + nf) 0 then none else some (ofDecimal mant (x - nf))
  | _ => none

def radixOf : Char → Option Nat
  | 'x' => some 16 | 'X' => some 16 | 'o' => some 8 | 'O' => some 8 | 'b' => some 2 | 'B' => some 2
  | _ => none

/-- Integer literal text (decimal or `0x`/`0o`/`0b`), for numbers and bigints. -/
def parseIntLit : List Char → Option Nat
  | '0' :: c :: cs => match radixOf c with
    | some r => match digitsLoop r cs 0 0 with
      | (v, k, []) => bif Nat.beq k 0 then none else some v
      | _ => none
    | none => match digitsLoop 10 ('0' :: c :: cs) 0 0 with
      | (v, _, []) => some v
      | _ => none
  | cs => match digitsLoop 10 cs 0 0 with
    | (v, k, []) => bif Nat.beq k 0 then none else some v
    | _ => none

/-- A numeric literal's raw text. -/
def ofLit (raw : List Char) : Option F64 :=
  match raw with
  | '0' :: c :: _ => match radixOf c with
    | some _ => (parseIntLit raw).map ofNat
    | none => parseDecimal raw
  | _ => parseDecimal raw

def natDigits : Nat → Nat → List Char → List Char
  | 0, _, acc => acc
  | f + 1, n, acc =>
    let acc := Char.ofNat (48 + n % 10) :: acc
    bif Nat.blt n 10 then acc else natDigits f (n / 10) acc

def natStr (n : Nat) : List Char := natDigits 400 n []

/-- `Number::toString` for integers below `10^21`; other values are not
modelled (`none`). -/
def toStr : F64 → Option (List Char)
  | nan => some ['N', 'a', 'N']
  | inf s => some ((bif s then ['-'] else []) ++ ['I', 'n', 'f', 'i', 'n', 'i', 't', 'y'])
  | zero _ => some ['0']
  | x@(fin s _ _) => match toInt? x with
    | some i => let n := i.natAbs; bif Nat.blt n (10 ^ 21) then some ((bif s then ['-'] else []) ++ natStr n) else none
    | none => none

def isWs (c : Char) : Bool := c == ' ' || c == '\n' || c == '\t' || c == '\r'

def trimWs (cs : List Char) : List Char := ((cs.dropWhile isWs).reverse.dropWhile isWs).reverse

/-- `StringToNumber` for decimal, radix-prefixed and empty strings. -/
def ofString (s : List Char) : F64 :=
  match trimWs s with
  | [] => zero false
  | '-' :: cs => match ofLit cs with | some x => neg x | none => nan
  | '+' :: cs => (ofLit cs).getD nan
  | cs => (ofLit cs).getD nan

end F64
end Host.Ts
