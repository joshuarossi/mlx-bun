import contracts.mlx.ThreadgroupWrites
import Mathlib.Data.List.Nodup

namespace Inference.Contracts.Mlx.WriteOwnership

-- Threads may write their own cells repeatedly in source order. Distinct
-- threads must have disjoint destinations, independent of stored values.
def Separated (address : α → Nat) (programs : List (List α)) : Prop :=
  programs.Pairwise (fun left right => List.Disjoint (left.map address) (right.map address))

theorem owned (labels : List ι) (unique : labels.Nodup) (program : ι → List α)
    (address : α → Nat) (owner : Nat → ι)
    (assigned : ∀ label ∈ labels, ∀ store ∈ program label, owner (address store)=label) :
    Separated address (labels.map program) := by
  apply List.pairwise_map.mpr
  apply unique.imp_of_mem
  intro first second hf hs different word left right
  obtain ⟨a, ha, ea⟩ := List.mem_map.mp left
  obtain ⟨b, hb, eb⟩ := List.mem_map.mp right
  have firstOwner := assigned first hf a ha
  have secondOwner := assigned second hs b hb
  rw [ea] at firstOwner
  rw [eb] at secondOwner
  exact different (firstOwner.symm.trans secondOwner)

theorem different_owners (owner : Nat → ι) (a b : Nat) (first second : ι)
    (ha : owner a=first) (hb : owner b=second) (different : first ≠ second) : a ≠ b := by
  intro equal
  subst b
  exact different (ha.symm.trans hb)

end Inference.Contracts.Mlx.WriteOwnership
