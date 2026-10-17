import kernels.trellis.GateUpBytes
import contracts.mlx.ArrayStorage

namespace Inference.Kernels.Trellis.GateUpSource
open Contracts.Mlx GateUpBarrier
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000
variable {input : Fin 5120 → BF}

-- The uint4 loads read the producer's byte buffer. No intermediate encoding
-- or floating-point conversion is introduced by this staging phase.
def inputEntry (source : ArrayStorage.BFBuffer input) (inputBase chunk word : Nat) : Store :=
  ⟨inputBase/4+4*chunk+word,
    ByteMemory.load32 source.bytes (source.base+16*GateUpCodebook.stagedChunk chunk+4*word)⟩

theorem load32_halves (bytes : ByteMemory.Bytes) (address : Nat) :
    ByteMemory.load32 bytes address=GateUpExecution.pack (HalfMemory.load bytes address)
      (HalfMemory.load bytes (address+2)) := by
  rw [GateUpBytes.pack_append]
  unfold ByteMemory.load32 ByteMemory.join HalfMemory.load
  simp only [Nat.add_zero, show address+2+1=address+3 by omega]
  exact BitVec.append_assoc

theorem inputEntry_eq (source : ArrayStorage.BFBuffer input) (inputBase chunk word : Nat)
    (hc : chunk<640) (hw : word<4) :
    inputEntry source inputBase chunk word=GateUpBarrier.inputEntry inputBase (ArrayStorage.bfWords input) chunk word := by
  have bound := GateUpBytes.source_bounds chunk word hc hw
  let index := GateUpCodebook.stagedChunk chunk*8+2*word
  have hi : index<5120 := by dsimp [index]; omega
  have hj : index+1<5120 := by dsimp [index]; omega
  have address : source.base+16*GateUpCodebook.stagedChunk chunk+4*word=source.base+2*index := by
    dsimp [index]; omega
  have nextAddress : source.base+2*index+2=source.base+2*(index+1) := by omega
  unfold inputEntry GateUpBarrier.inputEntry
  rw [address, load32_halves, nextAddress, source.attached ⟨index, hi⟩, source.attached ⟨index+1, hj⟩]
  dsimp only [index] at hi hj ⊢
  simp only [ArrayStorage.bfWords, hi, hj, ↓reduceDIte]

def programs (source : ArrayStorage.BFBuffer input) (tableBase inputBase : Nat) : List (List Store) :=
  (List.range 1024).map fun thread =>
    (List.range 4).map (codeEntry tableBase thread) ++
      if thread<640 then (List.range 4).map (inputEntry source inputBase thread) else []

theorem programs_eq (source : ArrayStorage.BFBuffer input) (tableBase inputBase : Nat) :
    programs source tableBase inputBase=GateUpBarrier.programs tableBase inputBase (ArrayStorage.bfWords input) := by
  unfold programs GateUpBarrier.programs
  apply List.map_congr_left
  intro thread _
  by_cases active : thread<640
  · simp only [active, ite_true]
    congr 1
    apply List.map_congr_left
    intro word hw
    exact inputEntry_eq source inputBase thread word active (List.mem_range.mp hw)
  · simp only [active, ite_false]

theorem source_bounds (source : ArrayStorage.BFBuffer input) (chunk word : Nat)
    (hc : chunk<640) (hw : word<4) :
    source.base ≤ source.base+16*GateUpCodebook.stagedChunk chunk+4*word ∧
    source.base+16*GateUpCodebook.stagedChunk chunk+4*word+4 ≤ source.base+10240 ∧
    source.base+16*GateUpCodebook.stagedChunk chunk+4*word+4 ≤ 2^64 := by
  have := GateUpBytes.source_bounds chunk word hc hw
  have := source.bounded
  omega

theorem vector_aligned (source : ArrayStorage.BFBuffer input) (aligned : source.base%16=0) (chunk : Nat) :
    (source.base+16*GateUpCodebook.stagedChunk chunk)%16=0 := by omega

structure Trace (tableBase : Nat) (source : ArrayStorage.BFBuffer input) where
  sourceAligned : source.base%16=0
  before : ByteMemory.Bytes
  inputBase : Nat
  separate : Separate tableBase inputBase
  aligned : inputBase%16=0
  schedule : List Store
  remaining : List (List Store)
  execution : ThreadgroupWrites.Executes (programs source tableBase inputBase) schedule remaining
  barrier : ThreadgroupWrites.AtBarrier remaining

variable {tableBase : Nat} {source : ArrayStorage.BFBuffer input}

def Trace.staged (trace : Trace tableBase source) : GateUpBytes.Trace tableBase (ArrayStorage.bfWords input) where
  before := trace.before
  inputBase := trace.inputBase
  separate := trace.separate
  aligned := by have := trace.aligned; omega
  schedule := trace.schedule
  remaining := trace.remaining
  execution := by simpa only [programs_eq] using trace.execution
  barrier := trace.barrier

def Trace.canonical (tableBase : Nat) (source : ArrayStorage.BFBuffer input) (aligned : source.base%16=0) :
    Trace tableBase source :=
  let inputBase := 16*(tableBase/16+1025)
  let threads := programs source tableBase inputBase
  ⟨aligned, fun _ => 0, inputBase, Or.inl (by dsimp [inputBase]; omega),
    by dsimp [inputBase]; omega, threads.flatten, List.replicate threads.length [],
    ThreadgroupWrites.canonical threads, ThreadgroupWrites.canonical_barrier threads⟩

theorem Trace.word_copied (trace : Trace tableBase source) (chunk word : Nat) (hc : chunk<640) (hw : word<4) :
    ByteMemory.load32 (ByteMemory.execute trace.schedule trace.before) (trace.inputBase+16*chunk+4*word)=
      ByteMemory.load32 source.bytes (source.base+16*GateUpCodebook.stagedChunk chunk+4*word) := by
  have copied := GateUpBytes.input_word_copied trace.before tableBase trace.inputBase (ArrayStorage.bfWords input)
    trace.separate trace.staged.aligned trace.schedule trace.remaining trace.staged.execution trace.barrier chunk word hc hw
  rw [GateUpBytes.source_word] at copied
  exact copied.trans (congrArg MemoryCells.Store.value (inputEntry_eq source trace.inputBase chunk word hc hw)).symm

theorem Trace.byte_copied (trace : Trace tableBase source) (chunk offset : Nat) (hc : chunk<640) (ho : offset<16) :
    ByteMemory.execute trace.schedule trace.before (trace.inputBase+16*chunk+offset)=
      source.bytes (source.base+16*GateUpCodebook.stagedChunk chunk+offset) := by
  have copied := congrArg (fun value => ByteMemory.byte value (offset%4))
    (trace.word_copied chunk (offset/4) hc (by omega))
  rw [ByteMemory.byte_load32 _ _ _ (by omega), ByteMemory.byte_load32 _ _ _ (by omega)] at copied
  simpa only [show trace.inputBase+16*chunk+4*(offset/4)+offset%4=trace.inputBase+16*chunk+offset by omega,
    show source.base+16*GateUpCodebook.stagedChunk chunk+4*(offset/4)+offset%4=
      source.base+16*GateUpCodebook.stagedChunk chunk+offset by omega] using copied

theorem Trace.ready (trace : Trace tableBase source) :
    GateUpBarrier.Ready trace.staged.memory tableBase trace.inputBase (ArrayStorage.bfWords input) := trace.staged.ready

end Inference.Kernels.Trellis.GateUpSource
