import metal.Syntax
import contracts.mlx.M1MaxContract
import contracts.mlx.Float16

namespace Metal
open Inference.Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

/-! # Typed core

Elaboration (proofs/metal/Elab.lean) turns a parsed kernel, instantiated at
its template arguments, into this core: every implicit conversion and every
operation's type is explicit, header functions are inlined, `constexpr`
values are folded, and each array declaration is a numbered allocation.
proofs/metal/Run.lean gives the core its meaning. -/

inductive Scalar where
  | bool | i8 | u8 | i16 | u16 | i32 | u32 | i64 | u64 | f16 | bf16 | f32
deriving DecidableEq, Repr, Inhabited

namespace Scalar
def bytes : Scalar → Nat
  | .bool | .i8 | .u8 => 1
  | .i16 | .u16 | .f16 | .bf16 => 2
  | .i32 | .u32 | .f32 => 4
  | .i64 | .u64 => 8
def isInt : Scalar → Bool
  | .i8 | .u8 | .i16 | .u16 | .i32 | .u32 | .i64 | .u64 => true
  | _ => false
def isSigned : Scalar → Bool
  | .i8 | .i16 | .i32 | .i64 => true
  | _ => false
def width (s : Scalar) : Nat := 8 * s.bytes
end Scalar

inductive Ty where
  | scalar (s : Scalar)
  | vec (s : Scalar) (n : Nat)
  | ptr (space : Space) (elem : Ty)
deriving DecidableEq, Repr, Inhabited

def Ty.bytes : Ty → Nat
  | .scalar s => s.bytes
  | .vec s n => s.bytes * (if n = 3 then 4 else n)
  | .ptr .. => 8

/-- A pointer: memory region, byte offset (may leave the region; only an
access out of bounds is undefined), element type. -/
structure Ptr where
  region : Nat
  offset : Int
  elem : Ty
deriving DecidableEq, Repr, Inhabited

inductive Val where
  | bool (b : Bool)
  /-- Integer of scalar type `s`, as its `s.width`-bit two's-complement word. -/
  | int (s : Scalar) (word : Nat)
  | f32 (x : Float32)
  | bf16 (x : BFloat16Arithmetic.Value)
  | f16 (x : Float16.Value)
  | vec (s : Scalar) (elements : List Val)
  | ptr (p : Ptr)
deriving Inhabited

/-- Built-in thread coordinates MLX passes as kernel attributes. -/
inductive Coord where
  | threadPositionInGrid | threadPositionInThreadgroup | threadgroupPositionInGrid
  | threadsPerThreadgroup | threadgroupsPerGrid | threadsPerGrid
  | threadIndexInSimdgroup | simdgroupIndexInThreadgroup
  | threadIndexInThreadgroup | simdgroupsPerThreadgroup | threadsPerSimdgroup
deriving DecidableEq, Repr, Inhabited

namespace Core

/-- Operations at a scalar type. `fastExp`, `fastFabs` … are the AIR
operations the source names lower to (M1Max.Contract); elaboration decides the
lowering of each source name. -/
inductive UnOp where
  | neg | not | bitNot
  | exp | fastExp | fabs | fastFabs | rsqrt | isnan
deriving DecidableEq, Repr, Inhabited

inductive BinOp where
  | add | sub | mul | div | rem | shl | shr | bitAnd | bitOr | bitXor
  | lt | le | gt | ge | eq | ne | min | max
deriving DecidableEq, Repr, Inhabited

inductive CExpr where
  | lit (v : Val)
  | local (slot : Nat)
  | coord (c : Coord)
  /-- `op` at scalar type `s` (vector operands apply it per component). -/
  | un (op : UnOp) (s : Scalar) (e : CExpr)
  /-- `op` at scalar type `s`. An `add` whose left operand is a `mul` at
  `f32` carries contraction site `site`: the compiler may fuse it. -/
  | bin (op : BinOp) (s : Scalar) (site : Nat) (a b : CExpr)
  | fma (a b c : CExpr)
  /-- Conversion between scalar types (C++ value conversion). -/
  | conv (target : Scalar) (e : CExpr)
  /-- `as_type`: reinterpret the bits. -/
  | bitcast (target : Scalar) (e : CExpr)
  /-- Short-circuit `&&` / `||`. -/
  | and (a b : CExpr) | or (a b : CExpr)
  /-- Lazy ternary: only the chosen operand is evaluated. -/
  | cond (c a b : CExpr)
  | load (t : Ty) (p : CExpr)
  /-- Pointer plus element count. -/
  | offset (p : CExpr) (i : CExpr)
  /-- Pointer reinterpretation to element type `t`. -/
  | ptrCast (t : Ty) (p : CExpr)
  | component (v : CExpr) (i : CExpr)
  | vector (s : Scalar) (elements : List CExpr)
deriving Inhabited

inductive Collective where
  | sum | shuffleDown
  /-- `simdgroup_multiply_accumulate(D, A, B, C)` with `A` of element type `a`, `B` of `b` (`C`
  and `D` float): each lane's value is `[A, B, C]`, each its 2-element `thread_elements()`, and
  its result `D`'s (Run.lean `resolve`). -/
  | mma (a b : Scalar)
deriving DecidableEq, Repr, Inhabited

inductive CStmt where
  | set (slot : Nat) (e : CExpr)
  | store (t : Ty) (p : CExpr) (v : CExpr)
  /-- `slot := ` pointer to threadgroup array `index`, or to this thread's
  thread array `index`. -/
  | array (slot : Nat) (threadgroup : Bool) (index : Nat) (elem : Ty)
  | ite (c : CExpr) (thenBranch elseBranch : List CStmt)
  /-- `for (; condition; step) body`; `continue` runs `step`. -/
  | loop (condition : CExpr) (step : List CStmt) (body : List CStmt)
  | continue_ | break_
  /-- Inlined function body; `leave` ends it. -/
  | scope (body : List CStmt)
  | leave
  /-- `threadgroup_barrier` at source site `site`, with whether it orders device and threadgroup memory. -/
  | barrier (site : Nat) (device threadgroup : Bool)
  /-- `slot := ` collective over the SIMD-group (`delta` for shuffles). -/
  | collective (site slot : Nat) (op : Collective) (s : Scalar) (e : CExpr) (delta : CExpr)
deriving Inhabited

/-- An elaborated kernel: its body, the threadgroup arrays (element type and
count) and the thread arrays every thread allocates. Buffer `i` of the launch
is region `i`; threadgroup array `j` is region `buffers + j`. -/
structure Kernel where
  buffers : Nat
  threadgroupArrays : List (Ty × Nat)
  threadArrays : List (Ty × Nat)
  body : List CStmt
deriving Inhabited

end Core
end Metal
