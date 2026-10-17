import layers.AffineVerifyLinear
import state.Ssm
import kernels.GatedRmsNorm

namespace Inference.Models.Qwen.DeltaNet
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Layers.AffineVerifyLinear
abbrev BF := BFloat16Arithmetic.Value

-- The written graph chooses each projection's bit width and implementation
-- during construction. These are the dimensions of its Qwen DeltaNet block.
structure Layer where
  qkv : Projection 10 10240
  z : Projection 10 6144
  a : Projection 10 48
  b : Projection 10 48
  out : Projection 12 5120
  convolutionWeight : Fin 10240 → Fin 4 → BF
  aLog : Fin 48 → BF
  dtBias : Fin 48 → BF
  headParams : State.Ssm.Parameters
  recurrence : State.Ssm.Platform
  gated : Kernels.GatedRmsNorm.Platform
  normWeight : Fin 128 → BF

structure Cache where
  history : Fin 3 → Fin 10240 → BF
  recurrent : Fin 48 → Fin 128 → Fin 128 → Float32
structure ReferenceCache where
  history : Fin 3 → Fin 10240 → ℝ
  recurrent : Fin 48 → Fin 128 → Fin 128 → ℝ

structure CacheError (cache : Cache) (target error : ReferenceCache) : Prop where
  history : ∀ i c, |Model.toReal (cache.history i c) - target.history i c| ≤ error.history i c
  recurrent : ∀ h v k, |real (cache.recurrent h v k) - target.recurrent h v k| ≤ error.recurrent h v k

def convData (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF) : State.Ssm.ConvData BF where
  history := cache.history
  input t := layer.qkv.forward (input t)
  weight := layer.convolutionWeight

noncomputable def targetConvData (layer : Layer) (cache : ReferenceCache) (input : Nat → Fin 5120 → ℝ) : State.Ssm.ConvData ℝ where
  history := cache.history
  input t := layer.qkv.target (input t)
  weight c i := Model.toReal (layer.convolutionWeight c i)

noncomputable def convErrors (layer : Layer) (cacheError : ReferenceCache) (input : Nat → Fin 5120 → BF)
    (target error : Nat → Fin 5120 → ℝ) : State.Ssm.ConvData ℝ where
  history := cacheError.history
  input t := layer.qkv.budget (input t) (target t) (error t)
  weight _ _ := 0

def gates (layer : Layer) (input : Nat → Fin 5120 → BF) : State.Ssm.GateData BF where
  aLog := layer.aLog
  dtBias := layer.dtBias
  a t := layer.a.forward (input t)
  b t := layer.b.forward (input t)

noncomputable def targetGates (layer : Layer) (input : Nat → Fin 5120 → ℝ) : State.Ssm.GateData ℝ where
  aLog h := Model.toReal (layer.aLog h)
  dtBias h := Model.toReal (layer.dtBias h)
  a t := layer.a.target (input t)
  b t := layer.b.target (input t)

noncomputable def gateErrors (layer : Layer) (input : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ) : State.Ssm.GateData ℝ where
  aLog _ := 0
  dtBias _ := 0
  a t := layer.a.budget (input t) (target t) (error t)
  b t := layer.b.budget (input t) (target t) (error t)

structure ProjectionFinite (layer : Layer) (input : Nat → Fin 5120 → BF) : Prop where
  qkv : ∀ t, layer.qkv.Finite (input t)
  a : ∀ t, layer.a.Finite (input t)
  b : ∀ t, layer.b.Finite (input t)
  z : ∀ t, layer.z.Finite (input t)

theorem convolution_input_error (layer : Layer) (cache : Cache) (targetCache errorCache : ReferenceCache)
    (hc : CacheError cache targetCache errorCache) (input : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ)
    (hi : ∀ t i, |Model.toReal (input t i) - target t i| ≤ error t i) (hf : ProjectionFinite layer input) :
    State.Ssm.ConvError (convData layer cache input) (targetConvData layer targetCache target) (convErrors layer errorCache input target error) := by
  constructor
  · exact hc.history
  · intro t i
    exact layer.qkv.forward_error (input t) (target t) (error t) (hi t) (hf.qkv t) i
  · intro c i
    simp [convData, targetConvData, convErrors]

theorem gate_input_error (layer : Layer) (input : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ)
    (hi : ∀ t i, |Model.toReal (input t i) - target t i| ≤ error t i) (hf : ProjectionFinite layer input) :
    State.Ssm.GateError (gates layer input) (targetGates layer target) (gateErrors layer input target error) := by
  constructor
  · intro h; simp [gates, targetGates, gateErrors]
  · intro h; simp [gates, targetGates, gateErrors]
  · intro t h
    exact layer.a.forward_error (input t) (target t) (error t) (hi t) (hf.a t) h
  · intro t h
    exact layer.b.forward_error (input t) (target t) (error t) (hi t) (hf.b t) h

-- Only the convolution's arithmetic range remains an obligation here.
-- Finiteness of every projected input is derived from its kernel proof.
structure ConvolutionFinite (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF) : Prop where
  history : ∀ i c, Model.isFinite (cache.history i c) = true
  weight : ∀ c i, Model.isFinite (layer.convolutionWeight c i) = true
  arithmetic : ∀ t c, Arithmetic.Finite
    (Convolution.bind (fun i => BFloat16.widen (State.Ssm.window (convData layer cache input) t c i))
      (fun i => BFloat16.widen (layer.convolutionWeight c i))) (Convolution.expression layer.recurrence.convolutionContracted)
  cast : ∀ t c, Model.isFinite (State.Ssm.convolved layer.recurrence (convData layer cache input) t c) = true

theorem convolution_finite (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF)
    (hp : ProjectionFinite layer input) (hf : ConvolutionFinite layer cache input) :
    State.Ssm.ConvFinite layer.recurrence (convData layer cache input) where
  history := hf.history
  input t := layer.qkv.forward_finite (input t) (hp.qkv t)
  weight := hf.weight
  arithmetic := hf.arithmetic
  cast := hf.cast

def inputs (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) (head : Fin 48) (value : Fin 128) : Nat → Recurrence.Inputs Float32 :=
  State.Ssm.inputs layer.recurrence layer.headParams (convData layer cache x) (gates layer x) head value

noncomputable def targets (layer : Layer) (eps : ℝ) (cache : ReferenceCache) (x : Nat → Fin 5120 → ℝ) (head : Fin 48) (value : Fin 128) : Nat → Recurrence.Inputs ℝ :=
  State.Ssm.targets layer.headParams eps (targetConvData layer cache x) (targetGates layer x) head value

noncomputable def inputBudgets (layer : Layer) (eps epsError : ℝ) (cache : Cache) (targetCache errorCache : ReferenceCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ) (head : Fin 48) (value : Fin 128) : Nat → Recurrence.Inputs ℝ :=
  State.Ssm.inputBudget layer.recurrence layer.headParams eps epsError (convData layer cache x)
    (targetConvData layer targetCache target) (convErrors layer errorCache x target error)
    (gates layer x) (targetGates layer target) (gateErrors layer x target error) head value

def recurrentOutput (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) (time : Nat) (head : Fin 48) (value : Fin 128) : BF :=
  Recurrence.outputAt layer.recurrence.reduce layer.recurrence.flags (inputs layer cache x head value) (cache.recurrent head value) time

noncomputable def targetOutput (layer : Layer) (eps : ℝ) (cache : ReferenceCache) (x : Nat → Fin 5120 → ℝ) (time : Nat) (head : Fin 48) (value : Fin 128) : ℝ :=
  Recurrence.targetOutputAt (targets layer eps cache x head value) (cache.recurrent head value) time

noncomputable def outputBudget (layer : Layer) (eps epsError : ℝ) (cache : Cache) (targetCache errorCache : ReferenceCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ) (time : Nat) (head : Fin 48) (value : Fin 128) : ℝ :=
  Recurrence.outputBudget layer.recurrence.reduce layer.recurrence.reduction.tree layer.recurrence.flags
    (inputs layer cache x head value) (cache.recurrent head value) (targets layer eps targetCache target head value)
    (inputBudgets layer eps epsError cache targetCache errorCache x target error head value)
    (targetCache.recurrent head value) (errorCache.recurrent head value) time

structure RecurrentFinite (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) (time : Nat) : Prop where
  heads : ∀ t, t ≤ time → State.Ssm.HeadFinite layer.recurrence layer.headParams (convData layer cache x) t
  gates : ∀ t, t ≤ time → State.Ssm.GateFinite layer.recurrence (gates layer x) t
  state : ∀ head value t, t < time → ∀ i : Fin 128, Arithmetic.Finite
    (Recurrence.bind (Recurrence.run layer.recurrence.reduce layer.recurrence.flags (inputs layer cache x head value)
      (cache.recurrent head value) t) (inputs layer cache x head value t))
    (Gated.stateExpr layer.recurrence.flags layer.recurrence.reduction.tree i)
  output : ∀ head value, Arithmetic.Finite
    (Recurrence.bind (Recurrence.run layer.recurrence.reduce layer.recurrence.flags (inputs layer cache x head value)
      (cache.recurrent head value) time) (inputs layer cache x head value time))
    (Gated.outputExpr layer.recurrence.flags layer.recurrence.reduction.tree)
  cast : ∀ head value, Model.isFinite (recurrentOutput layer cache x time head value) = true

theorem recurrent_output_error (layer : Layer) (eps epsError : ℝ) (hp : 0 < eps) (hee : |real layer.headParams.eps - eps| ≤ epsError)
    (cache : Cache) (targetCache errorCache : ReferenceCache) (hc : CacheError cache targetCache errorCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ)
    (hi : ∀ t i, |Model.toReal (x t i) - target t i| ≤ error t i) (hf : ProjectionFinite layer x)
    (hv : ConvolutionFinite layer cache x) (time : Nat) (hr : RecurrentFinite layer cache x time) (head : Fin 48) (value : Fin 128) :
    |Model.toReal (recurrentOutput layer cache x time head value) - targetOutput layer eps targetCache target time head value| ≤
      outputBudget layer eps epsError cache targetCache errorCache x target error time head value :=
  State.Ssm.output_error layer.recurrence layer.headParams eps epsError hp hee
    (convData layer cache x) (targetConvData layer targetCache target) (convErrors layer errorCache x target error)
    (gates layer x) (targetGates layer target) (gateErrors layer x target error)
    (convolution_finite layer cache x hf hv) (convolution_input_error layer cache targetCache errorCache hc x target error hi hf)
    (gate_input_error layer x target error hi hf) head value (cache.recurrent head value)
    (targetCache.recurrent head value) (errorCache.recurrent head value) (hc.recurrent head value) time
    hr.heads hr.gates (hr.state head value) (hr.output head value) (hr.cast head value)

def channel (head : Fin 48) (value : Fin 128) : Fin 6144 :=
  ⟨head.val * 128 + value.val, by have := head.isLt; have := value.isLt; omega⟩
def headOf (i : Fin 6144) : Fin 48 := ⟨i.val / 128, by have := i.isLt; omega⟩
def valueOf (i : Fin 6144) : Fin 128 := ⟨i.val % 128, by omega⟩

theorem reshape_roundtrip (i : Fin 6144) : channel (headOf i) (valueOf i) = i := by
  apply Fin.ext
  dsimp [channel, headOf, valueOf]
  omega
theorem reshape_head (head : Fin 48) (value : Fin 128) : headOf (channel head value) = head := by
  apply Fin.ext
  dsimp [channel, headOf]
  have := value.isLt
  omega
theorem reshape_value (head : Fin 48) (value : Fin 128) : valueOf (channel head value) = value := by
  apply Fin.ext
  dsimp [channel, valueOf]
  have := value.isLt
  omega

def zHead (layer : Layer) (x : Nat → Fin 5120 → BF) (time : Nat) (head : Fin 48) (value : Fin 128) : BF :=
  layer.z.forward (x time) (channel head value)
noncomputable def targetZ (layer : Layer) (target : Nat → Fin 5120 → ℝ) (time : Nat) (head : Fin 48) (value : Fin 128) : ℝ :=
  layer.z.target (target time) (channel head value)
noncomputable def zBudget (layer : Layer) (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ)
    (time : Nat) (head : Fin 48) (value : Fin 128) : ℝ :=
  layer.z.budget (x time) (target time) (error time) (channel head value)

def gatedOutput (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) (time : Nat) (head : Fin 48) : Fin 128 → BF :=
  Kernels.GatedRmsNorm.value layer.gated (recurrentOutput layer cache x time head) (zHead layer x time head)
    layer.normWeight layer.headParams.width layer.headParams.eps

noncomputable def targetGated (layer : Layer) (eps : ℝ) (cache : ReferenceCache) (target : Nat → Fin 5120 → ℝ)
    (time : Nat) (head : Fin 48) (value : Fin 128) : ℝ :=
  Kernels.Trellis.GateUpTail.swiglu (targetZ layer target time head value)
    (Normalization.rmsNorm (targetOutput layer eps cache target time head) (fun i => Model.toReal (layer.normWeight i)) eps value)

noncomputable def gatedBudget (layer : Layer) (eps epsError : ℝ) (cache : Cache) (targetCache errorCache : ReferenceCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ) (time : Nat) (head : Fin 48) (value : Fin 128) : ℝ :=
  let normalized := Kernels.GatedRmsNorm.normalized layer.gated (recurrentOutput layer cache x time head)
    layer.normWeight layer.headParams.width layer.headParams.eps value
  Kernels.GatedRmsNorm.tailBudget layer.gated (BFloat16.widen (zHead layer x time head value)) (BFloat16.widen normalized) +
    zBudget layer x target error time head value * (1 + |targetZ layer target time head value| / 4) * |Model.toReal normalized| +
    |targetZ layer target time head value| * Kernels.GatedRmsNorm.propagatedNormBudget layer.gated
      (recurrentOutput layer cache x time head) layer.normWeight layer.headParams.width layer.headParams.eps eps epsError
      (targetOutput layer eps targetCache target time head) (outputBudget layer eps epsError cache targetCache errorCache x target error time head) value

structure GatedFinite (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) (time : Nat) : Prop where
  normalization : ∀ head, Kernels.GatedRmsNorm.NormFinite layer.gated (recurrentOutput layer cache x time head)
    layer.normWeight layer.headParams.width layer.headParams.eps
  tail : ∀ head value, Kernels.GatedRmsNorm.TailFinite layer.gated (BFloat16.widen (zHead layer x time head value))
    (BFloat16.widen (Kernels.GatedRmsNorm.normalized layer.gated (recurrentOutput layer cache x time head)
      layer.normWeight layer.headParams.width layer.headParams.eps value))

theorem gated_error (layer : Layer) (eps epsError : ℝ) (hp : 0 < eps) (hee : |real layer.headParams.eps - eps| ≤ epsError)
    (cache : Cache) (targetCache errorCache : ReferenceCache) (hc : CacheError cache targetCache errorCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ)
    (hi : ∀ t i, |Model.toReal (x t i) - target t i| ≤ error t i) (hf : ProjectionFinite layer x)
    (hv : ConvolutionFinite layer cache x) (time : Nat) (hr : RecurrentFinite layer cache x time)
    (hg : GatedFinite layer cache x time) (head : Fin 48) (value : Fin 128) :
    |Model.toReal (gatedOutput layer cache x time head value) - targetGated layer eps targetCache target time head value| ≤
      gatedBudget layer eps epsError cache targetCache errorCache x target error time head value :=
  Kernels.GatedRmsNorm.value_error layer.gated (recurrentOutput layer cache x time head) (zHead layer x time head)
    layer.normWeight layer.headParams.width layer.headParams.eps eps epsError hp hee (hg.normalization head) (hr.cast head)
    (targetOutput layer eps targetCache target time head) (outputBudget layer eps epsError cache targetCache errorCache x target error time head)
    (targetZ layer target time head) (zBudget layer x target error time head)
    (recurrent_output_error layer eps epsError hp hee cache targetCache errorCache hc x target error hi hf hv time hr head)
    (fun i => layer.z.forward_finite (x time) (hf.z time) (channel head i))
    (fun i => layer.z.forward_error (x time) (target time) (error time) (hi time) (hf.z time) (channel head i)) value (hg.tail head value)

def merged (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) (time : Nat) (i : Fin 6144) : BF :=
  gatedOutput layer cache x time (headOf i) (valueOf i)
noncomputable def targetMerged (layer : Layer) (eps : ℝ) (cache : ReferenceCache) (target : Nat → Fin 5120 → ℝ) (time : Nat) (i : Fin 6144) : ℝ :=
  targetGated layer eps cache target time (headOf i) (valueOf i)
noncomputable def mergedBudget (layer : Layer) (eps epsError : ℝ) (cache : Cache) (targetCache errorCache : ReferenceCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ) (time : Nat) (i : Fin 6144) : ℝ :=
  gatedBudget layer eps epsError cache targetCache errorCache x target error time (headOf i) (valueOf i)

theorem merged_finite (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) (time : Nat)
    (hg : GatedFinite layer cache x time) (i : Fin 6144) : Model.isFinite (merged layer cache x time i) = true :=
  (hg.tail (headOf i) (valueOf i)).cast

def Layer.forward (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) (time : Nat) : Fin 5120 → BF :=
  layer.out.forward (merged layer cache x time)
noncomputable def Layer.target (layer : Layer) (eps : ℝ) (cache : ReferenceCache) (x : Nat → Fin 5120 → ℝ) (time : Nat) : Fin 5120 → ℝ :=
  layer.out.target (targetMerged layer eps cache x time)
noncomputable def Layer.budget (layer : Layer) (eps epsError : ℝ) (cache : Cache) (targetCache errorCache : ReferenceCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ) (time : Nat) : Fin 5120 → ℝ :=
  layer.out.budget (merged layer cache x time) (targetMerged layer eps targetCache target time)
    (mergedBudget layer eps epsError cache targetCache errorCache x target error time)

structure Layer.Finite (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) (time : Nat) : Prop where
  projections : ProjectionFinite layer x
  convolution : ConvolutionFinite layer cache x
  recurrence : RecurrentFinite layer cache x time
  gated : GatedFinite layer cache x time
  output : layer.out.Finite (merged layer cache x time)

-- The mathematical path includes all five affine projections, convolution,
-- head normalization, decay/beta, recurrent state/output, gated normalization,
-- reshape, and output projection. Range and primitive-platform obligations
-- remain explicit; no component's whole numerical accuracy is assumed.
theorem Layer.forward_error (layer : Layer) (eps epsError : ℝ) (hp : 0 < eps) (hee : |real layer.headParams.eps - eps| ≤ epsError)
    (cache : Cache) (targetCache errorCache : ReferenceCache) (hc : CacheError cache targetCache errorCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ)
    (hi : ∀ t i, |Model.toReal (x t i) - target t i| ≤ error t i) (time : Nat) (hf : layer.Finite cache x time) (i : Fin 5120) :
    |Model.toReal (layer.forward cache x time i) - layer.target eps targetCache target time i| ≤
      layer.budget eps epsError cache targetCache errorCache x target error time i := by
  apply layer.out.forward_error _ _ _ _ hf.output i
  intro j
  exact gated_error layer eps epsError hp hee cache targetCache errorCache hc x target error hi hf.projections
    hf.convolution time hf.recurrence hf.gated (headOf j) (valueOf j)

theorem Layer.forward_finite (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) (time : Nat)
    (hf : layer.Finite cache x time) (i : Fin 5120) : Model.isFinite (layer.forward cache x time i) = true :=
  layer.out.forward_finite _ hf.output i

end Inference.Models.Qwen.DeltaNet
