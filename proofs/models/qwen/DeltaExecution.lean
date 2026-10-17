import models.qwen.ResidualDelta

namespace Inference.Models.Qwen.DeltaExecution
abbrev BF := Contracts.Mlx.BFloat16Arithmetic.Value

structure Implementation where
  Trace : DeltaNet.Layer → (Fin 5120 → BF) → DeltaNet.Cache → Type
  run : (layer : DeltaNet.Layer) → (input : Fin 5120 → BF) → (cache : DeltaNet.Cache) →
    Trace layer input cache → (Fin 5120 → BF) × DeltaNet.Cache
  refines : ∀ layer input cache execution,
    run layer input cache execution=(layer.forward cache (fun _ => input) 0, DeltaCache.after layer cache (fun _ => input) 1)
  canonical : ∀ layer input cache, Trace layer input cache

def reference : Implementation where
  Trace := fun _ _ _ => PUnit
  run := fun layer input cache _ => (layer.forward cache (fun _ => input) 0, DeltaCache.after layer cache (fun _ => input) 1)
  refines := fun _ _ _ _ => rfl
  canonical := fun _ _ _ => ⟨⟩

abbrev ResidualTrace (impl : Implementation) (layer : ResidualDelta.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache) :=
  impl.Trace layer.mixer (layer.inputNorm.forward input) cache

def mixed (impl : Implementation) (layer : ResidualDelta.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : ResidualTrace impl layer input cache) : Fin 5120 → BF :=
  (impl.run layer.mixer (layer.inputNorm.forward input) cache execution).1

def cacheAfter (impl : Implementation) (layer : ResidualDelta.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : ResidualTrace impl layer input cache) : DeltaNet.Cache :=
  (impl.run layer.mixer (layer.inputNorm.forward input) cache execution).2

theorem mixed_eq (impl : Implementation) (layer : ResidualDelta.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : ResidualTrace impl layer input cache) : mixed impl layer input cache execution=layer.mixed cache (fun _ => input) 0 := by
  unfold mixed
  rw [impl.refines]
  rfl

theorem cache_eq (impl : Implementation) (layer : ResidualDelta.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : ResidualTrace impl layer input cache) : cacheAfter impl layer input cache execution=layer.cacheAfter cache (fun _ => input) 1 := by
  unfold cacheAfter
  rw [impl.refines]
  rfl

end Inference.Models.Qwen.DeltaExecution
