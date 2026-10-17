import models.qwen.DeltaCache
import models.qwen.ResidualBlocks

namespace Inference.Models.Qwen.ResidualDelta
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- Complete arithmetic composition of QwenResidualDeltaLayer.forward, for
-- the no-adapter, one-row route. The loaded weights and static specialization
-- are parameters; their link to the model artifact is a separate obligation.
structure Layer where
  inputNorm : Blocks.Norm
  mixer : DeltaNet.Layer
  suffix : ResidualBlocks.Mlp
  epsilon : mixer.headParams.eps = Blocks.eps

def Layer.normalized (b : Layer) (x : Nat → Fin 5120 → BF) : Nat → Fin 5120 → BF := fun t => b.inputNorm.forward (x t)
noncomputable def Layer.normalizedTarget (b : Layer) (x : Nat → Fin 5120 → ℝ) : Nat → Fin 5120 → ℝ := fun t => b.inputNorm.target (x t)
noncomputable def Layer.normalizedBudget (b : Layer) (x : Nat → Fin 5120 → BF)
    (target error : Nat → Fin 5120 → ℝ) : Nat → Fin 5120 → ℝ := fun t => b.inputNorm.errorBudget (x t) (target t) (error t)

def Layer.mixed (b : Layer) (cache : DeltaNet.Cache) (x : Nat → Fin 5120 → BF) (time : Nat) : Fin 5120 → BF :=
  b.mixer.forward cache (b.normalized x) time
noncomputable def Layer.mixedTarget (b : Layer) (cache : DeltaNet.ReferenceCache) (x : Nat → Fin 5120 → ℝ) (time : Nat) : Fin 5120 → ℝ :=
  b.mixer.target Blocks.idealEps cache (b.normalizedTarget x) time
noncomputable def Layer.mixedBudget (b : Layer) (cache : DeltaNet.Cache) (targetCache errorCache : DeltaNet.ReferenceCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ) (time : Nat) : Fin 5120 → ℝ :=
  b.mixer.budget Blocks.idealEps Blocks.epsError cache targetCache errorCache (b.normalized x)
    (b.normalizedTarget target) (b.normalizedBudget x target error) time

def Layer.forward (b : Layer) (cache : DeltaNet.Cache) (x : Nat → Fin 5120 → BF) (time : Nat) : Fin 5120 → BF :=
  b.suffix.forward (x time) (b.mixed cache x time)
noncomputable def Layer.target (b : Layer) (cache : DeltaNet.ReferenceCache) (x : Nat → Fin 5120 → ℝ) (time : Nat) : Fin 5120 → ℝ :=
  b.suffix.target (x time) (b.mixedTarget cache x time)

structure Layer.Finite (b : Layer) (cache : DeltaNet.Cache) (x : Nat → Fin 5120 → BF) (time : Nat) where
  input : ∀ t i, Model.isFinite (x t i) = true
  weight : ∀ i, Model.isFinite (b.inputNorm.weight i) = true
  normalization : ∀ t, b.inputNorm.Finite (x t)
  mixer : b.mixer.Finite cache (b.normalized x) time
  suffix : b.suffix.Finite (x time) (b.mixed cache x time)

noncomputable def Layer.budget (b : Layer) (cache : DeltaNet.Cache) (targetCache errorCache : DeltaNet.ReferenceCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ) (time : Nat) (hf : b.Finite cache x time) : Fin 5120 → ℝ :=
  b.suffix.budget (x time) (b.mixed cache x time) (target time) (b.mixedTarget targetCache target time)
    (error time) (b.mixedBudget cache targetCache errorCache x target error time) hf.suffix

def Layer.Capacity (b : Layer) (cache : DeltaNet.Cache) (targetCache errorCache : DeltaNet.ReferenceCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ) (time : Nat) (hf : b.Finite cache x time) : Prop :=
  b.suffix.Capacity (x time) (b.mixed cache x time) (target time) (b.mixedTarget targetCache target time)
    (error time) (b.mixedBudget cache targetCache errorCache x target error time) hf.suffix

theorem Layer.normalized_error (b : Layer) (cache : DeltaNet.Cache) (x : Nat → Fin 5120 → BF)
    (target error : Nat → Fin 5120 → ℝ) (hi : ∀ t i, |Model.toReal (x t i) - target t i| ≤ error t i)
    (time : Nat) (hf : b.Finite cache x time) (t : Nat) (i : Fin 5120) :
    |Model.toReal (b.normalized x t i) - b.normalizedTarget target t i| ≤ b.normalizedBudget x target error t i :=
  b.inputNorm.forward_error (x t) (target t) (error t) (hi t) (hf.input t) hf.weight (hf.normalization t) i

theorem Layer.mixed_error (b : Layer) (cache : DeltaNet.Cache) (targetCache errorCache : DeltaNet.ReferenceCache)
    (hc : DeltaNet.CacheError cache targetCache errorCache) (x : Nat → Fin 5120 → BF)
    (target error : Nat → Fin 5120 → ℝ) (hi : ∀ t i, |Model.toReal (x t i) - target t i| ≤ error t i)
    (time : Nat) (hf : b.Finite cache x time) (i : Fin 5120) :
    |Model.toReal (b.mixed cache x time i) - b.mixedTarget targetCache target time i| ≤
      b.mixedBudget cache targetCache errorCache x target error time i :=
  b.mixer.forward_error Blocks.idealEps Blocks.epsError (by norm_num [Blocks.idealEps])
    (by rw [b.epsilon]; exact Blocks.eps_accuracy) cache targetCache errorCache hc (b.normalized x)
    (b.normalizedTarget target) (b.normalizedBudget x target error)
    (b.normalized_error cache x target error hi time hf) time hf.mixer i

theorem Layer.forward_error (b : Layer) (cache : DeltaNet.Cache) (targetCache errorCache : DeltaNet.ReferenceCache)
    (hc : DeltaNet.CacheError cache targetCache errorCache) (x : Nat → Fin 5120 → BF)
    (target error : Nat → Fin 5120 → ℝ) (hi : ∀ t i, |Model.toReal (x t i) - target t i| ≤ error t i)
    (time : Nat) (hf : b.Finite cache x time) (capacity : b.Capacity cache targetCache errorCache x target error time hf) (i : Fin 5120) :
    |Model.toReal (b.forward cache x time i) - b.target targetCache target time i| ≤
      b.budget cache targetCache errorCache x target error time hf i :=
  b.suffix.forward_error (x time) (b.mixed cache x time) (target time) (b.mixedTarget targetCache target time)
    (error time) (b.mixedBudget cache targetCache errorCache x target error time) (hi time)
    (b.mixed_error cache targetCache errorCache hc x target error hi time hf) hf.suffix capacity i

theorem Layer.forward_finite (b : Layer) (cache : DeltaNet.Cache) (targetCache errorCache : DeltaNet.ReferenceCache)
    (hc : DeltaNet.CacheError cache targetCache errorCache) (x : Nat → Fin 5120 → BF)
    (target error : Nat → Fin 5120 → ℝ) (hi : ∀ t i, |Model.toReal (x t i) - target t i| ≤ error t i)
    (time : Nat) (hf : b.Finite cache x time) (capacity : b.Capacity cache targetCache errorCache x target error time hf) (i : Fin 5120) :
    Model.isFinite (b.forward cache x time i) = true :=
  b.suffix.forward_finite (x time) (b.mixed cache x time) (target time) (b.mixedTarget targetCache target time)
    (error time) (b.mixedBudget cache targetCache errorCache x target error time) (hi time)
    (b.mixed_error cache targetCache errorCache hc x target error hi time hf) hf.suffix capacity i

def Layer.cacheAfter (b : Layer) (cache : DeltaNet.Cache) (x : Nat → Fin 5120 → BF) (steps : Nat) : DeltaNet.Cache :=
  DeltaCache.after b.mixer cache (b.normalized x) steps

noncomputable def Layer.targetCacheAfter (b : Layer) (cache : DeltaNet.ReferenceCache) (x : Nat → Fin 5120 → ℝ)
    (steps : Nat) : DeltaNet.ReferenceCache :=
  DeltaCache.targetAfter b.mixer Blocks.idealEps cache (b.normalizedTarget x) steps

noncomputable def Layer.cacheBudget (b : Layer) (cache : DeltaNet.Cache) (targetCache errorCache : DeltaNet.ReferenceCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ) (steps : Nat) : DeltaNet.ReferenceCache :=
  DeltaCache.budgetAfter b.mixer Blocks.idealEps Blocks.epsError cache targetCache errorCache (b.normalized x)
    (b.normalizedTarget target) (b.normalizedBudget x target error) steps

theorem Layer.cache_error (b : Layer) (cache : DeltaNet.Cache) (targetCache errorCache : DeltaNet.ReferenceCache)
    (hc : DeltaNet.CacheError cache targetCache errorCache) (x : Nat → Fin 5120 → BF)
    (target error : Nat → Fin 5120 → ℝ) (hi : ∀ t i, |Model.toReal (x t i) - target t i| ≤ error t i)
    (time : Nat) (hf : b.Finite cache x time) :
    DeltaNet.CacheError (b.cacheAfter cache x (time+1)) (b.targetCacheAfter targetCache target (time+1))
      (b.cacheBudget cache targetCache errorCache x target error (time+1)) :=
  DeltaCache.after_error b.mixer Blocks.idealEps Blocks.epsError (by norm_num [Blocks.idealEps])
    (by rw [b.epsilon]; exact Blocks.eps_accuracy) cache targetCache errorCache hc (b.normalized x)
    (b.normalizedTarget target) (b.normalizedBudget x target error)
    (b.normalized_error cache x target error hi time hf) hf.mixer.projections hf.mixer.convolution time hf.mixer.recurrence

theorem Layer.cache_finite (b : Layer) (cache : DeltaNet.Cache) (x : Nat → Fin 5120 → BF) (time : Nat)
    (hf : b.Finite cache x time) : DeltaCache.Finite (b.cacheAfter cache x (time+1)) :=
  DeltaCache.after_finite b.mixer cache (b.normalized x) hf.mixer.projections hf.mixer.convolution time hf.mixer.recurrence

end Inference.Models.Qwen.ResidualDelta
