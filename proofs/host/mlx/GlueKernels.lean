import host.mlx.Kernel
import kernels.delta.SiluHeads128Memory
import kernels.delta.GatedOutputSource
import kernels.normalization.GatedRms128OutputSource
import kernels.sampling.ArgmaxLaunchSourceMemory

namespace Host.Mlx.GlueKernels
open Inference Inference.Contracts.Mlx Inference.Kernels Inference.Layers
open Inference.Models.Qwen WrittenLayers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

/-! Value-level statements of the route's custom kernels: each launch
returns outputs encoding the model function, for every M1 Max execution the
contract admits. The heap readback theorems are the existing ones; the
parsed-source certificates are stated on the same execution. -/

variable {C : M1Max.Contract} (K : KernelContract C)

theorem half_read (memory : ByteMemory.Bytes) (base i : Nat) (shape : List Nat) :
    bf ((halfArray memory base shape).elems i) = (Model.ofBits (HalfMemory.load memory (base+2*i)) : BF) := bf_toNat _

theorem word_read (memory : ByteMemory.Bytes) (base i : Nat) (shape : List Nat) :
    f32 ((wordArray .float32 memory base shape).elems i) = FloatMemory.load memory (base+4*i) := f32_toNat _

/-! ## affine_row -/

theorem affine_row3 {steps blocks : Nat} (p : AffineVerifyLinear.Projection3 steps (4*(blocks*16)))
    (input : Fin (steps*512) → BF) (x w scales biases : Value) (hp : p.platform = K.affine)
    (hx : Row x (steps*512) input) (hw : Affine3 p w scales biases) (limit : blocks ≤ 3880) :
    ∃ y, K.apply .affineRow [x, w, scales, biases] (affineConfig (steps*512) (4*(blocks*16)) 3) = some [y] ∧
      Row y (4*(blocks*16)) (p.forward input) ∧
      ∃ e : AffineMemory.Execution3 p input, y = halfArray e.kernel.stores.memory e.kernel.base [1,1,4*(blocks*16)] ∧
        ∀ before, steps ≤ 15 → p.Finite input → AffineParsedSource3.Certificate e before := by
  obtain ⟨y, ha, e, rfl⟩ := K.affineRow3 p input x w scales biases hp hx hw
  exact ⟨_, ha, Row.mk rfl rfl fun j => (half_read _ _ _ _).trans (AffineParsedSource3.value_eq e limit j),
    e, rfl, fun before hs hf => AffineParsedSource3.checked e before hs limit hf⟩

theorem affine_row4 {steps blocks : Nat} (p : AffineVerifyLinear.Projection4 steps (4*(blocks*16)))
    (input : Fin (steps*512) → BF) (x w scales biases : Value) (hp : p.platform = K.affine)
    (hx : Row x (steps*512) input) (hw : Affine4 p w scales biases) (limit : blocks ≤ 3880) :
    ∃ y, K.apply .affineRow [x, w, scales, biases] (affineConfig (steps*512) (4*(blocks*16)) 4) = some [y] ∧
      Row y (4*(blocks*16)) (p.forward input) ∧
      ∃ e : AffineMemory.Execution4 p input, y = halfArray e.kernel.stores.memory e.kernel.base [1,1,4*(blocks*16)] ∧
        ∀ before, steps ≤ 15 → p.Finite input → AffineParsedSource4.Certificate e before := by
  obtain ⟨y, ha, e, rfl⟩ := K.affineRow4 p input x w scales biases hp hx hw
  exact ⟨_, ha, Row.mk rfl rfl fun j => (half_read _ _ _ _).trans (AffineParsedSource4.value_eq e limit j),
    e, rfl, fun before hs hf => AffineParsedSource4.checked e before hs limit hf⟩

/-! ## silu_rms_heads -/

theorem heads_tensor (memory : ByteMemory.Bytes) (base : Nat) (heads : Nat)
    (f : Fin heads → Fin 128 → BF) (read : ∀ h i, (Model.ofBits (HalfMemory.load memory (base+2*(h.val*128+i.val))) : BF) = f h i) :
    Tensor4 (halfArray memory base [1,1,heads,128]) 1 heads 128 (fun _ => f) :=
  Tensor4.mk rfl rfl fun a h i => by
    have : a.val = 0 := by omega
    rw [half_read]; simp only [this, Nat.zero_mul, Nat.zero_add]; exact read h i

theorem silu_rms_heads (values : Fin 10240 → BF) (qScale kScale : Fin 128 → BF) (x qs ks : Value)
    (hx : Row x 10240 values) (hq : GlueAttention.Vector qs 128 qScale) (hk : GlueAttention.Vector ks 128 kScale) :
    ∃ q k v, KernelClosure.eval K .siluRmsHeads [x, qs, ks] = some [q, k, v] ∧
      let out := DeltaHeads.forward K.heads (fun _ : Fin 1 => values) qScale kScale
        Delta.SiluHeads128Output.width Delta.SiluHeads128Output.epsilon
      Tensor4 q 1 16 128 (fun _ => out.q 0) ∧ Tensor4 k 1 16 128 (fun _ => out.k 0) ∧
        Tensor4 v 1 48 128 (fun _ => out.v 0) := by
  obtain ⟨q, k, v, ha, input, e, rfl, rfl, rfl⟩ := K.siluRmsHeads values qScale kScale x qs ks hx hq hk
  have he := e.output_eq
  refine ⟨_, _, _, ha, ?_, ?_, ?_⟩
  · exact heads_tensor _ _ 16 _ fun h i => congrFun (congrFun (congrFun (congrArg DeltaHeads.Output.q he) 0) h) i
  · exact heads_tensor _ _ 16 _ fun h i => congrFun (congrFun (congrFun (congrArg DeltaHeads.Output.k he) 0) h) i
  · exact heads_tensor _ _ 48 _ fun h i => congrFun (congrFun (congrFun (congrArg DeltaHeads.Output.v he) 0) h) i

/-! ## gated_delta_step -/

theorem gated_delta_step (initial : Delta.GatedDevice.State) (values : Delta.GatedInputs.Values) (q k v g beta s : Value)
    (hq : Flat q [1,1,16,128] (Delta.GatedInputs.flatten values.query))
    (hk : Flat k [1,1,16,128] (Delta.GatedInputs.flatten values.key))
    (hv : Flat v [1,1,48,128] (Delta.GatedInputs.flatten values.value)) (hg : FlatF32 g [1,1,48] values.decay)
    (hb : Flat beta [1,1,48] values.beta)
    (hs : s.dtype = .float32 ∧ s.shape = [1,48,128,128] ∧
      ∀ h r c, f32 (s.elems (Delta.GatedStores.stateIndex h r c)) = initial h r c) :
    ∃ y s', K.apply .gatedDeltaStep [q, k, v, g, beta, s, ⟨.int32, [1], fun _ => 1⟩] gatedConfig = some [y, s'] ∧
      Tensor4 y 1 48 128 (fun _ => Delta.GatedDevice.producedOutput C.simdSum K.flags initial values.inputs) ∧
      s'.dtype = .float32 ∧ s'.shape = [1,48,128,128] ∧
      ∀ h r c, f32 (s'.elems (Delta.GatedStores.stateIndex h r c)) =
        Delta.GatedDevice.producedState C.simdSum K.flags initial values.inputs h r c := by
  obtain ⟨y, s', ha, e, rfl, rfl⟩ := K.gatedDeltaStep initial values q k v g beta s _ hq hk hv hg hb hs rfl
  refine ⟨_, _, ha, heads_tensor _ _ 48 _ fun h r => congrFun (congrFun e.output_eq h) r, rfl, rfl, fun h r c => ?_⟩
  rw [word_read]
  exact congrFun (congrFun (congrFun e.state_eq h) r) c

/-! ## gated_rms_norm and residual_rms_norm closures -/

theorem gated_rms_norm (x gate : GatedRmsNormDevice.Rows) (weights : Fin 128 → BF) (xv gv wv : Value)
    (hx : Flat xv [1,1,48,128] (Delta.GatedInputs.flatten x)) (hg : Flat gv [1,1,48,128] (Delta.GatedInputs.flatten gate))
    (hw : GlueAttention.Vector wv 128 weights) :
    ∃ out, KernelClosure.eval K .gatedRmsNorm [xv, gv, wv] = some [out] ∧
      Flat out [1,1,48,128] (Delta.GatedInputs.flatten (fun h => GatedRmsNorm.value K.gated (x h) (gate h) weights
        Normalization.GatedRms128TailSource.width (FloatMemory.decode (BitVec.ofNat 32 epsWord)))) := by
  obtain ⟨out, ha, input, e, rfl⟩ := K.gatedRmsNorm x gate weights xv gv wv hx hg hw
  refine ⟨_, ha, rfl, rfl, fun j => ?_⟩
  rw [half_read]
  have hj : Delta.GatedInputs.index (⟨j.val/128, by omega⟩ : Fin 48) ⟨j.val%128, by omega⟩ = j :=
    Fin.ext (by simp only [Delta.GatedInputs.index]; omega)
  have read := congrFun (congrFun e.output_eq ⟨j.val/128, by omega⟩) ⟨j.val%128, by omega⟩
  unfold GatedRmsNormMemory.Execution.output at read
  rw [hj] at read
  exact read

theorem residual_rms_norm (left right weight : Fin 5120 → BF) (xv uv wv : Value)
    (hx : Row xv 5120 left) (hu : Row uv 5120 right) (hw : GlueAttention.Vector wv 5120 weight)
    (scratch : M1Max.WordMemory) (base : Nat) :
    ∃ h n, KernelClosure.eval K .residualRmsNorm [xv, uv, wv] = some [h, n] ∧
      Row h 5120 (fun i => ResidualRmsNorm.residual (left i) (right i)) ∧
      Row n 5120 (ResidualRmsNorm.normalized K.residual left right weight Blocks.width Blocks.eps scratch base) := by
  obtain ⟨h, n, ha, input, residual, e, rfl, rfl⟩ := K.residualRmsNorm left right weight xv uv wv hx hu hw
  refine ⟨_, _, ha, (halfArray_buffer e.residualBuffer [1,1,5120]).row, Row.mk rfl rfl fun j => ?_⟩
  rw [half_read]
  exact (e.outputBuffer.read_correct j).trans (congrFun (e.output_eq scratch base) j)

/-! ## Trellis MLP (gate-up, down partial, fold) -/

-- Every Trellis value reads its codebook through `sourceLane_correct`, so
-- threadgroup contents and the table base never reach the result.
theorem raw_reference (p : TrellisCodebookGateUp.Platform) (w : TrellisCodebookGateUp.Projection)
    (input : Nat → BitVec 16) (row : Nat) :
    TrellisCodebookGateUp.raw p w input row =
      p.reduce (fun lane => Trellis.GateUpFlushToZero.referenceLane w.words w.width w.scale input row lane.val) := by
  exact congrArg p.reduce (funext fun lane =>
    Trellis.GateUpFlushToZero.sourceLane_correct p.load p.loads _ p.base p.aligned p.bounded
    (TrellisCodebookGateUp.table_initialized p) w.words w.width w.validWidth w.scale input row lane.val lane.isLt)

theorem scratch_forward (mlp : GateDown) (gate : M1Max.WordMemory) (gateBase : Nat) (gateAligned : gateBase%4=0)
    (gateBounded : gateBase+16384 ≤ 2^64) (down : Nat → M1Max.WordMemory) (downBase : Nat) (downAligned : downBase%4=0)
    (downBounded : downBase+16384 ≤ 2^64) :
    (mlp.withScratch gate gateBase gateAligned gateBounded down downBase downAligned downBounded).forward = mlp.forward := by
  funext input
  have hidden : (mlp.withScratch gate gateBase gateAligned gateBounded down downBase downAligned downBounded).intermediate input =
      mlp.intermediate input := by
    funext row
    unfold GateDown.intermediate WrittenLayers.hidden GateDown.withScratch
    cases mlp.activation <;>
      simp only [TrellisCodebookGateUp.floatOutput, TrellisCodebookGateUp.splitOutput, raw_reference]
  unfold GateDown.forward
  rw [hidden]
  rfl

theorem trellis_mlp (mlp : GateDown) (input : Fin 5120 → BF) (x gc gs uc us dc ds : Value)
    (gateLoad : mlp.gatePlatform.load = C.threadgroupLoad) (gateReduce : mlp.gatePlatform.reduce = C.simdSum)
    (downLoad : mlp.downPlatform.load = C.threadgroupLoad) (downReduce : mlp.downPlatform.reduce = C.simdSum)
    (activation : mlp.activation = K.activation mlp.gate.width mlp.up.width) (weights : Trellis mlp gc gs uc us dc ds)
    (hx : Flat x [1,5120] input) :
    ∃ mid part out, K.apply .gateUp [x, gc, gs, uc, us] (gateUpConfig mlp.gate.width mlp.up.width) = some [mid] ∧
      K.apply .downPartial [mid, dc, ds] (downConfig mlp.down.width) = some [part] ∧
      K.apply .downFold [part] foldConfig = some [out] ∧
      mid.shape = [1,17408] ∧ Flat out [1,5120] (mlp.forward (Blocks.packed input)) := by
  obtain ⟨mid, part, out, h1, h2, h3, gate, gateBase, gateAligned, gateBounded, down, downBase, downAligned, downBounded,
    e, _, rfl, rfl, rfl⟩ := K.trellis mlp input x gc gs uc us dc ds gateLoad gateReduce downLoad downReduce activation weights hx
  refine ⟨_, _, _, h1, h2, h3, rfl, rfl, rfl, fun j => ?_⟩
  rw [half_read]
  have := TrellisMlpParsedDown.output_eq e j
  rw [scratch_forward] at this
  exact this

/-! ## normalized_argmax closure (logsumexp, partial, finish, reshape) -/

theorem logsumexp_value (P : Sampling.LogSumExpRanges.Platform) (logits : Fin 248320 → BF) (l : Value)
    (hl : Flat l [1,248320] logits) :
    ∃ s, logsumexp P l = some s ∧ Flat s [1,1] (fun _ : Fin 1 => Sampling.LogSumExpRanges.value P logits) := by
  have hf : (fun i : Fin 248320 => bf (l.elems i.val)) = logits := funext hl.2.2
  refine ⟨_, by unfold logsumexp; rw [ite_eq_left ⟨hl.1, hl.2.1⟩], rfl, rfl, fun _ => ?_⟩
  dsimp only
  rw [bf_word, hf]

theorem normalized_argmax (logits : Fin 248320 → BF) (l : Value) (hl : Flat l [1,248320] logits)
    (primitive : Sampling.LogSumExpRanges.Primitives K.sampling)
    (bound : ∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2:ℝ)^(23:Nat)) :
    ∃ r, KernelClosure.eval K .normalizedArgmax [l] = some [r] ∧ r.dtype = .uint32 ∧ r.shape = [1] ∧
      r.elems 0 = Sampling.GreedySampling.sample K.sampling logits := by
  obtain ⟨s, hs, fs⟩ := logsumexp_value K.sampling logits l hl
  obtain ⟨values, indices, token, h1, h2, source, lse, e, rfl, rfl, rfl⟩ := K.argmax logits l s hl fs
  have tok := e.token_eq primitive bound
  refine ⟨wordArray .uint32 e.memory e.destination [1], ?_, rfl, rfl, by simpa [KernelContract.sampling, wordArray, Sampling.NormalizedArgmaxMemory.Execution.token] using tok⟩
  simp only [KernelClosure.eval, hs, Option.bind_eq_bind, Option.bind_some]
  rw [h1]
  simp only [Option.bind_some]
  rw [h2]
  simp only [Option.bind_some]
  rw [reshape_some _ [1] rfl]
  rfl

end Host.Mlx.GlueKernels
