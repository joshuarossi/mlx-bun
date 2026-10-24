import metal.tests.Elab

namespace Metal.Elab.Tests
open Metal Core Elab Assemble.Tests Host.Mlx

/-! # Typing rules on small kernels -/

/-- A kernel around `body`: float, bfloat, int and half buffers 0-3 and the
SIMD lane `i`. -/
def unit (body : List Char) : List Char :=
  chars!"[[kernel]] void k(device float* a [[buffer(0)]], device bfloat16_t* b [[buffer(1)]], device int* n [[buffer(2)]], const device half* h [[buffer(3)]], uint i [[thread_index_in_simdgroup]]) {\n" ++
    body ++ chars!"\n}\n"

def coreOf (body : List Char) : Option Core.Kernel := (frontend (unit body)).bind elaborate
def coreO0 (body : List Char) : Option Core.Kernel := (frontend (unit body)).bind elaborateO0

/-- The values the top-level statements store, and set. -/
def stored : Option Core.Kernel → List CExpr
  | some k => k.body.filterMap fun | .store _ _ v => some v | _ => none
  | none => []

def sets : Option Core.Kernel → List CExpr
  | some k => k.body.filterMap fun | .set _ v => some v | _ => none
  | none => []

def word (e : CExpr) : Option (Scalar × Nat) :=
  match e with
  | .lit v => v.word
  | _ => none

def isMul : CExpr → Bool
  | .bin .mul .f32 0 _ _ => true
  | _ => false

def contracted : CExpr → Bool
  | .bin .add .f32 s a b => s != 0 && (isMul a || isMul b)
  | .bin .sub .f32 s a b => s != 0 && (isMul a || isMul b)
  | _ => false

def plain : CExpr → Bool
  | .bin .add .f32 0 _ _ | .bin .sub .f32 0 _ _ => true
  | _ => false

/-- An `f32` `+`/`-` whose operand is an `f32` `*` is a contraction site
(left product kept as the left operand, `c - a*b` and compound `+=`
included); not through a slot, a negation, or a division turned into a
product. -/
theorem contraction :
    (stored (coreOf chars!"a[0] = a[1] * a[2] + a[3];")).all contracted = true ∧
    (match stored (coreOf chars!"a[0] = a[1] * a[2] + a[3] * a[4];") with
      | [.bin .add .f32 s (.bin .mul .f32 0 _ _) (.bin .mul .f32 0 _ _)] => s != 0
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = a[3] - a[1] * a[2];") with
      | [.bin .sub .f32 s _ (.bin .mul .f32 0 _ _)] => s != 0
      | _ => false) = true ∧
    (sets (coreOf chars!"float t = a[0]; t += a[1] * a[2]; a[0] = t;")).any contracted = true ∧
    (stored (coreOf chars!"float t = a[1] * a[2]; a[0] = t + a[3];")).all plain = true ∧
    (match stored (coreOf chars!"a[0] = -(a[1] * a[2]) + a[3];") with
      | [.bin .add .f32 0 (.un .neg .f32 (.bin .mul .f32 0 _ _)) _] => true
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = a[1] / 8.0f + a[3];") with
      | [.bin .add .f32 0 (.conv .f32 (.bin .mul .f32 0 _ r)) _] => word r == some (.f32, 0x3E000000)
      | _ => false) = true ∧
    (match stored (coreO0 chars!"a[0] = a[1] / 8.0f + a[3];") with
      | [.bin .add .f32 0 (.bin .div .f32 0 _ _) _] => true
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = a[1] / 3.0f;") with
      | [.bin .div .f32 0 _ _] => true
      | _ => false) = true := by
  decide +kernel

/-- `bfloat` with `bfloat` or an integer computes in `bfloat` (the integer
converted at compile time); with `float`, in `float`. `float` → `bfloat` is
only explicit; `half` only widens explicitly and has no arithmetic; a
`bfloat` contraction (`llvm.fmuladd.bf16`) is rejected. -/
theorem conversions :
    (match stored (coreOf chars!"b[0] = 1 + b[1];") with
      | [.bin .add .bf16 0 one (.load (.scalar .bf16) _)] => word one == some (.bf16, 0x3F80)
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = b[0] + 2.0f;") with
      | [.bin .add .f32 0 (.conv .f32 (.load (.scalar .bf16) _)) _] => true
      | _ => false) = true ∧
    (coreOf chars!"b[0] = a[0];").isNone = true ∧
    (match stored (coreOf chars!"b[0] = bfloat16_t(a[0]);") with
      | [.conv .bf16 (.load (.scalar .f32) _)] => true
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = float(h[0]);") with
      | [.conv .f32 (.load (.scalar .f16) _)] => true
      | _ => false) = true ∧
    (coreOf chars!"a[0] = h[0];").isNone = true ∧
    (coreOf chars!"a[0] = float(h[0] + h[1]);").isNone = true ∧
    (coreOf chars!"b[0] = b[1] * b[2] + b[3];").isNone = true ∧
    (match stored (coreOf chars!"n[0] = 0xffffffff + 1;") with
      | [v] => word v == some (.i32, 0)
      | _ => false) = true ∧
    (coreOf chars!"n[0] = 2147483647 + 1;").isNone = true ∧
    (match stored (coreOf chars!"a[0] = -INFINITY;") with
      | [v] => word v == some (.f32, 0xFF800000)
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = as_type<float>(n[0]) + as_type<float>(0x3F800000u);") with
      | [.bin .add .f32 0 (.bitcast .f32 (.load (.scalar .i32) _)) one] => word one == some (.f32, 0x3F800000)
      | _ => false) = true := by
  decide +kernel

/-- The default level narrows `bfloat(op(float(x), float(y)))` to the
`bfloat` operation; a candidate it might narrow through a slot is rejected;
a `half`-exact constant operand blocks the narrowing (probed). -/
theorem narrowing :
    (match stored (coreOf chars!"b[0] = bfloat16_t(float(b[1]) + float(b[2]));") with
      | [.bin .add .bf16 0 (.load (.scalar .bf16) _) (.load (.scalar .bf16) _)] => true
      | _ => false) = true ∧
    (match stored (coreO0 chars!"b[0] = bfloat16_t(float(b[1]) + float(b[2]));") with
      | [.conv .bf16 (.bin .add .f32 0 (.conv .f32 _) (.conv .f32 _))] => true
      | _ => false) = true ∧
    (coreOf chars!"const float p = float(b[1]) * float(b[2]); b[0] = bfloat16_t(p);").isNone = true ∧
    (coreOf chars!"const float g = float(b[1]); b[0] = bfloat16_t(g + float(b[2]));").isNone = true ∧
    (match stored (coreOf chars!"b[0] = bfloat16_t(float(b[1]) * 2.0f);") with
      | [.conv .bf16 (.bin .mul .f32 0 (.conv .f32 _) _)] => true
      | _ => false) = true := by
  decide +kernel

/-- Built-ins: their core operations, MLX's bfloat overloads (widen, the
float operation, narrow), integer `min` on equal types only, collectives
with the `ushort` delta, barrier flags; conditions convert to `bool`; `?:`
is lazy. -/
theorem builtins :
    (match stored (coreOf chars!"b[0] = metal::exp(b[1]);") with
      | [.conv .bf16 (.un .fastExp .f32 (.conv .f32 _))] => true
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = metal::precise::exp(a[1]) + metal::abs(a[2]) + metal::precise::rsqrt(a[3]);") with
      | [.bin .add .f32 0 (.bin .add .f32 0 (.un .exp .f32 _) (.un .fastFabs .f32 _)) (.un .rsqrt .f32 _)] => true
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = metal::fma(a[1], a[2], a[3]);") with
      | [.fma _ _ _] => true
      | _ => false) = true ∧
    (match stored (coreOf chars!"n[0] = min(n[1], n[2]);") with
      | [.bin .min .i32 0 _ _] => true
      | _ => false) = true ∧
    (coreOf chars!"n[0] = min(n[1], i);").isNone = true ∧
    (match (coreOf chars!"b[0] = simd_sum(b[1]);").map (·.body) with
      | some [_, _, _, _, .collective 1 s .sum .f32 (.conv .f32 _) _, .store _ _ (.conv .bf16 (.local s'))] => s == s'
      | _ => false) = true ∧
    (match (coreOf chars!"a[0] = simd_shuffle_down(a[1], i);").map (·.body) with
      | some [_, _, _, _, .collective 1 _ .shuffleDown .f32 _ (.conv .u16 (.coord .threadIndexInSimdgroup)), _] => true
      | _ => false) = true ∧
    (match (coreOf chars!"threadgroup_barrier(mem_flags::mem_threadgroup | mem_flags::mem_device); threadgroup_barrier(metal::mem_flags::mem_threadgroup);").map (·.body) with
      | some [_, _, _, _, .barrier 1 true true, .barrier 2 false true] => true
      | _ => false) = true ∧
    (match (coreOf chars!"if (n[0]) a[0] = isnan(a[1]) ? 1.0f : 0.0f;").map (·.body) with
      | some [_, _, _, _, .ite (.conv .bool (.load (.scalar .i32) _)) [.store _ _ (.cond (.un .isnan .f32 _) _ _)] []] => true
      | _ => false) = true := by
  decide +kernel

/-- A template kernel: template arguments bind its parameters, `constexpr`
values and array extents fold (threadgroup and thread arrays numbered in
order, `= {0}` zero-filled, 2-D arrays flattened), constant conditions
keep only the live branch. -/
def templated : List Char :=
  chars!"template <int K, typename T>\n[[kernel]] void k(device float* a [[buffer(0)]], device T* b [[buffer(1)]]) {\n  constexpr int N = 2 * K;\n  threadgroup float s[N];\n  thread float t[K][2];\n  float r[4] = {0};\n  if (K == 3) s[0] = r[1]; else s[1] = r[2];\n  a[0] = s[0] + t[1][1];\n  b[0] = T(a[1]);\n}\ntemplate [[host_name(\"k\")]] [[kernel]] decltype(k<3, bfloat16_t>) k<3, bfloat16_t>;\n"

theorem template_kernel :
    (match (frontend templated).bind elaborate with
      | some k =>
        k.buffers == 2 && k.threadgroupArrays == [(.scalar .f32, 6)] &&
          k.threadArrays == [(.scalar .f32, 6), (.scalar .f32, 4)] &&
          !k.body.any (fun | .ite .. => true | _ => false) &&
          (match stored (some k) with
            | [z0, _, _, _, .load _ _, .bin .add .f32 0 _ _, .conv .bf16 _] => word z0 == some (.f32, 0)
            | _ => false)
      | none => false) = true := by
  decide +kernel

/-- Header functions inline at each call (template arguments explicit);
each inlined contraction gets its own site. -/
def inlined : List Char :=
  chars!"template <int B> inline float f(float x, float y) { return x * B + y; }\n[[kernel]] void k(device float* a [[buffer(0)]]) {\n  a[0] = f<4>(a[1], a[2]) + f<4>(a[3], a[4]);\n}\n"

theorem inlining :
    (match (frontend inlined).bind elaborate with
      | some k => siteS 1000 k.body == [1, 2] &&
        (match k.body with
          | [_, _, _, .scope _, _, _, .scope _, .store _ _ (.bin .add .f32 0 (.local _) (.local _))] => true
          | _ => false)
      | none => false) = true := by
  decide +kernel

/-- A kernel-level `return` leaves the scope the kernel body is then wrapped in.
Outside the modeled subset: an assignment inside an expression, a float → integer
conversion. -/
theorem rejected :
    (match (coreOf chars!"if (i == 0) return; a[0] = 1.0f;").map (·.body) with
      | some [_, _, _, _, .scope [.ite _ [.leave] [], .store _ _ _]] => true
      | _ => false) = true ∧
    (coreOf chars!"a[0] = (a[1] = 2.0f);").isNone = true ∧
    (coreOf chars!"n[0] = int(a[0]);").isNone = true := by
  decide +kernel

/-- The prefill kernels' constructs: SIMD-group matrices (a matrix declared without initializer is a
thread object; the multiply-accumulate is the `.mma` collective on `[a, b, c]`), an under-aligned
vector store made component by component, `if constexpr` (only the live branch elaborates; a plain
`if` elaborates both), arrays of pointers, pointer minus integer, the comma operator in a `for`
step, and `half` narrowing the optimizer might apply rejected. -/
theorem prefill_rules :
    (match (coreOf chars!"metal::simdgroup_float8x8 x = metal::make_filled_simdgroup_matrix<float, 8, 8>(a[0]); metal::simdgroup_half8x8 y; y.thread_elements()[0] = h[0]; y.thread_elements()[1] = h[1]; metal::simdgroup_multiply_accumulate(x, y, x, x); a[1] = x.thread_elements()[i & 1u];").map (·.body) with
      | some body =>
        body.any (fun | .collective _ _ (.mma .f16 .f32) .f32 (.vector .f32 [_, _, _]) _ => true | _ => false) &&
          body.any (fun | .array _ false 0 (.vec .f16 2) => true | _ => false)
      | none => false) = true ∧
    (match (coreOf chars!"threadgroup bfloat16_t s[8]; *((threadgroup metal::vec<bfloat16_t, 4>*)(&s[4])) = metal::vec<bfloat16_t, 4>(b[0]);").map (·.body) with
      | some body => (body.filter fun | .store (.scalar .bf16) _ _ => true | _ => false).length == 4
      | none => false) = true ∧
    (coreOf chars!"if constexpr (1 > 0) a[0] = 1.0f; else b[0] = a[0];").isSome = true ∧
    (coreOf chars!"if (1 > 0) a[0] = 1.0f; else b[0] = a[0];").isNone = true ∧
    (coreOf chars!"const device float* ps[2]; ps[0] = a + 8 - i; for (uint j = 0; j < 2u; j++, n[0] += 1) a[j] = ps[0][j];").isSome = true ∧
    (coreOf chars!"((device half*)h)[0] = half(float(h[1]) * float(h[2]));").isNone = true ∧
    (coreOf chars!"((device half*)h)[0] = half(a[1] * a[2]);").isSome = true := by
  decide +kernel

end Metal.Elab.Tests
