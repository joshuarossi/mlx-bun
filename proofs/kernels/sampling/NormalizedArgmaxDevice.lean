import kernels.sampling.ArgmaxReductionDevice
import kernels.sampling.NormalizedArgmaxExecution

namespace Inference.Kernels.Sampling.NormalizedArgmaxDevice
open Contracts.Mlx ArgmaxPairs NormalizedArgmaxLayout
set_option maxRecDepth 10000

theorem partial_lane_valid (input : Fin 248320 → Candidate) (valid : ∀ i, ArgmaxStorage.Valid (input i))
    (tile : Fin 243) (thread : Fin 128) : ArgmaxStorage.Valid (NormalizedArgmaxExecution.partialLane input tile thread) := by
  apply ArgmaxStorage.scan_valid _ _ ArgmaxStorage.sentinel_valid
  intro value member
  obtain ⟨i, _, rfl⟩ := List.mem_map.mp member
  exact valid _

def finishInput (partials : Fin 243 → Candidate) (thread : Fin 128) : Candidate :=
  scan ((finishOffsets thread).attach.map (fun i => partials ⟨i.val, finish_in_bounds thread i.val i.property⟩)) sentinel

theorem finish_input_valid (partials : Fin 243 → Candidate) (valid : ∀ i, ArgmaxStorage.Valid (partials i)) (thread : Fin 128) :
    ArgmaxStorage.Valid (finishInput partials thread) := by
  apply ArgmaxStorage.scan_valid _ _ ArgmaxStorage.sentinel_valid
  intro value member
  obtain ⟨i, _, rfl⟩ := List.mem_map.mp member
  exact valid _

-- Both launches use the proved four-SIMD scratch reduction. The finish
-- launch reads the actual completed global score and uint32-ID arrays.
structure Execution (input : Fin 248320 → Candidate) where
  tiles : ∀ tile, ArgmaxReductionDevice.Trace (NormalizedArgmaxExecution.partialLane input tile)
  partials : ArgmaxStorage.Trace (fun tile => (tiles tile).output)
  finish : ArgmaxReductionDevice.Trace (finishInput partials.read)
  output : WordArrayWrites.Trace 0 (fun _ : Fin 1 => BitVec.ofNat 32 finish.output.index)

def Execution.fromPartials (input : Fin 248320 → Candidate)
    (tiles : ∀ tile, ArgmaxReductionDevice.Trace (NormalizedArgmaxExecution.partialLane input tile)) : Execution input :=
  let partials := ArgmaxStorage.Trace.canonical (fun tile => (tiles tile).output) (by decide)
  let finish := ArgmaxReductionDevice.Trace.canonical (finishInput partials.read)
  ⟨tiles, partials, finish, WordArrayWrites.Trace.canonical _ (by decide)⟩

def Execution.canonical (input : Fin 248320 → Candidate) : Execution input :=
  Execution.fromPartials input (fun tile => ArgmaxReductionDevice.Trace.canonical (NormalizedArgmaxExecution.partialLane input tile))

variable {input : Fin 248320 → Candidate}

theorem Execution.partials_valid (execution : Execution input) (valid : ∀ i, ArgmaxStorage.Valid (input i)) (tile : Fin 243) :
    ArgmaxStorage.Valid (execution.tiles tile).output := (execution.tiles tile).output_valid (partial_lane_valid input valid tile)

theorem Execution.partials_read (execution : Execution input) (valid : ∀ i, ArgmaxStorage.Valid (input i)) :
    execution.partials.read=NormalizedArgmaxExecution.partialTile input := by
  funext tile
  calc
    _ = (execution.tiles tile).output := execution.partials.read_correct (execution.partials_valid valid) tile
    _ = _ := (execution.tiles tile).output_eq (partial_lane_valid input valid tile)

theorem Execution.finish_valid (execution : Execution input) (valid : ∀ i, ArgmaxStorage.Valid (input i)) :
    ∀ thread, ArgmaxStorage.Valid (finishInput execution.partials.read thread) := by
  apply finish_input_valid
  intro tile
  rw [execution.partials.read_correct (execution.partials_valid valid)]
  exact execution.partials_valid valid tile

theorem Execution.result_eq (execution : Execution input) (valid : ∀ i, ArgmaxStorage.Valid (input i)) :
    execution.finish.output=NormalizedArgmaxExecution.run input := by
  rw [execution.finish.output_eq (execution.finish_valid valid), execution.partials_read valid]
  rfl

def Execution.token (execution : Execution input) : Nat := (ByteMemory.load32 execution.output.memory 0).toNat

theorem Execution.token_eq (execution : Execution input) (valid : ∀ i, ArgmaxStorage.Valid (input i)) :
    execution.token=(NormalizedArgmaxExecution.run input).index := by
  have stored := execution.output.read_correct 0
  change ByteMemory.load32 execution.output.memory 0=BitVec.ofNat 32 execution.finish.output.index at stored
  have bound := (execution.finish.output_valid (execution.finish_valid valid)).2
  unfold Execution.token
  rw [stored]
  simp only [BitVec.toNat_ofNat, Nat.mod_eq_of_lt bound]
  exact congrArg Candidate.index (execution.result_eq valid)

theorem Execution.partial_score_read (execution : Execution input) (tile : Fin 243) :
    FloatMemory.load execution.partials.scores.memory (4*tile.val)=ArgmaxStorage.score (execution.tiles tile).output :=
  execution.partials.score_bytes tile

theorem Execution.partial_id_read (execution : Execution input) (tile : Fin 243) :
    ByteMemory.load32 execution.partials.ids.memory (4*tile.val)=BitVec.ofNat 32 (execution.tiles tile).output.index :=
  execution.partials.id_bytes tile

theorem launch : (248320+1023)/1024=243 ∧ 243*128=31104 ∧ 128/32=4 := by decide

end Inference.Kernels.Sampling.NormalizedArgmaxDevice
