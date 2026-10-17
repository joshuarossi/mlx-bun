import kernels.sampling.ArgmaxShuffleSemantics
import kernels.sampling.NormalizedArgmaxMemory

namespace Inference.Kernels.Sampling.ArgmaxSourceOrigins
open Contracts.Mlx ArgmaxPairs ArgmaxShuffleSyntax ArgmaxShuffleSemantics
open NormalizedArgmaxExecution (Origin)
set_option maxRecDepth 10000

-- Candidate identity comes from the unique original token ID, including its
-- exact float bits. Semantic score equality alone would lose signed-zero bits.
def Identified (input : Fin 248320 → Candidate) : Prop := ∀ i, (input i).index=i.val

theorem unique (input : Fin 248320 → Candidate) (identified : Identified input)
    (x y : Candidate) (first : Origin input x) (second : Origin input y) (same : x.index=y.index) : x=y := by
  rcases first with rfl|⟨i,rfl⟩ <;> rcases second with rfl|⟨j,rfl⟩
  · rfl
  · have bound := j.isLt
    rw [identified] at same
    change 4294967295=j.val at same
    omega
  · have bound := i.isLt
    rw [identified] at same
    change i.val=4294967295 at same
    omega
  · rw [identified,identified] at same
    exact congrArg input (Fin.ext same)

theorem round_origin (original : Fin 248320 → Candidate) (input : Fin n → Candidate)
    (origin : ∀ i, Origin original (input i)) (distance : Nat) :
    ∀ i, Origin original (round betterExpr distance input i) := by
  intro i
  unfold ArgmaxShuffleSemantics.round
  split
  · rw [selected_eq]
    exact choose_preserves _ _ _ (origin _) (origin _)
  · exact origin _

theorem rounds_origin (original : Fin 248320 → Candidate) (input : Fin n → Candidate)
    (origin : ∀ i, Origin original (input i)) (distances : List Nat) :
    ∀ i, Origin original (rounds betterExpr distances input i) := by
  induction distances generalizing input with
  | nil => exact origin
  | cons distance rest ih => exact ih _ (round_origin original input origin distance)

theorem simd_exact (original : Fin 248320 → Candidate) (identified : Identified original)
    (input : Fin 32 → Candidate) (finite : ∀ i, Finite (input i)) (origin : ∀ i, Origin original (input i)) :
    runLoop betterExpr ⟨16,1,32⟩ input 0=tree input NormalizedArgmaxLayout.simdTree :=
  unique original identified _ _ (rounds_origin original input origin _ 0)
    (tree_preserves (Origin original) _ _ origin)
    (congrArg Argmax.Candidate.index (simd_semantic input finite))

theorem merge_exact (original : Fin 248320 → Candidate) (identified : Identified original)
    (input : Fin 4 → Candidate) (finite : ∀ i, Finite (input i)) (origin : ∀ i, Origin original (input i)) :
    runLoop betterExpr ⟨2,1,4⟩ input 0=tree input NormalizedArgmaxLayout.mergeTree :=
  unique original identified _ _ (rounds_origin original input origin _ 0)
    (tree_preserves (Origin original) _ _ origin)
    (congrArg Argmax.Candidate.index (merge_semantic input finite))

theorem parsed_simd_exact (original : Fin 248320 → Candidate) (identified : Identified original)
    (input : Fin 32 → Candidate) (finite : ∀ i, Finite (input i)) (origin : ∀ i, Origin original (input i)) :
    parsedRun simdLoop input 0=some (tree input NormalizedArgmaxLayout.simdTree) := by
  unfold parsedRun
  rw [parsed_better,parsed_simd]
  change some (runLoop betterExpr ⟨16,1,32⟩ input 0)=_
  exact congrArg some (simd_exact original identified input finite origin)

theorem parsed_merge_exact (original : Fin 248320 → Candidate) (identified : Identified original)
    (input : Fin 4 → Candidate) (finite : ∀ i, Finite (input i)) (origin : ∀ i, Origin original (input i)) :
    parsedRun mergeLoop input 0=some (tree input NormalizedArgmaxLayout.mergeTree) := by
  unfold parsedRun
  rw [parsed_better,parsed_merge]
  change some (runLoop betterExpr ⟨2,1,4⟩ input 0)=_
  exact congrArg some (merge_exact original identified input finite origin)

theorem partial_lane_origin (input : Fin 248320 → Candidate) (tile : Fin 243) (thread : Fin 128) :
    Origin input (NormalizedArgmaxExecution.partialLane input tile thread) := by
  apply scan_preserves (Origin input) _ sentinel (Or.inl rfl)
  intro value member
  obtain ⟨index,_,rfl⟩ := List.mem_map.mp member
  exact Or.inr ⟨_,rfl⟩

theorem group_exact (original : Fin 248320 → Candidate) (identified : Identified original)
    (input : Fin 128 → Candidate) (valid : ∀ i, ArgmaxStorage.Valid (input i))
    (origin : ∀ i, Origin original (input i)) (group : Fin 4) :
    parsedRun simdLoop (fun lane => input (ArgmaxReductionDevice.thread group lane)) 0=
      some (ArgmaxReductionDevice.simd input group) :=
  parsed_simd_exact original identified _ (fun _lane => (valid _).1) (fun _lane => origin _)

theorem scratch_exact (original : Fin 248320 → Candidate) (identified : Identified original)
    (input : Fin 128 → Candidate) (valid : ∀ i, ArgmaxStorage.Valid (input i))
    (origin : ∀ i, Origin original (input i)) (trace : ArgmaxPairMemory.Reduction input) :
    parsedRun mergeLoop trace.scratch.read 0=some trace.output := by
  have finite : ∀ group, Finite (trace.scratch.read group) := by
    intro group
    rw [trace.scratch.read_correct (ArgmaxReductionDevice.group_valid input valid)]
    exact (ArgmaxReductionDevice.group_valid input valid group).1
  have fromOriginal : ∀ group, Origin original (trace.scratch.read group) := by
    intro group
    rw [trace.scratch.read_correct (ArgmaxReductionDevice.group_valid input valid)]
    apply tree_preserves (Origin original)
    intro lane
    exact origin _
  exact parsed_merge_exact original identified trace.scratch.read finite fromOriginal

open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
variable {logits : Fin 248320 → ArrayStorage.BF} {platform : LogSumExpRanges.Platform}
  {source : ArrayStorage.BFBuffer logits} {lse : LogSumExpMemory.Execution platform source}
  (execution : NormalizedArgmaxMemory.Execution lse)

theorem candidates_identified : Identified (NormalizedArgmaxMemory.candidates lse) := by
  intro i
  rw [NormalizedArgmaxMemory.candidates_eq]
  rfl

theorem partial_reduction (valid : ∀ i, ArgmaxStorage.Valid (NormalizedArgmaxMemory.candidates lse i))
    (tile : Fin 243) :
    (∀ group, parsedRun simdLoop (fun lane => NormalizedArgmaxExecution.partialLane (NormalizedArgmaxMemory.candidates lse)
      tile (ArgmaxReductionDevice.thread group lane)) 0=some (ArgmaxReductionDevice.simd
        (NormalizedArgmaxExecution.partialLane (NormalizedArgmaxMemory.candidates lse) tile) group)) ∧
    parsedRun mergeLoop (execution.tiles tile).scratch.read 0=some (execution.tiles tile).output := by
  have finite := NormalizedArgmaxDevice.partial_lane_valid (NormalizedArgmaxMemory.candidates lse) valid tile
  have origin := partial_lane_origin (NormalizedArgmaxMemory.candidates lse) tile
  exact ⟨fun group => group_exact _ candidates_identified _ finite origin group,
    scratch_exact _ candidates_identified _ finite origin (execution.tiles tile)⟩

theorem finish_lane_origin (valid : ∀ i, ArgmaxStorage.Valid (NormalizedArgmaxMemory.candidates lse i)) (thread : Fin 128) :
    Origin (NormalizedArgmaxMemory.candidates lse) (NormalizedArgmaxDevice.finishInput execution.partials.read thread) := by
  apply scan_preserves (Origin (NormalizedArgmaxMemory.candidates lse)) _ sentinel (Or.inl rfl)
  intro value member
  obtain ⟨index,_,rfl⟩ := List.mem_map.mp member
  rw [execution.partials_read valid]
  exact NormalizedArgmaxExecution.partial_origin _ _

theorem finish_reduction (valid : ∀ i, ArgmaxStorage.Valid (NormalizedArgmaxMemory.candidates lse i)) :
    (∀ group, parsedRun simdLoop (fun lane => NormalizedArgmaxDevice.finishInput execution.partials.read
      (ArgmaxReductionDevice.thread group lane)) 0=some (ArgmaxReductionDevice.simd
        (NormalizedArgmaxDevice.finishInput execution.partials.read) group)) ∧
    parsedRun mergeLoop execution.finish.scratch.read 0=some execution.finish.output := by
  have finite := execution.finish_valid valid
  have origin := finish_lane_origin execution valid
  exact ⟨fun group => group_exact _ candidates_identified _ finite origin group,
    scratch_exact _ candidates_identified _ finite origin execution.finish⟩

end Inference.Kernels.Sampling.ArgmaxSourceOrigins
