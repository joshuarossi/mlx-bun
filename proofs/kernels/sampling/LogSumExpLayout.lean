import contracts.mlx.Reduction

namespace Inference.Kernels.Sampling.LogSumExpLayout
open Contracts.Mlx

-- Selected looped kernel geometry: four reads, 1024 threads, 61 iterations.
-- The host chooses the pipeline's maximum threadgroup size. Its equality
-- to 1024 is an explicit native pipeline obligation, not proved here.
def offset (iteration : Fin 61) (thread : Fin 1024) (read : Fin 4) : Nat :=
  iteration.val * 4096 + thread.val * 4 + read.val
def iterationOf (i : Fin 248320) : Fin 61 := ⟨i.val/4096, by omega⟩
def threadOf (i : Fin 248320) : Fin 1024 := ⟨(i.val%4096)/4, by omega⟩
def readOf (i : Fin 248320) : Fin 4 := ⟨i.val%4, Nat.mod_lt _ (by decide)⟩

theorem iterations : (248320+4*1024-1)/(4*1024) = 61 := by decide +kernel
theorem looped_dispatch : 4096 < 248320 := by decide +kernel
theorem reconstruct (i : Fin 248320) : offset (iterationOf i) (threadOf i) (readOf i) = i.val := by
  simp only [offset, iterationOf, threadOf, readOf]
  omega

theorem owner_unique (i : Fin 248320) (iteration : Fin 61) (thread : Fin 1024) (read : Fin 4)
    (address : offset iteration thread read = i.val) :
    iterationOf i = iteration ∧ threadOf i = thread ∧ readOf i = read := by
  simp only [offset] at address
  refine ⟨Fin.ext ?_, Fin.ext ?_, Fin.ext ?_⟩ <;>
    simp only [iterationOf, threadOf, readOf] <;> omega

theorem read_in_bounds (iteration : Fin 61) (thread : Fin 1024) (read : Fin 4) :
    offset iteration thread read < 248320 ↔ iteration.val < 60 ∨ thread.val < 640 := by
  simp only [offset]
  omega

theorem whole_block_or_padding (iteration : Fin 61) (thread : Fin 1024) :
    (∀ read, offset iteration thread read < 248320) ∨
      (∀ read, 248320 ≤ offset iteration thread read) := by
  by_cases valid : iteration.val < 60 ∨ thread.val < 640
  · exact Or.inl (fun read => (read_in_bounds iteration thread read).mpr valid)
  · exact Or.inr (fun read => Nat.le_of_not_lt (fun h => valid ((read_in_bounds iteration thread read).mp h)))

theorem first_block_valid (thread : Fin 1024) (read : Fin 4) : offset ⟨0, by decide⟩ thread read < 248320 :=
  (read_in_bounds _ _ _).mpr (Or.inl (by decide))

theorem signed_address_safe (iteration : Fin 61) (thread : Fin 1024) (read : Fin 4) :
    offset iteration thread read + 4 < 2^31 := by
  simp only [offset]
  norm_num
  omega

def groupOf (thread : Fin 1024) : Fin 32 := ⟨thread.val/32, by omega⟩
def laneOf (thread : Fin 1024) : Fin 32 := ⟨thread.val%32, Nat.mod_lt _ (by decide)⟩
def threadAt (group lane : Fin 32) : Fin 1024 := ⟨group.val*32+lane.val, by omega⟩

theorem thread_roundtrip (thread : Fin 1024) : threadAt (groupOf thread) (laneOf thread) = thread := by
  apply Fin.ext
  simp only [threadAt, groupOf, laneOf]
  omega

theorem group_lane_roundtrip (group lane : Fin 32) :
    groupOf (threadAt group lane) = group ∧ laneOf (threadAt group lane) = lane := by
  constructor <;> apply Fin.ext <;> simp only [threadAt, groupOf, laneOf] <;> omega

-- Every one of the 32 scratch cells has a distinct lane-zero writer before
-- every later SIMD load. The barrier's execution is a native obligation.
def writer (group : Fin 32) : Fin 1024 := threadAt group ⟨0, by decide⟩
theorem writer_index (group : Fin 32) : groupOf (writer group) = group ∧ (laneOf (writer group)).val = 0 := by
  have h := group_lane_roundtrip group ⟨0, by decide⟩
  exact ⟨h.1, congrArg Fin.val h.2⟩
theorem writer_unique (left right : Fin 32) (same : writer left = writer right) : left = right := by
  have h := congrArg groupOf same
  simpa only [(writer_index left).1, (writer_index right).1] using h

theorem all_scratch_reads_written (thread : Fin 1024) :
    ∃ owner : Fin 1024, groupOf owner = laneOf thread ∧ (laneOf owner).val = 0 := by
  exact ⟨writer (laneOf thread), writer_index (laneOf thread)⟩

end Inference.Kernels.Sampling.LogSumExpLayout
