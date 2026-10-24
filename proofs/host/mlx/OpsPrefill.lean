import host.mlx.Ops

namespace Host.Mlx
open Inference Inference.Contracts.Mlx Inference.Kernels
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

/-! # MLX v0.32.2 operations at the prompt's multi-row shapes

The prefill forwards (r ≥ 2 rows at cache offset o) call MLX's built-ins at
shapes the decode semantics (`Host.Mlx.Ops`) leaves undefined. This module
gives them values, as `Ops` does: partial functions on immutable array values,
defined for the dtypes and shapes the forwards issue.

* Where an existing definition gives MLX's behaviour at the new shape it is
  reused: row-wise and elementwise kernels (rms_norm rows, the rope rotation
  and angles, depthwise conv1d rows, 4-bit affine dequantize elements,
  compute_g elements), exact layout and selection operations (broadcast,
  `where`, `less_equal`, `arange`), and the native float conversions of
  `astype` (the conversions the proved kernels' stores use).
* Where MLX's internal choices fix the bits (GEMM tiling, reductions, the
  attention dispatch, fused compiled closures), `MlxPrefillContract` names
  MLX's operation as a function on values: a field gives the result's
  elements in the output shape and dtype MLX documents (`ops.cpp`), which the
  wrappers here fix. These are assumptions about MLX, not models to prove.

`MlxPrefillContract` extends `MlxContract`: the decode statements keep their
hypothesis `M : MlxContract C` unchanged, and a prefill statement over
`P : MlxPrefillContract C` uses them at `P.toMlxContract`.
Sources: ml-explore/mlx@1f8e74e3 (v0.32.2), pinned in proofs/check.ts. -/

/-- MLX at the prefill's shapes, over the decode contract. -/
structure MlxPrefillContract (C : M1Max.Contract) extends MlxContract C where
  -- rope.cpp:94-123: T > 1 rows select `rope_<dtype>` (rope.metal rope_impl),
  -- whose rotation is rope_single_impl's expression; the Metal compiler's
  -- multiply-add contraction in that kernel is its own choice (no claim).
  ropeRowsFirst : Attention.Rope.Contraction
  ropeRowsSecond : Attention.Rope.Contraction
  -- mlx_fast_scaled_dot_product_attention(q, k, v, 1/16, "causal") on bf16
  -- q [1,24,r,256], k and v [1,4,n,256], 2 ≤ r ≤ n: element i of the bf16
  -- [1,24,r,256] result (query t sees keys j ≤ n - r + t). The dispatch
  -- (scaled_dot_product_attention.cpp:633-767) is MLX's: r ≤ 5 the causal
  -- vector kernels; r ≥ 6 its unfused fallback (r·6 > 32 queries per KV head,
  -- or head dim 256 above 8 queries without NAX on applegpu_g13s).
  sdpaCausal : Value → Value → Value → Nat → BF
  -- mlx_matmul on bf16 operands (ops.cpp:3464; steel GEMM): element i of the
  -- bf16 result in the shape `matmulOut`.
  matmul : Value → Value → Nat → BF
  -- mlx_softmax_axis(a, last axis, precise = true) on bf16 (the Softmax
  -- primitive, ops.cpp:4077): element i of the bf16 result of a's shape.
  softmaxPrecise : Value → Nat → BF
  -- mlx_sum_axis(a, axis, keepdims = false) on float32 (Reduce Sum,
  -- ops.cpp:2250): element i of the float32 result, `axis` removed.
  sumAxis : Value → Nat → Nat → Float32
  -- mlx_quantized_matmul(x, w, scales, biases, transpose, g64, b4, "affine")
  -- on bf16 x [1,m,k], m ≥ 2 rows (quantized.cpp:1782-1850: qmv below the
  -- batch limit, qmm_splitk above): element i of the bf16 [1,m,rows] result.
  qmmRows : Value → Value → Value → Value → Nat → BF
  -- mlx_dequantize(w, scales, biases, g64, b3, "affine") (affine_dequantize
  -- at three bits): element i of the bf16 result, the last axis k·32/3.
  dequantize3 : Value → Value → Value → Nat → BF
  -- compiled.cpp fuses a compiled closure's elementwise chain into one JIT
  -- kernel: the per-element values of nn.silu (blocks.ts compiledSilu),
  -- swiglu (swiglu.ts compiledSwiglu) and _precise_swiglu (blocks.ts
  -- compiledPreciseSwiglu, f32 inside, bf16 out) on bf16 elements.
  silu : BF → BF
  swiglu : BF → BF → BF
  preciseSwiglu : BF → BF → BF

namespace MlxPrefillContract
variable {C : M1Max.Contract} (P : MlxPrefillContract C)

noncomputable def rowsRotation : Attention.Rope.Platform := C.rotationPlatform P.ropeRowsFirst P.ropeRowsSecond
-- normalization.cpp:57-80 (MlxRmsHostSelection.select): axis 128 ≤ 4096
-- selects rms_norm with 32·⌈⌈128/4⌉/32⌉ = 32 threads, one SIMD group.
noncomputable def narrowNorm : RmsNorm.Platform := C.rmsPlatform 1 (by decide) (by decide) P.rmsContracted

end MlxPrefillContract

/-! ## Broadcasting and exact operations -/

/-- Right-aligned broadcast of shapes (`broadcast_shapes`), reversed. -/
def bcastRevN : List Nat → List Nat → Option (List Nat)
  | [], ys => some ys
  | xs, [] => some xs
  | x :: xs, y :: ys =>
    (if x = y then some x else if x = 1 then some y else if y = 1 then some x else none).bind fun d =>
      (bcastRevN xs ys).map (d :: ·)

def bshape (a b : List Nat) : Option (List Nat) := (bcastRevN a.reverse b.reverse).map List.reverse

/-- The index of `inShape` an output index reads under broadcasting: the
trailing coordinates, 0 on a stretched axis. -/
def bindex (inShape outIdx : List Nat) : List Nat :=
  (List.zip inShape (outIdx.drop (outIdx.length - inShape.length))).map fun (n, x) => if n = 1 then 0 else x

/-- Element `i` of the output of shape `shape` that `v` broadcasts to. -/
def Value.bget (v : Value) (shape : List Nat) (i : Nat) : Nat := v.elems (flat v.shape (bindex v.shape (unflat shape i)))

/-- A signed int32 element. -/
def i32 (n : Nat) : Int := if n % 2^32 < 2^31 then (n % 2^32 : Nat) else ((n % 2^32 : Nat) : Int) - 2^32

/-- mlx_less_equal on int32 operands (ops.cpp:2004): bool [broadcast shape], 1 where a ≤ b. -/
def lessEqual (a b : Value) : Option Value :=
  if a.dtype = .int32 ∧ b.dtype = .int32 then (bshape a.shape b.shape).map fun sh =>
    { dtype := .bool, shape := sh, elems := fun i => if i32 (a.bget sh i) ≤ i32 (b.bget sh i) then 1 else 0 }
  else none

/-- mlx_where on a bool condition and operands of one dtype (ops.cpp:2074,
Select): the element of x where the condition is nonzero, else of y. -/
def select (c x y : Value) : Option Value :=
  if c.dtype = .bool ∧ x.dtype = y.dtype then ((bshape c.shape x.shape).bind fun s => bshape s y.shape).map fun sh =>
    { dtype := x.dtype, shape := sh, elems := fun i => if c.bget sh i = 0 then y.bget sh i else x.bget sh i }
  else none

/-- BF16 multiplication on equal shapes or by a right-hand scalar
(`binary_vs`, the same Multiply as `multiply`): `ops.mulScalar`. -/
def multiplyScalar (a b : Value) : Option Value :=
  if a.shape = b.shape then multiply a b
  else if a.dtype = .bfloat16 ∧ b.dtype = .bfloat16 ∧ b.shape = [] then
    some { a with elems := fun i => bfWord (BFloat16Arithmetic.mul (bf (a.elems i)) (bf (b.elems 0))) }
  else none

/-! ## Conversions (astype) -/

def f16 (n : Nat) : Model FloatFormat.binary16 := Model.ofBits (BitVec.ofNat 16 n)

/-- binary16 to bfloat16 through float (exact widening, nearest-even narrowing). -/
def halfToBf (h : Model FloatFormat.binary16) : BF :=
  Model.cast FloatFormat.binary32 FloatFormat.bfloat16 (Model.cast FloatFormat.binary16 FloatFormat.binary32 h)

/-- mlx_astype as the copy kernel's `static_cast` (the native conversions the
proved kernels' stores are modelled with): float32 → bf16, bf16 → float32,
float16 → bf16; the same dtype is the array itself. -/
def astypeV (v : Value) (d : Dtype) : Option Value :=
  if v.dtype = d then some v
  else match v.dtype, d with
  | .float32, .bfloat16 => some ⟨.bfloat16, v.shape, fun i => bfWord (BFloat16.narrow (f32 (v.elems i)))⟩
  | .bfloat16, .float32 => some ⟨.float32, v.shape, fun i => f32Word (BFloat16.widen (bf (v.elems i)))⟩
  | .float16, .bfloat16 => some ⟨.bfloat16, v.shape, fun i => bfWord (halfToBf (f16 (v.elems i)))⟩
  | _, _ => none

/-! ## Row-wise and elementwise kernels at more rows -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C)

/-- mlx_fast_rope on T ≥ 2 rows ([B, H, T, 256] bf16, dims 64, offset o ≥ 0):
row (b, h, t) is the single-row model at position o + t (rope.metal
rope_impl: `scale * float(pos.y + offset)`), under the multi-row kernel's
contraction (`rowsRotation`). -/
noncomputable def ropeRows (x : Value) (dims : Nat) (traditional : Bool) (base : Option Float32)
    (scale : Float32) (offset : Int) : Option Value :=
  match base with
  | some b =>
    let T := x.shape.getD 2 0
    if dims = 64 ∧ traditional = false ∧ x.shape.length = 4 ∧ 2 ≤ T ∧ 0 ≤ offset then
      rowwise 256 (fun ρ row => Attention.Rope.head P.rowsRotation row
        (Attention.RopeAngles.value P.angles ⟨P.log2 b, Float32.ofInt (offset + (ρ % T : Nat)), scale⟩)) x
    else none
  | none => none

/-- mlx_fast_rms_norm over a 128-wide last axis (the delta heads' q, k and
gated norm), one SIMD group (`narrowNorm`); `rmsNorm` is row-wise. -/
noncomputable def rmsNormNarrow (x weight : Value) (eps : Float32) : Option Value :=
  match weight.shape with
  | [128] => rmsNorm P.narrowNorm x weight eps
  | _ => none

/-- mlx_conv1d(in [b, l, c], w [c, 4, 1], stride 1, padding 0, dilation 1,
groups c), l ≥ 4: depthwise_conv_1d (conv.cpp:1483-1553) computes output (bb,
t, ch) from input rows t..t+3 with `Convolution.value`, as the decode's
four-row call. -/
def conv1dRows (x weight : Value) (stride padding dilation groups : Nat) : Option Value :=
  match x.shape with
  | [bsz, l, c] =>
    if x.dtype = .bfloat16 ∧ weight.dtype = .bfloat16 ∧ weight.shape = [c, 4, 1] ∧ 4 ≤ l ∧
        Delta.Convolution.depthwiseSelected c c groups stride dilation 1 padding false then
      some { dtype := .bfloat16, shape := [bsz, l - 3, c], elems := fun i =>
        bfWord (Delta.Convolution.value P.convContracted
          (fun tap => bf (x.get [i / c / (l - 3), i / c % (l - 3) + tap.val, i % c]))
          (fun tap => bf (weight.get [i % c, tap.val, 0]))) }
    else none
  | _ => none

/-- mlx_dequantize(w u32 [.., k/8], scales and biases bf16 [.., k/64], g64, b4,
"affine"): element (ρ, j) is `AffineDequantize.value` of byte ρ·k/2 + j/2's
nibble j % 2 with group ρ·k/64 + j/64 (the decode row's kernel). -/
def dequantize4 (w scales biases : Value) : Option Value :=
  match w.shape.getLast? with
  | some words =>
    let k := words * 8
    let lead := w.shape.dropLast
    if w.dtype = .uint32 ∧ scales.dtype = .bfloat16 ∧ biases.dtype = .bfloat16 ∧ 0 < k ∧
        scales.shape = lead ++ [k / 64] ∧ biases.shape = lead ++ [k / 64] then
      some { dtype := .bfloat16, shape := lead ++ [k], elems := fun i =>
        let g := i / k * (k / 64) + i % k / 64
        bfWord (Quantization.AffineDequantize.value P.dequantizeContracted (bf (scales.elems g)) (bf (biases.elems g))
          (Quantization.AffineDequantize.code (w.byte (i / k * (k / 2) + i % k / 2)) ⟨i % k % 2, Nat.mod_lt _ (by decide)⟩)) }
    else none
  | none => none

/-- compute_g on rows: a [.., 48] bf16 with A_log and dt_bias [48]; each
element is the compiled closure's element (`ComputeGHostSource`), the
per-head parameters broadcast over the rows. -/
noncomputable def computeGRows (aLog a dt : Value) : Option Value :=
  if aLog.dtype = .bfloat16 ∧ a.dtype = .bfloat16 ∧ dt.dtype = .bfloat16 ∧ aLog.shape = [48] ∧ dt.shape = [48] ∧
      a.shape.getLast? = some 48 then
    some { dtype := .float32, shape := a.shape, elems := fun i =>
      let r := Delta.ComputeGHostSource.execute P.logAddExp P.decay (bf (aLog.elems (i % 48))) (bf (a.elems i))
        (bf (dt.elems (i % 48)))
      match r with
      | some (.fp g) => f32Word g
      | _ => 0 }
  else none

/-! ## Operations the contract names -/

/-- `matmul`'s output shape (ops.cpp:3464), both operands at least 2-D: a
batched `a` against a matrix keeps `a`'s leading axes, else they broadcast. -/
def matmulOut (a b : List Nat) : Option (List Nat) :=
  if a.length < 2 ∨ b.length < 2 then none
  else if a.getD (a.length - 1) 0 ≠ b.getD (b.length - 2) 0 then none
  else if 2 < a.length ∧ b.length ≤ 2 then some (a.dropLast ++ [b.getD (b.length - 1) 0])
  else (bshape (a.take (a.length - 2)) (b.take (b.length - 2))).map fun batch =>
    batch ++ [a.getD (a.length - 2) 0, b.getD (b.length - 1) 0]

noncomputable def matmulV (a b : Value) : Option Value :=
  if a.dtype = .bfloat16 ∧ b.dtype = .bfloat16 then
    (matmulOut a.shape b.shape).map fun sh => ⟨.bfloat16, sh, fun i => bfWord (P.matmul a b i)⟩
  else none

noncomputable def softmaxV (a : Value) : Option Value :=
  if a.dtype = .bfloat16 ∧ a.shape ≠ [] then some ⟨.bfloat16, a.shape, fun i => bfWord (P.softmaxPrecise a i)⟩ else none

noncomputable def sumV (a : Value) (axis : Nat) : Option Value :=
  if a.dtype = .float32 ∧ axis < a.shape.length then
    some ⟨.float32, a.shape.eraseIdx axis, fun i => f32Word (P.sumAxis a axis i)⟩
  else none

noncomputable def sdpaCausalV (q k v : Value) (scale : Float32) : Option Value :=
  match q.shape, k.shape with
  | [1, 24, r, 256], [1, 4, n, 256] =>
    if q.dtype = .bfloat16 ∧ k.dtype = .bfloat16 ∧ v.dtype = .bfloat16 ∧ v.shape = [1, 4, n, 256] ∧
        2 ≤ r ∧ r ≤ n ∧ scale = Attention.SdpaScore.scale then
      some { q with elems := fun i => bfWord (P.sdpaCausal q k v i) }
    else none
  | _, _ => none

noncomputable def qmmRowsV (x w scales biases : Value) (transpose : Bool) (group bits : Nat) (mode : String) :
    Option Value :=
  match x.shape, w.shape with
  | [1, m, k], [rows, _] =>
    if x.dtype = .bfloat16 ∧ w.dtype = .uint32 ∧ transpose = true ∧ group = 64 ∧ bits = 4 ∧ mode = "affine" ∧
        2 ≤ m ∧ k % 512 = 0 ∧ w.shape = [rows, k / 8] ∧ scales.shape = [rows, k / 64] ∧ biases.shape = [rows, k / 64] then
      some ⟨.bfloat16, [1, m, rows], fun i => bfWord (P.qmmRows x w scales biases i)⟩
    else none
  | _, _ => none

noncomputable def dequantize3V (w scales biases : Value) : Option Value :=
  match w.shape.getLast? with
  | some words =>
    let k := words * 32 / 3
    let lead := w.shape.dropLast
    if w.dtype = .uint32 ∧ scales.dtype = .bfloat16 ∧ biases.dtype = .bfloat16 ∧ words % 3 = 0 ∧ k % 64 = 0 ∧
        scales.shape = lead ++ [k / 64] ∧ biases.shape = lead ++ [k / 64] then
      some ⟨.bfloat16, lead ++ [k], fun i => bfWord (P.dequantize3 w scales biases i)⟩
    else none
  | none => none

/-- The compiled closures the forwards apply. -/
inductive Compiled where
  | silu | swiglu | preciseSwiglu
deriving DecidableEq

/-- A compiled closure on its bf16 inputs (equal shapes), elementwise. -/
noncomputable def compiledValue : Compiled → List Value → Option Value
  | .silu, [x] => map1 P.silu x
  | .swiglu, [g, u] => map2 P.swiglu g u
  | .preciseSwiglu, [g, x] => map2 P.preciseSwiglu g x
  | _, _ => none

end

end Host.Mlx
