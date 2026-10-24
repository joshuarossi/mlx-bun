import host.mlx.GlueRoute
import layers.AffineParsedSource3
import layers.AffineParsedSource4
import layers.DeltaHeadsMemory
import kernels.delta.GatedShared
import kernels.GatedRmsNormMemory
import kernels.ResidualRmsMemory
import models.qwen.TrellisMlpParsedPipeline
import kernels.sampling.NormalizedArgmaxMemory
import kernels.normalization.GatedRms128TailSource
import kernels.delta.SiluHeads128Output
import kernels.sampling.GreedySampling
import models.qwen.TrellisMlp

namespace Host.Mlx
open Inference Inference.Contracts.Mlx Inference.Kernels Inference.Layers
open Inference.Models.Qwen WrittenLayers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

/-! # Custom Metal kernels (mlx_fast_metal_kernel_apply)

packages/mlx/src/metal-kernel.ts builds every route kernel with
mlx_fast_metal_kernel_new(name, inputs, outputs, body, header,
ensureRowContiguous = true, atomicOutputs = false) and applies it with the
call's output shapes/dtypes, grid, threadgroup and template arguments; no
route kernel sets initValue.

The MLX v0.32.2 contract (ml-explore/mlx@1f8e74e3):
- backend/metal/custom_kernel.cpp:23-30 allocates a fresh buffer per output,
  filled with init_value when set and otherwise of arbitrary contents;
- :32-45 binds each input as-is when row-contiguous and otherwise a
  row-contiguous copy, so every input buffer holds the row-major bytes of
  its value;
- backend/common/metal_kernel.cpp:52-177,340-347 writes the kernel signature
  from the names and instantiates the body at the template arguments;
- custom_kernel.cpp:83-97 rejects a threadgroup larger than the pipeline's
  maxTotalThreadsPerThreadgroup and dispatches threads(grid, min(tg, grid)).
The body then executes under the M1 Max contract and the output values are
the final buffer contents.

Each field of `KernelContract` states one route kernel's launch at value
level: on inputs encoding the model's operands (and finite where the model's
range certificates say so), the launch returns outputs encoding the model
function the route consumes. `KernelGpu.ofGpu` builds the contract from the
GPU assumption `Metal.Gpu` and proves every field from the kernel's Metal
source. -/

/-! ## Decoded views and readouts -/

-- A bf16 array of `shape` whose row-major elements decode to `f`.
def Flat (v : Value) (shape : List Nat) (f : Fin n → BF) : Prop :=
  v.dtype = .bfloat16 ∧ v.shape = shape ∧ ∀ i : Fin n, bf (v.elems i.val) = f i
def FlatF32 (v : Value) (shape : List Nat) (f : Fin n → Float32) : Prop :=
  v.dtype = .float32 ∧ v.shape = shape ∧ ∀ i : Fin n, f32 (v.elems i.val) = f i

-- Final buffer contents as values: 2-byte or 4-byte little-endian elements.
def halfArray (memory : ByteMemory.Bytes) (base : Nat) (shape : List Nat) : Value :=
  ⟨.bfloat16, shape, fun i => (HalfMemory.load memory (base+2*i)).toNat⟩
def wordArray (dtype : Dtype) (memory : ByteMemory.Bytes) (base : Nat) (shape : List Nat) : Value :=
  ⟨dtype, shape, fun i => (ByteMemory.load32 memory (base+4*i)).toNat⟩

theorem bf_toNat (b : BitVec 16) : bf b.toNat = (Model.ofBits b : BF) := by
  unfold bf; rw [BitVec.ofNat_toNat, BitVec.setWidth_eq]

theorem f32_toNat (b : BitVec 32) : f32 b.toNat = FloatMemory.decode b := by
  unfold f32; rw [BitVec.ofNat_toNat, BitVec.setWidth_eq]

theorem Flat.row (h : Flat v [1,1,n] f) : Row v n f := Row.mk h.1 h.2.1 h.2.2
theorem Row.flat (h : Row v n f) : Flat v [1,1,n] f := ⟨h.1, h.2.1, Row.elems h⟩

/-! ## Launches as issued by the route -/

inductive Kernel where
  | affineRow | siluRmsHeads | gatedDeltaStep | gatedRmsNorm | residualRmsNorm
  | gateUp | downPartial | downFold | argmaxPartial | argmaxFinish
  deriving DecidableEq

-- metal-kernel.ts MetalKernelCall: template dtypes are added before ints.
structure Config where
  outputs : List (List Nat × Dtype)
  grid : Nat × Nat × Nat
  threadGroup : Nat × Nat × Nat
  templateDtypes : List (String × Dtype)
  templateInts : List (String × Nat)
  initValue : Option Nat := none

-- affine-row.ts affineRow (R = 4, S = 16) for x [1,1,K], N output rows.
def affineConfig (k n bits : Nat) : Config :=
  ⟨[([1,1,n], .bfloat16)], (32, n/4, 1), (32, 16, 1), [("T", .bfloat16)],
    [("N", n), ("K", k), ("BITS", bits), ("R", 4), ("S", 16)], none⟩
-- silu-rms-heads.ts with HK=16, HV=48, DK=DV=128, C=10240, B=S=1.
def headsConfig : Config :=
  ⟨[([1,1,16,128], .bfloat16), ([1,1,16,128], .bfloat16), ([1,1,48,128], .bfloat16)], (2560, 1, 1), (32, 1, 1),
    [("T", .bfloat16)], [("C", 10240), ("HK", 16), ("HV", 48), ("DK", 128), ("DV", 128)], none⟩
-- gated.ts launchRecurrence (no mask) for B=T=1.
def gatedConfig : Config :=
  ⟨[([1,1,48,128], .bfloat16), ([1,48,128,128], .float32)], (32, 128, 48), (32, 4, 1),
    [("InT", .bfloat16), ("StT", .float32)], [("Dk", 128), ("Dv", 128), ("Hk", 16), ("Hv", 48)], none⟩
-- gated-rms-norm.ts / residual-rms-norm.ts: threads = min(1024, ceil(D/128)·32);
-- EPS is the f32 word of 1e-6.
def epsWord : Nat := 0x358637bd
def gatedNormConfig : Config :=
  ⟨[([1,1,48,128], .bfloat16)], (1536, 1, 1), (32, 1, 1), [("T", .bfloat16)],
    [("D", 128), ("THREADS", 32), ("EPS", epsWord)], none⟩
def residualConfig : Config :=
  ⟨[([1,1,5120], .bfloat16), ([1,1,5120], .bfloat16)], (1024, 1, 1), (1024, 1, 1), [("T", .bfloat16)],
    [("D", 5120), ("THREADS", 1024), ("EPS", epsWord)], none⟩
-- gate-up-codebook.ts gateUpCodebookRow (THREADS 1024, ROWS_TG 32, 160 groups)
-- and down-codebook.ts launch (P 16, U 2, SPLITS 128, THREADS 256), T=256, L=12.
def gateUpConfig (gateBits upBits : Nat) : Config :=
  ⟨[([1,17408], .bfloat16)], (1024, 160, 1), (1024, 1, 1), [("T", .bfloat16)],
    [("R", 17408), ("C", 5120), ("BT", 256), ("KG", gateBits), ("KU", upBits), ("L", 12), ("ROWS_TG", 32),
      ("THREADS", 1024), ("TAIL", if gateBits ≠ upBits then 1 else 0)], none⟩
def downConfig (bits : Nat) : Config :=
  ⟨[([1,32,5120], .float32)], (256, 160, 1), (256, 1, 1), [("T", .bfloat16)],
    [("R", 17408), ("C", 5120), ("K", bits), ("L", 12), ("P", 16), ("U", 2), ("SPLITS", 128), ("THREADS", 256),
      ("INTERLEAVE", if bits = 3 then 1 else 0)], none⟩
def foldConfig : Config :=
  ⟨[([1,5120], .bfloat16)], (40960, 1, 1), (256, 1, 1), [("T", .bfloat16)], [("C", 5120)], none⟩
-- normalized-argmax.ts kernelGraph for logits [1, 248320]: 243 tiles.
def partialConfig : Config :=
  ⟨[([1,243], .float32), ([1,243], .uint32)], (31104, 1, 1), (128, 1, 1), [("T", .bfloat16)],
    [("V", 248320), ("P", 243)], none⟩
def finishConfig : Config :=
  ⟨[([1], .uint32)], (128, 1, 1), (128, 1, 1), [], [("P", 243)], none⟩

/-! ## Weight decodings

`w` is the uint32 storage of an affine-quantized tensor; byte b of its
row-major storage is `w.byte b`. -/

def weights3 (w scales biases : Value) (steps row : Nat) : Quantization.AffineRow.Weights3 steps where
  bytes step lane chunk byte := w.byte (Quantization.AffineLayout.weightOffset 3 row steps step.val lane.val (chunk.val*3+byte.val))
  scale g := bf (scales.elems (row*(steps*8)+g.val))
  bias g := bf (biases.elems (row*(steps*8)+g.val))

structure Affine3 (p : AffineVerifyLinear.Projection3 steps rows) (w scales biases : Value) : Prop where
  words : w.dtype = .uint32 ∧ w.shape = [rows, steps*48]
  groups : scales.dtype = .bfloat16 ∧ scales.shape = [rows, steps*8] ∧ biases.dtype = .bfloat16 ∧ biases.shape = [rows, steps*8]
  weights : ∀ row, p.weights row = weights3 w scales biases steps row.val

structure Affine4 (p : AffineVerifyLinear.Projection4 steps rows) (w scales biases : Value) : Prop where
  words : w.dtype = .uint32 ∧ w.shape = [rows, steps*64]
  groups : scales.dtype = .bfloat16 ∧ scales.shape = [rows, steps*8] ∧ biases.dtype = .bfloat16 ∧ biases.shape = [rows, steps*8]
  weights : ∀ row, p.weights row = weights4 w scales biases steps row.val

-- Byte b of a value's row-major storage.
def Value.storageByte (v : Value) (b : Nat) : BitVec 8 :=
  BitVec.ofNat 8 (v.elems (b / v.dtype.bytes) / 256^(b % v.dtype.bytes))

-- Trellis payloads (CheckpointTrellis layouts) read from the loaded arrays.
def codes (width : Nat) (v : Value) : CheckpointTrellis.Codes width := fun b => v.storageByte b.val
def trellisScales (v : Value) : CheckpointTrellis.Scales := fun b => v.storageByte b.val

-- The loaded arrays encode the MLP: their bytes are its codes and scales, and their dtypes and shapes are the
-- checkpoint's (trellis-linear.ts trellisGeometry: row-major uint32 codes [17408, 5120·K/32], the 3-bit down
-- projection block-interleaved [10, 17408, 48]; checkpoint-trellis.ts float16 scales [17408]).
structure Trellis (mlp : GateDown) (gc gs uc us dc ds : Value) : Prop where
  gate : CheckpointTrellis.gateUp mlp.gate.width mlp.gate.validWidth (codes _ gc) (trellisScales gs) = mlp.gate
  up : CheckpointTrellis.gateUp mlp.up.width mlp.up.validWidth (codes _ uc) (trellisScales us) = mlp.up
  down : CheckpointTrellis.down mlp.down.width mlp.down.validWidth (codes _ dc) (trellisScales ds) = mlp.down
  gateCodes : gc.dtype = .uint32 ∧ gc.shape = [17408, 160 * mlp.gate.width]
  upCodes : uc.dtype = .uint32 ∧ uc.shape = [17408, 160 * mlp.up.width]
  downCodes : dc.dtype = .uint32 ∧
    dc.shape = if mlp.down.width = 3 then [10, 17408, 48] else [17408, 160 * mlp.down.width]
  scales : gs.dtype = .float16 ∧ gs.shape = [17408] ∧ us.dtype = .float16 ∧ us.shape = [17408] ∧
    ds.dtype = .float16 ∧ ds.shape = [17408]

/-! ## The MLX contract for the route's custom kernels -/

-- gate-up-codebook.ts:131 TAIL = (gate width ≠ up width) on the route's
-- "split" tail: MLX's bf16 sigmoid (fast_fabs/fast_exp), else precise
-- exp(-float(gate)).
def trellisActivation (C : M1Max.Contract) (gateBits upBits : Nat) : Activation :=
  if gateBits ≠ upBits then .split C.fastExpAbs else .float C.expNeg

-- The (K steps, N/64 blocks) of the route's affine_row launches: in_proj_qkv,
-- in_proj_z, out_proj and the lm_head (affine-verify-linear.ts eligibility;
-- attention projections are plain).
def AffineRoute (steps blocks : Nat) : Prop := (steps, blocks) ∈ [(10, 160), (10, 96), (12, 80), (10, 3880)]

structure KernelContract (C : M1Max.Contract) where
  -- mlx_fast_metal_kernel_apply on the default GPU stream.
  apply : Kernel → List Value → Config → Option (List Value)
  -- Metal compiler choices (contraction sites) and the MLX-native logsumexp's
  -- choices; they carry no claim beyond the platform structures' own primitive contracts.
  -- affine_row: one text per (bits, K steps, N rows), each with its own choice at
  -- every site of the tile's dot and at its tail.
  affineContracted : (bits steps rows : Nat) → Nat → Bool
  affineTail : (bits steps rows : Nat) → Bool
  headsContracted : Bool
  flags : Delta.Gated.Contraction
  gatedContracted : Bool
  residualContracted : Bool
  lseSum : Bool
  lseNumerator : Attention.SdpaUpdate.Contraction
  affineRow3 : ∀ {steps blocks : Nat} (p : AffineVerifyLinear.Projection3 steps (4*(blocks*16)))
    (input : Fin (steps*512) → BF) (x w scales biases : Value),
    p.platform = C.rowPlatformAt (affineContracted 3 steps (4*(blocks*16))) (affineTail 3 steps (4*(blocks*16))) →
    Row x (steps*512) input → Affine3 p w scales biases →
    p.Finite input → AffineRoute steps blocks →
    ∃ y, apply .affineRow [x, w, scales, biases] (affineConfig (steps*512) (4*(blocks*16)) 3) = some [y] ∧
      Row y (4*(blocks*16)) (p.forward input)
  affineRow4 : ∀ {steps blocks : Nat} (p : AffineVerifyLinear.Projection4 steps (4*(blocks*16)))
    (input : Fin (steps*512) → BF) (x w scales biases : Value),
    p.platform = C.rowPlatformAt (affineContracted 4 steps (4*(blocks*16))) (affineTail 4 steps (4*(blocks*16))) →
    Row x (steps*512) input → Affine4 p w scales biases →
    p.Finite input → AffineRoute steps blocks →
    ∃ y, apply .affineRow [x, w, scales, biases] (affineConfig (steps*512) (4*(blocks*16)) 4) = some [y] ∧
      Row y (4*(blocks*16)) (p.forward input)
  siluRmsHeads : ∀ (values : Fin 10240 → BF) (qScale kScale : Fin 128 → BF) (x qs ks : Value),
    Row x 10240 values → GlueAttention.Vector qs 128 qScale → GlueAttention.Vector ks 128 kScale →
    DeltaHeads.Finite (C.headsPlatform headsContracted) (fun _ : Fin 1 => values) qScale kScale
      Delta.SiluHeads128Output.width Delta.SiluHeads128Output.epsilon →
    ∃ q k v, apply .siluRmsHeads [x, qs, ks] headsConfig = some [q, k, v] ∧
      let out := DeltaHeads.forward (C.headsPlatform headsContracted) (fun _ : Fin 1 => values) qScale kScale
        Delta.SiluHeads128Output.width Delta.SiluHeads128Output.epsilon
      Tensor4 q 1 16 128 (fun _ => out.q 0) ∧ Tensor4 k 1 16 128 (fun _ => out.k 0) ∧ Tensor4 v 1 48 128 (fun _ => out.v 0)
  -- `reduction`: the tree of the model's recurrence platform for the machine's
  -- simd_sum (the model's finiteness certificate is stated on that tree).
  gatedDeltaStep : ∀ (reduce : (Fin 32 → Float32) → Float32) (reduction : FlushedReduction.SimdContract reduce)
    (initial : Delta.GatedDevice.State) (values : Delta.GatedInputs.Values) (q k v g beta s : Value),
    reduce = C.simdSum →
    Flat q [1,1,16,128] (Delta.GatedInputs.flatten values.query) → Flat k [1,1,16,128] (Delta.GatedInputs.flatten values.key) →
    Flat v [1,1,48,128] (Delta.GatedInputs.flatten values.value) → FlatF32 g [1,1,48] values.decay →
    Flat beta [1,1,48] values.beta →
    (s.dtype = .float32 ∧ s.shape = [1,48,128,128] ∧ ∀ h r c, f32 (s.elems (Delta.GatedStores.stateIndex h r c)) = initial h r c) →
    (∀ h r, Arithmetic.Finite (Delta.Recurrence.bind (initial h r) (values.inputs h r)) (Delta.Gated.outputExpr flags reduction.tree)) →
    ∃ y s', apply .gatedDeltaStep [q, k, v, g, beta, s, ⟨.int32, [1], fun _ => 1⟩] gatedConfig = some [y, s'] ∧
      Tensor4 y 1 48 128 (fun _ => Delta.GatedDevice.producedOutput C.simdSum flags initial values.inputs) ∧
      s'.dtype = .float32 ∧ s'.shape = [1,48,128,128] ∧
      ∀ h r c, f32 (s'.elems (Delta.GatedStores.stateIndex h r c)) =
        Delta.GatedDevice.producedState C.simdSum flags initial values.inputs h r c
  gatedRmsNorm : ∀ (x gate : GatedRmsNormDevice.Rows) (weights : Fin 128 → BF) (xv gv wv : Value),
    Flat xv [1,1,48,128] (Delta.GatedInputs.flatten x) → Flat gv [1,1,48,128] (Delta.GatedInputs.flatten gate) →
    GlueAttention.Vector wv 128 weights →
    (∀ h, GatedRmsNorm.NormFinite (C.gatedPlatform gatedContracted) (x h) weights
      Normalization.GatedRms128TailSource.width (FloatMemory.decode (BitVec.ofNat 32 epsWord))) →
    (∀ h i, GatedRmsNorm.TailFinite (C.gatedPlatform gatedContracted) (BFloat16.widen (gate h i))
      (BFloat16.widen (GatedRmsNorm.normalized (C.gatedPlatform gatedContracted) (x h) weights
        Normalization.GatedRms128TailSource.width (FloatMemory.decode (BitVec.ofNat 32 epsWord)) i))) →
    ∃ out, apply .gatedRmsNorm [xv, gv, wv] gatedNormConfig = some [out] ∧
      Flat out [1,1,48,128] (Delta.GatedInputs.flatten (fun h => GatedRmsNorm.value (C.gatedPlatform gatedContracted)
        (x h) (gate h) weights Normalization.GatedRms128TailSource.width (FloatMemory.decode (BitVec.ofNat 32 epsWord))))
  residualRmsNorm : ∀ (left right weight : Fin 5120 → BF) (xv uv wv : Value),
    Row xv 5120 left → Row uv 5120 right → GlueAttention.Vector wv 5120 weight →
    (∀ i, ResidualRmsNorm.AddFinite (left i) (right i)) →
    ResidualRmsNorm.NormFinite (C.rmsPlatform 32 (by decide) (by decide) residualContracted) left right weight
      Blocks.width Blocks.eps →
    ∃ h n, apply .residualRmsNorm [xv, uv, wv] residualConfig = some [h, n] ∧
      Row h 5120 (fun i => ResidualRmsNorm.residual (left i) (right i)) ∧
      ∀ scratch base, Row n 5120 (ResidualRmsNorm.normalized (C.rmsPlatform 32 (by decide) (by decide) residualContracted)
        left right weight Blocks.width Blocks.eps scratch base)
  trellis : ∀ (mlp : GateDown) (input : Fin 5120 → BF) (x gc gs uc us dc ds : Value),
    mlp.gatePlatform.reduce = C.simdSum → mlp.downPlatform.reduce = C.simdSum →
    mlp.activation = trellisActivation C mlp.gate.width mlp.up.width → Trellis mlp gc gs uc us dc ds →
    Flat x [1,5120] input → TrellisMlp.Finite mlp (Blocks.packed input) →
    ∃ mid part out, apply .gateUp [x, gc, gs, uc, us] (gateUpConfig mlp.gate.width mlp.up.width) = some [mid] ∧
      apply .downPartial [mid, dc, ds] (downConfig mlp.down.width) = some [part] ∧
      apply .downFold [part] foldConfig = some [out] ∧
      mid.shape = [1,17408] ∧ Flat out [1,5120] (mlp.forward (Blocks.packed input))
  argmax : ∀ (logits : Fin 248320 → BF) (l s : Value),
    Flat l [1,248320] logits → Flat s [1,1] (fun _ : Fin 1 => Sampling.LogSumExpRanges.value (C.logSumExpPlatform lseSum lseNumerator) logits) →
    Sampling.LogSumExpRanges.Primitives (C.logSumExpPlatform lseSum lseNumerator) →
    (∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2:ℝ)^(23:Nat)) →
    ∃ values indices token, apply .argmaxPartial [l, s] partialConfig = some [values, indices] ∧
      apply .argmaxFinish [values, indices] finishConfig = some [token] ∧
      token.dtype = .uint32 ∧ token.shape = [1] ∧
      token.elems 0 = Sampling.GreedySampling.sample (C.logSumExpPlatform lseSum lseNumerator) logits

namespace KernelContract
variable {C : M1Max.Contract} (K : KernelContract C)

noncomputable def sampling : Sampling.LogSumExpRanges.Platform := C.logSumExpPlatform K.lseSum K.lseNumerator
noncomputable def residual : RmsNorm.Platform := C.rmsPlatform 32 (by decide) (by decide) K.residualContracted
-- The platform of the affine_row text for `bits`, K = 512·`steps`, N = `rows`.
noncomputable def affine (bits steps rows : Nat) : Quantization.AffineRow.Platform :=
  C.rowPlatformAt (K.affineContracted bits steps rows) (K.affineTail bits steps rows)
noncomputable def heads : Delta.SiluRmsHeads.Platform := C.headsPlatform K.headsContracted
noncomputable def gated : GatedRmsNorm.Platform := C.gatedPlatform K.gatedContracted
def activation (_ : KernelContract C) : Nat → Nat → Activation := trellisActivation C

end KernelContract

/-! ## MLX-native logsumexp

mlx_logsumexp_axis(logits [1,248320], -1, keepdims) runs logsumexp.cpp's
looped kernel (LogSumExpSourceHost); its value is LogSumExpRanges.value. -/
def logsumexp (P : Sampling.LogSumExpRanges.Platform) (v : Value) : Option Value :=
  if v.dtype = .bfloat16 ∧ v.shape = [1, 248320] then
    some ⟨.bfloat16, [1, 1], fun _ => bfWord (Sampling.LogSumExpRanges.value P (fun i => bf (v.elems i.val)))⟩
  else none

/-! ## Compiled closures over custom kernels

layers/delta-heads.ts, layers/compiled-normalization.ts and
kernels/sampling/normalized-argmax.ts wrap the launches in
CompiledFunction(fn, shapeless = false). In mlx/compile.cpp the traced
graph is simplified (compile_simplify: merge equal scalars, drop Copy and
StopGradient, merge equivalent duplicate primitives) and fused
(compile_fuse) only over `is_fusable` primitives, i.e. unary, binary,
ternary and Broadcast (compile.cpp:27-80, 862). CustomKernel, LogSumExp and
Reshape are not fusable and none is duplicated, so the compiled closure
evaluates the traced launches in order. -/
inductive KernelClosure where
  | siluRmsHeads | gatedRmsNorm | residualRmsNorm | normalizedArgmax

noncomputable def KernelClosure.eval {C : M1Max.Contract} (K : KernelContract C) : KernelClosure → List Value → Option (List Value)
  | .siluRmsHeads, xs => K.apply .siluRmsHeads xs headsConfig
  | .gatedRmsNorm, xs => K.apply .gatedRmsNorm xs gatedNormConfig
  | .residualRmsNorm, xs => K.apply .residualRmsNorm xs residualConfig
  | .normalizedArgmax, [l] => do
    let s ← logsumexp K.sampling l
    let pair ← K.apply .argmaxPartial [l, s] partialConfig
    match pair with
    | [values, indices] =>
      let out ← K.apply .argmaxFinish [values, indices] finishConfig
      match out with
      | [token] => (reshape token [1]).map (fun r => [r])
      | _ => none
    | _ => none
  | .normalizedArgmax, _ => none

end Host.Mlx
