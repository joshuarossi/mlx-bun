import metal.Types
import host.ts.Source

namespace Metal.Builtins
open Core

/-! # Built-in environment

What each name the route kernels take from the Metal standard library or
from MLX's `metal::utils()` preamble means, as core. Sources: the SDK headers
of metalfe-32023.921.6 (`lib/clang/32023/include/metal/…`) and the pinned
preamble (ml-explore/mlx@1f8e74e3, mlx/backend/metal/kernels/{bf16.h,
bf16_math.h, utils.h}, rebuilt byte-identical by proofs/metal/AirInventory.ts).
Each lowering was read off `xcrun metal -std=metal4.1 -fmetal-math-mode=safe
-S -emit-llvm` of small probes compiled after that exact preamble, and
agrees with AirInventory.ts's call-site attribution for the route kernels.

The preamble's `using namespace metal;` (bf16.h:7) makes every name below
usable with or without `metal::`; `precise::` names also with `metal::`.

Type names (Types.lean `scalarOfName`): `bfloat16_t` is MLX's `typedef bfloat
bfloat16_t` (bf16.h:9); `uint8_t` … `uint64_t`, `int8_t` … are metal_stdlib
typedefs. -/

def same : List Char → List Char → Bool
  | a :: as, b :: bs => Nat.beq a.toNat b.toNat && same as bs
  | [], [] => true
  | _, _ => false

/-- A built-in function. -/
inductive Fn where
  /-- Unary float math lowering to the AIR operation `op` (`UnOp.fastExp` is
  `air.fast_exp.f32`, …). -/
  | math (op : Core.UnOp)
  | fma | min | max | isnan
  | simdSum | simdShuffleDown
  | threadgroupBarrier
deriving DecidableEq, Repr, Inhabited

/-- A path as written, without `metal::`: whether it is in `precise::`, and
the name. -/
def strip : List (List Char) → Option (Bool × List Char)
  | [n] => some (false, n)
  | [m, n] =>
    if same m chars!"metal" then some (false, n)
    else if same m chars!"precise" then some (true, n) else none
  | [m, p, n] => if same m chars!"metal" && same p chars!"precise" then some (true, n) else none
  | _ => none

/-- The built-in a call names.
* `exp` → `air.fast_exp.f32`: metal_math `exp(float)` is
  `__metal_exp(x, __METAL_MAYBE_FAST_MATH__)`, fast even in safe math mode
  (fp32 functions keep MTLCompileOptions' default, fast).
* `precise::exp` → `air.exp.f32` (metal_math, `metal::precise`).
* `abs`, `fabs` → `air.fast_fabs.f32` (metal_math:25, :102).
* `precise::rsqrt` → `air.rsqrt.f32`.
* `fma` → `air.fma.f32` (metal_math:117; not `llvm.fma`).
* `min`, `max` on integers → `air.min.u.i32` / `air.min.s.i32` (metal_integer:
  one non-template overload per integer type); `max` on float →
  `air.fast_fmax.f32`.
* `isnan` → the bit test of metal_relational:386 (`bitcast`, `and`, `icmp ugt`),
  the core's `isnan`.
* `simd_sum` → `air.simd_sum.f32` (metal_simdgroup:274).
* `simd_shuffle_down` → `air.simd_shuffle_down.f32` / `.u.i32`
  (metal_simdgroup:239; the delta parameter is `ushort`: `trunc i32 to i16`).
* `threadgroup_barrier` → `air.wg.barrier(flags, …)` (metal_compute:75) with
  `mem_device` = 1, `mem_threadgroup` = 2. -/
def fn (path : List (List Char)) : Option Fn := do
  let (precise, n) ← strip path
  if precise then
    if same n chars!"exp" then some (.math .exp)
    else if same n chars!"rsqrt" then some (.math .rsqrt)
    else none
  else if same n chars!"exp" then some (.math .fastExp)
  else if same n chars!"abs" || same n chars!"fabs" then some (.math .fastFabs)
  else if same n chars!"fma" then some .fma
  else if same n chars!"min" then some .min
  else if same n chars!"max" then some .max
  else if same n chars!"isnan" then some .isnan
  else if same n chars!"simd_sum" then some .simdSum
  else if same n chars!"simd_shuffle_down" then some .simdShuffleDown
  else if same n chars!"threadgroup_barrier" then some .threadgroupBarrier
  else none

/-- MLX's bfloat overloads of the math functions (bf16_math.h:33-246,
instantiated at :250-272 with `ctype = float`): `static_cast<bfloat>(
__metal_op(static_cast<float>(x), mfast))`, so widen, the float operation,
narrow. In `metal::` `mfast` is `__METAL_MAYBE_FAST_MATH__` and in
`metal::precise::` `__METAL_PRECISE_MATH__`; probed: `metal::exp(bfloat)` →
`fpext`, `air.fast_exp.f32`, `fptrunc`; `metal::abs(bfloat)` → `fpext`,
`air.fast_fabs.f32`, `fptrunc`; `metal::precise::exp(bfloat)` → `fpext`,
`air.exp.f32`, `fptrunc`. Other bfloat overloads were not probed. -/
def bfloatOverload : Core.UnOp → Bool
  | .fastExp | .fastFabs | .exp => true
  | _ => false

/-- What a built-in call becomes. -/
inductive Lowered where
  /-- The call's value. -/
  | value (e : CExpr)
  /-- `slot := op` over the SIMD-group at scalar type `s` on `arg` (with
  `delta`); the call's value is the slot's, narrowed to bfloat if `narrow`. -/
  | collective (op : Collective) (s : Scalar) (arg delta : CExpr) (narrow : Bool)

/-- The overload a call resolves to: parameter types (arguments convert to
them implicitly), result type, and the lowering of converted arguments. -/
structure Overload where
  params : List Scalar
  result : Scalar
  lower : List CExpr → Option Lowered

def arg1 (f : CExpr → CExpr) : List CExpr → Option Lowered
  | [a] => some (.value (f a))
  | _ => none

def arg2 (f : CExpr → CExpr → CExpr) : List CExpr → Option Lowered
  | [a, b] => some (.value (f a b))
  | _ => none

def arg3 (f : CExpr → CExpr → CExpr → CExpr) : List CExpr → Option Lowered
  | [a, b, c] => some (.value (f a b c))
  | _ => none

def integer32 (s : Scalar) : Bool := s = .i32 ∨ s = .u32

/-- Overload resolution on the argument types (no overload, or an
unprobed one: `none`). Integer `min`/`max` take exactly equal argument types
(metal_integer has one overload per type; mixed types are ambiguous). -/
def resolve : Fn → List Scalar → Option Overload
  | .math op, [.f32] => some ⟨[.f32], .f32, arg1 (.un op .f32)⟩
  | .math op, [.bf16] =>
    if bfloatOverload op then some ⟨[.bf16], .bf16, arg1 fun a => .conv .bf16 (.un op .f32 (.conv .f32 a))⟩
    else none
  | .fma, [.f32, .f32, .f32] => some ⟨[.f32, .f32, .f32], .f32, arg3 .fma⟩
  | .min, [s, t] => if s = t ∧ integer32 s then some ⟨[s, s], s, arg2 (.bin .min s 0)⟩ else none
  | .max, [s, t] =>
    if s = t ∧ (integer32 s ∨ s = .f32) then some ⟨[s, s], s, arg2 (.bin .max s 0)⟩ else none
  | .isnan, [.f32] => some ⟨[.f32], .bool, arg1 (.un .isnan .f32)⟩
  /- `simd_sum(float)`; `simd_sum(bfloat)` is MLX's overload (bf16_math.h:362,
  instantiated :378 with `ctype = float`): widen, `air.simd_sum.f32`, narrow
  (probed). -/
  | .simdSum, [.f32] => some ⟨[.f32], .f32, fun
      | [a] => some (.collective .sum .f32 a (.lit (.int .u16 0)) false)
      | _ => none⟩
  | .simdSum, [.bf16] => some ⟨[.bf16], .bf16, fun
      | [a] => some (.collective .sum .f32 (.conv .f32 a) (.lit (.int .u16 0)) true)
      | _ => none⟩
  | .simdShuffleDown, [s, d] =>
    if (s = .f32 ∨ s = .u32) ∧ (d.isInt ∨ d = .bool) then
      some ⟨[s, .u16], s, fun
        | [a, delta] => some (.collective .shuffleDown s a delta false)
        | _ => none⟩
    else none
  | _, _ => none

/-- `mem_flags` of a `threadgroup_barrier` argument (metal_compute:13-31,
`operator|` at :31): whether it orders device and threadgroup memory. -/
def memFlags (fuel : Nat) (e : Expr) : Option (Bool × Bool) :=
  match fuel, e with
  | 0, _ => none
  | _ + 1, .name path =>
    let flag : List Char → Option (Bool × Bool) := fun n =>
      if same n chars!"mem_none" then some (false, false)
      else if same n chars!"mem_device" then some (true, false)
      else if same n chars!"mem_threadgroup" then some (false, true)
      else none
    match path with
    | [f, n] => if same f chars!"mem_flags" then flag n else none
    | [m, f, n] => if same m chars!"metal" && same f chars!"mem_flags" then flag n else none
    | _ => none
  | f + 1, .binary .bitOr a b => do
    let (d, g) ← memFlags f a
    let (d', g') ← memFlags f b
    pure (d || d', g || g')
  | _, _ => none

/-- `INFINITY` (metal_types:310, `__builtin_inff()`): binary32 +∞. -/
def infinityBits : Nat := 0x7F800000

/-! ## SIMD-group matrices

metal_simdgroup_matrix:47-80: `simdgroup_matrix<T, 8, 8>` keeps its elements in a
`vec<T, 64>` spread over the SIMD-group (AIR `<64 x T>`); `thread_elements()` is
the lane's part, its elements 0 and 1, so the core holds a matrix as each lane's
`.vec T 2`. -/

/-- `simdgroup_float8x8`, `simdgroup_half8x8`, `simdgroup_bfloat8x8` (:77-80). -/
def matrixOfName (n : List Char) : Option Scalar :=
  if same n chars!"simdgroup_float8x8" then some .f32
  else if same n chars!"simdgroup_half8x8" then some .f16
  else if same n chars!"simdgroup_bfloat8x8" then some .bf16
  else none

inductive MatFn where
  /-- `make_filled_simdgroup_matrix<T, 8, 8>(v)` (:84-106): every element `T(v)`
  (`air.simdgroup_matrix_8x8_init_filled`). -/
  | fill
  /-- `simdgroup_multiply_accumulate(d, a, b, c)` (:167-188): `d` from the
  SIMD-group collective on `a`, `b`, `c`
  (`air.simdgroup_matrix_8x8_multiply_accumulate`, Core `Collective.mma`). -/
  | mma
deriving DecidableEq, Repr, Inhabited

def matFn (path : List (List Char)) : Option MatFn := do
  let (precise, n) ← strip path
  if precise then none
  else if same n chars!"make_filled_simdgroup_matrix" then some .fill
  else if same n chars!"simdgroup_multiply_accumulate" then some .mma
  else none

/-- Kernel parameter attributes MLX writes (metal_kernel.cpp:243-264), the
coordinate each one is and its parameter type (Launch.lean gives the values). -/
def coord (attr : List Char) : Option (Coord × Ty) :=
  let u3 : Ty := .vec .u32 3
  let u : Ty := .scalar .u32
  if same attr chars!"thread_position_in_grid" then some (.threadPositionInGrid, u3)
  else if same attr chars!"thread_position_in_threadgroup" then some (.threadPositionInThreadgroup, u3)
  else if same attr chars!"threadgroup_position_in_grid" then some (.threadgroupPositionInGrid, u3)
  else if same attr chars!"threads_per_threadgroup" then some (.threadsPerThreadgroup, u3)
  else if same attr chars!"threadgroups_per_grid" then some (.threadgroupsPerGrid, u3)
  else if same attr chars!"threads_per_grid" then some (.threadsPerGrid, u3)
  else if same attr chars!"thread_index_in_simdgroup" then some (.threadIndexInSimdgroup, u)
  else if same attr chars!"simdgroup_index_in_threadgroup" then some (.simdgroupIndexInThreadgroup, u)
  else if same attr chars!"thread_index_in_threadgroup" then some (.threadIndexInThreadgroup, u)
  else if same attr chars!"simdgroups_per_threadgroup" then some (.simdgroupsPerThreadgroup, u)
  else if same attr chars!"threads_per_simdgroup" then some (.threadsPerSimdgroup, u)
  else none

end Metal.Builtins
