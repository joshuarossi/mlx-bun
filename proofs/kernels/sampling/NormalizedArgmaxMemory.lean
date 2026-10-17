import kernels.sampling.ArgmaxPairMemory
import kernels.sampling.LogSumExpMemory
import kernels.sampling.GreedyDevice

namespace Inference.Kernels.Sampling.NormalizedArgmaxMemory
open Contracts.Mlx ArgmaxPairs
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000
set_option maxHeartbeats 400000
variable {logits : Fin 248320 → BF} {p : LogSumExpRanges.Platform} {source : ArrayStorage.BFBuffer logits}

def candidates (lse : LogSumExpMemory.Execution p source) : Fin 248320 → Candidate :=
  GreedyDevice.candidates lse.logitsAfter lse.buffer

theorem candidates_eq (lse : LogSumExpMemory.Execution p source) :
    candidates lse=NormalizedScores.candidates logits (LogSumExpRanges.value p logits) :=
  GreedyDevice.candidates_eq lse.logitsAfter lse.buffer

theorem candidates_valid (lse : LogSumExpMemory.Execution p source) (primitive : LogSumExpRanges.Primitives p)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat)) :
    ∀ i, ArgmaxStorage.Valid (candidates lse i) := by
  rw [candidates_eq]
  intro i
  exact ⟨NormalizedScores.candidates_finite logits _ bound (LogSumExpRanges.bf16_ranges p primitive logits bound).2 i,by change i.val<2^32; omega⟩

structure Execution (lse : LogSumExpMemory.Execution p source) where
  tiles : ∀ tile, ArgmaxPairMemory.Reduction (NormalizedArgmaxExecution.partialLane (candidates lse) tile)
  layout : ArgmaxPairMemory.Layout 243
  partials : ArgmaxPairMemory.Trace layout (fun tile => (tiles tile).output)
  initial : partials.before=lse.memory
  logitsSafe : ArgmaxPairMemory.Safe layout source.base 496640
  lseSafe : ArgmaxPairMemory.Safe layout lse.destination 2
  finish : ArgmaxPairMemory.Reduction (NormalizedArgmaxDevice.finishInput partials.read)
  destination : Nat
  output : WordArrayWrites.Trace destination (fun _ : Fin 1 => BitVec.ofNat 32 finish.output.index)
  afterPartials : output.before=partials.memory
  tokenScoreSafe : MemoryRegions.Disjoint destination 4 layout.scores 972
  tokenIdSafe : MemoryRegions.Disjoint destination 4 layout.ids 972
  tokenLogitsSafe : MemoryRegions.Disjoint destination 4 source.base 496640
  tokenLseSafe : MemoryRegions.Disjoint destination 4 lse.destination 2

variable {lse : LogSumExpMemory.Execution p source}

def tokenTrace (destination : Nat) (value : Candidate) (before : ByteMemory.Bytes)
    (aligned : destination%4=0) (bounded : destination+4≤2^64) :
    WordArrayWrites.Trace destination (fun _ : Fin 1 => BitVec.ofNat 32 value.index) :=
  ⟨before,aligned,bounded,(WordArrayWrites.programs destination (fun _ : Fin 1 => BitVec.ofNat 32 value.index)).flatten,
    List.replicate (WordArrayWrites.programs destination (fun _ : Fin 1 => BitVec.ofNat 32 value.index)).length [],
    ThreadgroupWrites.canonical _,ThreadgroupWrites.canonical_barrier _⟩

def Execution.canonical (lse : LogSumExpMemory.Execution p source) (layout : ArgmaxPairMemory.Layout 243)
    (localBefore : Fin 243 → ByteMemory.Bytes) (finishBefore : ByteMemory.Bytes)
    (logitsSafe : ArgmaxPairMemory.Safe layout source.base 496640)
    (lseSafe : ArgmaxPairMemory.Safe layout lse.destination 2)
    (destination : Nat) (aligned : destination%4=0) (bounded : destination+4≤2^64)
    (tokenScoreSafe : MemoryRegions.Disjoint destination 4 layout.scores 972)
    (tokenIdSafe : MemoryRegions.Disjoint destination 4 layout.ids 972)
    (tokenLogitsSafe : MemoryRegions.Disjoint destination 4 source.base 496640)
    (tokenLseSafe : MemoryRegions.Disjoint destination 4 lse.destination 2) : Execution lse :=
  let tiles := fun tile => ArgmaxPairMemory.Reduction.canonical (NormalizedArgmaxExecution.partialLane (candidates lse) tile) (localBefore tile)
  let partials := ArgmaxPairMemory.Trace.canonical layout (fun tile => (tiles tile).output) lse.memory
  let finish := ArgmaxPairMemory.Reduction.canonical (NormalizedArgmaxDevice.finishInput partials.read) finishBefore
  ⟨tiles,layout,partials,rfl,logitsSafe,lseSafe,finish,destination,
   tokenTrace destination finish.output partials.memory aligned bounded,rfl,tokenScoreSafe,tokenIdSafe,tokenLogitsSafe,tokenLseSafe⟩

theorem Execution.partials_valid (execution : Execution lse) (valid : ∀ i, ArgmaxStorage.Valid (candidates lse i)) (tile : Fin 243) :
    ArgmaxStorage.Valid (execution.tiles tile).output :=
  (execution.tiles tile).output_valid (NormalizedArgmaxDevice.partial_lane_valid (candidates lse) valid tile)

theorem Execution.partials_read (execution : Execution lse) (valid : ∀ i, ArgmaxStorage.Valid (candidates lse i)) :
    execution.partials.read=NormalizedArgmaxExecution.partialTile (candidates lse) := by
  funext tile
  rw [execution.partials.read_correct (execution.partials_valid valid)]
  exact (execution.tiles tile).output_eq (NormalizedArgmaxDevice.partial_lane_valid _ valid tile)

theorem Execution.finish_valid (execution : Execution lse) (valid : ∀ i, ArgmaxStorage.Valid (candidates lse i)) :
    ∀ thread, ArgmaxStorage.Valid (NormalizedArgmaxDevice.finishInput execution.partials.read thread) := by
  apply NormalizedArgmaxDevice.finish_input_valid
  intro tile
  rw [execution.partials.read_correct (execution.partials_valid valid)]
  exact execution.partials_valid valid tile

theorem Execution.result_eq (execution : Execution lse) (valid : ∀ i, ArgmaxStorage.Valid (candidates lse i)) :
    execution.finish.output=NormalizedArgmaxExecution.run (candidates lse) := by
  rw [execution.finish.output_eq (execution.finish_valid valid),execution.partials_read valid]
  rfl

def Execution.memory (execution : Execution lse) : ByteMemory.Bytes := execution.output.memory

def Execution.token (execution : Execution lse) : Nat := (ByteMemory.load32 execution.memory execution.destination).toNat

theorem Execution.token_eq (execution : Execution lse) (primitive : LogSumExpRanges.Primitives p)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat)) :
    execution.token=GreedySampling.sample p logits := by
  have valid := candidates_valid lse primitive bound
  have stored := execution.output.read_correct 0
  simp only [Fin.val_zero,Nat.mul_zero,Nat.add_zero] at stored
  have indexBound := (execution.finish.output_valid (execution.finish_valid valid)).2
  unfold Execution.token Execution.memory
  rw [stored]
  simp only [BitVec.toNat_ofNat,Nat.mod_eq_of_lt indexBound]
  rw [execution.result_eq valid,candidates_eq]
  rfl

theorem Execution.token_during_other (execution : Execution lse) (stores : List ByteMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.output.schedule)
    (separate : MemoryRegions.Disjoint execution.destination 4 base size) (offset : Nat) (bound : offset<size) :
    ByteMemory.execute stores execution.partials.memory (base+offset)=execution.partials.memory (base+offset) := by
  apply MemoryRegions.execute32_other _ _ _ separate offset bound
  intro store present
  exact ArrayFrame.word_stores_inside execution.output store (subset store present)

theorem Execution.token_other (execution : Execution lse)
    (separate : MemoryRegions.Disjoint execution.destination 4 base size) (offset : Nat) (bound : offset<size) :
    execution.memory (base+offset)=execution.partials.memory (base+offset) := by
  unfold Execution.memory WordArrayWrites.Trace.memory
  rw [execution.afterPartials]
  exact execution.token_during_other _ (fun _ h => h) separate offset bound

def Safe (execution : Execution lse) (base size : Nat) : Prop :=
  ArgmaxPairMemory.Safe execution.layout base size ∧ MemoryRegions.Disjoint execution.destination 4 base size

theorem Execution.other_region (execution : Execution lse) (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.memory (base+offset)=lse.memory (base+offset) :=
  (execution.token_other safe.2 offset bound).trans ((execution.partials.other_region safe.1 offset bound).trans (congrFun execution.initial _))

def Execution.logitsDuring (execution : Execution lse) (stores : List ByteMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.partials.schedule) : ArrayStorage.BFBuffer logits :=
  ArrayFrame.bf lse.logitsAfter (ByteMemory.execute stores execution.partials.before) (fun offset bound =>
    (execution.partials.during_other stores subset execution.logitsSafe offset bound).trans (congrFun execution.initial _))

def Execution.lseDuring (execution : Execution lse) (stores : List ByteMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.partials.schedule) :
    ArrayStorage.BFBuffer (fun _ : Fin 1 => LogSumExpRanges.value p logits) :=
  ArrayFrame.bf lse.buffer (ByteMemory.execute stores execution.partials.before) (fun offset bound =>
    (execution.partials.during_other stores subset execution.lseSafe offset bound).trans (congrFun execution.initial _))

theorem Execution.candidates_during (execution : Execution lse) (stores : List ByteMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.partials.schedule) :
    GreedyDevice.candidates (execution.logitsDuring stores subset) (execution.lseDuring stores subset)=
      NormalizedScores.candidates logits (LogSumExpRanges.value p logits) :=
  GreedyDevice.candidates_eq _ _

theorem Execution.partials_during (execution : Execution lse) (stores : List ByteMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.output.schedule) (tile : Fin 243) :
    ArgmaxPairMemory.readAt execution.layout (ByteMemory.execute stores execution.partials.memory) tile=execution.partials.read tile := by
  exact ArgmaxPairMemory.readAt_congr execution.layout execution.partials.memory _
    (execution.token_during_other stores subset execution.tokenScoreSafe)
    (execution.token_during_other stores subset execution.tokenIdSafe) tile

def Execution.logitsAfter (execution : Execution lse) : ArrayStorage.BFBuffer logits :=
  ArrayFrame.bf lse.logitsAfter execution.memory (execution.other_region ⟨execution.logitsSafe,execution.tokenLogitsSafe⟩)

def Execution.lseAfter (execution : Execution lse) : ArrayStorage.BFBuffer (fun _ : Fin 1 => LogSumExpRanges.value p logits) :=
  ArrayFrame.bf lse.buffer execution.memory (execution.other_region ⟨execution.lseSafe,execution.tokenLseSafe⟩)

def Execution.preserveBF {values : Fin n → BF} (execution : Execution lse) (buffer : ArrayStorage.BFBuffer values)
    (shared : buffer.bytes=lse.memory) (safe : Safe execution buffer.base (2*n)) : ArrayStorage.BFBuffer values :=
  ArrayFrame.bf buffer execution.memory (fun offset bound => (execution.other_region safe offset bound).trans (congrFun shared _).symm)

theorem Execution.finish_input_during (execution : Execution lse) (stores : List ByteMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.output.schedule) (thread : Fin 128) :
    NormalizedArgmaxDevice.finishInput (ArgmaxPairMemory.readAt execution.layout
      (ByteMemory.execute stores execution.partials.memory)) thread=
      NormalizedArgmaxDevice.finishInput execution.partials.read thread := by
  rw [show ArgmaxPairMemory.readAt execution.layout (ByteMemory.execute stores execution.partials.memory)=execution.partials.read
    from funext (execution.partials_during stores subset)]

theorem Execution.partials_after (execution : Execution lse) (tile : Fin 243) :
    ArgmaxPairMemory.readAt execution.layout execution.memory tile=execution.partials.read tile := by
  unfold Execution.memory WordArrayWrites.Trace.memory
  rw [execution.afterPartials]
  exact execution.partials_during _ (fun _ h => h) tile

theorem Execution.shared (execution : Execution lse) : execution.logitsAfter.bytes=execution.memory ∧
    execution.lseAfter.bytes=execution.memory ∧ execution.output.memory=execution.memory := ⟨rfl,rfl,rfl⟩

structure Pipeline (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits) where
  lse : LogSumExpMemory.Execution p source
  selection : Execution lse

def Pipeline.canonical (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits)
    (lseLocal : ByteMemory.Bytes) (normalizer : Nat) (normalizerAligned : normalizer%2=0)
    (normalizerBounded : normalizer+2≤2^64)
    (normalizerSafe : MemoryRegions.Disjoint normalizer 2 source.base 496640)
    (layout : ArgmaxPairMemory.Layout 243) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (logitsSafe : ArgmaxPairMemory.Safe layout source.base 496640)
    (lseSafe : ArgmaxPairMemory.Safe layout normalizer 2)
    (destination : Nat) (aligned : destination%4=0) (bounded : destination+4≤2^64)
    (tokenScoreSafe : MemoryRegions.Disjoint destination 4 layout.scores 972)
    (tokenIdSafe : MemoryRegions.Disjoint destination 4 layout.ids 972)
    (tokenLogitsSafe : MemoryRegions.Disjoint destination 4 source.base 496640)
    (tokenLseSafe : MemoryRegions.Disjoint destination 4 normalizer 2) : Pipeline p source :=
  let lse := LogSumExpMemory.Execution.canonical p source lseLocal normalizer normalizerAligned normalizerBounded normalizerSafe
  ⟨lse,Execution.canonical lse layout tileLocal finishLocal logitsSafe lseSafe destination aligned bounded
    tokenScoreSafe tokenIdSafe tokenLogitsSafe tokenLseSafe⟩

def Pipeline.memory (pipeline : Pipeline p source) : ByteMemory.Bytes := pipeline.selection.memory

theorem Pipeline.token_eq (pipeline : Pipeline p source) (primitive : LogSumExpRanges.Primitives p)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat)) :
    pipeline.selection.token=GreedySampling.sample p logits := pipeline.selection.token_eq primitive bound

theorem Pipeline.correct (pipeline : Pipeline p source) (primitive : LogSumExpRanges.Primitives p)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat)) :
    ∃ selected : Fin 248320, pipeline.selection.token=selected.val ∧
      (∀ i, GreedySampling.score p logits i≤GreedySampling.score p logits selected) ∧
      (∀ i, GreedySampling.score p logits selected=GreedySampling.score p logits i → selected.val ≤ i.val) := by
  rw [pipeline.token_eq primitive bound]
  exact (GreedySampling.correct p primitive logits bound).2.2

def Pipeline.Safe (pipeline : Pipeline p source) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint pipeline.lse.destination 2 base size ∧ Inference.Kernels.Sampling.NormalizedArgmaxMemory.Safe pipeline.selection base size

theorem Pipeline.other_region (pipeline : Pipeline p source) (safe : pipeline.Safe base size) (offset : Nat) (bound : offset<size) :
    pipeline.memory (base+offset)=source.bytes (base+offset) :=
  (pipeline.selection.other_region safe.2 offset bound).trans (pipeline.lse.other_region safe.1 offset bound)

end Inference.Kernels.Sampling.NormalizedArgmaxMemory
