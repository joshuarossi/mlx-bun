import metal.Elab
import metal.Frontend
import metal.Assemble
import host.mlx.PrefillKernelSources
import metal.kernels.AffineRows3

namespace Metal.Kernels.AffineRows4
open Metal Metal.Core

/-! # affine4-rows.ts: `mlx_bun_affine4_rows`

No header. The body:

```
const uint lane = thread_index_in_simdgroup;
const uint sg = simdgroup_index_in_threadgroup;
const uint n0 = (threadgroup_position_in_grid.y * (uint)SGS + sg) * (uint)NR;
if (n0 >= (uint)N) return;
const ulong rowBytes = (ulong)K / 2u;
const uint groups = (uint)K / 64u;
const device uint8_t* wb = (const device uint8_t*)w;
float acc[NR][M];
#pragma clang loop unroll(full)
for (uint r = 0; r < (uint)NR; ++r)
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) acc[r][m] = 0.0f;
for (uint k0 = lane * (uint)VPT; k0 < (uint)K; k0 += 32u * (uint)VPT) {
  float xr[M][VPT];
  float xs[M];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const device metal::vec<T, 4>* xp = (const device metal::vec<T, 4>*)(x + (ulong)m * (ulong)K + k0);
    float sum = 0.0f;
    #pragma clang loop unroll(full)
    for (uint v = 0; v < (uint)VPT / 4u; ++v) {
      const float4 f = float4(xp[v]);
      xr[m][4 * v] = f.x; xr[m][4 * v + 1] = f.y; xr[m][4 * v + 2] = f.z; xr[m][4 * v + 3] = f.w;
      sum += (f.x + f.y) + (f.z + f.w);
    }
    xs[m] = sum;
  }
  const uint g = k0 / 64u;
  #pragma clang loop unroll(full)
  for (uint r = 0; r < (uint)NR; ++r) {
    const uint n = n0 + r;
    const device uint8_t* p = wb + (ulong)n * rowBytes + (ulong)k0 / 2u;
    float q[VPT];
    #pragma clang loop unroll(full)
    for (uint c = 0; c < (uint)VPT / 8u; ++c) {
      const uint packed = ((const device uint32_t*)p)[c];
      #pragma clang loop unroll(full)
      for (uint j = 0; j < 8u; ++j)
        q[8 * c + j] = as_type<float>(0x4b000000u | ((packed >> (4u * j)) & 15u)) - 8388608.0f;
    }
    const float s = float(scales[(ulong)n * groups + g]);
    const float b = float(biases[(ulong)n * groups + g]);
    #pragma clang loop unroll(full)
    for (uint m = 0; m < (uint)M; ++m) {
      float dot = 0.0f;
      #pragma clang loop unroll(full)
      for (uint j = 0; j < (uint)VPT; ++j) dot = metal::fma(q[j], xr[m][j], dot);
      acc[r][m] = metal::fma(s, dot, metal::fma(b, xs[m], acc[r][m]));
    }
  }
}
#pragma clang loop unroll(full)
for (uint r = 0; r < (uint)NR; ++r)
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const float v = metal::simd_sum(acc[r][m]);
    if (lane == 0u) y[(ulong)m * (ulong)N + n0 + r] = T(v);
  }
```
Launch (affine4-rows.ts:87-97): inputs `x` bfloat16 `[M, K]`, `w` uint32 `[N, K/8]`, `scales` and
`biases` bfloat16 `[N, K/64]`, output `y` bfloat16 `[M, N]`; grid `[64, ⌈N/8⌉, 1]`, threadgroup
`[64, 1, 1]`; `T` = bfloat16, template ints M, N, K, NR = 4, SGS = 2, VPT = 16 (:14). The route's
instances are the 4-bit projections of the verify-width forward (2 or 3 rows, `#rows`,
qwen38-27b-trellis-m1max.ts `Affine4`): M ∈ {2, 3} at in_proj_qkv (K 5120, N 10240), in_proj_z
(K 5120, N 6144), in_proj_a and in_proj_b (K 5120, N 48), out_proj (K 6144, N 5120), and the attention
q_proj (K 5120, N 12288), k_proj and v_proj (K 5120, N 1024) and o_proj (K 6144, N 5120). The core is
`core M N K` (NR, SGS, VPT the kernel's constants); the elaborator folds rowBytes = K/2, groups = K/64,
the bounds N and K and the strides M (of `acc`) and 16 (of `xr`). -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u64l (n : Nat) : CExpr := .lit (.int .u64 n)
def u16l (n : Nat) : CExpr := .lit (.int .u16 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))

def u32 (op : Core.BinOp) (a b : CExpr) : CExpr := .bin op .u32 0 a b
def u64 (op : Core.BinOp) (a b : CExpr) : CExpr := .bin op .u64 0 a b
def toU64 (e : CExpr) : CExpr := .conv .u64 e
def fadd (a b : CExpr) : CExpr := .bin .add .f32 0 a b

/-- `i = 0; i < n; ++i` over slot `i`. -/
def forU (i n : Nat) (body : List CStmt) : List CStmt :=
  [.set i (u32l 0), .loop (u32 .lt (.local i) (u32l n)) [.set i (u32 .add (.local i) (u32l 1))] body]

/-- Element `[u][i]` of the 2-D thread array in slot `a` with rows of `stride`. -/
def at2 (a : Nat) (u : CExpr) (stride : Nat) (i : CExpr) : CExpr :=
  .offset (.offset (.local a) (u64 .mul (toU64 u) (u64l stride))) i

/-- Component `i` of the vector in slot `k`. -/
def comp (k i : Nat) : CExpr := .component (.local k) (u32l i)

/-! ## The K step -/

/-- `xr[m][4·v + k] = f.k` (no `+ 0` for the first). -/
def xrStore (k : Nat) : CStmt :=
  .store (.scalar .f32)
    (at2 15 (.local 17) 16 (if k = 0 then u32 .mul (u32l 4) (.local 20) else u32 .add (u32 .mul (u32l 4) (.local 20)) (u32l k)))
    (comp 21 k)

/-- One 4-value chunk `v` (slot 20) of row `m`: `f`, its values into `xr`, `sum += (f.x + f.y) + (f.z + f.w)`. -/
def chunkBody : List CStmt :=
  [.set 21 (.conv .f32 (.load (.vec .bf16 4) (.offset (.local 18) (.local 20)))),
   xrStore 0, xrStore 1, xrStore 2, xrStore 3,
   .set 19 (fadd (.local 19) (fadd (fadd (comp 21 0) (comp 21 1)) (fadd (comp 21 2) (comp 21 3))))]

/-- Row `m` (slot 17) of `x`: `xp`, `sum`, the chunks, `xs[m] = sum`. -/
def xRow (K : Nat) : List CStmt :=
  [.set 18 (.ptrCast (.vec .bf16 4) (.offset (.offset (.local 0) (u64 .mul (toU64 (.local 17)) (u64l K))) (.local 14))),
   .set 19 (f32l 0x0)] ++
  forU 20 4 chunkBody ++
  [.store (.scalar .f32) (.offset (.local 16) (.local 17)) (.local 19)]

/-- `packed`: word `c` of the row's codes. -/
def packed : CExpr := .load (.scalar .u32) (.offset (.ptrCast (.scalar .u32) (.local 25)) (.local 27))

/-- `q[8c + j]`: the 4-bit field `j` of `packed` in the mantissa of 2^23, minus 2^23. -/
def field : CExpr :=
  .bin .sub .f32 0
    (.bitcast .f32 (u32 .bitOr (u32l 0x4B000000) (u32 .bitAnd (u32 .shr (.local 28) (u32 .mul (u32l 4) (.local 29))) (u32l 15))))
    (f32l 0x4B000000)

/-- `acc[r][m]` for `r` in slot `r`. -/
def accAt (M r : Nat) : CExpr := at2 11 (.local r) M (.local 32)

/-- Output row `r` (slot 23) of the K step: `n`, `p`, `q`, `s`, `b`, then for each `m` the dot product and
`acc[r][m] = fma(s, dot, fma(b, xs[m], acc[r][m]))`. -/
def outRow (M : Nat) : List CStmt :=
  [.set 24 (u32 .add (.local 7) (.local 23)),
   .set 25 (.offset (.offset (.local 10) (u64 .mul (toU64 (.local 24)) (.local 8)))
     (u64 .div (toU64 (.local 14)) (u64l 2))),
   .array 26 false 3 (.scalar .f32)] ++
  forU 27 2 ([.set 28 packed] ++
    forU 29 8 [.store (.scalar .f32) (.offset (.local 26) (u32 .add (u32 .mul (u32l 8) (.local 27)) (.local 29))) field]) ++
  [.set 30 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 2)
     (u64 .add (u64 .mul (toU64 (.local 24)) (toU64 (.local 9))) (toU64 (.local 22)))))),
   .set 31 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 3)
     (u64 .add (u64 .mul (toU64 (.local 24)) (toU64 (.local 9))) (toU64 (.local 22))))))] ++
  forU 32 M
    ([.set 33 (f32l 0x0)] ++
     forU 34 16 [.set 33 (.fma (.load (.scalar .f32) (.offset (.local 26) (.local 34)))
       (.load (.scalar .f32) (at2 15 (.local 32) 16 (.local 34))) (.local 33))] ++
     [.store (.scalar .f32) (accAt M 23)
       (.fma (.local 30) (.local 33) (.fma (.local 31) (.load (.scalar .f32) (.offset (.local 16) (.local 32)))
         (.load (.scalar .f32) (accAt M 23))))])

/-- One K step `k0` (slot 14): `xr`, `xs`, the rows of `x`, `g`, the output rows. -/
def kStep (M K : Nat) : List CStmt :=
  [.array 15 false 1 (.scalar .f32), .array 16 false 2 (.scalar .f32)] ++
  forU 17 M (xRow K) ++
  [.set 22 (u32 .div (.local 14) (u32l 64))] ++
  forU 23 4 (outRow M)

/-- Output `(r, m)` (slots 35, 36): `simd_sum` into slot 37, `v`, lane 0 stores `y[m·N + n0 + r]`. -/
def outBody (M N : Nat) : List CStmt :=
  [.collective 1 37 .sum .f32 (.load (.scalar .f32) (at2 11 (.local 35) M (.local 36))) (u16l 0),
   .set 38 (.local 37),
   .ite (u32 .eq (.local 5) (u32l 0))
     [.store (.scalar .bf16)
       (.offset (.local 4) (u64 .add (u64 .add (u64 .mul (toU64 (.local 36)) (u64l N)) (toU64 (.local 7))) (toU64 (.local 35))))
       (.conv .bf16 (.local 38))] []]

/-- Slots: 0 x, 1 w, 2 scales, 3 biases, 4 y, 5 lane, 6 sg, 7 n0, 8 rowBytes, 9 groups, 10 wb, 11 acc (thread
array 0), 12 r, 13 m, 14 k0, 15 xr (thread array 1), 16 xs (thread array 2), 17 m, 18 xp, 19 sum, 20 v, 21 f,
22 g, 23 r, 24 n, 25 p, 26 q (thread array 3), 27 c, 28 packed, 29 j, 30 s, 31 b, 32 m, 33 dot, 34 j, 35 r,
36 m, 37 the `simd_sum` result, 38 v. The body after the parameters is a scope (the kernel's `return`). -/
def body (M N K : Nat) : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .u32⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .bf16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .bf16⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .bf16⟩)),
   .scope
     ([.set 5 (.coord .threadIndexInSimdgroup),
       .set 6 (.coord .simdgroupIndexInThreadgroup),
       .set 7 (u32 .mul (u32 .add (u32 .mul (.component (.coord .threadgroupPositionInGrid) (u32l 1)) (u32l 2)) (.local 6))
         (u32l 4)),
       .ite (u32 .ge (.local 7) (u32l N)) [.leave] [],
       .set 8 (u64l (K / 2)),
       .set 9 (u32l (K / 64)),
       .set 10 (.ptrCast (.scalar .u8) (.local 1)),
       .array 11 false 0 (.scalar .f32)] ++
      forU 12 4 (forU 13 M [.store (.scalar .f32) (at2 11 (.local 12) M (.local 13)) (f32l 0x0)]) ++
      [.set 14 (u32 .mul (.local 5) (u32l 16)),
       .loop (u32 .lt (.local 14) (u32l K)) [.set 14 (u32 .add (.local 14) (u32l 512))] (kStep M K)] ++
      forU 35 4 (forU 36 M (outBody M N)))]

/-- Thread arrays `acc[4][M]`, `xr[M][16]`, `xs[M]`, `q[16]`. -/
def core (M N K : Nat) : Kernel :=
  ⟨5, [], [(.scalar .f32, 4 * M), (.scalar .f32, 16 * M), (.scalar .f32, M), (.scalar .f32, 16)], body M N K⟩

section Texts
open Host.Mlx
/-! ## The texts MLX compiles -/

def inputs (M N K : Nat) : List Assemble.Input :=
  [⟨chars!"x", .bfloat16, [M, K]⟩, ⟨chars!"w", .uint32, [N, K / 8]⟩, ⟨chars!"scales", .bfloat16, [N, K / 64]⟩,
    ⟨chars!"biases", .bfloat16, [N, K / 64]⟩]

def args (M N K : Nat) : List Assemble.TemplateArg :=
  [.dtype chars!"T" .bfloat16, .int chars!"M" M, .int chars!"N" N, .int chars!"K" K, .int chars!"NR" 4,
    .int chars!"SGS" 2, .int chars!"VPT" 16]

def assembled (M N K : Nat) : Option (List Char) :=
  Assemble.assemble (PrefillSources.name .affine4Rows) (inputs M N K) [chars!"y"] [.bfloat16]
    (PrefillSources.source .affine4Rows) (PrefillSources.header .affine4Rows) (args M N K) false

def text (M N K : Nat) : List Char := (assembled M N K).getD []

/-- Every route instance assembles. -/
theorem assembled_route :
    (assembled 2 10240 5120).isSome ∧ (assembled 2 6144 5120).isSome ∧ (assembled 2 48 5120).isSome ∧
    (assembled 2 5120 6144).isSome ∧ (assembled 2 12288 5120).isSome ∧ (assembled 2 1024 5120).isSome ∧
    (assembled 3 10240 5120).isSome ∧ (assembled 3 6144 5120).isSome ∧ (assembled 3 48 5120).isSome ∧
    (assembled 3 5120 6144).isSome ∧ (assembled 3 12288 5120).isSome ∧ (assembled 3 1024 5120).isSome := by
  decide +kernel

kernel_rfl compile_2_10240_5120 : (frontend (text 2 10240 5120)).bind elaborate = some (core 2 10240 5120)
kernel_rfl compile_2_6144_5120 : (frontend (text 2 6144 5120)).bind elaborate = some (core 2 6144 5120)
kernel_rfl compile_2_48_5120 : (frontend (text 2 48 5120)).bind elaborate = some (core 2 48 5120)
kernel_rfl compile_2_5120_6144 : (frontend (text 2 5120 6144)).bind elaborate = some (core 2 5120 6144)
kernel_rfl compile_2_12288_5120 : (frontend (text 2 12288 5120)).bind elaborate = some (core 2 12288 5120)
kernel_rfl compile_2_1024_5120 : (frontend (text 2 1024 5120)).bind elaborate = some (core 2 1024 5120)
kernel_rfl compile_3_10240_5120 : (frontend (text 3 10240 5120)).bind elaborate = some (core 3 10240 5120)
kernel_rfl compile_3_6144_5120 : (frontend (text 3 6144 5120)).bind elaborate = some (core 3 6144 5120)
kernel_rfl compile_3_48_5120 : (frontend (text 3 48 5120)).bind elaborate = some (core 3 48 5120)
kernel_rfl compile_3_5120_6144 : (frontend (text 3 5120 6144)).bind elaborate = some (core 3 5120 6144)
kernel_rfl compile_3_12288_5120 : (frontend (text 3 12288 5120)).bind elaborate = some (core 3 12288 5120)
kernel_rfl compile_3_1024_5120 : (frontend (text 3 1024 5120)).bind elaborate = some (core 3 1024 5120)

end Texts
end Metal.Kernels.AffineRows4

/-! # The proof

The common core and its proof are in AffineRows3.lean (`AffineRows.gpu_output_of`); here the 4-bit weight decode. -/

namespace Metal.Kernels.AffineRows
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineRows3 (u32l u64l toU64)

/-! ## BITS = 4 -/

section Bits4
variable (C : M1Max.Contract)

/-- `((const device uint32_t*)p)[c]` for `p` the lane's weight bytes: the word at byte `o`, little-endian. -/
def word32 (W : ByteMemory.Bytes) (o : Nat) : Nat := bytesWord ((List.range 4).map fun j => W (o + j))

/-- `q[8c + j] = as_type<float>(0x4b000000u | ((packed >> (4j)) & 15u)) - 8388608.0f`, `packed` word `c`. -/
def q4 (W : ByteMemory.Bytes) (o e : Nat) : Float32 := deq C ((word32 W (o + 4 * (e / 8)) >>> (4 * (e % 8))) &&& 15)

def pOff4 : CExpr := AffineRows3.u64 .div (toU64 (.local 14)) (u64l 2)

/-- affine4-rows.ts: rows of `K/2` bytes, the lane's 16 weights in the two words at `k0/2`, read as `uint`. -/
def v4 : Variant := ⟨fun K => K / 2, fun k0 => k0 / 2, 8, 4, pOff4, qfillG AffineRows4.packed 4 15, q4 C⟩

theorem word32_lt (W : ByteMemory.Bytes) (o : Nat) : word32 W o < 2 ^ 32 := by
  unfold word32
  have h0 : (W (o + 0)).toNat < 256 := (W _).isLt
  have h1 : (W (o + 1)).toNat < 256 := (W _).isLt
  have h2 : (W (o + 2)).toNat < 256 := (W _).isLt
  have h3 : (W (o + 3)).toNat < 256 := (W _).isLt
  simp only [bytesWord, List.range_succ, List.range_zero, List.nil_append, List.cons_append, List.map_cons, List.map_nil,
    List.foldr_cons, List.foldr_nil]
  omega

variable {C}

theorem packed4_spec : ∀ (ctx : Ctx) (l : Locals) (sh : Shared) (o wsize aw c : Nat),
    sh.regions 1 = some ⟨.device, wsize, aw⟩ → aw % 4 = 0 → o % 4 = 0 → o + 8 ≤ wsize → c < 2 →
    l 25 = some (.ptr ⟨1, ((o : Nat) : Int), .scalar .u8⟩) → l 27 = some (u32 c) →
    ∃ sh', (eval C ctx l AffineRows4.packed).run sh = some (u32 (word32 (sh.bytes 1) (o + 4 * c)), sh') ∧
      Footprint ctx (isR 1) noT sh sh' := by
  intro ctx l sh o wsize aw c hr1 haw ho hb hc h25 h27
  have hp := eval_offset_u32 C (eval_ptrCast C (t := .scalar .u32) (eval_local' C (ctx := ctx) h25 sh)) (eval_local' C h27 sh)
    (by omega)
  rw [show o + c * (Ty.scalar .u32).bytes = o + 4 * c by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hld := load_u32 ctx sh 1 wsize aw (o + 4 * c) hr1 haw (by omega) (by omega)
  exact ⟨_, (eval_load C _ _ _ _ _ _ _ hp).trans hld, Footprint.rdn noT sh _ 4 (show isR 1 1 from rfl)⟩

variable (C)

theorem p4_spec : PSpec C (v4 C) := by
  intro ctx l sh k0 h14 hk0
  show (eval C ctx l pOff4).run sh = some (u64 (k0 / 2), sh)
  exact eval_u64bin C (eval_toU64 C (eval_local' C h14 sh) (by omega)) (eval_u64l C (by norm_num) sh)
    (binary_div_u64 C (by omega) (by norm_num) (by norm_num))

theorem q4_spec : QSpec C (v4 C) :=
  qspec_of (C := C) (rb := fun K => K / 2) (off := fun k0 => k0 / 2) (span := 8) (wA := 4)
    (pOff := pOff4) (packedE := AffineRows4.packed) (w := 4) (mask := 15) (by norm_num) (by norm_num)
    (fun W o c => word32 W (o + 4 * c)) (fun W o c => word32_lt W _) packed4_spec

theorem v4_ok : (v4 C).Ok where
  bound K k0 hK hk h := by show k0 / 2 + 8 ≤ K / 2; omega
  align K k0 n hK hk := by
    show (n * (K / 2) + k0 / 2) % 4 = 0
    have : 4 ∣ n * (K / 2) := Dvd.dvd.mul_left (show 4 ∣ K / 2 by omega) n
    omega
  rb K hK := by show K / 2 < 2 ^ 31; omega

end Bits4

end Metal.Kernels.AffineRows

namespace Metal.Kernels.AffineRows4
open Metal Metal.Core Inference.Contracts.Mlx

theorem core_eq (C : M1Max.Contract) (M N K : Nat) : core M N K = AffineRows.coreG (AffineRows.v4 C) M N K := rfl

/-- Byte `b` of `y` [M, N] bf16: element `(b / 2) / N, (b / 2) % N` is `AffineRows.yv`, through `acc` over the K/512
steps with the weights `q4` (`word32`, `deq`), `xf`, `xsum` and `dot`. -/
def expected (C : M1Max.Contract) (M N K : Nat) (X W S B : ByteMemory.Bytes) : Nat → BitVec 8 :=
  AffineRows.expected C (AffineRows.v4 C) M N K X W S B

/-- **The GPU runs `mlx_bun_affine4_rows` as specified**, for any M rows, N a multiple of 8 and K of 512 (each below
2^31), for any text that elaborates to `core M N K`. `x` must be 8-aligned (`vec<bfloat, 4>` loads) and `w` 4-aligned
(the codes are read as `uint32_t`). -/
theorem gpu_output_of (C : M1Max.Contract) (G : Gpu C) {M N K : Nat} (hD : AffineRows.Dims M N K) (text : List Char)
    (hc : (frontend text).bind elaborate = some (core M N K)) (hmax : 64 ≤ G.maxThreads text)
    (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat) (hax : 8 ∣ ax) (haw : 4 ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute text (64, N / 8, 1) (64, 1, 1)
      [⟨.device, 2 * (M * K), ax, X⟩, ⟨.device, 4 * (N * (K / 8)), aw, W⟩, ⟨.device, 2 * (N * (K / 64)), as, S⟩,
       ⟨.device, 2 * (N * (K / 64)), ab, B⟩] [2 * (M * N)] =
      some [expected C M N K X W S B] := by
  have hw : 4 * (N * (K / 8)) = N * (K / 2) := by
    have := hD.k512; rw [show K / 2 = 4 * (K / 8) by omega]; ring
  rw [hw]
  rw [core_eq C] at hc
  exact AffineRows.gpu_output_of C (AffineRows.v4 C) (AffineRows.p4_spec C) (AffineRows.q4_spec C) (AffineRows.v4_ok C) hD G
    text hc hmax X W S B ax aw as ab hax haw has hab

/-! ## The route's instances -/

section Route
variable (C : M1Max.Contract) (G : Gpu C) (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat)

/-- in_proj_qkv: K 5120, N 10240, 2 rows. -/
theorem gpu_output_2_10240_5120 (hmax : 64 ≤ G.maxThreads (text 2 10240 5120)) (hax : 8 ∣ ax) (haw : 4 ∣ aw)
    (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 2 10240 5120) (64, 1280, 1) (64, 1, 1)
      [⟨.device, 20480, ax, X⟩, ⟨.device, 26214400, aw, W⟩, ⟨.device, 1638400, as, S⟩, ⟨.device, 1638400, ab, B⟩] [40960] =
      some [expected C 2 10240 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_2_10240_5120 hmax X W S B ax aw as ab hax haw has hab

/-- in_proj_z: K 5120, N 6144, 2 rows. -/
theorem gpu_output_2_6144_5120 (hmax : 64 ≤ G.maxThreads (text 2 6144 5120)) (hax : 8 ∣ ax) (haw : 4 ∣ aw)
    (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 2 6144 5120) (64, 768, 1) (64, 1, 1)
      [⟨.device, 20480, ax, X⟩, ⟨.device, 15728640, aw, W⟩, ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩] [24576] =
      some [expected C 2 6144 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_2_6144_5120 hmax X W S B ax aw as ab hax haw has hab

/-- in_proj_a and in_proj_b: K 5120, N 48, 2 rows. -/
theorem gpu_output_2_48_5120 (hmax : 64 ≤ G.maxThreads (text 2 48 5120)) (hax : 8 ∣ ax) (haw : 4 ∣ aw)
    (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 2 48 5120) (64, 6, 1) (64, 1, 1)
      [⟨.device, 20480, ax, X⟩, ⟨.device, 122880, aw, W⟩, ⟨.device, 7680, as, S⟩, ⟨.device, 7680, ab, B⟩] [192] =
      some [expected C 2 48 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_2_48_5120 hmax X W S B ax aw as ab hax haw has hab

/-- out_proj and o_proj: K 6144, N 5120, 2 rows. -/
theorem gpu_output_2_5120_6144 (hmax : 64 ≤ G.maxThreads (text 2 5120 6144)) (hax : 8 ∣ ax) (haw : 4 ∣ aw)
    (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 2 5120 6144) (64, 640, 1) (64, 1, 1)
      [⟨.device, 24576, ax, X⟩, ⟨.device, 15728640, aw, W⟩, ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩] [20480] =
      some [expected C 2 5120 6144 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_2_5120_6144 hmax X W S B ax aw as ab hax haw has hab

/-- q_proj: K 5120, N 12288, 2 rows. -/
theorem gpu_output_2_12288_5120 (hmax : 64 ≤ G.maxThreads (text 2 12288 5120)) (hax : 8 ∣ ax) (haw : 4 ∣ aw)
    (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 2 12288 5120) (64, 1536, 1) (64, 1, 1)
      [⟨.device, 20480, ax, X⟩, ⟨.device, 31457280, aw, W⟩, ⟨.device, 1966080, as, S⟩, ⟨.device, 1966080, ab, B⟩] [49152] =
      some [expected C 2 12288 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_2_12288_5120 hmax X W S B ax aw as ab hax haw has hab

/-- k_proj and v_proj: K 5120, N 1024, 2 rows. -/
theorem gpu_output_2_1024_5120 (hmax : 64 ≤ G.maxThreads (text 2 1024 5120)) (hax : 8 ∣ ax) (haw : 4 ∣ aw)
    (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 2 1024 5120) (64, 128, 1) (64, 1, 1)
      [⟨.device, 20480, ax, X⟩, ⟨.device, 2621440, aw, W⟩, ⟨.device, 163840, as, S⟩, ⟨.device, 163840, ab, B⟩] [4096] =
      some [expected C 2 1024 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_2_1024_5120 hmax X W S B ax aw as ab hax haw has hab

/-- in_proj_qkv: K 5120, N 10240, 3 rows. -/
theorem gpu_output_3_10240_5120 (hmax : 64 ≤ G.maxThreads (text 3 10240 5120)) (hax : 8 ∣ ax) (haw : 4 ∣ aw)
    (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 3 10240 5120) (64, 1280, 1) (64, 1, 1)
      [⟨.device, 30720, ax, X⟩, ⟨.device, 26214400, aw, W⟩, ⟨.device, 1638400, as, S⟩, ⟨.device, 1638400, ab, B⟩] [61440] =
      some [expected C 3 10240 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_3_10240_5120 hmax X W S B ax aw as ab hax haw has hab

/-- in_proj_z: K 5120, N 6144, 3 rows. -/
theorem gpu_output_3_6144_5120 (hmax : 64 ≤ G.maxThreads (text 3 6144 5120)) (hax : 8 ∣ ax) (haw : 4 ∣ aw)
    (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 3 6144 5120) (64, 768, 1) (64, 1, 1)
      [⟨.device, 30720, ax, X⟩, ⟨.device, 15728640, aw, W⟩, ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩] [36864] =
      some [expected C 3 6144 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_3_6144_5120 hmax X W S B ax aw as ab hax haw has hab

/-- in_proj_a and in_proj_b: K 5120, N 48, 3 rows. -/
theorem gpu_output_3_48_5120 (hmax : 64 ≤ G.maxThreads (text 3 48 5120)) (hax : 8 ∣ ax) (haw : 4 ∣ aw)
    (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 3 48 5120) (64, 6, 1) (64, 1, 1)
      [⟨.device, 30720, ax, X⟩, ⟨.device, 122880, aw, W⟩, ⟨.device, 7680, as, S⟩, ⟨.device, 7680, ab, B⟩] [288] =
      some [expected C 3 48 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_3_48_5120 hmax X W S B ax aw as ab hax haw has hab

/-- out_proj and o_proj: K 6144, N 5120, 3 rows. -/
theorem gpu_output_3_5120_6144 (hmax : 64 ≤ G.maxThreads (text 3 5120 6144)) (hax : 8 ∣ ax) (haw : 4 ∣ aw)
    (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 3 5120 6144) (64, 640, 1) (64, 1, 1)
      [⟨.device, 36864, ax, X⟩, ⟨.device, 15728640, aw, W⟩, ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩] [30720] =
      some [expected C 3 5120 6144 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_3_5120_6144 hmax X W S B ax aw as ab hax haw has hab

/-- q_proj: K 5120, N 12288, 3 rows. -/
theorem gpu_output_3_12288_5120 (hmax : 64 ≤ G.maxThreads (text 3 12288 5120)) (hax : 8 ∣ ax) (haw : 4 ∣ aw)
    (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 3 12288 5120) (64, 1536, 1) (64, 1, 1)
      [⟨.device, 30720, ax, X⟩, ⟨.device, 31457280, aw, W⟩, ⟨.device, 1966080, as, S⟩, ⟨.device, 1966080, ab, B⟩] [73728] =
      some [expected C 3 12288 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_3_12288_5120 hmax X W S B ax aw as ab hax haw has hab

/-- k_proj and v_proj: K 5120, N 1024, 3 rows. -/
theorem gpu_output_3_1024_5120 (hmax : 64 ≤ G.maxThreads (text 3 1024 5120)) (hax : 8 ∣ ax) (haw : 4 ∣ aw)
    (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 3 1024 5120) (64, 128, 1) (64, 1, 1)
      [⟨.device, 30720, ax, X⟩, ⟨.device, 2621440, aw, W⟩, ⟨.device, 163840, as, S⟩, ⟨.device, 163840, ab, B⟩] [6144] =
      some [expected C 3 1024 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_3_1024_5120 hmax X W S B ax aw as ab hax haw has hab

end Route

end Metal.Kernels.AffineRows4

