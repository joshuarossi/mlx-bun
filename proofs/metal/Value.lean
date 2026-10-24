import metal.Core
import contracts.mlx.FlushToZero
import contracts.mlx.FloatMemory

namespace Metal
open Inference.Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

/-! # Values: bytes and operations

Scalar values as little-endian bytes, and the meaning of each core operation.
Floating operations are the M1 Max operations of `M1Max.Contract`; integer
operations follow C++ (Metal is C++14 based): signed overflow, division by
zero and out-of-range shifts are undefined (`none`). -/

abbrev BF := BFloat16Arithmetic.Value

namespace Val

def f32Bits (x : Float32) : Nat := (FloatMemory.bits x).toNat
def ofF32Bits (n : Nat) : Float32 := FloatMemory.decode (BitVec.ofNat 32 n)
def bf16Bits (x : BF) : Nat := x.bits.toNat
def ofBf16Bits (n : Nat) : BF := Model.ofBits (BitVec.ofNat 16 n)
def f16Bits (x : Float16.Value) : Nat := x.bits.toNat
def ofF16Bits (n : Nat) : Float16.Value := Model.ofBits (BitVec.ofNat 16 n)

/-- The two's-complement word of a scalar value, for encoding and bit
reinterpretation. -/
def word : Val → Option (Scalar × Nat)
  | .bool b => some (.bool, if b then 1 else 0)
  | .int s w => some (s, w)
  | .f32 x => some (.f32, f32Bits x)
  | .bf16 x => some (.bf16, bf16Bits x)
  | .f16 x => some (.f16, f16Bits x)
  | _ => none

def ofWord (s : Scalar) (w : Nat) : Val :=
  match s with
  | .bool => .bool (w % 2 = 1)
  | .f32 => .f32 (ofF32Bits w)
  | .bf16 => .bf16 (ofBf16Bits w)
  | .f16 => .f16 (ofF16Bits w)
  | s => .int s (w % 2 ^ s.width)

/-- Signed value of an integer word. -/
def signed (s : Scalar) (w : Nat) : Int :=
  if s.isSigned ∧ 2 ^ (s.width - 1) ≤ w then (w : Int) - 2 ^ s.width else w

/-- The word of an exact integer at `s`, if representable (signed types) or
reduced modulo 2^width (unsigned types). -/
def wrap (s : Scalar) (v : Int) : Option Nat :=
  if s.isSigned then
    if -(2 ^ (s.width - 1) : Int) ≤ v ∧ v < 2 ^ (s.width - 1) then some (v % 2 ^ s.width).toNat else none
  else some (v % 2 ^ s.width).toNat

end Val

/-- Little-endian bytes of a word. -/
def wordBytes (n w : Nat) : List (BitVec 8) := (List.range n).map fun i => BitVec.ofNat 8 (w / 256 ^ i)
def bytesWord (bytes : List (BitVec 8)) : Nat := bytes.foldr (fun b w => b.toNat + 256 * w) 0

/-- The 64-bit word of a pointer kept in memory (an element of a thread array of pointers): its
region · 2^40 + its byte offset. Elaboration never lets a program read that storage as anything but
a pointer of the same element type, so any injective word serves; a pointer outside the range has
no encoding (no result). -/
def ptrWord (p : Ptr) : Option Nat :=
  if 0 ≤ p.offset ∧ p.offset < 2 ^ 40 ∧ p.region < 2 ^ 24 then some (p.region * 2 ^ 40 + p.offset.toNat) else none

/-- Bytes of a value stored at type `t`. -/
def encode : Ty → Val → Option (List (BitVec 8))
  | .scalar s, v => do
    let (s', w) ← v.word
    if s = s' then some (wordBytes s.bytes w) else none
  | .vec s n, .vec s' xs =>
    if s = s' ∧ xs.length = n then
      (xs.mapM fun (x : Val) => do let (t, w) ← x.word; if t = s then some (wordBytes s.bytes w) else none).map
        fun (parts : List (List (BitVec 8))) => parts.flatten ++ List.replicate ((Ty.vec s n).bytes - s.bytes * n) 0
    else none
  | .ptr _ e, .ptr p => if p.elem = e then (ptrWord p).map (wordBytes 8) else none
  | _, _ => none

/-- The value of type `t` in `bytes` (at least `t.bytes` of them). -/
def decode : Ty → List (BitVec 8) → Option Val
  | .scalar s, bytes => some (Val.ofWord s (bytesWord (bytes.take s.bytes)))
  | .vec s n, bytes => some (.vec s ((List.range n).map fun i =>
      Val.ofWord s (bytesWord ((bytes.drop (s.bytes * i)).take s.bytes))))
  | .ptr _ e, bytes =>
    let w := bytesWord (bytes.take 8)
    some (.ptr ⟨w / 2 ^ 40, ((w % 2 ^ 40 : Nat) : Int), e⟩)

namespace Core
variable (C : M1Max.Contract)

/-- binary32 bits of an integer of magnitude at most 2^24 (exactly representable). -/
def exactF32 (n : Int) : Nat :=
  let m := n.natAbs
  let e := Nat.log2 m
  if m = 0 then (if n < 0 then 0x80000000 else 0)
  else (if n < 0 then 0x80000000 else 0) + (e + 127) * 2 ^ 23 +
    (if e ≤ 23 then (m - 2 ^ e) * 2 ^ (23 - e) else (m - 2 ^ e) / 2 ^ (e - 23))

def f32Neg (x : Float32) : Float32 := Val.ofF32Bits (Val.f32Bits x ^^^ 0x80000000)

/-- Comparison of binary32 values as the hardware compares them: subnormals
flushed, unordered when either is NaN. -/
def f32Compare (x y : Float32) : Option Ordering :=
  Model.compare (Numerics.model (FlushToZero.flush x)) (Numerics.model (FlushToZero.flush y))

def ordered (op : BinOp) (o : Option Ordering) : Option Bool :=
  match op, o with
  | .lt, some .lt => some true | .lt, _ => some false
  | .le, some .lt | .le, some .eq => some true | .le, _ => some false
  | .gt, some .gt => some true | .gt, _ => some false
  | .ge, some .gt | .ge, some .eq => some true | .ge, _ => some false
  | .eq, some .eq => some true | .eq, _ => some false
  | .ne, some .eq => some false | .ne, _ => some true
  | _, _ => none

def intCompare (op : BinOp) (a b : Int) : Option Bool :=
  ordered op (some (compare a b))

/-- A binary operation on scalars of type `s` (operands already converted). -/
def binary (op : BinOp) (s : Scalar) (a b : Val) : Option Val :=
  match s, a, b with
  | .f32, .f32 x, .f32 y =>
    match op with
    | .add => some (.f32 (C.fadd x y))
    | .sub => some (.f32 (C.fadd x (f32Neg y)))
    | .mul => some (.f32 (C.fmul x y))
    | .div => some (.f32 (C.fdiv x y))
    | .max => some (.f32 (C.fmax x y))
    | .lt | .le | .gt | .ge | .eq | .ne => (ordered op (f32Compare x y)).map .bool
    | _ => none
  | .bf16, .bf16 x, .bf16 y =>
    match op with
    | .add => some (.bf16 (C.bfadd x y))
    | .sub => some (.bf16 (C.bfsub x y))
    | .mul => some (.bf16 (C.bfmul x y))
    | .div => some (.bf16 (C.bfdiv x y))
    | .lt | .le | .gt | .ge | .eq | .ne => (ordered op (f32Compare (C.widen x) (C.widen y))).map .bool
    | _ => none
  | .bool, .bool x, .bool y =>
    match op with
    | .eq => some (.bool (x == y)) | .ne => some (.bool (x != y))
    | .bitAnd => some (.bool (x && y)) | .bitOr => some (.bool (x || y))
    | .bitXor => some (.bool (x != y))
    | _ => none
  | s, .int sa x, .int sb y =>
    if sa = s ∧ sb = s ∧ s.isInt then
      let a := Val.signed s x
      let b := Val.signed s y
      let int (v : Int) := (Val.wrap s v).map (.int s)
      match op with
      | .add => int (a + b)
      | .sub => int (a - b)
      | .mul => int (a * b)
      | .div => if b = 0 then none else int (a.tdiv b)
      | .rem => if b = 0 then none else int (a.tmod b)
      | .bitAnd => some (.int s (x &&& y))
      | .bitOr => some (.int s (x ||| y))
      | .bitXor => some (.int s (x ^^^ y))
      | .shl =>
        if b < 0 ∨ s.width ≤ b.toNat then none
        else if s.isSigned ∧ (a < 0 ∨ 2 ^ s.width ≤ a.toNat * 2 ^ b.toNat) then none
        else some (.int s (x * 2 ^ b.toNat % 2 ^ s.width))
      | .shr =>
        if b < 0 ∨ s.width ≤ b.toNat then none
        else int (a / 2 ^ b.toNat)
      | .min => int (min a b)
      | .max => int (max a b)
      | .lt | .le | .gt | .ge | .eq | .ne => (intCompare op a b).map .bool
    else none
  | _, _, _ => none

def unary (op : UnOp) (s : Scalar) (a : Val) : Option Val :=
  match op, s, a with
  | .neg, .f32, .f32 x => some (.f32 (f32Neg x))
  | .neg, .bf16, .bf16 x => some (.bf16 (Val.ofBf16Bits (Val.bf16Bits x ^^^ 0x8000)))
  | .neg, s, .int s' x => if s = s' ∧ s.isInt then (Val.wrap s (-Val.signed s x)).map (.int s) else none
  | .not, .bool, .bool x => some (.bool (!x))
  | .bitNot, s, .int s' x => if s = s' ∧ s.isInt then some (.int s (2 ^ s.width - 1 - x)) else none
  | .exp, .f32, .f32 x => some (.f32 (C.exp x))
  | .fastExp, .f32, .f32 x => some (.f32 (C.fastExp x))
  | .fabs, .f32, .f32 x => some (.f32 (C.fabs x))
  | .fastFabs, .f32, .f32 x => some (.f32 (C.fastFabs x))
  | .rsqrt, .f32, .f32 x => some (.f32 (C.rsqrt x))
  | .isnan, .f32, .f32 x => some (.bool (Model.isNaN (Numerics.model x)))
  | _, _, _ => none

/-- C++ value conversion to `target`. Conversions from floating to integer
types and between floating types other than binary32/bfloat are outside the
modeled subset, except binary16 to binary32 (`Float16.widen`, the exact
cast; like the other conversions, part of the compiler-conformance boundary).
Integer to binary32 is modeled where it is exact. -/
def convert (target : Scalar) (a : Val) : Option Val :=
  match target, a with
  | .bool, .bool b => some (.bool b)
  | .bool, .int s w => if s.isInt then some (.bool (w ≠ 0)) else none
  | t, .bool b => if t.isInt then some (.int t (if b then 1 else 0)) else none
  | t, .int s w =>
    if !s.isInt then none
    else if t.isInt then some (.int t ((Val.signed s w) % 2 ^ t.width).toNat)
    else if t = .f32 ∧ (Val.signed s w).natAbs ≤ 2 ^ 24 then some (.f32 (Val.ofF32Bits (exactF32 (Val.signed s w))))
    else none
  | .f32, .f32 x => some (.f32 x)
  | .bf16, .bf16 x => some (.bf16 x)
  | .f32, .bf16 x => some (.f32 (C.widen x))
  | .bf16, .f32 x => some (.bf16 (C.narrow x))
  | .f32, .f16 x => some (.f32 (Float16.widen x))
  | .f16, .f32 x => some (.f16 (C.narrowHalf x))
  | _, _ => none

def bitcast (target : Scalar) (a : Val) : Option Val := do
  let (s, w) ← a.word
  if s.bytes = target.bytes then some (Val.ofWord target w) else none

end Core
end Metal
