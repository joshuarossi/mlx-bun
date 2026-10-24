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

/-! Value-level statements of the route's custom kernels and their compiled
closures: each launch returns outputs encoding the model function, on inputs
the model's range certificates make finite (`KernelContract`'s fields). -/

variable {C : M1Max.Contract} (K : KernelContract C)

theorem half_read (memory : ByteMemory.Bytes) (base i : Nat) (shape : List Nat) :
    bf ((halfArray memory base shape).elems i) = (Model.ofBits (HalfMemory.load memory (base+2*i)) : BF) := bf_toNat _

theorem word_read (memory : ByteMemory.Bytes) (base i : Nat) (shape : List Nat) :
    f32 ((wordArray .float32 memory base shape).elems i) = FloatMemory.load memory (base+4*i) := f32_toNat _

/-! ## affine_row -/

theorem affine_row3 {steps blocks : Nat} (p : AffineVerifyLinear.Projection3 steps (4*(blocks*16)))
    (input : Fin (steps*512) → BF) (x w scales biases : Value) (hp : p.platform = K.affine 3 steps (4*(blocks*16)))
    (hx : Row x (steps*512) input) (hw : Affine3 p w scales biases) (hf : p.Finite input) (route : AffineRoute steps blocks) :
    ∃ y, K.apply .affineRow [x, w, scales, biases] (affineConfig (steps*512) (4*(blocks*16)) 3) = some [y] ∧
      Row y (4*(blocks*16)) (p.forward input) :=
  K.affineRow3 p input x w scales biases hp hx hw hf route

theorem affine_row4 {steps blocks : Nat} (p : AffineVerifyLinear.Projection4 steps (4*(blocks*16)))
    (input : Fin (steps*512) → BF) (x w scales biases : Value) (hp : p.platform = K.affine 4 steps (4*(blocks*16)))
    (hx : Row x (steps*512) input) (hw : Affine4 p w scales biases) (hf : p.Finite input) (route : AffineRoute steps blocks) :
    ∃ y, K.apply .affineRow [x, w, scales, biases] (affineConfig (steps*512) (4*(blocks*16)) 4) = some [y] ∧
      Row y (4*(blocks*16)) (p.forward input) :=
  K.affineRow4 p input x w scales biases hp hx hw hf route

/-! ## silu_rms_heads -/

theorem heads_tensor (memory : ByteMemory.Bytes) (base : Nat) (heads : Nat)
    (f : Fin heads → Fin 128 → BF) (read : ∀ h i, (Model.ofBits (HalfMemory.load memory (base+2*(h.val*128+i.val))) : BF) = f h i) :
    Tensor4 (halfArray memory base [1,1,heads,128]) 1 heads 128 (fun _ => f) :=
  Tensor4.mk rfl rfl fun a h i => by
    have : a.val = 0 := by omega
    rw [half_read]; simp only [this, Nat.zero_mul, Nat.zero_add]; exact read h i

theorem silu_rms_heads (values : Fin 10240 → BF) (qScale kScale : Fin 128 → BF) (x qs ks : Value)
    (hx : Row x 10240 values) (hq : GlueAttention.Vector qs 128 qScale) (hk : GlueAttention.Vector ks 128 kScale)
    (hf : DeltaHeads.Finite K.heads (fun _ : Fin 1 => values) qScale kScale
      Delta.SiluHeads128Output.width Delta.SiluHeads128Output.epsilon) :
    ∃ q k v, KernelClosure.eval K .siluRmsHeads [x, qs, ks] = some [q, k, v] ∧
      let out := DeltaHeads.forward K.heads (fun _ : Fin 1 => values) qScale kScale
        Delta.SiluHeads128Output.width Delta.SiluHeads128Output.epsilon
      Tensor4 q 1 16 128 (fun _ => out.q 0) ∧ Tensor4 k 1 16 128 (fun _ => out.k 0) ∧
        Tensor4 v 1 48 128 (fun _ => out.v 0) :=
  K.siluRmsHeads values qScale kScale x qs ks hx hq hk hf

/-! ## gated_delta_step -/

theorem gated_delta_step (reduce : (Fin 32 → Float32) → Float32) (reduction : FlushedReduction.SimdContract reduce)
    (hr : reduce = C.simdSum) (initial : Delta.GatedDevice.State) (values : Delta.GatedInputs.Values) (q k v g beta s : Value)
    (hq : Flat q [1,1,16,128] (Delta.GatedInputs.flatten values.query))
    (hk : Flat k [1,1,16,128] (Delta.GatedInputs.flatten values.key))
    (hv : Flat v [1,1,48,128] (Delta.GatedInputs.flatten values.value)) (hg : FlatF32 g [1,1,48] values.decay)
    (hb : Flat beta [1,1,48] values.beta)
    (hs : s.dtype = .float32 ∧ s.shape = [1,48,128,128] ∧
      ∀ h r c, f32 (s.elems (Delta.GatedStores.stateIndex h r c)) = initial h r c)
    (hf : ∀ h r, Arithmetic.Finite (Delta.Recurrence.bind (initial h r) (values.inputs h r))
      (Delta.Gated.outputExpr K.flags reduction.tree)) :
    ∃ y s', K.apply .gatedDeltaStep [q, k, v, g, beta, s, ⟨.int32, [1], fun _ => 1⟩] gatedConfig = some [y, s'] ∧
      Tensor4 y 1 48 128 (fun _ => Delta.GatedDevice.producedOutput C.simdSum K.flags initial values.inputs) ∧
      s'.dtype = .float32 ∧ s'.shape = [1,48,128,128] ∧
      ∀ h r c, f32 (s'.elems (Delta.GatedStores.stateIndex h r c)) =
        Delta.GatedDevice.producedState C.simdSum K.flags initial values.inputs h r c :=
  K.gatedDeltaStep reduce reduction initial values q k v g beta s hr hq hk hv hg hb hs hf

/-! ## gated_rms_norm and residual_rms_norm closures -/

theorem gated_rms_norm (x gate : GatedRmsNormDevice.Rows) (weights : Fin 128 → BF) (xv gv wv : Value)
    (hx : Flat xv [1,1,48,128] (Delta.GatedInputs.flatten x)) (hg : Flat gv [1,1,48,128] (Delta.GatedInputs.flatten gate))
    (hw : GlueAttention.Vector wv 128 weights)
    (hn : ∀ h, GatedRmsNorm.NormFinite K.gated (x h) weights
      Normalization.GatedRms128TailSource.width (FloatMemory.decode (BitVec.ofNat 32 epsWord)))
    (ht : ∀ h i, GatedRmsNorm.TailFinite K.gated (BFloat16.widen (gate h i))
      (BFloat16.widen (GatedRmsNorm.normalized K.gated (x h) weights
        Normalization.GatedRms128TailSource.width (FloatMemory.decode (BitVec.ofNat 32 epsWord)) i))) :
    ∃ out, KernelClosure.eval K .gatedRmsNorm [xv, gv, wv] = some [out] ∧
      Flat out [1,1,48,128] (Delta.GatedInputs.flatten (fun h => GatedRmsNorm.value K.gated (x h) (gate h) weights
        Normalization.GatedRms128TailSource.width (FloatMemory.decode (BitVec.ofNat 32 epsWord)))) :=
  K.gatedRmsNorm x gate weights xv gv wv hx hg hw hn ht

theorem residual_rms_norm (left right weight : Fin 5120 → BF) (xv uv wv : Value)
    (hx : Row xv 5120 left) (hu : Row uv 5120 right) (hw : GlueAttention.Vector wv 5120 weight)
    (hA : ∀ i, ResidualRmsNorm.AddFinite (left i) (right i))
    (hn : ResidualRmsNorm.NormFinite K.residual left right weight Blocks.width Blocks.eps)
    (scratch : M1Max.WordMemory) (base : Nat) :
    ∃ h n, KernelClosure.eval K .residualRmsNorm [xv, uv, wv] = some [h, n] ∧
      Row h 5120 (fun i => ResidualRmsNorm.residual (left i) (right i)) ∧
      Row n 5120 (ResidualRmsNorm.normalized K.residual left right weight Blocks.width Blocks.eps scratch base) := by
  obtain ⟨h, n, ha, th, tn⟩ := K.residualRmsNorm left right weight xv uv wv hx hu hw hA hn
  exact ⟨h, n, ha, th, tn scratch base⟩

/-! ## Trellis MLP (gate-up, down partial, fold) -/

theorem trellis_mlp (mlp : GateDown) (input : Fin 5120 → BF) (x gc gs uc us dc ds : Value)
    (gateReduce : mlp.gatePlatform.reduce = C.simdSum) (downReduce : mlp.downPlatform.reduce = C.simdSum)
    (activation : mlp.activation = K.activation mlp.gate.width mlp.up.width) (weights : Trellis mlp gc gs uc us dc ds)
    (hx : Flat x [1,5120] input) (hf : TrellisMlp.Finite mlp (Blocks.packed input)) :
    ∃ mid part out, K.apply .gateUp [x, gc, gs, uc, us] (gateUpConfig mlp.gate.width mlp.up.width) = some [mid] ∧
      K.apply .downPartial [mid, dc, ds] (downConfig mlp.down.width) = some [part] ∧
      K.apply .downFold [part] foldConfig = some [out] ∧
      mid.shape = [1,17408] ∧ Flat out [1,5120] (mlp.forward (Blocks.packed input)) :=
  K.trellis mlp input x gc gs uc us dc ds gateReduce downReduce activation weights hx hf

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
  obtain ⟨values, indices, token, h1, h2, td, ts, te⟩ := K.argmax logits l s hl fs primitive bound
  refine ⟨token, ?_, td, ts, te⟩
  simp only [KernelClosure.eval, hs, Option.bind_eq_bind, Option.bind_some]
  rw [h1]
  simp only [Option.bind_some]
  rw [h2]
  simp only [Option.bind_some]
  rw [reshape_some _ [1] (by rw [ts])]
  cases token
  simp only at ts
  subst ts
  rfl

end Host.Mlx.GlueKernels
