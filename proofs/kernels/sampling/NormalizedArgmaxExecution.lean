import kernels.sampling.NormalizedScores
import kernels.sampling.NormalizedArgmaxLayout

namespace Inference.Kernels.Sampling.NormalizedArgmaxExecution
open Contracts.Mlx Contracts.Mlx.Numerics NormalizedArgmaxLayout ArgmaxPairs
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Functional execution of the two selected kernels, retaining the source's
-- lane-strided loops, 1024-word tiles and exact shuffle trees. Scratch-memory
-- realization and native compilation are separate correspondence obligations.
def partialValues (input : Fin 248320 → Candidate) (tile : Fin 243) (thread : Fin 128) : List Candidate :=
  (partialOffsets tile thread).attach.map (fun i => input ⟨i.val, visited_in_bounds tile thread i.val i.property⟩)
def partialLane (input : Fin 248320 → Candidate) (tile : Fin 243) (thread : Fin 128) : Candidate :=
  scan (partialValues input tile thread) sentinel
def partialTile (input : Fin 248320 → Candidate) (tile : Fin 243) : Candidate :=
  tree (partialLane input tile) threadgroupTree
def finishValues (input : Fin 248320 → Candidate) (thread : Fin 128) : List Candidate :=
  (finishOffsets thread).attach.map (fun i => partialTile input ⟨i.val, finish_in_bounds thread i.val i.property⟩)
def finishLane (input : Fin 248320 → Candidate) (thread : Fin 128) : Candidate :=
  scan (finishValues input thread) sentinel
def run (input : Fin 248320 → Candidate) : Candidate := tree (finishLane input) threadgroupTree

theorem partial_mem (input : Fin 248320 → Candidate) (i : Fin 248320) :
    input i ∈ partialValues input (tileOf i) (threadOf i) := by
  apply List.mem_map.mpr
  refine ⟨⟨i.val, token_visited i⟩, by simp, ?_⟩
  congr 1

theorem partial_values_finite (input : Fin 248320 → Candidate) (hi : ∀ i, Finite (input i))
    (tile : Fin 243) (thread : Fin 128) : ∀ x ∈ partialValues input tile thread, Finite x := by
  intro x hx
  obtain ⟨i, _, rfl⟩ := List.mem_map.mp hx
  exact hi _
theorem partial_lane_finite (input : Fin 248320 → Candidate) (hi : ∀ i, Finite (input i))
    (tile : Fin 243) (thread : Fin 128) : Finite (partialLane input tile thread) :=
  scan_finite _ _ sentinel_finite (partial_values_finite input hi tile thread)
theorem partial_finite (input : Fin 248320 → Candidate) (hi : ∀ i, Finite (input i)) (tile : Fin 243) :
    Finite (partialTile input tile) := tree_finite _ _ (partial_lane_finite input hi tile)

theorem partial_dominates (input : Fin 248320 → Candidate) (hi : ∀ i, Finite (input i)) (i : Fin 248320) :
    Argmax.Dominates (semantic (partialTile input (tileOf i))) (semantic (input i)) := by
  have htree := tree_correct (partialLane input (tileOf i)) threadgroupTree
    (partial_lane_finite input hi (tileOf i)) threadgroup_coverage (threadOf i)
  have hscan := scan_dominates (partialValues input (tileOf i) (threadOf i)) sentinel sentinel_finite
    (partial_values_finite input hi (tileOf i) (threadOf i)) (input i) (partial_mem input i)
  exact Argmax.dominates_trans htree hscan

theorem finish_mem (input : Fin 248320 → Candidate) (tile : Fin 243) :
    partialTile input tile ∈ finishValues input (finishThread tile) := by
  apply List.mem_map.mpr
  refine ⟨⟨tile.val, partial_visited tile⟩, by simp, ?_⟩
  congr 1

theorem finish_values_finite (input : Fin 248320 → Candidate) (hi : ∀ i, Finite (input i)) (thread : Fin 128) :
    ∀ x ∈ finishValues input thread, Finite x := by
  intro x hx
  obtain ⟨i, _, rfl⟩ := List.mem_map.mp hx
  exact partial_finite input hi _
theorem finish_lane_finite (input : Fin 248320 → Candidate) (hi : ∀ i, Finite (input i)) (thread : Fin 128) :
    Finite (finishLane input thread) := scan_finite _ _ sentinel_finite (finish_values_finite input hi thread)
theorem run_finite (input : Fin 248320 → Candidate) (hi : ∀ i, Finite (input i)) : Finite (run input) :=
  tree_finite _ _ (finish_lane_finite input hi)

theorem run_dominates (input : Fin 248320 → Candidate) (hi : ∀ i, Finite (input i)) (i : Fin 248320) :
    Argmax.Dominates (semantic (run input)) (semantic (input i)) := by
  have htree := tree_correct (finishLane input) threadgroupTree (finish_lane_finite input hi)
    threadgroup_coverage (finishThread (tileOf i))
  have hscan := scan_dominates (finishValues input (finishThread (tileOf i))) sentinel sentinel_finite
    (finish_values_finite input hi (finishThread (tileOf i))) (partialTile input (tileOf i)) (finish_mem input (tileOf i))
  exact Argmax.dominates_trans (Argmax.dominates_trans htree hscan) (partial_dominates input hi i)

def Origin (input : Fin 248320 → Candidate) (x : Candidate) : Prop := x = sentinel ∨ ∃ i, x = input i

theorem partial_origin (input : Fin 248320 → Candidate) (tile : Fin 243) : Origin input (partialTile input tile) := by
  apply tree_preserves (Origin input)
  intro thread
  apply scan_preserves (Origin input) _ sentinel (Or.inl rfl)
  intro x hx
  obtain ⟨i, _, rfl⟩ := List.mem_map.mp hx
  exact Or.inr ⟨_, rfl⟩

theorem run_origin (input : Fin 248320 → Candidate) : Origin input (run input) := by
  apply tree_preserves (Origin input)
  intro thread
  apply scan_preserves (Origin input) _ sentinel (Or.inl rfl)
  intro x hx
  obtain ⟨i, _, rfl⟩ := List.mem_map.mp hx
  exact partial_origin input _

theorem run_correct (input : Fin 248320 → Candidate) (hi : ∀ i, Finite (input i))
    (present : ∀ i, ∃ value, (input i).score = some value) :
    ∃ selected, run input = input selected ∧ ∀ i, Argmax.Dominates (semantic (run input)) (semantic (input i)) := by
  rcases run_origin input with he | ⟨selected, he⟩
  · obtain ⟨value, hv⟩ := present ⟨0, by decide⟩
    have h := (run_dominates input hi ⟨0, by decide⟩).1
    rw [he] at h
    change (match (input ⟨0, by decide⟩).score with
      | none => (⊥ : WithBot ℝ)
      | some value => (real (FlushToZero.flush value) : WithBot ℝ)) ≤ ⊥ at h
    rw [hv] at h
    simp at h
  · exact ⟨selected, he, run_dominates input hi⟩

theorem normalized_correct (logits : Fin 248320 → NormalizedScores.BF) (normalizer : NormalizedScores.BF)
    (hl : ∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat))
    (hn : Model.isFinite normalizer = true ∧ |Model.toReal normalizer| ≤ (2 : ℝ)^(24 : Nat)) :
    ∃ selected : Fin 248320, (run (NormalizedScores.candidates logits normalizer)).index = selected.val ∧
      (∀ i, real (NormalizedScores.value (logits i) normalizer) ≤ real (NormalizedScores.value (logits selected) normalizer)) ∧
      (∀ i, real (NormalizedScores.value (logits selected) normalizer) = real (NormalizedScores.value (logits i) normalizer) → selected.val ≤ i.val) := by
  obtain ⟨selected, he, h⟩ := run_correct (NormalizedScores.candidates logits normalizer)
    (NormalizedScores.candidates_finite logits normalizer hl hn) (fun i => ⟨_, rfl⟩)
  have hfix i := NormalizedScores.value_flush (logits i) normalizer (hl i) hn
  refine ⟨selected, congrArg (fun x => x.index) he, ?_, ?_⟩
  · intro i
    have hi := (h i).1
    rw [he] at hi
    simpa only [NormalizedScores.candidates, semantic, WithBot.coe_le_coe, hfix] using hi
  · intro i equal
    have hi := h i
    rw [he] at hi
    exact hi.2 (by simpa only [NormalizedScores.candidates, semantic, WithBot.coe_eq_coe, hfix] using equal)


end Inference.Kernels.Sampling.NormalizedArgmaxExecution
