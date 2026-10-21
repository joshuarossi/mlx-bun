import metal.Core

namespace Metal

/-! # Metal types of the modeled subset

Type names, integer promotion and the usual arithmetic conversions, as the
Metal compiler (metalfe-32023.921.6, `-fmetal-math-mode=safe`) applies them;
each rule below was confirmed on that compiler's LLVM output:
- bfloat with bfloat or with an integer computes in bfloat (`1 + a`, `a * 2`);
- bfloat with float converts the bfloat to float (`a + 2.0f`);
- integer operands narrower than `int` are promoted to `int`;
- a floating literal, suffixed or not, is rounded directly to `float`.
`bfloat16_t` and `float16_t` are MLX's typedefs for `bfloat` and `half`. -/

def scalarOfName : List Char → Option Scalar
  | ['b','o','o','l'] => some .bool
  | ['c','h','a','r'] | ['i','n','t','8','_','t'] => some .i8
  | ['u','c','h','a','r'] | ['u','i','n','t','8','_','t'] => some .u8
  | ['s','h','o','r','t'] | ['i','n','t','1','6','_','t'] => some .i16
  | ['u','s','h','o','r','t'] | ['u','i','n','t','1','6','_','t'] => some .u16
  | ['i','n','t'] | ['i','n','t','3','2','_','t'] => some .i32
  | ['u','i','n','t'] | ['u','i','n','t','3','2','_','t'] => some .u32
  | ['l','o','n','g'] | ['i','n','t','6','4','_','t'] => some .i64
  | ['u','l','o','n','g'] | ['u','i','n','t','6','4','_','t'] | ['s','i','z','e','_','t'] => some .u64
  | ['h','a','l','f'] | ['f','l','o','a','t','1','6','_','t'] => some .f16
  | ['b','f','l','o','a','t'] | ['b','f','l','o','a','t','1','6','_','t'] => some .bf16
  | ['f','l','o','a','t'] => some .f32
  | _ => none

/-- `uint4`, `float4`, … : a scalar name followed by a width 2, 3 or 4. -/
def vectorName (name : List Char) : Option (Scalar × Nat) :=
  match name.reverse with
  | d :: rest =>
    let n := d.toNat - '0'.toNat
    if 2 ≤ n ∧ n ≤ 4 then (scalarOfName rest.reverse).map (·, n) else none
  | [] => none

/-- A name, with an optional `metal::` qualification. -/
def unqualified : List (List Char) → Option (List Char)
  | [n] => some n
  | [['m','e','t','a','l'], n] => some n
  | _ => none

/-- Integer promotion: integers narrower than `int` (and `bool`) become `int`. -/
def promote (s : Scalar) : Scalar :=
  match s with
  | .bool | .i8 | .u8 | .i16 | .u16 => .i32
  | s => s

def rank : Scalar → Nat
  | .i32 | .u32 => 4
  | .i64 | .u64 => 8
  | _ => 0

/-- The usual arithmetic conversions: the common type of two operands. -/
def common (a b : Scalar) : Option Scalar :=
  if a = .f32 ∨ b = .f32 then some .f32
  else if a = .bf16 ∨ b = .bf16 then
    (if a = .f16 ∨ b = .f16 then none else some .bf16)
  else if a = .f16 ∨ b = .f16 then some .f16
  else
    let a := promote a
    let b := promote b
    if a = b then some a
    else if a.isSigned = b.isSigned then some (if rank a ≥ rank b then a else b)
    else
      let (u, s) := if a.isSigned then (b, a) else (a, b)
      if rank u ≥ rank s then some u
      else if rank s > rank u then some s
      else none

/-- Type of an integer literal (C++ [lex.icon]): decimal literals take the first
of `int`, `long` (with `u`: `uint`, `ulong`) that holds the value; hexadecimal
literals also try the unsigned type of each rank. -/
def intLiteral (value : Nat) (unsigned long hex : Bool) : Option Scalar :=
  let candidates : List Scalar :=
    match unsigned, long, hex with
    | false, false, false => [.i32, .i64]
    | false, false, true => [.i32, .u32, .i64, .u64]
    | true, false, _ => [.u32, .u64]
    | false, true, false => [.i64]
    | false, true, true => [.i64, .u64]
    | true, true, _ => [.u64]
  candidates.find? fun s => value < 2 ^ (if s.isSigned then s.width - 1 else s.width)

end Metal
