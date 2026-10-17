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

Each field of `KernelContract` states that contract for one route kernel:
the M1 Max execution of the body from MLX's placement is an object of that
kernel's existing heap execution type, whose input storages are attached to
the decoded input values, and the outputs are the bytes of its output
regions. Placement (bases, alignment, bounds, disjointness, one shared
heap), the store schedule and all threadgroup contents are existential: the
lifting theorems hold for every such execution. The parsed-source theorems
(`source_execution`, `checked`, `ready`, `source_token`) prove that these
executions' write programs are the parsed kernel bodies' programs. -/

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

theorem halfArray_buffer {values : Fin n → BF} (buffer : ArrayStorage.BFBuffer values) (shape : List Nat) :
    Flat (halfArray buffer.bytes buffer.base shape) shape values :=
  ⟨rfl, rfl, fun i => by
    change bf (HalfMemory.load buffer.bytes (buffer.base+2*i.val)).toNat = _
    rw [bf_toNat]; exact buffer.read_correct i⟩

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

structure Trellis (mlp : GateDown) (gc gs uc us dc ds : Value) : Prop where
  gate : CheckpointTrellis.gateUp mlp.gate.width mlp.gate.validWidth (codes _ gc) (trellisScales gs) = mlp.gate
  up : CheckpointTrellis.gateUp mlp.up.width mlp.up.validWidth (codes _ uc) (trellisScales us) = mlp.up
  down : CheckpointTrellis.down mlp.down.width mlp.down.validWidth (codes _ dc) (trellisScales ds) = mlp.down

-- The model's MLP with the threadgroup scratch MLX supplies.
def _root_.Inference.Models.Qwen.WrittenLayers.GateDown.withScratch (mlp : GateDown) (gate : M1Max.WordMemory) (gateBase : Nat) (gateAligned : gateBase%4=0)
    (gateBounded : gateBase+16384 ≤ 2^64) (down : Nat → M1Max.WordMemory) (downBase : Nat) (downAligned : downBase%4=0)
    (downBounded : downBase+16384 ≤ 2^64) : GateDown :=
  { mlp with
    gatePlatform := { mlp.gatePlatform with before := gate, base := gateBase, aligned := gateAligned, bounded := gateBounded }
    downPlatform := { mlp.downPlatform with before := down, base := downBase, aligned := downAligned, bounded := downBounded } }

/-! ## The MLX contract for the route's custom kernels -/

-- gate-up-codebook.ts:131 TAIL = (gate width ≠ up width) on the route's
-- "split" tail: MLX's bf16 sigmoid (fast_fabs/fast_exp), else precise
-- exp(-float(gate)).
def trellisActivation (C : M1Max.Contract) (gateBits upBits : Nat) : Activation :=
  if gateBits ≠ upBits then .split C.fastExpAbs else .float C.expNeg

structure KernelContract (C : M1Max.Contract) where
  -- mlx_fast_metal_kernel_apply on the default GPU stream.
  apply : Kernel → List Value → Config → Option (List Value)
  -- Metal compiler choices and kernel platforms; they carry no claim beyond
  -- the platform structures' own primitive contracts.
  affineContracted : Bool
  affineTail : Bool
  headsContracted : Bool
  flags : Delta.Gated.Contraction
  gatedContracted : Bool
  residualContracted : Bool
  lseSum : Bool
  lseNumerator : Attention.SdpaUpdate.Contraction
  affineRow3 : ∀ {steps blocks : Nat} (p : AffineVerifyLinear.Projection3 steps (4*(blocks*16)))
    (input : Fin (steps*512) → BF) (x w scales biases : Value),
    p.platform = C.rowPlatform affineContracted affineTail → Row x (steps*512) input → Affine3 p w scales biases →
    ∃ y, apply .affineRow [x, w, scales, biases] (affineConfig (steps*512) (4*(blocks*16)) 3) = some [y] ∧
      ∃ e : AffineMemory.Execution3 p input, y = halfArray e.kernel.stores.memory e.kernel.base [1,1,4*(blocks*16)]
  affineRow4 : ∀ {steps blocks : Nat} (p : AffineVerifyLinear.Projection4 steps (4*(blocks*16)))
    (input : Fin (steps*512) → BF) (x w scales biases : Value),
    p.platform = C.rowPlatform affineContracted affineTail → Row x (steps*512) input → Affine4 p w scales biases →
    ∃ y, apply .affineRow [x, w, scales, biases] (affineConfig (steps*512) (4*(blocks*16)) 4) = some [y] ∧
      ∃ e : AffineMemory.Execution4 p input, y = halfArray e.kernel.stores.memory e.kernel.base [1,1,4*(blocks*16)]
  siluRmsHeads : ∀ (values : Fin 10240 → BF) (qScale kScale : Fin 128 → BF) (x qs ks : Value),
    Row x 10240 values → GlueAttention.Vector qs 128 qScale → GlueAttention.Vector ks 128 kScale →
    ∃ q k v, apply .siluRmsHeads [x, qs, ks] headsConfig = some [q, k, v] ∧
      ∃ (input : DeltaHeadsMemory.Input values qScale kScale)
        (e : DeltaHeadsMemory.Execution input (C.headsPlatform headsContracted) Delta.SiluHeads128Output.width Delta.SiluHeads128Output.epsilon),
        q = halfArray e.trace.memory (e.geometry.base 0) [1,1,16,128] ∧
        k = halfArray e.trace.memory (e.geometry.base 1) [1,1,16,128] ∧
        v = halfArray e.trace.memory (e.geometry.base 2) [1,1,48,128]
  gatedDeltaStep : ∀ (initial : Delta.GatedDevice.State) (values : Delta.GatedInputs.Values) (q k v g beta s t : Value),
    Flat q [1,1,16,128] (Delta.GatedInputs.flatten values.query) → Flat k [1,1,16,128] (Delta.GatedInputs.flatten values.key) →
    Flat v [1,1,48,128] (Delta.GatedInputs.flatten values.value) → FlatF32 g [1,1,48] values.decay →
    Flat beta [1,1,48] values.beta →
    (s.dtype = .float32 ∧ s.shape = [1,48,128,128] ∧ ∀ h r c, f32 (s.elems (Delta.GatedStores.stateIndex h r c)) = initial h r c) →
    t = ⟨.int32, [1], fun _ => 1⟩ →
    ∃ y s', apply .gatedDeltaStep [q, k, v, g, beta, s, t] gatedConfig = some [y, s'] ∧
      ∃ e : Delta.GatedShared.Execution C.simdSum flags initial values,
        y = halfArray e.stores.memory e.stores.trace.outputBase [1,1,48,128] ∧
        s' = wordArray .float32 e.stores.memory e.stores.trace.stateBase [1,48,128,128]
  gatedRmsNorm : ∀ (x gate : GatedRmsNormDevice.Rows) (weights : Fin 128 → BF) (xv gv wv : Value),
    Flat xv [1,1,48,128] (Delta.GatedInputs.flatten x) → Flat gv [1,1,48,128] (Delta.GatedInputs.flatten gate) →
    GlueAttention.Vector wv 128 weights →
    ∃ out, apply .gatedRmsNorm [xv, gv, wv] gatedNormConfig = some [out] ∧
      ∃ (input : GatedRmsNormMemory.Input x gate weights)
        (e : GatedRmsNormMemory.Execution input (C.gatedPlatform gatedContracted) Normalization.GatedRms128TailSource.width (FloatMemory.decode (BitVec.ofNat 32 epsWord))),
        out = halfArray e.stores.memory e.base [1,1,48,128]
  residualRmsNorm : ∀ (left right weight : Fin 5120 → BF) (xv uv wv : Value),
    Row xv 5120 left → Row uv 5120 right → GlueAttention.Vector wv 5120 weight →
    ∃ h n, apply .residualRmsNorm [xv, uv, wv] residualConfig = some [h, n] ∧
      ∃ (input : BinaryMemory.Input left right) (residual : ResidualRmsMemory.Residual input weight)
        (e : ResidualRmsMemory.Execution residual (C.rmsPlatform 32 (by decide) (by decide) residualContracted)
          Blocks.width Blocks.eps),
        h = halfArray e.normalized.trace.memory (2*residual.addition.base) [1,1,5120] ∧
        n = halfArray e.normalized.trace.memory (2*e.normalized.base) [1,1,5120]
  trellis : ∀ (mlp : GateDown) (input : Fin 5120 → BF) (x gc gs uc us dc ds : Value),
    mlp.gatePlatform.load = C.threadgroupLoad → mlp.gatePlatform.reduce = C.simdSum →
    mlp.downPlatform.load = C.threadgroupLoad → mlp.downPlatform.reduce = C.simdSum →
    mlp.activation = trellisActivation C mlp.gate.width mlp.up.width → Trellis mlp gc gs uc us dc ds →
    Flat x [1,5120] input →
    ∃ mid part out, apply .gateUp [x, gc, gs, uc, us] (gateUpConfig mlp.gate.width mlp.up.width) = some [mid] ∧
      apply .downPartial [mid, dc, ds] (downConfig mlp.down.width) = some [part] ∧
      apply .downFold [part] foldConfig = some [out] ∧
      ∃ (gate : M1Max.WordMemory) (gateBase : Nat) (gateAligned : gateBase%4=0) (gateBounded : gateBase+16384 ≤ 2^64)
        (down : Nat → M1Max.WordMemory) (downBase : Nat) (downAligned : downBase%4=0) (downBounded : downBase+16384 ≤ 2^64)
        (e : TrellisMlpParsedDown.Execution
          (mlp.withScratch gate gateBase gateAligned gateBounded down downBase downAligned downBounded) input),
        Nonempty (TrellisMlpParsedPipeline.GateExecution e) ∧
        mid = halfArray e.preceding.kernel.middle.memory e.preceding.kernel.middle.base [1,17408] ∧
        part = wordArray .float32 e.down.memory e.down.partialBase [1,32,5120] ∧
        out = halfArray e.output.memory e.output.base [1,5120]
  argmax : ∀ (logits : Fin 248320 → BF) (l s : Value),
    Flat l [1,248320] logits → Flat s [1,1] (fun _ : Fin 1 => Sampling.LogSumExpRanges.value (C.logSumExpPlatform lseSum lseNumerator) logits) →
    ∃ values indices token, apply .argmaxPartial [l, s] partialConfig = some [values, indices] ∧
      apply .argmaxFinish [values, indices] finishConfig = some [token] ∧
      ∃ (source : ArrayStorage.BFBuffer logits) (lse : Sampling.LogSumExpMemory.Execution (C.logSumExpPlatform lseSum lseNumerator) source)
        (e : Sampling.NormalizedArgmaxMemory.Execution lse),
        values = wordArray .float32 e.partials.memory e.layout.scores [1,243] ∧
        indices = wordArray .uint32 e.partials.memory e.layout.ids [1,243] ∧
        token = wordArray .uint32 e.memory e.destination [1]

namespace KernelContract
variable {C : M1Max.Contract} (K : KernelContract C)

noncomputable def sampling : Sampling.LogSumExpRanges.Platform := C.logSumExpPlatform K.lseSum K.lseNumerator
noncomputable def residual : RmsNorm.Platform := C.rmsPlatform 32 (by decide) (by decide) K.residualContracted
noncomputable def affine : Quantization.AffineRow.Platform := C.rowPlatform K.affineContracted K.affineTail
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
