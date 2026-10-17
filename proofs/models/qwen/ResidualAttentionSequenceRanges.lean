import models.qwen.ResidualAttention
import models.qwen.AttentionSequenceRanges
import models.qwen.ResidualMlpRanges

namespace Inference.Models.Qwen.ResidualAttentionSequenceRanges
open Contracts.Mlx Contracts.Mlx.Numerics ResidualAttention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Kernels.Attention

structure Parameters (b : Layer) : Prop where
  mixer : AttentionSequenceRanges.Parameters b.inputNorm b.mixer
  suffix : ResidualMlpRanges.Parameters b.suffix
structure Primitives (b : Layer) where
  mixer : AttentionSequenceRanges.Primitives b.inputNorm b.mixer
  suffix : ResidualMlpRanges.Primitives b.suffix

structure CacheBound (cache : Cache BF steps) : Prop where
  keys : ∀ h t i, Model.isFinite (cache.keys h t i) = true ∧ |Model.toReal (cache.keys h t i)| ≤ 1024
  values : ∀ h t i, Model.isFinite (cache.values h t i) = true ∧ |Model.toReal (cache.values h t i)| ≤ (2 : ℝ)^(23 : Nat)

theorem CacheBound.finite (cache : Cache BF steps) (h : CacheBound cache) : State.Kv.Finite cache :=
  ⟨fun i t j => (h.keys i t j).1, fun i t j => (h.values i t j).1⟩

structure Result (b : Layer) (stage : Nat) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF steps) where
  finite : b.Finite x angle cache
  addition : ElementwiseAdd.Bounds (ResidualBlocks.residual x (b.mixed x angle cache)) (b.suffix.branch x (b.mixed x angle cache))
  output : ∀ i, |Model.toReal (b.forward x angle cache i)| ≤ (stage+1 : Nat)*(2 : ℝ)^(50 : Nat)
  cacheBound : CacheBound (b.cacheAfter x angle cache)

noncomputable def checked (b : Layer) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (x : Fin 5120 → BF) (hx : ResidualMlpRanges.InputBound stage x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (cache : Cache BF steps) (hc : CacheBound cache) (supported : steps+1 ≤ 262144) : Result b stage x angle cache := by
  have hcap : ResidualMlpRanges.inputCeiling stage ≤ (2 : ℝ)^(56 : Nat) := by
    have h : (stage : ℝ) ≤ 63 := by exact_mod_cast (show stage ≤ 63 by omega)
    unfold ResidualMlpRanges.inputCeiling
    push_cast
    norm_num
    linarith
  have mixer := AttentionSequenceRanges.ranges b.inputNorm b.mixer parameters.mixer primitive.mixer x
    (fun i => ⟨(hx i).1, (hx i).2.trans hcap⟩) angle ha steps supported cache hc.keys hc.values
  let suffix := ResidualMlpRanges.checked b.suffix parameters.suffix primitive.suffix stage hs x (b.mixed x angle cache) hx mixer.output
  exact ⟨⟨fun i => (hx i).1, fun i => (parameters.mixer.normalization i).1, mixer.normalization, mixer.finite, suffix.finite⟩,
    suffix.addition, suffix.output, ⟨mixer.keys, mixer.values⟩⟩

theorem next_input (b : Layer) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (x : Fin 5120 → BF) (hx : ResidualMlpRanges.InputBound stage x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (cache : Cache BF steps) (hc : CacheBound cache) (supported : steps+1 ≤ 262144) :
    ResidualMlpRanges.InputBound (stage+1) (b.forward x angle cache) := by
  let h := checked b parameters primitive stage hs x hx angle ha cache hc supported
  intro i
  refine ⟨ElementwiseAdd.forward_finite _ _ h.addition i, (h.output i).trans ?_⟩
  unfold ResidualMlpRanges.inputCeiling
  push_cast
  norm_num
  linarith

theorem accuracy (b : Layer) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (x : Fin 5120 → BF) (hx : ResidualMlpRanges.InputBound stage x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (cache : Cache BF steps) (cacheBound : CacheBound cache) (supported : steps+1 ≤ 262144)
    (target error : Fin 5120 → ℝ) (hi : ∀ i, |Model.toReal (x i)-target i| ≤ error i)
    (angleTarget angleError : RopeAngles.Target) (he : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base)
    (cacheTarget cacheError : Cache ℝ steps) (hc : State.Kv.Error cache cacheTarget cacheError) :
    (∀ i, |Model.toReal (b.forward x angle cache i)-b.target target angleTarget cacheTarget i| ≤
      b.budget x target error angle angleTarget angleError cache cacheTarget cacheError
        (checked b parameters primitive stage hs x hx angle ha cache cacheBound supported).finite i) ∧
    State.Kv.Error (b.cacheAfter x angle cache) (b.targetCacheAfter target angleTarget cacheTarget)
      (b.cacheBudget x target error angle angleTarget angleError cacheError) := by
  let h := checked b parameters primitive stage hs x hx angle ha cache cacheBound supported
  refine ⟨fun i => ?_, b.cache_error x target error angle angleTarget angleError cache cacheTarget cacheError hi hc h.finite he hb⟩
  exact b.suffix.forward_error_of_bounds x (b.mixed x angle cache) target (b.mixedTarget target angleTarget cacheTarget) error
    (b.mixedBudget x target error angle angleTarget angleError cache cacheTarget cacheError) hi
    (b.mixed_error x target error angle angleTarget angleError cache cacheTarget cacheError hi hc
      (CacheBound.finite cache cacheBound) h.finite he hb) h.finite.suffix h.addition i

end Inference.Models.Qwen.ResidualAttentionSequenceRanges
