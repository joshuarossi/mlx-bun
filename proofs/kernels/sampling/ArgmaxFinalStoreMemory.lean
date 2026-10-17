import kernels.sampling.ArgmaxFinalStoreSyntax
import kernels.sampling.ArgmaxShuffleSemantics
import kernels.sampling.NormalizedArgmaxMemory

namespace Inference.Kernels.Sampling.ArgmaxFinalStoreMemory
open Contracts.Mlx ArgmaxPairs ArgmaxFinalStoreSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

abbrev Env := String → Option (BitVec 32)
def environment (lane : Fin 32) (row value : BitVec 32) : Env := fun name =>
  if name="lane" then some (BitVec.ofNat 32 lane.val)
  else if name="row" then some row else if name="bestId" then some value else none

def execute (statement : Store) (env : Env) (base : Nat) (memory : ByteMemory.Bytes) : Option ByteMemory.Bytes := do
  let guard ←env statement.guardVariable
  if guard=BitVec.ofNat 32 statement.guardValue then
    if statement.destination="out" then do
      let index ←env statement.index
      let value ←env statement.value
      pure (ByteMemory.store32 memory (base+4*index.toNat) value)
    else none
  else pure memory

def executeSource (lane : Fin 32) (row value : BitVec 32) (base : Nat)
    (memory : ByteMemory.Bytes) : Option ByteMemory.Bytes := do
  let statement ←parse sourceBody
  execute statement (environment lane row value) base memory

theorem lane_zero (row value : BitVec 32) (base : Nat) (memory : ByteMemory.Bytes) :
    executeSource 0 row value base memory=some (ByteMemory.store32 memory (base+4*row.toNat) value) := by
  unfold executeSource
  rw [parsed]
  simp [execute,environment,body]

theorem inactive (lane : Fin 32) (nonzero : lane.val≠0) (row value : BitVec 32)
    (base : Nat) (memory : ByteMemory.Bytes) : executeSource lane row value base memory=some memory := by
  have different : BitVec.ofNat 32 lane.val≠BitVec.ofNat 32 0 := by
    intro same
    have equal := congrArg BitVec.toNat same
    have small : lane.val<2^32 := by have := lane.isLt; omega
    simp only [BitVec.toNat_ofNat,Nat.mod_eq_of_lt small,Nat.zero_mod] at equal
    exact nonzero equal
  unfold executeSource
  rw [parsed]
  simp [execute,environment,body,different]

-- The enclosing shared reduction block is executed only by simd==0. Together
-- with the parsed lane==0 guard, this selects exactly thread zero.
theorem unique_owner (thread : Fin 128) : thread.val/32=0 ∧ thread.val%32=0 ↔ thread.val=0 := by omega

-- A completed one-word output trace has precisely one store. Derive the
-- whole-byte equality, rather than assuming a correct final output heap.
theorem trace_store (trace : WordArrayWrites.Trace base (fun _ : Fin 1 => value)) :
    trace.memory=ByteMemory.store32 trace.before base value := by
  have permutation := ThreadgroupWrites.completed_schedule trace.execution trace.completed
  have schedule : trace.schedule=[⟨base/4,value⟩] := by
    simpa [WordArrayWrites.programs,WordArrayWrites.entry,List.finRange_succ] using permutation
  have aligned : 4*(base/4)=base := by have := trace.aligned; omega
  simp only [WordArrayWrites.Trace.memory,schedule,ByteMemory.execute,aligned]

variable {logits : Fin 248320 → ArrayStorage.BF} {platform : LogSumExpRanges.Platform}
  {source : ArrayStorage.BFBuffer logits} {lse : LogSumExpMemory.Execution platform source}
  (execution : NormalizedArgmaxMemory.Execution lse)

-- Execute both parsed reduction and parsed store on the actual finish scratch
-- and completed partial-output byte images used by the existing sampler.
def finishSource : Option ByteMemory.Bytes :=
  ((ArgmaxShuffleSemantics.parsedRun ArgmaxShuffleSyntax.mergeLoop execution.finish.scratch.read 0).map Candidate.index).bind
    (fun index => executeSource 0 0 (BitVec.ofNat 32 index) execution.destination execution.partials.memory)

theorem finish_memory (valid : ∀ i, ArgmaxStorage.Valid (NormalizedArgmaxMemory.candidates lse i)) :
    finishSource execution=some execution.memory := by
  have scratchFinite : ∀ i, Finite (execution.finish.scratch.read i) := by
    intro group
    rw [execution.finish.scratch.read_correct
      (ArgmaxReductionDevice.group_valid _ (execution.finish_valid valid))]
    exact (ArgmaxReductionDevice.group_valid _ (execution.finish_valid valid) group).1
  have merge := ArgmaxShuffleSemantics.parsed_merge_index execution.finish.scratch.read scratchFinite
  change (ArgmaxShuffleSemantics.parsedRun ArgmaxShuffleSyntax.mergeLoop execution.finish.scratch.read 0).map Candidate.index=
    some execution.finish.output.index at merge
  unfold finishSource
  rw [merge]
  change executeSource 0 0 (BitVec.ofNat 32 execution.finish.output.index) execution.destination execution.partials.memory=some execution.memory
  rw [lane_zero]
  change some (ByteMemory.store32 execution.partials.memory execution.destination
    (BitVec.ofNat 32 execution.finish.output.index))=some execution.memory
  apply congrArg some
  exact ((trace_store execution.output).trans
    (congrArg (fun memory => ByteMemory.store32 memory execution.destination (BitVec.ofNat 32 execution.finish.output.index)) execution.afterPartials)).symm

theorem source_token (primitive : LogSumExpRanges.Primitives platform)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat)) :
    (finishSource execution).map (fun memory => (ByteMemory.load32 memory execution.destination).toNat)=
      some (GreedySampling.sample platform logits) := by
  rw [finish_memory execution (NormalizedArgmaxMemory.candidates_valid lse primitive bound)]
  exact congrArg some (execution.token_eq primitive bound)

end Inference.Kernels.Sampling.ArgmaxFinalStoreMemory
