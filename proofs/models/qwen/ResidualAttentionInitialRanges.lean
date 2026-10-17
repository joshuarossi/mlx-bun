import models.qwen.ResidualAttention
import models.qwen.AttentionInitialRanges
import models.qwen.ResidualMlpRanges

namespace Inference.Models.Qwen.ResidualAttentionInitialRanges
open Contracts.Mlx Contracts.Mlx.Numerics ResidualAttention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Kernels.Attention

structure Parameters (b : Layer) : Prop where
  mixer : AttentionInitialRanges.Parameters b.inputNorm b.mixer
  suffix : ResidualMlpRanges.Parameters b.suffix
structure Primitives (b : Layer) where
  mixer : AttentionInitialRanges.Primitives b.inputNorm b.mixer
  suffix : ResidualMlpRanges.Primitives b.suffix

structure Result (b : Layer) (stage : Nat) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF 0) where
  finite : b.Finite x angle cache
  addition : ElementwiseAdd.Bounds (ResidualBlocks.residual x (b.mixed x angle cache)) (b.suffix.branch x (b.mixed x angle cache))
  output : ∀ i, |Model.toReal (b.forward x angle cache i)| ≤ (stage+1 : Nat) * (2 : ℝ)^(50 : Nat)
  keys : ∀ h t i, Model.isFinite ((b.cacheAfter x angle cache).keys h t i) = true ∧
    |Model.toReal ((b.cacheAfter x angle cache).keys h t i)| ≤ 1024
  values : ∀ h t i, Model.isFinite ((b.cacheAfter x angle cache).values h t i) = true ∧
    |Model.toReal ((b.cacheAfter x angle cache).values h t i)| ≤ (2 : ℝ)^(23 : Nat)

noncomputable def checked (b : Layer) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (x : Fin 5120 → BF) (hx : ResidualMlpRanges.InputBound stage x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0)
    (cache : Cache BF 0) : Result b stage x angle cache := by
  have hcap : ResidualMlpRanges.inputCeiling stage ≤ (2 : ℝ)^(56 : Nat) := by
    have h : (stage : ℝ) ≤ 63 := by exact_mod_cast (show stage ≤ 63 by omega)
    unfold ResidualMlpRanges.inputCeiling
    push_cast
    norm_num
    linarith
  have mixer := AttentionInitialRanges.ranges b.inputNorm b.mixer parameters.mixer primitive.mixer x
    (fun i => ⟨(hx i).1, (hx i).2.trans hcap⟩) angle ha position cache
  let suffix := ResidualMlpRanges.checked b.suffix parameters.suffix primitive.suffix stage hs x (b.mixed x angle cache) hx mixer.output
  exact ⟨⟨fun i => (hx i).1, fun i => (parameters.mixer.normalization i).1, mixer.normalization, mixer.finite, suffix.finite⟩,
    suffix.addition, suffix.output, mixer.keys, mixer.values⟩

theorem next_input (b : Layer) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (x : Fin 5120 → BF) (hx : ResidualMlpRanges.InputBound stage x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0)
    (cache : Cache BF 0) : ResidualMlpRanges.InputBound (stage+1) (b.forward x angle cache) := by
  let h := checked b parameters primitive stage hs x hx angle ha position cache
  intro i
  refine ⟨ElementwiseAdd.forward_finite _ _ h.addition i, (h.output i).trans ?_⟩
  unfold ResidualMlpRanges.inputCeiling
  push_cast
  norm_num
  linarith

theorem accuracy (b : Layer) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (x : Fin 5120 → BF) (hx : ResidualMlpRanges.InputBound stage x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0)
    (cache : Cache BF 0) (target error : Fin 5120 → ℝ) (hi : ∀ i, |Model.toReal (x i)-target i| ≤ error i)
    (angleTarget angleError : RopeAngles.Target) (he : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base)
    (cacheTarget cacheError : Cache ℝ 0) (hc : State.Kv.Error cache cacheTarget cacheError) :
    (∀ i, |Model.toReal (b.forward x angle cache i)-b.target target angleTarget cacheTarget i| ≤
      b.budget x target error angle angleTarget angleError cache cacheTarget cacheError
        (checked b parameters primitive stage hs x hx angle ha position cache).finite i) ∧
    State.Kv.Error (b.cacheAfter x angle cache) (b.targetCacheAfter target angleTarget cacheTarget)
      (b.cacheBudget x target error angle angleTarget angleError cacheError) := by
  let h := checked b parameters primitive stage hs x hx angle ha position cache
  have hcf : State.Kv.Finite cache := by constructor <;> intro _ t <;> exact Fin.elim0 t
  refine ⟨fun i => ?_, b.cache_error x target error angle angleTarget angleError cache cacheTarget cacheError hi hc h.finite he hb⟩
  exact b.suffix.forward_error_of_bounds x (b.mixed x angle cache) target (b.mixedTarget target angleTarget cacheTarget) error
    (b.mixedBudget x target error angle angleTarget angleError cache cacheTarget cacheError) hi
    (b.mixed_error x target error angle angleTarget angleError cache cacheTarget cacheError hi hc hcf h.finite he hb)
    h.finite.suffix h.addition i

end Inference.Models.Qwen.ResidualAttentionInitialRanges
