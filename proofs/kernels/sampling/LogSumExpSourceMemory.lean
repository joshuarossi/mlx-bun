import kernels.sampling.LogSumExpSourceScratch
import kernels.sampling.LogSumExpSourceHost
namespace Inference.Kernels.Sampling.LogSumExpSourceMemory
open Contracts.Mlx
set_option maxRecDepth 10000

-- A native scheduler supplies owners, not values. Reconstruct every scratch
-- word from the source-computed registers; existing expected payloads are
-- never read by this interpreter.
def owners (base : Nat) (schedule : List ByteMemory.Store) : List (Fin 32) :=
  schedule.map (fun store=>⟨(store.word-base/4)%32,Nat.mod_lt _ (by decide)⟩)
def writes (base : Nat) (values : Fin 32→Float32) (schedule : List (Fin 32)) : List ByteMemory.Store :=
  schedule.map (FloatArrayWrites.entry base values)

private theorem map_identity {α : Type} (f : α→α) (xs : List α) (same : ∀ x∈xs,f x=x) : xs.map f=xs := by
  induction xs with
  | nil => rfl
  | cons x rest ih =>
    rw [List.map_cons,same x (by simp),ih (fun y hy=>same y (by simp [hy]))]

private theorem owner_writes {values : Fin 32→Float32} (trace : FloatArrayWrites.Trace base values) :
    writes base values (owners base trace.schedule)=trace.schedule := by
  unfold writes owners
  rw [List.map_map]
  apply map_identity
  intro store member
  have inside := (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp member
  obtain ⟨index,rfl⟩ := FloatArrayWrites.member base values store inside
  have owner : (⟨((base/4+index.val)-base/4)%32,Nat.mod_lt _ (by decide)⟩ : Fin 32)=index := by
    apply Fin.ext
    simp only [Nat.add_sub_cancel_left,Nat.mod_eq_of_lt index.isLt]
  change FloatArrayWrites.entry base values ⟨((base/4+index.val)-base/4)%32,_⟩=FloatArrayWrites.entry base values index
  rw [owner]

def maxima (p : LogSumExpRanges.Platform) (memory : ByteMemory.Bytes) (inputBase : Nat) : Fin 32→Float32 :=
  fun simd=>(LogSumExpSourceMerge.groups p memory inputBase simd).maximum

def maxHeap (p : LogSumExpRanges.Platform) (memory : ByteMemory.Bytes) (inputBase maxBase : Nat)
    (localBefore : ByteMemory.Bytes) (order : List (Fin 32)) : ByteMemory.Bytes :=
  ByteMemory.execute (writes maxBase (maxima p memory inputBase) order) localBefore

def normalizers (p : LogSumExpRanges.Platform) (memory : ByteMemory.Bytes) (inputBase : Nat)
    (current : ByteMemory.Bytes) (maxBase : Nat) : Fin 32→Float32 := fun simd=>
  let state := LogSumExpSourceMerge.groups p memory inputBase simd
  FlushToZero.mul state.normalizer
    (LogSumExpSourceArithmetic.exponential p.scalar state.maximum (LogSumExpSourceScratch.maximum p current maxBase))

def normHeap (p : LogSumExpRanges.Platform) (memory : ByteMemory.Bytes) (inputBase maxBase normBase : Nat)
    (localBefore : ByteMemory.Bytes) (maxOrder normOrder : List (Fin 32)) : ByteMemory.Bytes :=
  let current := maxHeap p memory inputBase maxBase localBefore maxOrder
  ByteMemory.execute (writes normBase (normalizers p memory inputBase current maxBase) normOrder) current

def output (p : LogSumExpRanges.Platform) (memory : ByteMemory.Bytes) (inputBase maxBase normBase destination : Nat)
    (localBefore : ByteMemory.Bytes) (maxOrder normOrder : List (Fin 32)) : ByteMemory.Bytes :=
  let scratch := normHeap p memory inputBase maxBase normBase localBefore maxOrder normOrder
  HalfMemory.store memory destination (ArrayStorage.bits (LogSumExpSourceScratch.finish p scratch maxBase normBase))

-- The accepted native phase sequence determines this order: input reads and
-- private updates, SIMD merge, max stores/barrier/read, rescaled normalizer
-- stores/barrier/read, and only then the lane-zero global BF16 store.
def executeProgram (code : List LogSumExpSourceSyntax.Phase) (p : LogSumExpRanges.Platform)
    (memory : ByteMemory.Bytes) (inputBase maxBase normBase destination : Nat) (localBefore : ByteMemory.Bytes)
    (maxOrder normOrder : List (Fin 32)) : Option ByteMemory.Bytes :=
  match code with
  | [.pointer,.setup,.loop,.group,.maxScratch,.normalizerScratch,.output] =>
    some (output p memory inputBase maxBase normBase destination localBefore maxOrder normOrder)
  | _ => none

def executeSource (p : LogSumExpRanges.Platform) (memory : ByteMemory.Bytes)
    (inputBase maxBase normBase destination : Nat) (localBefore : ByteMemory.Bytes) (maxOrder normOrder : List (Fin 32)) :
    Option ByteMemory.Bytes := do
  let code ←LogSumExpSourceSyntax.parse LogSumExpSourceSyntax.bodyTokens
  executeProgram code p memory inputBase maxBase normBase destination localBefore maxOrder normOrder

variable {logits : Fin 248320→ArrayStorage.BF} {p : LogSumExpRanges.Platform} {source : ArrayStorage.BFBuffer logits}

theorem max_heap (scratch : LogSumExpMemory.Scratch p source) :
    maxHeap p source.bytes source.base scratch.maxBase scratch.maxima.before (owners scratch.maxBase scratch.maxima.schedule)=
      scratch.maxima.memory := by
  unfold maxHeap maxima
  rw [LogSumExpSourceMerge.groups_model source p,owner_writes scratch.maxima]
  rfl

theorem normalizers_model (scratch : LogSumExpMemory.Scratch p source) :
    normalizers p source.bytes source.base scratch.maxima.memory scratch.maxBase=
      LogSumExpMemory.adjusted p source scratch.maxima := by
  unfold normalizers
  rw [LogSumExpSourceMerge.groups_model source p,LogSumExpSourceScratch.max_read scratch]
  unfold LogSumExpMemory.adjusted
  rfl

theorem norm_heap (scratch : LogSumExpMemory.Scratch p source) :
    normHeap p source.bytes source.base scratch.maxBase scratch.normBase scratch.maxima.before
      (owners scratch.maxBase scratch.maxima.schedule) (owners scratch.normBase scratch.normalizers.schedule)=
      scratch.normalizers.memory := by
  unfold normHeap
  rw [max_heap scratch]
  dsimp only
  rw [normalizers_model scratch,owner_writes scratch.normalizers,←scratch.afterMaxima]
  rfl

private theorem output_schedule (execution : LogSumExpMemory.Execution p source) :
    execution.output.schedule=[HalfArrayWrites.entry execution.destination
      (fun _ : Fin 1=>ArrayStorage.bits (LogSumExpMemory.finish p source execution.scratch.maxima execution.scratch.normalizers)) 0] := by
  have schedule := ThreadgroupWrites.completed_schedule execution.output.execution execution.output.completed
  change execution.output.schedule.Perm [HalfArrayWrites.entry execution.destination _ 0] at schedule
  exact List.perm_singleton.mp schedule

theorem output_heap (execution : LogSumExpMemory.Execution p source) :
    output p source.bytes source.base execution.scratch.maxBase execution.scratch.normBase execution.destination
      execution.scratch.maxima.before (owners execution.scratch.maxBase execution.scratch.maxima.schedule)
      (owners execution.scratch.normBase execution.scratch.normalizers.schedule)=execution.memory := by
  unfold output
  rw [norm_heap execution.scratch]
  dsimp only
  rw [LogSumExpSourceScratch.finish_model execution.scratch]
  unfold LogSumExpMemory.Execution.memory HalfArrayWrites.Trace.memory
  rw [output_schedule execution,execution.initial]
  change HalfMemory.store source.bytes execution.destination _=HalfMemory.store source.bytes (2*(execution.destination/2+0)) _
  have aligned : 2*(execution.destination/2)=execution.destination := by have := execution.output.aligned; omega
  rw [Nat.add_zero,aligned]
  rfl

theorem source_execution (execution : LogSumExpMemory.Execution p source) :
    executeSource p source.bytes source.base execution.scratch.maxBase execution.scratch.normBase execution.destination
      execution.scratch.maxima.before (owners execution.scratch.maxBase execution.scratch.maxima.schedule)
      (owners execution.scratch.normBase execution.scratch.normalizers.schedule)=some execution.memory := by
  rw [executeSource,LogSumExpSourceSyntax.parsed]
  change some (output p source.bytes source.base execution.scratch.maxBase execution.scratch.normBase execution.destination
    execution.scratch.maxima.before (owners execution.scratch.maxBase execution.scratch.maxima.schedule)
    (owners execution.scratch.normBase execution.scratch.normalizers.schedule))=_
  rw [output_heap execution]

theorem readback (execution : LogSumExpMemory.Execution p source) :
    LogSumExpSourceScratch.finish p (normHeap p source.bytes source.base execution.scratch.maxBase execution.scratch.normBase
      execution.scratch.maxima.before (owners execution.scratch.maxBase execution.scratch.maxima.schedule)
      (owners execution.scratch.normBase execution.scratch.normalizers.schedule)) execution.scratch.maxBase execution.scratch.normBase=
      execution.buffer.read 0 := by
  rw [norm_heap execution.scratch,LogSumExpSourceScratch.finish_model execution.scratch,LogSumExpMemory.finish_eq]
  exact (execution.buffer.read_correct 0).symm
end Inference.Kernels.Sampling.LogSumExpSourceMemory
