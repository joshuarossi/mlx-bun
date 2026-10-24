import host.mlx.GlueKernels
import metal.tests.Assemble
import metal.bridge.SiluRmsHeads
import metal.bridge.GatedDeltaStep
import metal.bridge.GatedRmsNorm
import metal.bridge.ResidualRmsNorm
import metal.bridge.SingleRounding
import metal.bridge.Argmax
import metal.bridge.Trellis
import metal.bridge.AffineRow
import host.mlx.KernelGpuTexts
import metal.kernels.AffineRows3
import metal.kernels.AffineRows4
import metal.kernels.AffineSplitMma
import metal.kernels.GateUpCodebookMma
import metal.kernels.GateUpMmaWide
import metal.kernels.DownMmaWide
import metal.kernels.DownK3iMmaWide
import metal.kernels.AneTrellisFill
import metal.kernels.AneTrellisFillK3i
import metal.kernels.AneWriteHalf
import metal.kernels.VectorExpand

namespace Host.Mlx.KernelGpu
open Metal Inference Inference.Contracts.Mlx Inference.Kernels Inference.Layers
open Inference.Models.Qwen WrittenLayers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

/-! # The route's kernel contract from the GPU assumption

`ofGpu G P` is a `KernelContract` whose `apply` is MLX's custom-kernel launch run by the GPU `G`
(`Metal.Gpu`, the one GPU assumption): the text MLX assembles for the call, the inputs' row-major bytes,
the outputs read back with the call's dtypes and shapes. Every field is proved from the kernel's Metal
source (metal/kernels, metal/bridge). The contraction choices are `G.fusion` of each text and site;
`P` holds the pipelines' threadgroup limits; the logsumexp choices belong to MLX's native logsumexp and
are parameters. -/

/-! ## The launch MLX issues -/

/-- The constructor's kernel name (`new MetalKernel({ name, ... })` in packages/inference/src/kernels/**;
the names `FfiEval.kernelOf` resolves, tests/Assemble.lean `route_names`). -/
def kernelName : Kernel → List Char
  | .affineRow => chars!"mlx_bun_affine_row"
  | .siluRmsHeads => chars!"mlx_bun_silu_rms_heads"
  | .gatedDeltaStep => chars!"gated_delta_step"
  | .gatedRmsNorm => chars!"mlx_bun_gated_rms_norm"
  | .residualRmsNorm => chars!"mlx_bun_residual_rms_norm"
  | .gateUp => chars!"mlx_bun_trellis_gateup_codebook_row"
  | .downPartial => chars!"mlx_bun_trellis_down_codebook_row"
  | .downFold => chars!"mlx_bun_trellis_down_codebook_fold"
  | .argmaxPartial => chars!"normalized_argmax_partial"
  | .argmaxFinish => chars!"normalized_argmax_finish"

/-- The constructor's `inputNames`. -/
def inputNames : Kernel → List (List Char)
  | .affineRow => [chars!"x", chars!"w", chars!"scales", chars!"biases"]
  | .siluRmsHeads => [chars!"x", chars!"qscale", chars!"kscale"]
  | .gatedDeltaStep => [chars!"q", chars!"k", chars!"v", chars!"g", chars!"beta", chars!"state_in", chars!"Tin"]
  | .gatedRmsNorm => [chars!"x", chars!"gate", chars!"weight"]
  | .residualRmsNorm => [chars!"x", chars!"update", chars!"weight"]
  | .gateUp => [chars!"x", chars!"gcodes", chars!"gscales", chars!"ucodes", chars!"uscales"]
  | .downPartial => [chars!"x", chars!"codes", chars!"scales"]
  | .downFold => [chars!"partial"]
  | .argmaxPartial => [chars!"logits", chars!"lse"]
  | .argmaxFinish => [chars!"values", chars!"indices"]

/-- The constructor's `outputNames`. -/
def outputNames : Kernel → List (List Char)
  | .affineRow => [chars!"y"]
  | .siluRmsHeads => [chars!"q", chars!"k", chars!"v"]
  | .gatedDeltaStep => [chars!"y", chars!"state_out"]
  | .gatedRmsNorm => [chars!"out"]
  | .residualRmsNorm => [chars!"residual", chars!"normalized"]
  | .gateUp => [chars!"mid"]
  | .downPartial => [chars!"partial"]
  | .downFold => [chars!"out"]
  | .argmaxPartial => [chars!"values", chars!"indices"]
  | .argmaxFinish => [chars!"out"]

/-- The text MLX compiles for the call (after `metal::utils()`): `Assemble.assemble` on the constructor's names,
the body and header (`SourceKernels.sources`, bound to the TypeScript by KernelSourceBinding.ts), the inputs'
dtypes and shapes and the call's output dtypes and template arguments (metal-kernel.ts order, `configArgs`). -/
def launchText (k : Kernel) (xs : List Value) (cfg : Config) : Option (List Char) :=
  Assemble.Tests.launch k (kernelName k) (List.zipWith (fun n v => ⟨n, v.dtype, v.shape⟩) (inputNames k) xs)
    (outputNames k) cfg

/-- The buffer MLX binds for an input array (custom_kernel.cpp:32-63, ensureRowContiguous): its row-major bytes,
`size × itemsize` of them, in the address space `write_signature` declares (constant below
`maxConstantArraySize` elements, Assemble's `inputLines`). Base alignment 16: `set_input_array` binds the
array's Metal buffer at its `offset()`, MLX's allocations (`allocator::malloc`) are at least 16-byte aligned
(as `Gpu` takes for outputs), and every custom-kernel input on the route is a whole allocation (a kernel
output, a loaded weight or a reshape of one: no view offset). Element alignment alone would not do: gate-up
reads `x` and the down fold reads `partial` with 16-byte vector loads. -/
def buffer (v : Value) : Buffer :=
  ⟨if v.size < Assemble.maxConstantArraySize then .constant else .device, v.size * v.dtype.bytes, 16, v.storageByte⟩

/-- An output's size in bytes. -/
def outputSize (out : List Nat × Dtype) : Nat := out.1.foldr (· * ·) 1 * out.2.bytes

/-- An output buffer's final bytes as the array of the call's dtype and shape (little-endian elements). -/
def readOutput (bytes : ByteMemory.Bytes) (out : List Nat × Dtype) : Value :=
  ⟨out.2, out.1, fun i => bytesWord ((List.range out.2.bytes).map fun k => bytes (out.2.bytes * i + k))⟩

/-- `mlx_fast_metal_kernel_apply` run by the GPU: MLX checks the input count (metal_kernel.cpp:296); no route
kernel sets `init_value` (an initialized output is not modelled). -/
def apply {C : M1Max.Contract} (G : Gpu C) (k : Kernel) (xs : List Value) (cfg : Config) : Option (List Value) :=
  if xs.length = (inputNames k).length ∧ cfg.initValue = none then
    (launchText k xs cfg).bind fun text =>
      (G.execute text cfg.grid cfg.threadGroup (xs.map buffer) (cfg.outputs.map outputSize)).map fun outs =>
        List.zipWith readOutput outs cfg.outputs
  else none

/-! ## Bytes -/

theorem apply_some {C : M1Max.Contract} (G : Gpu C) {k : Kernel} {xs : List Value} {cfg : Config} {text : List Char}
    {outs : List ByteMemory.Bytes} {ys : List Value} (hlen : xs.length = (inputNames k).length)
    (hinit : cfg.initValue = none) (ht : launchText k xs cfg = some text)
    (he : G.execute text cfg.grid cfg.threadGroup (xs.map buffer) (cfg.outputs.map outputSize) = some outs)
    (hr : List.zipWith readOutput outs cfg.outputs = ys) :
    apply G k xs cfg = some ys := by
  unfold apply
  rw [ite_eq_left ⟨hlen, hinit⟩, ht, Option.bind_some, he, Option.map_some, hr]

theorem buffer_of {v : Value} {d : Dtype} {shape : List Nat} (hd : v.dtype = d) (hs : v.shape = shape) :
    buffer v = ⟨if shape.foldr (· * ·) 1 < Assemble.maxConstantArraySize then .constant else .device,
      shape.foldr (· * ·) 1 * d.bytes, 16, v.storageByte⟩ := by
  unfold buffer Value.size
  rw [hd, hs]

theorem append_toNat {m : Nat} (a : BitVec m) (b : BitVec 8) : (a ++ b).toNat = b.toNat + 256 * a.toNat := by
  rw [BitVec.toNat_append, Nat.shiftLeft_eq, Nat.mul_comm, ← Nat.two_pow_add_eq_or_of_lt b.isLt]
  omega

theorem readOutput_half (B : ByteMemory.Bytes) (shape : List Nat) :
    readOutput B (shape, .bfloat16) = halfArray B 0 shape := by
  unfold readOutput halfArray
  congr 1
  funext i
  rw [show List.range (Dtype.bytes .bfloat16) = [0, 1] from rfl]
  simp only [List.map_cons, List.map_nil, bytesWord, List.foldr_cons, List.foldr_nil, Dtype.bytes]
  unfold HalfMemory.load
  rw [append_toNat, Nat.zero_add]
  simp only [Nat.add_zero, Nat.mul_zero]

theorem readOutput_word (B : ByteMemory.Bytes) (shape : List Nat) (d : Dtype) (hd : d.bytes = 4) :
    readOutput B (shape, d) = wordArray d B 0 shape := by
  unfold readOutput wordArray
  congr 1
  funext i
  simp only [hd]
  rw [show List.range 4 = [0, 1, 2, 3] from rfl]
  simp only [List.map_cons, List.map_nil, bytesWord, List.foldr_cons, List.foldr_nil]
  unfold ByteMemory.load32 ByteMemory.join
  rw [append_toNat, append_toNat, append_toNat, Nat.zero_add]
  simp only [Nat.add_zero, Nat.mul_zero]

/-- MLX rebinds a read-back output as an input: its row-major storage is the output's bytes. -/
theorem readOutput_storage_half (B : ByteMemory.Bytes) (shape : List Nat) :
    (readOutput B (shape, .bfloat16)).storageByte = B := by
  rw [readOutput_half]
  funext b
  exact Metal.Bridge.Trellis.halfArray_storage B shape b

theorem readOutput_storage_word (B : ByteMemory.Bytes) (shape : List Nat) (d : Dtype) (hd : d.bytes = 4) :
    (readOutput B (shape, d)).storageByte = B := by
  rw [readOutput_word B shape d hd]
  funext b
  unfold Value.storageByte wordArray
  simp only [hd]
  rw [Metal.Bridge.Trellis.ofNat8_byte, ByteMemory.byte_load32 _ _ _ (Nat.mod_lt _ (by decide)), Nat.zero_add,
    show 4 * (b / 4) + b % 4 = b by omega]

/-! ## The kernels -/

section Kernels
variable {C : M1Max.Contract} (G : Gpu C)

/-- silu_rms_heads (site 1 the only contraction site). -/
theorem heads (hmax : 32 ≤ G.maxThreads Metal.Elab.Tests.siluRmsHeadsText)
    (values : Fin 10240 → BF) (qScale kScale : Fin 128 → BF) (x qs ks : Value)
    (hx : Row x 10240 values) (hq : GlueAttention.Vector qs 128 qScale) (hk : GlueAttention.Vector ks 128 kScale)
    (hf : DeltaHeads.Finite (C.headsPlatform (G.fusion Metal.Elab.Tests.siluRmsHeadsText 1)) (fun _ : Fin 1 => values)
      qScale kScale Delta.SiluHeads128Output.width Delta.SiluHeads128Output.epsilon) :
    ∃ q k v, apply G .siluRmsHeads [x, qs, ks] headsConfig = some [q, k, v] ∧
      let out := DeltaHeads.forward (C.headsPlatform (G.fusion Metal.Elab.Tests.siluRmsHeadsText 1))
        (fun _ : Fin 1 => values) qScale kScale Delta.SiluHeads128Output.width Delta.SiluHeads128Output.epsilon
      Tensor4 q 1 16 128 (fun _ => out.q 0) ∧ Tensor4 k 1 16 128 (fun _ => out.k 0) ∧
        Tensor4 v 1 48 128 (fun _ => out.v 0) := by
  have heps := Metal.Bridge.SiluRmsHeads.eps_eq
  obtain ⟨Q, K', V, he, tq, tk, tv⟩ := Metal.Bridge.SiluRmsHeads.gpu_value C G hmax x qs ks values qScale kScale hx hq hk
    16 16 16 (by decide) (by decide) (by decide) _ rfl _ (by rw [heps]; exact hf)
  simp only [Metal.Bridge.SiluRmsHeads.out, heps] at tq tk tv
  have ht : launchText .siluRmsHeads [x, qs, ks] headsConfig = some Metal.Elab.Tests.siluRmsHeadsText := by
    show Assemble.Tests.launch .siluRmsHeads chars!"mlx_bun_silu_rms_heads"
      [⟨chars!"x", x.dtype, x.shape⟩, ⟨chars!"qscale", qs.dtype, qs.shape⟩, ⟨chars!"kscale", ks.dtype, ks.shape⟩]
      [chars!"q", chars!"k", chars!"v"] headsConfig = _
    rw [hx.1, hx.2.1, hq.1, hq.2.1, hk.1, hk.2.1]
    exact Assemble.Tests.siluRmsHeads_assemble
  have hb : [x, qs, ks].map buffer =
      [⟨.device, 20480, 16, x.storageByte⟩, ⟨.device, 256, 16, qs.storageByte⟩, ⟨.device, 256, 16, ks.storageByte⟩] := by
    show [buffer x, buffer qs, buffer ks] = _
    rw [buffer_of hx.1 hx.2.1, buffer_of hq.1 hq.2.1, buffer_of hk.1 hk.2.1]
    rfl
  refine ⟨_, _, _, apply_some G rfl rfl ht (by rw [hb]; exact he) ?_, tq, tk, tv⟩
  show [readOutput Q ([1,1,16,128], .bfloat16), readOutput K' ([1,1,16,128], .bfloat16),
    readOutput V ([1,1,48,128], .bfloat16)] = _
  rw [readOutput_half, readOutput_half, readOutput_half]

/-- gated_rms_norm (site 1 the only contraction site). -/
theorem gatedNorm (hmax : 32 ≤ G.maxThreads Metal.Elab.Tests.gatedRmsNormText)
    (x gate : GatedRmsNormDevice.Rows) (weights : Fin 128 → BF) (xv gv wv : Value)
    (hx : Flat xv [1,1,48,128] (Delta.GatedInputs.flatten x)) (hg : Flat gv [1,1,48,128] (Delta.GatedInputs.flatten gate))
    (hw : GlueAttention.Vector wv 128 weights)
    (hn : ∀ h, GatedRmsNorm.NormFinite (C.gatedPlatform (G.fusion Metal.Elab.Tests.gatedRmsNormText 1)) (x h) weights
      Normalization.GatedRms128TailSource.width (FloatMemory.decode (BitVec.ofNat 32 epsWord)))
    (ht : ∀ h i, GatedRmsNorm.TailFinite (C.gatedPlatform (G.fusion Metal.Elab.Tests.gatedRmsNormText 1))
      (BFloat16.widen (gate h i))
      (BFloat16.widen (GatedRmsNorm.normalized (C.gatedPlatform (G.fusion Metal.Elab.Tests.gatedRmsNormText 1)) (x h) weights
        Normalization.GatedRms128TailSource.width (FloatMemory.decode (BitVec.ofNat 32 epsWord)) i))) :
    ∃ out, apply G .gatedRmsNorm [xv, gv, wv] gatedNormConfig = some [out] ∧
      Flat out [1,1,48,128] (Delta.GatedInputs.flatten (fun h =>
        GatedRmsNorm.value (C.gatedPlatform (G.fusion Metal.Elab.Tests.gatedRmsNormText 1)) (x h) (gate h) weights
          Normalization.GatedRms128TailSource.width (FloatMemory.decode (BitVec.ofNat 32 epsWord)))) := by
  obtain ⟨O, he, tout⟩ := Metal.Bridge.GatedRmsNorm.gpu_value C G hmax xv gv wv x gate weights hx hg hw 16 16 16
    (by decide) (by decide) (by decide) _ rfl _ hn ht
  have htx : launchText .gatedRmsNorm [xv, gv, wv] gatedNormConfig = some Metal.Elab.Tests.gatedRmsNormText := by
    show Assemble.Tests.launch .gatedRmsNorm chars!"mlx_bun_gated_rms_norm"
      [⟨chars!"x", xv.dtype, xv.shape⟩, ⟨chars!"gate", gv.dtype, gv.shape⟩, ⟨chars!"weight", wv.dtype, wv.shape⟩]
      [chars!"out"] gatedNormConfig = _
    rw [hx.1, hx.2.1, hg.1, hg.2.1, hw.1, hw.2.1]
    exact Assemble.Tests.gatedRmsNorm_assemble
  have hb : [xv, gv, wv].map buffer =
      [⟨.device, 12288, 16, xv.storageByte⟩, ⟨.device, 12288, 16, gv.storageByte⟩, ⟨.device, 256, 16, wv.storageByte⟩] := by
    show [buffer xv, buffer gv, buffer wv] = _
    rw [buffer_of hx.1 hx.2.1, buffer_of hg.1 hg.2.1, buffer_of hw.1 hw.2.1]
    rfl
  refine ⟨_, apply_some G rfl rfl htx (by rw [hb]; exact he) ?_, tout⟩
  show [readOutput O ([1,1,48,128], .bfloat16)] = _
  rw [readOutput_half]

/-- residual_rms_norm (site 1 the only contraction site; MLX's single bf16 rounding of the residual add is the
model's, `SingleRounding`). -/
theorem residualNorm (hmax : 1024 ≤ G.maxThreads Metal.Elab.Tests.residualRmsNormText)
    (left right weight : Fin 5120 → BF) (xv uv wv : Value)
    (hx : Row xv 5120 left) (hu : Row uv 5120 right) (hw : GlueAttention.Vector wv 5120 weight)
    (hA : ∀ i, ResidualRmsNorm.AddFinite (left i) (right i))
    (hn : ResidualRmsNorm.NormFinite (C.rmsPlatform 32 (by decide) (by decide)
      (G.fusion Metal.Elab.Tests.residualRmsNormText 1)) left right weight Blocks.width Blocks.eps) :
    ∃ h n, apply G .residualRmsNorm [xv, uv, wv] residualConfig = some [h, n] ∧
      Row h 5120 (fun i => ResidualRmsNorm.residual (left i) (right i)) ∧
      ∀ scratch base, Row n 5120 (ResidualRmsNorm.normalized (C.rmsPlatform 32 (by decide) (by decide)
        (G.fusion Metal.Elab.Tests.residualRmsNormText 1)) left right weight Blocks.width Blocks.eps scratch base) := by
  obtain ⟨H, N, he, th, tn⟩ := Metal.Bridge.ResidualRmsNorm.gpu_value C G hmax xv uv wv left right weight hx hu hw
    16 16 16 (by decide) (by decide) (by decide) _ rfl hA Metal.Bridge.ResidualRmsNorm.singleRounding hn
  have ht : launchText .residualRmsNorm [xv, uv, wv] residualConfig = some Metal.Elab.Tests.residualRmsNormText := by
    show Assemble.Tests.launch .residualRmsNorm chars!"mlx_bun_residual_rms_norm"
      [⟨chars!"x", xv.dtype, xv.shape⟩, ⟨chars!"update", uv.dtype, uv.shape⟩, ⟨chars!"weight", wv.dtype, wv.shape⟩]
      [chars!"residual", chars!"normalized"] residualConfig = _
    rw [hx.1, hx.2.1, hu.1, hu.2.1, hw.1, hw.2.1]
    exact Assemble.Tests.residualRmsNorm_assemble
  have hb : [xv, uv, wv].map buffer =
      [⟨.device, 10240, 16, xv.storageByte⟩, ⟨.device, 10240, 16, uv.storageByte⟩, ⟨.device, 10240, 16, wv.storageByte⟩] := by
    show [buffer xv, buffer uv, buffer wv] = _
    rw [buffer_of hx.1 hx.2.1, buffer_of hu.1 hu.2.1, buffer_of hw.1 hw.2.1]
    rfl
  refine ⟨_, _, apply_some G rfl rfl ht (by rw [hb]; exact he) ?_, th, tn⟩
  show [readOutput H ([1,1,5120], .bfloat16), readOutput N ([1,1,5120], .bfloat16)] = _
  rw [readOutput_half, readOutput_half]

/-- normalized argmax: the partial launch, then the finish launch on its read-back outputs. -/
theorem argmax (hmaxP : 128 ≤ G.maxThreads Metal.Elab.Tests.argmaxPartialText)
    (hmaxF : 128 ≤ G.maxThreads Metal.Elab.Tests.argmaxFinishText) (p : Sampling.LogSumExpRanges.Platform)
    (logits : Fin 248320 → BF) (l s : Value)
    (hl : Flat l [1,248320] logits) (hs : Flat s [1,1] (fun _ : Fin 1 => Sampling.LogSumExpRanges.value p logits))
    (primitive : Sampling.LogSumExpRanges.Primitives p)
    (bound : ∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2:ℝ)^(23:Nat)) :
    ∃ values indices token, apply G .argmaxPartial [l, s] partialConfig = some [values, indices] ∧
      apply G .argmaxFinish [values, indices] finishConfig = some [token] ∧
      token.dtype = .uint32 ∧ token.shape = [1] ∧ token.elems 0 = Sampling.GreedySampling.sample p logits := by
  obtain ⟨hLg, hS⟩ := Metal.Bridge.Argmax.decodes_of_values p logits l s hl hs
  have he := Metal.Bridge.Argmax.gpu_model C l.storageByte s.storageByte G hmaxP hmaxF 16 16 16 16 (by decide)
    (by decide) (by decide) (by decide) p primitive logits bound hLg hS
  obtain ⟨outs, hP, hF⟩ := Option.bind_eq_some_iff.mp he
  obtain ⟨V, X, rfl⟩ : ∃ V X, outs = [V, X] := by
    match outs, hF with
    | [V, X], _ => exact ⟨V, X, rfl⟩
  have ht : launchText .argmaxPartial [l, s] partialConfig = some Metal.Elab.Tests.argmaxPartialText := by
    show Assemble.Tests.launch .argmaxPartial chars!"normalized_argmax_partial"
      [⟨chars!"logits", l.dtype, l.shape⟩, ⟨chars!"lse", s.dtype, s.shape⟩] [chars!"values", chars!"indices"]
      partialConfig = _
    rw [hl.1, hl.2.1, hs.1, hs.2.1]
    exact Assemble.Tests.argmaxPartial_assemble
  have hb : [l, s].map buffer = [⟨.device, 496640, 16, l.storageByte⟩, ⟨.constant, 2, 16, s.storageByte⟩] := by
    show [buffer l, buffer s] = _
    rw [buffer_of hl.1 hl.2.1, buffer_of hs.1 hs.2.1]
    rfl
  let values := readOutput V ([1,243], .float32)
  let indices := readOutput X ([1,243], .uint32)
  have htF : launchText .argmaxFinish [values, indices] finishConfig = some Metal.Elab.Tests.argmaxFinishText :=
    Assemble.Tests.argmaxFinish_assemble
  have hbF : [values, indices].map buffer = [⟨.device, 972, 16, V⟩, ⟨.device, 972, 16, X⟩] := by
    show [buffer values, buffer indices] = _
    rw [buffer_of (v := values) rfl rfl, buffer_of (v := indices) rfl rfl,
      readOutput_storage_word V _ .float32 rfl, readOutput_storage_word X _ .uint32 rfl]
    rfl
  obtain ⟨sel, hsel, -⟩ := (Sampling.GreedySampling.correct p primitive logits bound).2.2
  refine ⟨values, indices, readOutput (Metal.Bridge.Argmax.tokenBytes (Sampling.GreedySampling.sample p logits)) ([1], .uint32),
    apply_some G rfl rfl ht (by rw [hb]; exact hP) rfl, apply_some G rfl rfl htF (by rw [hbF]; exact hF) rfl, rfl, rfl, ?_⟩
  rw [readOutput_word _ _ .uint32 rfl]
  exact Metal.Bridge.Argmax.readback _ (by rw [hsel]; have := sel.isLt; omega)

end Kernels


section Kernels2
variable {C : M1Max.Contract} (G : Gpu C)

/-- The compiler's choices at gated_delta_step's three contraction sites (`Bridge.GatedDeltaStep.Fuses`). -/
def deltaFlags : Delta.Gated.Contraction :=
  ⟨G.fusion Metal.Elab.Tests.gatedDeltaStepText 1, G.fusion Metal.Elab.Tests.gatedDeltaStepText 3,
    G.fusion Metal.Elab.Tests.gatedDeltaStepText 4⟩

/-- gated_delta_step (no mask, T = 1). -/
theorem gatedDelta (hmax : 128 ≤ G.maxThreads Metal.Elab.Tests.gatedDeltaStepText)
    (reduce : (Fin 32 → Float32) → Float32) (reduction : FlushedReduction.SimdContract reduce)
    (initial : Delta.GatedDevice.State) (values : Delta.GatedInputs.Values) (q k v g beta s : Value)
    (hr : reduce = C.simdSum)
    (hq : Flat q [1,1,16,128] (Delta.GatedInputs.flatten values.query))
    (hk : Flat k [1,1,16,128] (Delta.GatedInputs.flatten values.key))
    (hv : Flat v [1,1,48,128] (Delta.GatedInputs.flatten values.value)) (hg : FlatF32 g [1,1,48] values.decay)
    (hb : Flat beta [1,1,48] values.beta)
    (hs : s.dtype = .float32 ∧ s.shape = [1,48,128,128] ∧
      ∀ h r c, f32 (s.elems (Delta.GatedStores.stateIndex h r c)) = initial h r c)
    (hf : ∀ h r, Arithmetic.Finite (Delta.Recurrence.bind (initial h r) (values.inputs h r))
      (Delta.Gated.outputExpr (deltaFlags G) reduction.tree)) :
    ∃ y s', apply G .gatedDeltaStep [q, k, v, g, beta, s, ⟨.int32, [1], fun _ => 1⟩] gatedConfig = some [y, s'] ∧
      Tensor4 y 1 48 128 (fun _ => Delta.GatedDevice.producedOutput C.simdSum (deltaFlags G) initial values.inputs) ∧
      s'.dtype = .float32 ∧ s'.shape = [1,48,128,128] ∧
      ∀ h r c, f32 (s'.elems (Delta.GatedStores.stateIndex h r c)) =
        Delta.GatedDevice.producedState C.simdSum (deltaFlags G) initial values.inputs h r c := by
  subst hr
  let T : Value := ⟨.int32, [1], fun _ => 1⟩
  have hd := Metal.Bridge.GatedDeltaStep.decodes_of_values T.storageByte hq hk hv hg hb hs
  have hT : T.storageByte 0 = 1 ∧ T.storageByte 1 = 0 ∧ T.storageByte 2 = 0 ∧ T.storageByte 3 = 0 := by decide
  obtain ⟨h1, h2⟩ := Metal.Bridge.GatedDeltaStep.outputs_tree reduction hd (fuse := G.fusion Metal.Elab.Tests.gatedDeltaStepText) ⟨rfl, rfl, rfl⟩ hf
  have he := Metal.Kernels.GatedDeltaStep.gpu_output C G hmax q.storageByte k.storageByte v.storageByte g.storageByte
    beta.storageByte s.storageByte T.storageByte 16 16 16 16 16 16 16 (by decide) (by decide) (by decide) (by decide)
    (by decide) (by decide) (by decide) hT
  rw [h1, h2] at he
  have ht : launchText .gatedDeltaStep [q, k, v, g, beta, s, T] gatedConfig = some Metal.Elab.Tests.gatedDeltaStepText := by
    show Assemble.Tests.launch .gatedDeltaStep chars!"gated_delta_step"
      [⟨chars!"q", q.dtype, q.shape⟩, ⟨chars!"k", k.dtype, k.shape⟩, ⟨chars!"v", v.dtype, v.shape⟩,
        ⟨chars!"g", g.dtype, g.shape⟩, ⟨chars!"beta", beta.dtype, beta.shape⟩, ⟨chars!"state_in", s.dtype, s.shape⟩,
        ⟨chars!"Tin", .int32, [1]⟩] [chars!"y", chars!"state_out"] gatedConfig = _
    rw [hq.1, hq.2.1, hk.1, hk.2.1, hv.1, hv.2.1, hg.1, hg.2.1, hb.1, hb.2.1, hs.1, hs.2.1]
    exact Assemble.Tests.gatedDeltaStep_assemble
  have hbuf : [q, k, v, g, beta, s, T].map buffer =
      [⟨.device, 4096, 16, q.storageByte⟩, ⟨.device, 4096, 16, k.storageByte⟩, ⟨.device, 12288, 16, v.storageByte⟩,
        ⟨.device, 192, 16, g.storageByte⟩, ⟨.device, 96, 16, beta.storageByte⟩, ⟨.device, 3145728, 16, s.storageByte⟩,
        ⟨.constant, 4, 16, T.storageByte⟩] := by
    show [buffer q, buffer k, buffer v, buffer g, buffer beta, buffer s, buffer T] = _
    rw [buffer_of hq.1 hq.2.1, buffer_of hk.1 hk.2.1, buffer_of hv.1 hv.2.1, buffer_of hg.1 hg.2.1,
      buffer_of hb.1 hb.2.1, buffer_of hs.1 hs.2.1, buffer_of (v := T) rfl rfl]
    rfl
  obtain ⟨ty, ts⟩ := Metal.Bridge.GatedDeltaStep.readback C (deltaFlags G) initial values
  refine ⟨_, _, apply_some G rfl rfl ht (by rw [hbuf]; exact he) rfl, ?_, rfl, rfl, ?_⟩
  · rw [readOutput_half]; exact ty
  · rw [readOutput_word _ _ .float32 rfl]; exact ts

end Kernels2

/-! ## The Trellis MLP: gate-up, down partial, fold

The route's gate and up widths are each 2, 3 or 4 (`TrellisCodebookGateUp.Projection.validWidth`); the kernel
file proves the text's elaboration for seven of the nine pairs, these two complete them. -/

section Trellis
open Metal.Bridge.Trellis Metal.Kernels.Trellis

theorem buffer_device {v : Value} {d : Dtype} {shape : List Nat} (hd : v.dtype = d) (hs : v.shape = shape) {n : Nat}
    (hn : shape.foldr (· * ·) 1 * d.bytes = n) (h8 : ¬ shape.foldr (· * ·) 1 < Assemble.maxConstantArraySize) :
    buffer v = ⟨.device, n, 16, v.storageByte⟩ := by
  rw [buffer_of hd hs, if_neg h8, hn]

variable {C : M1Max.Contract} (G : Gpu C)

/-- The three Trellis launches (gate-up, down partial on its read-back `mid`, fold on the read-back `partial`). -/
theorem trellis (mlp : GateDown) (hmax1 : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text mlp.gate.width mlp.up.width))
    (hmax2 : 256 ≤ G.maxThreads (Metal.Kernels.DownPartial.text mlp.down.width))
    (hmax3 : 256 ≤ G.maxThreads Metal.Elab.Tests.downFoldText) (input : Fin 5120 → BF) (x gc gs uc us dc ds : Value)
    (gateReduce : mlp.gatePlatform.reduce = C.simdSum) (downReduce : mlp.downPlatform.reduce = C.simdSum)
    (activation : mlp.activation = trellisActivation C mlp.gate.width mlp.up.width)
    (weights : Trellis mlp gc gs uc us dc ds) (hx : Flat x [1,5120] input) (hf : TrellisMlp.Finite mlp (Blocks.packed input)) :
    ∃ mid part out, apply G .gateUp [x, gc, gs, uc, us] (gateUpConfig mlp.gate.width mlp.up.width) = some [mid] ∧
      apply G .downPartial [mid, dc, ds] (downConfig mlp.down.width) = some [part] ∧
      apply G .downFold [part] foldConfig = some [out] ∧
      mid.shape = [1,17408] ∧ Flat out [1,5120] (mlp.forward (Blocks.packed input)) := by
  have hd := gateUp_decodes_of_values mlp input x gc gs uc us dc ds weights hx
  have hdn := down_decodes_of_values mlp gc gs uc us dc ds weights
  have hg := mlp.gate.validWidth
  have hu := mlp.up.validWidth
  have hk := mlp.down.validWidth
  -- gate-up
  have e1 : G.execute (Metal.Kernels.GateUp.text mlp.gate.width mlp.up.width) (1024, 160, 1) (1024, 1, 1)
      [⟨.device, 10240, 16, x.storageByte⟩, ⟨.device, Metal.Kernels.GateUp.codesBytes mlp.gate.width, 16, gc.storageByte⟩,
        ⟨.device, 34816, 16, gs.storageByte⟩, ⟨.device, Metal.Kernels.GateUp.codesBytes mlp.up.width, 16, uc.storageByte⟩,
        ⟨.device, 34816, 16, us.storageByte⟩] [34816] = some [midBytes mlp input] := by
    rw [Metal.Kernels.GateUp.gpu_output_of C _ _ _ (width_of hg) (width_of hu) _ (gateUp_compiles hg hu) G hmax1
      _ _ _ _ _ 16 16 16 16 16 (by decide) (by decide) (by decide) (by decide) (by decide)]
    congr 2
    funext b
    unfold Metal.Kernels.GateUp.expected midBytes
    by_cases hb : b < 34816
    · rw [ite_eq_left hb, ite_eq_left hb, mid_value C mlp input _ _ _ _ _ hd gateReduce activation hf (b / 2) (by omega)]
    · rw [ite_eq_right hb, ite_eq_right hb]
  have ht1 : launchText .gateUp [x, gc, gs, uc, us] (gateUpConfig mlp.gate.width mlp.up.width) =
      some (Metal.Kernels.GateUp.text mlp.gate.width mlp.up.width) := by
    show Assemble.Tests.launch .gateUp (kernelName .gateUp)
      [⟨chars!"x", x.dtype, x.shape⟩, ⟨chars!"gcodes", gc.dtype, gc.shape⟩, ⟨chars!"gscales", gs.dtype, gs.shape⟩,
        ⟨chars!"ucodes", uc.dtype, uc.shape⟩, ⟨chars!"uscales", us.dtype, us.shape⟩] (outputNames .gateUp) _ = _
    rw [hx.1, hx.2.1, weights.gateCodes.1, weights.gateCodes.2, weights.scales.1, weights.scales.2.1,
      weights.upCodes.1, weights.upCodes.2, weights.scales.2.2.1, weights.scales.2.2.2.1]
    exact gateUp_launch hg hu
  have hb1 : [x, gc, gs, uc, us].map buffer =
      [⟨.device, 10240, 16, x.storageByte⟩, ⟨.device, Metal.Kernels.GateUp.codesBytes mlp.gate.width, 16, gc.storageByte⟩,
        ⟨.device, 34816, 16, gs.storageByte⟩, ⟨.device, Metal.Kernels.GateUp.codesBytes mlp.up.width, 16, uc.storageByte⟩,
        ⟨.device, 34816, 16, us.storageByte⟩] := by
    show [buffer x, buffer gc, buffer gs, buffer uc, buffer us] = _
    rw [buffer_device (n := 10240) hx.1 hx.2.1 (by decide) (by decide),
      buffer_device (n := Metal.Kernels.GateUp.codesBytes mlp.gate.width) weights.gateCodes.1 weights.gateCodes.2
        (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes, Metal.Kernels.GateUp.codesBytes]; omega)
        (by simp only [List.foldr_cons, List.foldr_nil, Assemble.maxConstantArraySize]; omega),
      buffer_device (n := 34816) weights.scales.1 weights.scales.2.1 (by decide) (by decide),
      buffer_device (n := Metal.Kernels.GateUp.codesBytes mlp.up.width) weights.upCodes.1 weights.upCodes.2
        (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes, Metal.Kernels.GateUp.codesBytes]; omega)
        (by simp only [List.foldr_cons, List.foldr_nil, Assemble.maxConstantArraySize]; omega),
      buffer_device (n := 34816) weights.scales.2.2.1 weights.scales.2.2.2.1 (by decide) (by decide)]
  -- down partial on the read-back mid
  let mid := readOutput (midBytes mlp input) ([1,17408], .bfloat16)
  have hM : ∀ r < 17408, C.widen (Val.ofBf16Bits (half (midBytes mlp input) r)) =
      mlp.intermediate (Blocks.packed input) r := by
    intro r hr
    obtain ⟨he, hfin⟩ := mid_eq C mlp input _ _ _ _ _ hd gateReduce activation hf r hr
    rw [half_midBytes mlp input r hr, ofBf16Bits_bf16Bits, ← mid_value C mlp input _ _ _ _ _ hd gateReduce activation hf r hr,
      C.widen_model _ hfin, he]
  have e2 := gpu_downPartial G mlp.downPlatform mlp.down _ (midBytes mlp input) dc.storageByte ds.storageByte 16 16 16
    hmax2 (by decide) (by decide) (by decide) hM hdn hf.down
  have ht2 : launchText .downPartial [mid, dc, ds] (downConfig mlp.down.width) =
      some (Metal.Kernels.DownPartial.text mlp.down.width) := by
    show Assemble.Tests.launch .downPartial (kernelName .downPartial)
      [⟨chars!"x", .bfloat16, [1, 17408]⟩, ⟨chars!"codes", dc.dtype, dc.shape⟩, ⟨chars!"scales", ds.dtype, ds.shape⟩]
      (outputNames .downPartial) _ = _
    rw [weights.downCodes.1, weights.downCodes.2, weights.scales.2.2.2.2.1, weights.scales.2.2.2.2.2, ← downPartial_launch hk]
    unfold Metal.Kernels.DownPartial.inputs
    by_cases h3 : mlp.down.width = 3
    · rw [if_pos h3, if_pos h3]; rfl
    · rw [if_neg h3, if_neg h3]; rfl
  have hdc : buffer dc = ⟨.device, Metal.Kernels.DownPartial.codesBytes mlp.down.width, 16, dc.storageByte⟩ := by
    by_cases h3 : mlp.down.width = 3
    · exact buffer_device (n := Metal.Kernels.DownPartial.codesBytes mlp.down.width) weights.downCodes.1
        (weights.downCodes.2.trans (if_pos h3)) (by rw [h3]; rfl) (by decide)
    · exact buffer_device (n := Metal.Kernels.DownPartial.codesBytes mlp.down.width) weights.downCodes.1
        (weights.downCodes.2.trans (if_neg h3))
        (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes, Metal.Kernels.DownPartial.codesBytes]; omega)
        (by simp only [List.foldr_cons, List.foldr_nil, Assemble.maxConstantArraySize]; omega)
  have hb2 : [mid, dc, ds].map buffer =
      [⟨.device, 34816, 16, midBytes mlp input⟩, ⟨.device, Metal.Kernels.DownPartial.codesBytes mlp.down.width, 16, dc.storageByte⟩,
        ⟨.device, 34816, 16, ds.storageByte⟩] := by
    show [buffer mid, buffer dc, buffer ds] = _
    rw [buffer_device (v := mid) (d := .bfloat16) (shape := [1, 17408]) (n := 34816) rfl rfl (by decide) (by decide), readOutput_storage_half, hdc,
      buffer_device (n := 34816) weights.scales.2.2.2.2.1 weights.scales.2.2.2.2.2 (by decide) (by decide)]
  -- the fold on the read-back partial
  let part := readOutput (partBytes (partialModel mlp input)) ([1,32,5120], .float32)
  have e3 := gpu_downFold G hmax3 mlp.downPlatform mlp.down _ downReduce hf.down
  have hb3 : [part].map buffer = [⟨.device, 655360, 16, partBytes (partialModel mlp input)⟩] := by
    show [buffer part] = _
    rw [buffer_device (v := part) (d := .float32) (shape := [1, 32, 5120]) (n := 655360) rfl rfl (by decide) (by decide), readOutput_storage_word _ _ .float32 rfl]
  have ht3 : launchText .downFold [part] foldConfig = some Metal.Elab.Tests.downFoldText :=
    Assemble.Tests.downFold_assemble
  refine ⟨mid, part, readOutput (Metal.Bridge.DownFold.foldBytes (mlp.forward (Blocks.packed input))) ([1,5120], .bfloat16),
    apply_some G rfl rfl ht1 (by rw [hb1]; exact e1) rfl, apply_some G rfl rfl ht2 (by rw [hb2]; exact e2) rfl,
    apply_some G rfl rfl ht3 (by rw [hb3]; exact e3) rfl, rfl, ?_⟩
  rw [readOutput_half]
  exact Metal.Bridge.DownFold.readback _

end Trellis

/-! ## affine_row

One text per (bits, K steps, N rows): `Metal.Kernels.AffineRow.text bits steps (rows / 64)`. Its platform is
`C.rowPlatformAt` at the compiler's choices of that text: sites 2–11 (3 bits, `sites3`) or 12–14 (4 bits,
`sites4`) for the tile's dot and site 15 for its tail. -/

section Affine
open Metal.Bridge.AffineRow

def affineText (bits steps rows : Nat) : List Char := Metal.Kernels.AffineRow.text bits steps (rows / 64)

variable {C : M1Max.Contract} (G : Gpu C)

def affineSites (bits steps rows : Nat) : Nat → Bool :=
  if bits = 3 then sites3 (G.fusion (affineText bits steps rows)) else sites4 (G.fusion (affineText bits steps rows))

def affineTailOf (bits steps rows : Nat) : Bool := G.fusion (affineText bits steps rows) 15

theorem rowBytes_row {rows : Nat} (f : Fin rows → BF) : Row (halfArray (rowBytes f) 0 [1,1,rows]) rows f :=
  Row.mk rfl rfl fun j => by
    rw [GlueKernels.half_read, Nat.zero_add]
    refine Metal.Bridge.General.half_readback _ _ _ fun k hk => ?_
    unfold rowBytes
    rw [dite_eq_left (by omega), show (2 * j.val + k) % 2 = k by omega]
    congr 4
    exact Fin.ext (by simp only; omega)

theorem affineConfig_grid (steps blocks bits : Nat) :
    (affineConfig (steps*512) (4*(blocks*16)) bits).grid = (32, 16 * blocks, 1) := by
  simp only [affineConfig, Prod.mk.injEq, true_and, and_true]
  omega

theorem affineConfig_sizes (steps blocks bits : Nat) :
    (affineConfig (steps*512) (4*(blocks*16)) bits).outputs.map outputSize = [2 * (64 * blocks)] := by
  simp only [affineConfig, outputSize, List.map_cons, List.map_nil, List.foldr_cons, List.foldr_nil, Dtype.bytes,
    List.cons.injEq, and_true]
  ring

theorem affine_buffers {steps blocks : Nat} (hst : 0 < steps) (hbk : 0 < blocks) (wcols : Nat) (hwc : 0 < wcols)
    {x w scales biases : Value} (hx : x.dtype = .bfloat16 ∧ x.shape = [1,1,steps*512])
    (hw : w.dtype = .uint32 ∧ w.shape = [4*(blocks*16), steps*wcols])
    (hs : scales.dtype = .bfloat16 ∧ scales.shape = [4*(blocks*16), steps*8])
    (hb : biases.dtype = .bfloat16 ∧ biases.shape = [4*(blocks*16), steps*8]) :
    [x, w, scales, biases].map buffer =
      [⟨.device, 2 * (512 * steps), 16, x.storageByte⟩, ⟨.device, 4 * (64 * blocks * (wcols * steps)), 16, w.storageByte⟩,
        ⟨.device, 2 * (64 * blocks * (8 * steps)), 16, scales.storageByte⟩,
        ⟨.device, 2 * (64 * blocks * (8 * steps)), 16, biases.storageByte⟩] := by
  have hbs : 0 < blocks * steps := Nat.mul_pos hbk hst
  have hbsw : 0 < blocks * steps * wcols := Nat.mul_pos hbs hwc
  show [buffer x, buffer w, buffer scales, buffer biases] = _
  rw [buffer_device (n := 2 * (512 * steps)) hx.1 hx.2 (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes]; ring)
      (by simp only [List.foldr_cons, List.foldr_nil, Assemble.maxConstantArraySize]; omega),
    buffer_device (n := 4 * (64 * blocks * (wcols * steps))) hw.1 hw.2 (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes]; ring)
      (by simp only [List.foldr_cons, List.foldr_nil, Assemble.maxConstantArraySize]; nlinarith),
    buffer_device (n := 2 * (64 * blocks * (8 * steps))) hs.1 hs.2 (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes]; ring)
      (by simp only [List.foldr_cons, List.foldr_nil, Assemble.maxConstantArraySize]; nlinarith),
    buffer_device (n := 2 * (64 * blocks * (8 * steps))) hb.1 hb.2 (by simp only [List.foldr_cons, List.foldr_nil, Dtype.bytes]; ring)
      (by simp only [List.foldr_cons, List.foldr_nil, Assemble.maxConstantArraySize]; nlinarith)]

theorem affine_launch {bits steps blocks wcols : Nat} (hwc : steps * wcols = steps * 512 * bits / 32)
    (ha : Metal.Kernels.AffineRow.assembled bits steps blocks = some (Metal.Kernels.AffineRow.text bits steps blocks))
    {x w scales biases : Value} (hx : x.dtype = .bfloat16 ∧ x.shape = [1,1,steps*512])
    (hw : w.dtype = .uint32 ∧ w.shape = [4*(blocks*16), steps*wcols])
    (hs : scales.dtype = .bfloat16 ∧ scales.shape = [4*(blocks*16), steps*8])
    (hb : biases.dtype = .bfloat16 ∧ biases.shape = [4*(blocks*16), steps*8]) :
    launchText .affineRow [x, w, scales, biases] (affineConfig (steps*512) (4*(blocks*16)) bits) =
      some (Metal.Kernels.AffineRow.text bits steps blocks) := by
  show Assemble.Tests.launch .affineRow (kernelName .affineRow)
    [⟨chars!"x", x.dtype, x.shape⟩, ⟨chars!"w", w.dtype, w.shape⟩, ⟨chars!"scales", scales.dtype, scales.shape⟩,
      ⟨chars!"biases", biases.dtype, biases.shape⟩] (outputNames .affineRow) _ = _
  rw [hx.1, hx.2, hw.1, hw.2, hs.1, hs.2, hb.1, hb.2, hwc, show 4 * (blocks * 16) = blocks * 64 by omega,
    show steps * 8 = steps * 512 / 64 by omega]
  exact ha

theorem affineRow3_of {steps blocks : Nat}
    (hc : (frontend (Metal.Kernels.AffineRow.text 3 steps blocks)).bind elaborate = some (Metal.Kernels.AffineRow.core3 steps))
    (ha : Metal.Kernels.AffineRow.assembled 3 steps blocks = some (Metal.Kernels.AffineRow.text 3 steps blocks))
    (hmax : 512 ≤ G.maxThreads (Metal.Kernels.AffineRow.text 3 steps blocks)) (hst : 0 < steps) (hbk : 0 < blocks)
    (hW : 64 * blocks * (192 * steps) < 2 ^ 31) (p : AffineVerifyLinear.Projection3 steps (4*(blocks*16)))
    (input : Fin (steps*512) → BF) (x w scales biases : Value)
    (hp : p.platform = C.rowPlatformAt (sites3 (G.fusion (Metal.Kernels.AffineRow.text 3 steps blocks)))
      (G.fusion (Metal.Kernels.AffineRow.text 3 steps blocks) 15))
    (hx : Row x (steps*512) input) (hw : Affine3 p w scales biases) (hf : p.Finite input) :
    ∃ y, apply G .affineRow [x, w, scales, biases] (affineConfig (steps*512) (4*(blocks*16)) 3) = some [y] ∧
      Row y (4*(blocks*16)) (p.forward input) := by
  have he := gpu_model3 G _ steps blocks hc hmax hst hbk hW x.storageByte w.storageByte scales.storageByte
    biases.storageByte 16 16 16 16 (by decide) (by decide) (by decide) p input hp
    (decodes3_of_values p input x w scales biases hx hw) hf
  refine ⟨_, apply_some G rfl rfl
    (affine_launch (wcols := 48) (by omega) ha ⟨hx.1, hx.2.1⟩ hw.words ⟨hw.groups.1, hw.groups.2.1⟩ hw.groups.2.2)
    (by rw [affineConfig_grid, affineConfig_sizes, affine_buffers hst hbk 48 (by decide) ⟨hx.1, hx.2.1⟩ hw.words
      ⟨hw.groups.1, hw.groups.2.1⟩ hw.groups.2.2]; exact he) rfl, ?_⟩
  show Row (readOutput _ ([1,1,4*(blocks*16)], .bfloat16)) _ _
  rw [readOutput_half]
  exact rowBytes_row _

theorem affineRow4_of {steps blocks : Nat}
    (hc : (frontend (Metal.Kernels.AffineRow.text 4 steps blocks)).bind elaborate = some (Metal.Kernels.AffineRow.core4 steps))
    (ha : Metal.Kernels.AffineRow.assembled 4 steps blocks = some (Metal.Kernels.AffineRow.text 4 steps blocks))
    (hmax : 512 ≤ G.maxThreads (Metal.Kernels.AffineRow.text 4 steps blocks)) (hst : 0 < steps) (hbk : 0 < blocks)
    (hW : 64 * blocks * (256 * steps) < 2 ^ 31) (p : AffineVerifyLinear.Projection4 steps (4*(blocks*16)))
    (input : Fin (steps*512) → BF) (x w scales biases : Value)
    (hp : p.platform = C.rowPlatformAt (sites4 (G.fusion (Metal.Kernels.AffineRow.text 4 steps blocks)))
      (G.fusion (Metal.Kernels.AffineRow.text 4 steps blocks) 15))
    (hx : Row x (steps*512) input) (hw : Affine4 p w scales biases) (hf : p.Finite input) :
    ∃ y, apply G .affineRow [x, w, scales, biases] (affineConfig (steps*512) (4*(blocks*16)) 4) = some [y] ∧
      Row y (4*(blocks*16)) (p.forward input) := by
  have he := gpu_model4 G _ steps blocks hc hmax hst hbk hW x.storageByte w.storageByte scales.storageByte
    biases.storageByte 16 16 16 16 (by decide) (by decide) (by decide) (by decide) p input hp
    (decodes4_of_values p input x w scales biases hx hw) hf
  refine ⟨_, apply_some G rfl rfl
    (affine_launch (wcols := 64) (by omega) ha ⟨hx.1, hx.2.1⟩ hw.words ⟨hw.groups.1, hw.groups.2.1⟩ hw.groups.2.2)
    (by rw [affineConfig_grid, affineConfig_sizes, affine_buffers hst hbk 64 (by decide) ⟨hx.1, hx.2.1⟩ hw.words
      ⟨hw.groups.1, hw.groups.2.1⟩ hw.groups.2.2]; exact he) rfl, ?_⟩
  show Row (readOutput _ ([1,1,4*(blocks*16)], .bfloat16)) _ _
  rw [readOutput_half]
  exact rowBytes_row _

end Affine

/-! ## The pipelines' threadgroup limits

What each route text's pipeline must admit (custom_kernel.cpp:84-91, `Gpu.maxThreads`): the threads per threadgroup
of its launch. Device facts; the GPU probe checks them. -/

structure RoutePipelines {C : M1Max.Contract} (G : Gpu C) : Prop where
  affine_3_10_160 : 512 ≤ G.maxThreads (Metal.Kernels.AffineRow.text 3 10 160)
  affine_3_10_96 : 512 ≤ G.maxThreads (Metal.Kernels.AffineRow.text 3 10 96)
  affine_3_12_80 : 512 ≤ G.maxThreads (Metal.Kernels.AffineRow.text 3 12 80)
  affine_3_10_3880 : 512 ≤ G.maxThreads (Metal.Kernels.AffineRow.text 3 10 3880)
  affine_4_10_160 : 512 ≤ G.maxThreads (Metal.Kernels.AffineRow.text 4 10 160)
  affine_4_10_96 : 512 ≤ G.maxThreads (Metal.Kernels.AffineRow.text 4 10 96)
  affine_4_12_80 : 512 ≤ G.maxThreads (Metal.Kernels.AffineRow.text 4 12 80)
  affine_4_10_3880 : 512 ≤ G.maxThreads (Metal.Kernels.AffineRow.text 4 10 3880)
  siluRmsHeads : 32 ≤ G.maxThreads Metal.Elab.Tests.siluRmsHeadsText
  gatedDeltaStep : 128 ≤ G.maxThreads Metal.Elab.Tests.gatedDeltaStepText
  gatedRmsNorm : 32 ≤ G.maxThreads Metal.Elab.Tests.gatedRmsNormText
  residualRmsNorm : 1024 ≤ G.maxThreads Metal.Elab.Tests.residualRmsNormText
  gateUp_2_2 : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text 2 2)
  gateUp_2_3 : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text 2 3)
  gateUp_2_4 : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text 2 4)
  gateUp_3_2 : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text 3 2)
  gateUp_3_3 : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text 3 3)
  gateUp_3_4 : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text 3 4)
  gateUp_4_2 : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text 4 2)
  gateUp_4_3 : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text 4 3)
  gateUp_4_4 : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text 4 4)
  downPartial_2 : 256 ≤ G.maxThreads (Metal.Kernels.DownPartial.text 2)
  downPartial_3 : 256 ≤ G.maxThreads (Metal.Kernels.DownPartial.text 3)
  downPartial_4 : 256 ≤ G.maxThreads (Metal.Kernels.DownPartial.text 4)
  downFold : 256 ≤ G.maxThreads Metal.Elab.Tests.downFoldText
  argmaxPartial : 128 ≤ G.maxThreads Metal.Elab.Tests.argmaxPartialText
  argmaxFinish : 128 ≤ G.maxThreads Metal.Elab.Tests.argmaxFinishText
  -- The prefill kernels (prefill-map §3–4): one fact per text the route assembles.
  rows3_2_10240_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows3.text 2 10240 5120)
  rows3_2_6144_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows3.text 2 6144 5120)
  rows3_2_5120_6144 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows3.text 2 5120 6144)
  rows3_3_10240_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows3.text 3 10240 5120)
  rows3_3_6144_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows3.text 3 6144 5120)
  rows3_3_5120_6144 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows3.text 3 5120 6144)
  rows4_2_10240_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows4.text 2 10240 5120)
  rows4_2_6144_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows4.text 2 6144 5120)
  rows4_2_48_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows4.text 2 48 5120)
  rows4_2_5120_6144 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows4.text 2 5120 6144)
  rows4_2_12288_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows4.text 2 12288 5120)
  rows4_2_1024_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows4.text 2 1024 5120)
  rows4_3_10240_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows4.text 3 10240 5120)
  rows4_3_6144_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows4.text 3 6144 5120)
  rows4_3_48_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows4.text 3 48 5120)
  rows4_3_5120_6144 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows4.text 3 5120 6144)
  rows4_3_12288_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows4.text 3 12288 5120)
  rows4_3_1024_5120 : 64 ≤ G.maxThreads (Metal.Kernels.AffineRows4.text 3 1024 5120)
  split_10240_5120_3 : 64 ≤ G.maxThreads (Metal.Kernels.AffineSplitMma.text 10240 5120 3 2 2)
  split_10240_5120_4 : 64 ≤ G.maxThreads (Metal.Kernels.AffineSplitMma.text 10240 5120 4 2 2)
  split_6144_5120_3 : 64 ≤ G.maxThreads (Metal.Kernels.AffineSplitMma.text 6144 5120 3 2 2)
  split_6144_5120_4 : 64 ≤ G.maxThreads (Metal.Kernels.AffineSplitMma.text 6144 5120 4 2 2)
  split_48_5120_4 : 256 ≤ G.maxThreads (Metal.Kernels.AffineSplitMma.text 48 5120 4 1 8)
  split_5120_6144_3 : 64 ≤ G.maxThreads (Metal.Kernels.AffineSplitMma.text 5120 6144 3 2 2)
  split_5120_6144_4 : 64 ≤ G.maxThreads (Metal.Kernels.AffineSplitMma.text 5120 6144 4 2 2)
  split_12288_5120_4 : 64 ≤ G.maxThreads (Metal.Kernels.AffineSplitMma.text 12288 5120 4 2 2)
  split_1024_5120_4 : 256 ≤ G.maxThreads (Metal.Kernels.AffineSplitMma.text 1024 5120 4 1 8)
  codebook_2_2 : 128 ≤ G.maxThreads (Metal.Kernels.GateUpCodebookMma.text 2 2)
  codebook_3_3 : 128 ≤ G.maxThreads (Metal.Kernels.GateUpCodebookMma.text 3 3)
  codebook_3_2 : 128 ≤ G.maxThreads (Metal.Kernels.GateUpCodebookMma.text 3 2)
  codebook_2_3 : 128 ≤ G.maxThreads (Metal.Kernels.GateUpCodebookMma.text 2 3)
  codebook_4_3 : 128 ≤ G.maxThreads (Metal.Kernels.GateUpCodebookMma.text 4 3)
  codebook_4_4 : 128 ≤ G.maxThreads (Metal.Kernels.GateUpCodebookMma.text 4 4)
  codebook_3_4 : 128 ≤ G.maxThreads (Metal.Kernels.GateUpCodebookMma.text 3 4)
  wide_2_2_2 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 2 2 2)
  wide_3_3_2 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 3 3 2)
  wide_3_2_2 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 3 2 2)
  wide_2_3_2 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 2 3 2)
  wide_4_3_2 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 4 3 2)
  wide_4_4_2 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 4 4 2)
  wide_3_4_2 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 3 4 2)
  wide_2_2_3 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 2 2 3)
  wide_3_3_3 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 3 3 3)
  wide_3_2_3 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 3 2 3)
  wide_2_3_3 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 2 3 3)
  wide_4_3_3 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 4 3 3)
  wide_4_4_3 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 4 4 3)
  wide_3_4_3 : 256 ≤ G.maxThreads (Metal.Kernels.GateUpMmaWide.text 3 4 3)
  down_2_16_1 : 128 ≤ G.maxThreads (Metal.Kernels.DownMmaWide.text 2 16 1 4)
  down_4_16_1 : 128 ≤ G.maxThreads (Metal.Kernels.DownMmaWide.text 4 16 1 6)
  down_2_8_2 : 128 ≤ G.maxThreads (Metal.Kernels.DownMmaWide.text 2 8 2 3)
  down_4_8_2 : 128 ≤ G.maxThreads (Metal.Kernels.DownMmaWide.text 4 8 2 4)
  down_2_8_3 : 128 ≤ G.maxThreads (Metal.Kernels.DownMmaWide.text 2 8 3 3)
  down_4_8_3 : 128 ≤ G.maxThreads (Metal.Kernels.DownMmaWide.text 4 8 3 4)
  downK3i : 128 ≤ G.maxThreads (Metal.Kernels.DownK3iMmaWide.text 3 16 1 5)
  fill_6144_2 : 128 ≤ G.maxThreads (Metal.Kernels.AneTrellisFill.text 6144 2 16)
  fill_6144_3 : 128 ≤ G.maxThreads (Metal.Kernels.AneTrellisFill.text 6144 3 16)
  fill_6144_4 : 128 ≤ G.maxThreads (Metal.Kernels.AneTrellisFill.text 6144 4 8)
  fill_6656_2 : 128 ≤ G.maxThreads (Metal.Kernels.AneTrellisFill.text 6656 2 16)
  fill_6656_3 : 128 ≤ G.maxThreads (Metal.Kernels.AneTrellisFill.text 6656 3 16)
  fill_6656_4 : 128 ≤ G.maxThreads (Metal.Kernels.AneTrellisFill.text 6656 4 8)
  fillK3i_6144 : 128 ≤ G.maxThreads (Metal.Kernels.AneTrellisFillK3i.text 6144)
  fillK3i_6656 : 128 ≤ G.maxThreads (Metal.Kernels.AneTrellisFillK3i.text 6656)
  -- the half writer's text for each element count: the hidden rows of the ANE forwards and the weight heads
  writeHalf_5120 : ∀ r, 224 ≤ r → r ≤ 2048 → 256 ≤ G.maxThreads (Metal.Kernels.AneWriteHalf.text (5120 * r))
  writeHalf_6144 : ∀ r, 224 ≤ r → r ≤ 2048 → 256 ≤ G.maxThreads (Metal.Kernels.AneWriteHalf.text (6144 * r))
  writeHalf_qkv : 256 ≤ G.maxThreads (Metal.Kernels.AneWriteHalf.text 19660800)
  writeHalf_zo : 256 ≤ G.maxThreads (Metal.Kernels.AneWriteHalf.text 11796480)
  writeHalf_q : 256 ≤ G.maxThreads (Metal.Kernels.AneWriteHalf.text 23592960)
  expand_11264_2 : 128 ≤ G.maxThreads (Metal.Kernels.VectorExpand.text 11264 2 0 0)
  expand_11264_3 : 128 ≤ G.maxThreads (Metal.Kernels.VectorExpand.text 11264 3 0 0)
  expand_11264_4 : 128 ≤ G.maxThreads (Metal.Kernels.VectorExpand.text 11264 4 0 0)
  expand_10752_2 : 128 ≤ G.maxThreads (Metal.Kernels.VectorExpand.text 10752 2 0 0)
  expand_10752_3 : 128 ≤ G.maxThreads (Metal.Kernels.VectorExpand.text 10752 3 0 0)
  expand_10752_4 : 128 ≤ G.maxThreads (Metal.Kernels.VectorExpand.text 10752 4 0 0)
  expand_11264_k3i : 128 ≤ G.maxThreads (Metal.Kernels.VectorExpand.text 11264 3 2 128)
  expand_10752_k3i : 128 ≤ G.maxThreads (Metal.Kernels.VectorExpand.text 10752 3 2 128)

section Contract
open Metal.Bridge.AffineRow
variable {C : M1Max.Contract} {G : Gpu C}

theorem RoutePipelines.gateUp (P : RoutePipelines G) {kg ku : Nat} (hg : kg = 2 ∨ kg = 3 ∨ kg = 4)
    (hu : ku = 2 ∨ ku = 3 ∨ ku = 4) : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text kg ku) := by
  rcases hg with rfl | rfl | rfl <;> rcases hu with rfl | rfl | rfl
  exacts [P.gateUp_2_2, P.gateUp_2_3, P.gateUp_2_4, P.gateUp_3_2, P.gateUp_3_3, P.gateUp_3_4, P.gateUp_4_2,
    P.gateUp_4_3, P.gateUp_4_4]

theorem RoutePipelines.downPartial (P : RoutePipelines G) {k : Nat} (hk : k = 2 ∨ k = 3 ∨ k = 4) :
    256 ≤ G.maxThreads (Metal.Kernels.DownPartial.text k) := by
  rcases hk with rfl | rfl | rfl
  exacts [P.downPartial_2, P.downPartial_3, P.downPartial_4]

theorem affineText_eq (bits steps blocks : Nat) :
    affineText bits steps (4*(blocks*16)) = Metal.Kernels.AffineRow.text bits steps blocks := by
  unfold affineText
  rw [show 4 * (blocks * 16) / 64 = blocks by omega]

theorem affine_route {steps blocks : Nat} (route : AffineRoute steps blocks) :
    (steps = 10 ∧ blocks = 160) ∨ (steps = 10 ∧ blocks = 96) ∨ (steps = 12 ∧ blocks = 80) ∨ (steps = 10 ∧ blocks = 3880) := by
  simpa [AffineRoute] using route

theorem affineRow3 (P : RoutePipelines G) {steps blocks : Nat} (p : AffineVerifyLinear.Projection3 steps (4*(blocks*16)))
    (input : Fin (steps*512) → BF) (x w scales biases : Value)
    (hp : p.platform = C.rowPlatformAt (affineSites G 3 steps (4*(blocks*16))) (affineTailOf G 3 steps (4*(blocks*16))))
    (hx : Row x (steps*512) input) (hw : Affine3 p w scales biases) (hf : p.Finite input) (route : AffineRoute steps blocks) :
    ∃ y, apply G .affineRow [x, w, scales, biases] (affineConfig (steps*512) (4*(blocks*16)) 3) = some [y] ∧
      Row y (4*(blocks*16)) (p.forward input) := by
  unfold affineSites affineTailOf at hp
  rw [if_pos rfl, affineText_eq] at hp
  rcases affine_route route with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · exact affineRow3_of G Metal.Kernels.AffineRow.compile_3_10_160 Metal.Kernels.AffineRow.assembled_route.1
      P.affine_3_10_160 (by decide) (by decide) (by decide) p input x w scales biases hp hx hw hf
  · exact affineRow3_of G Metal.Kernels.AffineRow.compile_3_10_96 Metal.Kernels.AffineRow.assembled_route.2.1
      P.affine_3_10_96 (by decide) (by decide) (by decide) p input x w scales biases hp hx hw hf
  · exact affineRow3_of G Metal.Kernels.AffineRow.compile_3_12_80 Metal.Kernels.AffineRow.assembled_route.2.2.1
      P.affine_3_12_80 (by decide) (by decide) (by decide) p input x w scales biases hp hx hw hf
  · exact affineRow3_of G affine_compile_3_10_3880 affine_assembled.2.2.2
      P.affine_3_10_3880 (by decide) (by decide) (by decide) p input x w scales biases hp hx hw hf

theorem affineRow4 (P : RoutePipelines G) {steps blocks : Nat} (p : AffineVerifyLinear.Projection4 steps (4*(blocks*16)))
    (input : Fin (steps*512) → BF) (x w scales biases : Value)
    (hp : p.platform = C.rowPlatformAt (affineSites G 4 steps (4*(blocks*16))) (affineTailOf G 4 steps (4*(blocks*16))))
    (hx : Row x (steps*512) input) (hw : Affine4 p w scales biases) (hf : p.Finite input) (route : AffineRoute steps blocks) :
    ∃ y, apply G .affineRow [x, w, scales, biases] (affineConfig (steps*512) (4*(blocks*16)) 4) = some [y] ∧
      Row y (4*(blocks*16)) (p.forward input) := by
  unfold affineSites affineTailOf at hp
  rw [if_neg (by decide), affineText_eq] at hp
  rcases affine_route route with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · exact affineRow4_of G affine_compile_4_10_160 affine_assembled.1
      P.affine_4_10_160 (by decide) (by decide) (by decide) p input x w scales biases hp hx hw hf
  · exact affineRow4_of G affine_compile_4_10_96 affine_assembled.2.1
      P.affine_4_10_96 (by decide) (by decide) (by decide) p input x w scales biases hp hx hw hf
  · exact affineRow4_of G affine_compile_4_12_80 affine_assembled.2.2.1
      P.affine_4_12_80 (by decide) (by decide) (by decide) p input x w scales biases hp hx hw hf
  · exact affineRow4_of G Metal.Kernels.AffineRow.compile_4_10_3880 Metal.Kernels.AffineRow.assembled_route.2.2.2
      P.affine_4_10_3880 (by decide) (by decide) (by decide) p input x w scales biases hp hx hw hf

variable (G)

/-- **The route's kernel contract, from the GPU assumption.** `apply` is MLX's launch run by `G`; the contraction
choices are `G.fusion` of each text and site; every field is proved from its kernel's Metal source. `lseSum` and
`lseNumerator` are the choices of MLX's native logsumexp (not a custom kernel), free. -/
def ofGpu (P : RoutePipelines G) (lseSum : Bool) (lseNumerator : Attention.SdpaUpdate.Contraction) : KernelContract C where
  apply := apply G
  affineContracted := affineSites G
  affineTail := affineTailOf G
  headsContracted := G.fusion Metal.Elab.Tests.siluRmsHeadsText 1
  flags := deltaFlags G
  gatedContracted := G.fusion Metal.Elab.Tests.gatedRmsNormText 1
  residualContracted := G.fusion Metal.Elab.Tests.residualRmsNormText 1
  lseSum := lseSum
  lseNumerator := lseNumerator
  affineRow3 := affineRow3 P
  affineRow4 := affineRow4 P
  siluRmsHeads := heads G P.siluRmsHeads
  gatedDeltaStep := gatedDelta G P.gatedDeltaStep
  gatedRmsNorm := gatedNorm G P.gatedRmsNorm
  residualRmsNorm := residualNorm G P.residualRmsNorm
  trellis mlp input x gc gs uc us dc ds gateReduce downReduce activation weights hx hf :=
    trellis G mlp (P.gateUp mlp.gate.validWidth mlp.up.validWidth) (P.downPartial mlp.down.validWidth) P.downFold
      input x gc gs uc us dc ds gateReduce downReduce activation weights hx hf
  argmax := argmax G P.argmaxPartial P.argmaxFinish _

end Contract

end Host.Mlx.KernelGpu
