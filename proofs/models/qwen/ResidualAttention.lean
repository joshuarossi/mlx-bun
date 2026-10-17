import models.qwen.Attention
import models.qwen.ResidualBlocks

namespace Inference.Models.Qwen.ResidualAttention
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Kernels.Attention
abbrev BF := BFloat16Arithmetic.Value
abbrev Cache := State.Kv.Cache

-- QwenResidualAttentionLayer.forward: input RMS normalization, attention,
-- fused residual/RMS normalization, Trellis MLP, and final residual addition.
structure Layer where
  inputNorm : Blocks.Norm
  mixer : Attention.Layer
  suffix : ResidualBlocks.Mlp

def Layer.mixed (b : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n) : Fin 5120 → BF :=
  b.mixer.forward (b.inputNorm.forward x) angle cache
noncomputable def Layer.mixedTarget (b : Layer) (x : Fin 5120 → ℝ) (angle : RopeAngles.Target) (cache : Cache ℝ n) : Fin 5120 → ℝ :=
  b.mixer.target (b.inputNorm.target x) angle cache
noncomputable def Layer.mixedBudget (b : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n) : Fin 5120 → ℝ :=
  b.mixer.budget (b.inputNorm.forward x) (b.inputNorm.target target) (b.inputNorm.errorBudget x target error)
    angle angleTarget angleError cache cacheTarget cacheError
def Layer.forward (b : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n) : Fin 5120 → BF :=
  b.suffix.forward x (b.mixed x angle cache)
noncomputable def Layer.target (b : Layer) (x : Fin 5120 → ℝ) (angle : RopeAngles.Target) (cache : Cache ℝ n) : Fin 5120 → ℝ :=
  b.suffix.target x (b.mixedTarget x angle cache)

structure Layer.Finite (b : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n) where
  input : ∀ i, Model.isFinite (x i) = true
  weight : ∀ i, Model.isFinite (b.inputNorm.weight i) = true
  normalization : b.inputNorm.Finite x
  mixer : b.mixer.Finite (b.inputNorm.forward x) angle cache
  suffix : b.suffix.Finite x (b.mixed x angle cache)

noncomputable def Layer.budget (b : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n) (hf : b.Finite x angle cache) : Fin 5120 → ℝ :=
  b.suffix.budget x (b.mixed x angle cache) target (b.mixedTarget target angleTarget cacheTarget)
    error (b.mixedBudget x target error angle angleTarget angleError cache cacheTarget cacheError) hf.suffix
def Layer.Capacity (b : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n) (hf : b.Finite x angle cache) : Prop :=
  b.suffix.Capacity x (b.mixed x angle cache) target (b.mixedTarget target angleTarget cacheTarget)
    error (b.mixedBudget x target error angle angleTarget angleError cache cacheTarget cacheError) hf.suffix

theorem Layer.normalized_error (b : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (cache : Cache BF n)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hf : b.Finite x angle cache) (i : Fin 5120) :
    |Model.toReal (b.inputNorm.forward x i) - b.inputNorm.target target i| ≤ b.inputNorm.errorBudget x target error i :=
  b.inputNorm.forward_error x target error hi hf.input hf.weight hf.normalization i

theorem Layer.mixed_error (b : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hc : State.Kv.Error cache cacheTarget cacheError)
    (hcf : State.Kv.Finite cache) (hf : b.Finite x angle cache)
    (ha : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base) (i : Fin 5120) :
    |Model.toReal (b.mixed x angle cache i) - b.mixedTarget target angleTarget cacheTarget i| ≤
      b.mixedBudget x target error angle angleTarget angleError cache cacheTarget cacheError i :=
  b.mixer.forward_error _ _ _ angle angleTarget angleError cache cacheTarget cacheError
    (b.normalized_error x target error angle cache hi hf) hc hcf hf.mixer ha hb i

theorem Layer.forward_error (b : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hc : State.Kv.Error cache cacheTarget cacheError)
    (hcf : State.Kv.Finite cache) (hf : b.Finite x angle cache)
    (ha : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base)
    (capacity : b.Capacity x target error angle angleTarget angleError cache cacheTarget cacheError hf) (i : Fin 5120) :
    |Model.toReal (b.forward x angle cache i) - b.target target angleTarget cacheTarget i| ≤
      b.budget x target error angle angleTarget angleError cache cacheTarget cacheError hf i :=
  b.suffix.forward_error x (b.mixed x angle cache) target (b.mixedTarget target angleTarget cacheTarget) error
    (b.mixedBudget x target error angle angleTarget angleError cache cacheTarget cacheError) hi
    (b.mixed_error x target error angle angleTarget angleError cache cacheTarget cacheError hi hc hcf hf ha hb) hf.suffix capacity i

theorem Layer.forward_finite (b : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hc : State.Kv.Error cache cacheTarget cacheError)
    (hcf : State.Kv.Finite cache) (hf : b.Finite x angle cache)
    (ha : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base)
    (capacity : b.Capacity x target error angle angleTarget angleError cache cacheTarget cacheError hf) (i : Fin 5120) :
    Model.isFinite (b.forward x angle cache i) = true :=
  b.suffix.forward_finite x (b.mixed x angle cache) target (b.mixedTarget target angleTarget cacheTarget) error
    (b.mixedBudget x target error angle angleTarget angleError cache cacheTarget cacheError) hi
    (b.mixed_error x target error angle angleTarget angleError cache cacheTarget cacheError hi hc hcf hf ha hb) hf.suffix capacity i

def Layer.cacheAfter (b : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n) : Cache BF (n+1) :=
  b.mixer.cacheAfter (b.inputNorm.forward x) angle cache
noncomputable def Layer.targetCacheAfter (b : Layer) (x : Fin 5120 → ℝ) (angle : RopeAngles.Target) (cache : Cache ℝ n) : Cache ℝ (n+1) :=
  b.mixer.targetCacheAfter (b.inputNorm.target x) angle cache
noncomputable def Layer.cacheBudget (b : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target) (cacheError : Cache ℝ n) : Cache ℝ (n+1) :=
  b.mixer.cacheBudgets (b.inputNorm.forward x) (b.inputNorm.target target) (b.inputNorm.errorBudget x target error)
    angle angleTarget angleError cacheError

theorem Layer.cache_error (b : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hc : State.Kv.Error cache cacheTarget cacheError)
    (hf : b.Finite x angle cache) (ha : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base) :
    State.Kv.Error (b.cacheAfter x angle cache) (b.targetCacheAfter target angleTarget cacheTarget)
      (b.cacheBudget x target error angle angleTarget angleError cacheError) :=
  b.mixer.cache_error _ _ _ angle angleTarget angleError cache cacheTarget cacheError
    (b.normalized_error x target error angle cache hi hf) hc hf.mixer ha hb

theorem Layer.cache_finite (b : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n)
    (hc : State.Kv.Finite cache) (hf : b.Finite x angle cache) : State.Kv.Finite (b.cacheAfter x angle cache) :=
  b.mixer.cache_finite _ angle cache hc hf.mixer

end Inference.Models.Qwen.ResidualAttention
