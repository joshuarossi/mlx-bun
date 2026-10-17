import kernels.trellis.GateInputContext
import kernels.trellis.GateUpSource
import kernels.trellis.CodebookTableSource
namespace Inference.Kernels.Trellis.GateInputSource
open Contracts.Mlx GateInputSemantics GateUpBarrier
set_option maxRecDepth 10000
variable {input : Fin 5120 → ArrayStorage.BF}

theorem thread_program (source : ArrayStorage.BFBuffer input) (inputBase thread : Nat) (valid : thread<1024) :
    threadProgram source.bytes source.base inputBase thread=some
      (if thread<640 then (List.range 4).map (GateUpSource.inputEntry source inputBase thread) else []) := by
  unfold threadProgram
  rw [selected ⟨thread,valid⟩]
  by_cases active : thread<640
  · simp only [ite_eq_left active]
    rfl
  · simp only [ite_eq_right active]
    rfl

-- All stores are generated from successful parsed iterations and actual
-- original global bytes. The fallback is unreachable for every launched lane.
def programs (source : ArrayStorage.BFBuffer input) (tableBase inputBase : Nat) : List (List Store) :=
  (List.range 1024).map (fun thread => (List.range 4).map (codeEntry tableBase thread) ++
    (threadProgram source.bytes source.base inputBase thread).getD [])

theorem programs_eq (source : ArrayStorage.BFBuffer input) (tableBase inputBase : Nat) :
    programs source tableBase inputBase=GateUpSource.programs source tableBase inputBase := by
  unfold programs GateUpSource.programs
  apply List.map_congr_left
  intro thread member
  rw [thread_program source inputBase thread (List.mem_range.mp member)]
  rfl

-- The other pre-barrier loop is already parsed, including both code helpers.
theorem codebook_thread (base thread : Nat) (bound : thread<1024) :
    CodebookTableSource.Runs CodebookTableSyntax.loop base 1024 thread
      ((List.range 4).map (CodebookInitialization.entry base 1024 thread)) :=
  CodebookTableSource.source_program base 1024 thread (Or.inr rfl) bound


theorem chunk_owner (thread : Fin 1024) (chunk : Nat) (bound : chunk<640) :
    (actions thread.val).map (fun writes => writes.map Action.destination)=some [chunk] ↔ thread.val=chunk := by
  rw [selected thread]
  by_cases active : thread.val<640
  · simp only [ite_eq_left active,Option.map_some,List.map_cons,List.map_nil,Option.some.injEq,List.cons.injEq,and_true]
  · simp only [ite_eq_right active,Option.map_some,List.map_nil,Option.some.injEq]
    constructor
    · intro impossible; cases impossible
    · intro equal; omega

theorem every_chunk_owned (chunk : Nat) (bound : chunk<640) :
    ∃! thread : Fin 1024, (actions thread.val).map (fun writes => writes.map Action.destination)=some [chunk] := by
  refine ⟨⟨chunk,by omega⟩,(chunk_owner _ chunk bound).2 rfl,?_⟩
  intro other same
  exact Fin.ext ((chunk_owner other chunk bound).1 same)

theorem scratch_word_unique (inputBase c₁ c₂ w₁ w₂ : Nat) (first : w₁<4) (second : w₂<4)
    (same : inputBase/4+4*c₁+w₁=inputBase/4+4*c₂+w₂) : c₁=c₂ ∧ w₁=w₂ := by omega

structure Execution (source : ArrayStorage.BFBuffer input) (tableBase inputBase : Nat) where
  sourceAligned : source.base%16=0
  tableAligned : tableBase%4=0
  tableBounded : tableBase+16384≤2^64
  inputAligned : inputBase%16=0
  inputBounded : inputBase+10240≤2^64
  separate : Separate tableBase inputBase
  before : ByteMemory.Bytes
  schedule : List Store
  remaining : List (List Store)
  execution : ThreadgroupWrites.Executes (programs source tableBase inputBase) schedule remaining
  barrier : ThreadgroupWrites.AtBarrier remaining

def canonical (source : ArrayStorage.BFBuffer input) (tableBase inputBase : Nat)
    (sourceAligned : source.base%16=0) (tableAligned : tableBase%4=0)
    (tableBounded : tableBase+16384≤2^64) (inputAligned : inputBase%16=0)
    (inputBounded : inputBase+10240≤2^64) (separate : Separate tableBase inputBase) (before : ByteMemory.Bytes) :
    Execution source tableBase inputBase :=
  let threads:=programs source tableBase inputBase
  ⟨sourceAligned,tableAligned,tableBounded,inputAligned,inputBounded,separate,before,threads.flatten,List.replicate threads.length [],
    ThreadgroupWrites.canonical threads,ThreadgroupWrites.canonical_barrier threads⟩

-- One concrete feasible static placement inside 32 KiB of threadgroup storage.
-- The native compiler's actual placement/address-space mapping is external.
def workspace (source : ArrayStorage.BFBuffer input) (aligned : source.base%16=0) (before : ByteMemory.Bytes) :
    Execution source 0 16384 :=
  canonical source 0 16384 aligned (by decide) (by decide) (by decide) (by decide) (Or.inl (by decide)) before

theorem workspace_bytes : 16384+10240≤32768 := by decide

variable {source : ArrayStorage.BFBuffer input} {tableBase inputBase : Nat}

def Execution.existing (actual : Execution source tableBase inputBase) : GateUpSource.Trace tableBase source where
  sourceAligned:=actual.sourceAligned
  before:=actual.before
  inputBase:=inputBase
  separate:=actual.separate
  aligned:=actual.inputAligned
  schedule:=actual.schedule
  remaining:=actual.remaining
  execution:=by rw [←programs_eq]; exact actual.execution
  barrier:=actual.barrier

def Execution.memory (actual : Execution source tableBase inputBase) : ByteMemory.Bytes :=
  ByteMemory.execute actual.schedule actual.before

theorem Execution.word_copied (actual : Execution source tableBase inputBase) (chunk word : Nat)
    (chunkBound : chunk<640) (wordBound : word<4) :
    ByteMemory.load32 actual.memory (inputBase+16*chunk+4*word)=
      ByteMemory.load32 source.bytes (source.base+16*GateUpCodebook.stagedChunk chunk+4*word) :=
  actual.existing.word_copied chunk word chunkBound wordBound

theorem Execution.byte_copied (actual : Execution source tableBase inputBase) (chunk offset : Nat)
    (chunkBound : chunk<640) (offsetBound : offset<16) :
    actual.memory (inputBase+16*chunk+offset)=source.bytes
      (source.base+16*GateUpCodebook.stagedChunk chunk+offset) :=
  actual.existing.byte_copied chunk offset chunkBound offsetBound

-- Every source vector lies within the original 10240-byte BF16 input, with
-- its native uint4 alignment stated independently of BFBuffer's half alignment.
theorem source_vector_bounds (source : ArrayStorage.BFBuffer input) (aligned : source.base%16=0)
    (chunk : Nat) (bound : chunk<640) :
    let address:=source.base+16*GateUpCodebook.stagedChunk chunk
    address%16=0 ∧ source.base≤address ∧ address+16≤ source.base+10240 ∧ address+16≤2^64 := by
  have endBound:=GateUpSource.source_bounds source chunk 3 bound (by decide)
  have startBound:=GateUpSource.source_bounds source chunk 0 bound (by decide)
  exact ⟨GateUpSource.vector_aligned source aligned chunk,by omega,by omega,by omega⟩


-- Explicit platform binding for one coherent native uint4 read. All components
-- refer to the SAME supplied heap. This contract is not proved for a compiled
-- Metal instruction by the source parser or source hash guard.
abbrev Uint4Load := ByteMemory.Bytes → Nat → Fin 4 → BitVec 32
structure CoherentUint4Load (load : Uint4Load) : Prop where
  word : ∀ memory address, address%16=0 → address+16≤2^64 → ∀ word : Fin 4,
    load memory address word=ByteMemory.load32 memory (address+4*word.val)

theorem native_vector_word (load : Uint4Load) (hardware : CoherentUint4Load load)
    (source : ArrayStorage.BFBuffer input) (aligned : source.base%16=0)
    (chunk : Nat) (bound : chunk<640) (word : Fin 4) :
    load source.bytes (source.base+16*GateUpCodebook.stagedChunk chunk) word=
      ByteMemory.load32 source.bytes (source.base+16*GateUpCodebook.stagedChunk chunk+4*word.val) :=
  hardware.word source.bytes _ (source_vector_bounds source aligned chunk bound).1
    (source_vector_bounds source aligned chunk bound).2.2.2 word

def readChunk (memory : ByteMemory.Bytes) (inputBase q run : Nat) : Option (Nat → BitVec 32) := do
  let code ←GateInputContext.parseChunk GateInputContext.chunkSource
  let index ←GateInputContext.index code q run
  pure (fun word => ByteMemory.load32 memory (inputBase+16*index+4*word))

def readValue (memory : ByteMemory.Bytes) (inputBase q run p : Nat) : Option Float32 := do
  unpackValue (←readChunk memory inputBase q run) p

attribute [local irreducible] GateInputContext.index GateInputContext.parseChunk unpackValue

theorem chunk_read (memory : ByteMemory.Bytes) (inputBase q run : Nat) (qBound : q<4) (runBound : run<160) :
    readChunk memory inputBase q run=some
      (fun word => ByteMemory.load32 memory (inputBase+16*(q*160+run)+4*word)) := by
  unfold readChunk
  rw [GateInputContext.parsed_chunk]
  change (GateInputContext.index GateInputContext.chunkAST q run).bind _=_
  rw [GateInputContext.index_selected ⟨q,qBound⟩ ⟨run,runBound⟩]
  rfl

attribute [local irreducible] readChunk Execution.memory GateUpExecution.stagedRead

theorem Execution.read_original (actual : Execution source tableBase inputBase) (run q p : Nat)
    (runBound : run<160) (qBound : q<4) (pBound : p<8) :
    readValue actual.memory inputBase q run p=some
      (GateUpExecution.widen (ArrayStorage.bfWords input (run*32+q*8+p))) := by
  unfold readValue
  rw [chunk_read actual.memory inputBase q run qBound runBound]
  change unpackValue _ p=_
  rw [unpack_value _ p pBound]
  change some (GateUpBytes.read actual.memory inputBase run q p)=_
  have chunkBound : q*160+run<640 := by omega
  have wordBound : p/2<4 := by omega
  have copied := actual.word_copied (q*160+run) (p/2) chunkBound wordBound
  have original := congrArg MemoryCells.Store.value
    (GateUpSource.inputEntry_eq source inputBase (q*160+run) (p/2) chunkBound wordBound)
  change ByteMemory.load32 source.bytes (source.base+16*GateUpCodebook.stagedChunk (q*160+run)+4*(p/2))=
    GateUpExecution.pack
      (ArrayStorage.bfWords input (GateUpCodebook.stagedChunk (q*160+run)*8+2*(p/2)))
      (ArrayStorage.bfWords input (GateUpCodebook.stagedChunk (q*160+run)*8+2*(p/2)+1)) at original
  have packed := copied.trans original
  unfold GateUpBytes.read
  rw [packed]
  simpa only [GateUpExecution.stagedRead,Nat.mul_comm (p/2) 2] using
    congrArg some (GateUpExecution.stagedRead_correct (ArrayStorage.bfWords input) run q p runBound qBound pBound)

theorem Execution.read_attached (actual : Execution source tableBase inputBase) (run q p : Nat)
    (runBound : run<160) (qBound : q<4) (pBound : p<8) :
    let index : Fin 5120:=⟨run*32+q*8+p,by omega⟩
    readValue actual.memory inputBase q run p=some (GateUpExecution.widen (ArrayStorage.bits (input index))) := by
  have result:=actual.read_original run q p runBound qBound pBound
  simpa only [ArrayStorage.bfWords,dite_eq_left (show run*32+q*8+p<5120 by omega)] using result
end Inference.Kernels.Trellis.GateInputSource
