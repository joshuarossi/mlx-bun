import host.load.Growth
import host.mlx.FfiEval

namespace Host.Load.CacheBoundary
open Host.Mlx Host.Mlx.FfiEval

/-- Positive cached positions already imply positive aligned capacity from
the existing semantic cache invariant. No separate capacity premise is
needed for a later source-loop iteration. -/
theorem positive_capacity_of_state (buffer : Value)
    (rows : Fin 4 → Fin n → Fin 256 → BF)
    (state : GlueKv.State (some buffer) n rows) (positive : 0 < n) :
    ∃ capacity, Growth.CapacityInvariant capacity ∧ GlueKv.Holds buffer capacity n rows := by
  obtain ⟨capacity,aligned,holds⟩ := state
  exact ⟨capacity,⟨by have := holds.2.2.1; omega,aligned⟩,holds⟩

/-- For a one-token append the interior, exact-fill alias and full-growth
branches exhaust every valid positive-capacity cache entry. -/
theorem populated_cases (position capacity : Nat) (within : position ≤ capacity)
    (aligned : capacity % 256 = 0) :
    position + 1 < capacity ∨ position + 1 = capacity ∨
      (position = capacity ∧ position % 256 = 0) := by omega

theorem growth_has_no_trim (position capacity : Nat) (within : position ≤ capacity)
    (aligned : capacity % 256 = 0) (growth : capacity < position + 1) :
    position = capacity ∧ position % 256 = 0 := by omega

theorem interior_capacity (position capacity : Nat) (room : position + 1 < capacity) :
    kvCap (some capacity) position = capacity ∧ kvCap (some capacity) position ≠ position + 1 := by
  have noGrowth : ¬ capacity < position + 1 := by omega
  simp [kvCap, noGrowth, show capacity ≠ position + 1 by omega]

theorem fill_capacity (position capacity : Nat) (full : position + 1 = capacity) :
    kvCap (some capacity) position = position + 1 := by
  have noGrowth : ¬ capacity < position + 1 := by omega
  simpa [kvCap, noGrowth] using full.symm

theorem growth_capacity (capacity : Nat) (aligned : capacity % 256 = 0) :
    kvCap (some capacity) capacity = capacity + 256 ∧
      Growth.CapacityInvariant (capacity + 256) := by
  refine ⟨by simp [kvCap, aligned], by omega, by omega⟩

end Host.Load.CacheBoundary
