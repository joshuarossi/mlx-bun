import models.qwen.ResidualAttention

namespace Inference.Models.Qwen.AttentionExecution
open Kernels.Attention
abbrev BF := Contracts.Mlx.BFloat16Arithmetic.Value

-- A static implementation supplies both the attention output and its
-- returned cache, together with their exact refinement proof. This is a
-- theorem interface; inference gains no dynamic validation or dispatch.
structure Implementation where
  Trace : {n : Nat} → Attention.Layer → (Fin 5120 → BF) → RopeAngles.Inputs → State.Kv.Cache BF n → Type
  run : {n : Nat} → (layer : Attention.Layer) → (input : Fin 5120 → BF) → (angle : RopeAngles.Inputs) →
    (cache : State.Kv.Cache BF n) → Trace layer input angle cache → (Fin 5120 → BF) × State.Kv.Cache BF (n+1)
  refines : ∀ {n} layer input angle (cache : State.Kv.Cache BF n) execution,
    run layer input angle cache execution=(layer.forward input angle cache, layer.cacheAfter input angle cache)
  canonical : ∀ {n} layer input angle (cache : State.Kv.Cache BF n), Trace layer input angle cache

def reference : Implementation where
  Trace := fun _ _ _ _ => PUnit
  run := fun layer input angle cache _ => (layer.forward input angle cache, layer.cacheAfter input angle cache)
  refines := fun _ _ _ _ _ => rfl
  canonical := fun _ _ _ _ => ⟨⟩

abbrev ResidualTrace (impl : Implementation) (layer : ResidualAttention.Layer) (input : Fin 5120 → BF)
    (angle : RopeAngles.Inputs) (cache : State.Kv.Cache BF n) :=
  impl.Trace layer.mixer (layer.inputNorm.forward input) angle cache

def mixed (impl : Implementation) (layer : ResidualAttention.Layer) (input : Fin 5120 → BF)
    (angle : RopeAngles.Inputs) (cache : State.Kv.Cache BF n) (execution : ResidualTrace impl layer input angle cache) : Fin 5120 → BF :=
  (impl.run layer.mixer (layer.inputNorm.forward input) angle cache execution).1

def cacheAfter (impl : Implementation) (layer : ResidualAttention.Layer) (input : Fin 5120 → BF)
    (angle : RopeAngles.Inputs) (cache : State.Kv.Cache BF n) (execution : ResidualTrace impl layer input angle cache) : State.Kv.Cache BF (n+1) :=
  (impl.run layer.mixer (layer.inputNorm.forward input) angle cache execution).2

theorem mixed_eq (impl : Implementation) (layer : ResidualAttention.Layer) (input : Fin 5120 → BF)
    (angle : RopeAngles.Inputs) (cache : State.Kv.Cache BF n) (execution : ResidualTrace impl layer input angle cache) :
    mixed impl layer input angle cache execution=layer.mixed input angle cache := by
  unfold mixed
  rw [impl.refines]
  rfl

theorem cache_eq (impl : Implementation) (layer : ResidualAttention.Layer) (input : Fin 5120 → BF)
    (angle : RopeAngles.Inputs) (cache : State.Kv.Cache BF n) (execution : ResidualTrace impl layer input angle cache) :
    cacheAfter impl layer input angle cache execution=layer.cacheAfter input angle cache := by
  unfold cacheAfter
  rw [impl.refines]
  rfl

end Inference.Models.Qwen.AttentionExecution
