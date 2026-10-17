import contracts.mlx.ByteMemory
import kernels.trellis.GateUpBarrier

namespace Inference.Kernels.Trellis.GateUpBytes
open Contracts.Mlx GateUpExecution GateUpBarrier

-- The source input is a contiguous BF16 row, independently represented as
-- little-endian bytes. No floating-point decoding occurs while copying it.
def inputBytes (input : Nat → BitVec 16) : ByteMemory.Bytes :=
  fun address => (input (address/2)).extractLsb' (8*(address%2)) 8

theorem input_byte (input : Nat → BitVec 16) (index offset : Nat) (bound : offset<2) :
    inputBytes input (2*index+offset)=(input index).extractLsb' (8*offset) 8 := by
  unfold inputBytes
  rw [show (2*index+offset)/2=index by omega, show (2*index+offset)%2=offset by omega]

theorem pack_append (lo hi : BitVec 16) : pack lo hi=hi ++ lo := by
  apply BitVec.eq_of_getLsbD_eq
  intro j hj
  simp only [pack, BitVec.getLsbD_or, BitVec.getLsbD_shiftLeft, BitVec.getLsbD_setWidth, BitVec.getLsbD_append]
  by_cases h : j<16
  · simp [h, hj]
  · have hlow : lo.getLsbD j=false := BitVec.getLsbD_of_ge lo j (by omega)
    simp [h, hj, hlow, show j-16<16 by omega, show j-16<32 by omega]

theorem load_input (input : Nat → BitVec 16) (index : Nat) :
    ByteMemory.load32 (inputBytes input) (2*index)=pack (input index) (input (index+1)) := by
  unfold ByteMemory.load32
  rw [input_byte input index 0 (by decide), input_byte input index 1 (by decide),
    show 2*index+2=2*(index+1)+0 by omega, show 2*index+3=2*(index+1)+1 by omega,
    input_byte input (index+1) 0 (by decide), input_byte input (index+1) 1 (by decide)]
  have halves (v : BitVec 16) : v.extractLsb' 8 8 ++ v.extractLsb' 0 8=v := by
    rw [BitVec.extractLsb'_append_extractLsb'_eq_extractLsb' (by decide)]
    exact BitVec.extractLsb'_eq_self
  change (((input (index+1)).extractLsb' 8 8 ++ (input (index+1)).extractLsb' 0 8) ++
    (input index).extractLsb' 8 8) ++ (input index).extractLsb' 0 8 = pack (input index) (input (index+1))
  rw [BitVec.append_assoc]
  change ((input (index+1)).extractLsb' 8 8 ++ (input (index+1)).extractLsb' 0 8) ++
    ((input index).extractLsb' 8 8 ++ (input index).extractLsb' 0 8) = pack (input index) (input (index+1))
  rw [halves, halves]
  exact (pack_append _ _).symm

theorem source_word (input : Nat → BitVec 16) (chunk word : Nat) :
    ByteMemory.load32 (inputBytes input) (16*GateUpCodebook.stagedChunk chunk+4*word)=
      (inputEntry inputBase input chunk word).value := by
  rw [show 16*GateUpCodebook.stagedChunk chunk+4*word=2*(GateUpCodebook.stagedChunk chunk*8+2*word) by omega]
  exact load_input input _

theorem destination_word (inputBase chunk word : Nat) (input : Nat → BitVec 16) (aligned : inputBase%4=0) :
    4*(inputEntry inputBase input chunk word).word=inputBase+16*chunk+4*word := by
  change 4*(inputBase/4+4*chunk+word)=inputBase+16*chunk+4*word
  omega

theorem source_bounds (chunk word : Nat) (hc : chunk<640) (hw : word<4) :
    16*GateUpCodebook.stagedChunk chunk+4*word+4 ≤ 10240 := by
  unfold GateUpCodebook.stagedChunk
  omega

def read (memory : ByteMemory.Bytes) (inputBase run q p : Nat) : Float32 :=
  let bits := ByteMemory.load32 memory (inputBase+16*(q*160+run)+4*(p/2))
  asFloat (if p%2=1 then bits &&& 0xffff0000#32 else bits <<< 16)

theorem read_view (memory : ByteMemory.Bytes) (inputBase run q p : Nat) (aligned : inputBase%4=0) :
    read memory inputBase run q p=GateUpBarrier.read (ByteMemory.view memory) inputBase run q p := by
  unfold read GateUpBarrier.read ByteMemory.view
  rw [show 4*(inputBase/4+4*(q*160+run)+p/2)=inputBase+16*(q*160+run)+4*(p/2) by omega]

theorem ready (before : RawMemory) (tableBase inputBase : Nat) (input : Nat → BitVec 16)
    (separate : Separate tableBase inputBase) (schedule : List Store) (remaining : List (List Store))
    (execution : ThreadgroupWrites.Executes (programs tableBase inputBase input) schedule remaining)
    (barrier : ThreadgroupWrites.AtBarrier remaining) :
    Ready (ByteMemory.view (ByteMemory.execute schedule (ByteMemory.encode before))) tableBase inputBase input := by
  rw [ByteMemory.view_execute]
  exact GateUpBarrier.ready before tableBase inputBase input separate schedule remaining execution barrier

theorem read_correct (before : RawMemory) (tableBase inputBase : Nat) (input : Nat → BitVec 16)
    (separate : Separate tableBase inputBase) (aligned : inputBase%4=0)
    (schedule : List Store) (remaining : List (List Store))
    (execution : ThreadgroupWrites.Executes (programs tableBase inputBase input) schedule remaining)
    (barrier : ThreadgroupWrites.AtBarrier remaining) (run q p : Nat) (hr : run<160) (hq : q<4) (hp : p<8) :
    read (ByteMemory.execute schedule (ByteMemory.encode before)) inputBase run q p=widen (input (run*32+q*8+p)) := by
  rw [read_view _ _ _ _ _ aligned, ByteMemory.view_execute]
  exact GateUpBarrier.read_correct before tableBase inputBase input separate schedule remaining execution barrier run q p hr hq hp

theorem ready_bytes (before : ByteMemory.Bytes) (tableBase inputBase : Nat) (input : Nat → BitVec 16)
    (separate : Separate tableBase inputBase) (schedule : List Store) (remaining : List (List Store))
    (execution : ThreadgroupWrites.Executes (programs tableBase inputBase input) schedule remaining)
    (barrier : ThreadgroupWrites.AtBarrier remaining) :
    Ready (ByteMemory.view (ByteMemory.execute schedule before)) tableBase inputBase input := by
  rw [ByteMemory.view_execute_bytes]
  exact GateUpBarrier.ready (ByteMemory.view before) tableBase inputBase input separate schedule remaining execution barrier

theorem input_word_copied (before : ByteMemory.Bytes) (tableBase inputBase : Nat) (input : Nat → BitVec 16)
    (separate : Separate tableBase inputBase) (aligned : inputBase%4=0)
    (schedule : List Store) (remaining : List (List Store))
    (execution : ThreadgroupWrites.Executes (programs tableBase inputBase input) schedule remaining)
    (barrier : ThreadgroupWrites.AtBarrier remaining) (chunk word : Nat) (hc : chunk<640) (hw : word<4) :
    ByteMemory.load32 (ByteMemory.execute schedule before) (inputBase+16*chunk+4*word)=
      ByteMemory.load32 (inputBytes input) (16*GateUpCodebook.stagedChunk chunk+4*word) := by
  rw [ByteMemory.execute_bytes_load32 _ _ _ (by omega),
    show (inputBase+16*chunk+4*word)/4=inputBase/4+4*chunk+word by omega,
    GateUpBarrier.input_written (ByteMemory.view before) tableBase inputBase input separate schedule remaining execution barrier chunk word hc hw]
  exact (source_word input chunk word).symm

-- All sixteen bytes of the uint4 copy are preserved, including bit patterns
-- which would be canonicalized if first interpreted as a floating NaN.
theorem input_byte_copied (before : ByteMemory.Bytes) (tableBase inputBase : Nat) (input : Nat → BitVec 16)
    (separate : Separate tableBase inputBase) (aligned : inputBase%4=0)
    (schedule : List Store) (remaining : List (List Store))
    (execution : ThreadgroupWrites.Executes (programs tableBase inputBase input) schedule remaining)
    (barrier : ThreadgroupWrites.AtBarrier remaining) (chunk offset : Nat) (hc : chunk<640) (ho : offset<16) :
    ByteMemory.execute schedule before (inputBase+16*chunk+offset)=
      inputBytes input (16*GateUpCodebook.stagedChunk chunk+offset) := by
  have copied := congrArg (fun value => ByteMemory.byte value (offset%4))
    (input_word_copied before tableBase inputBase input separate aligned schedule remaining execution barrier chunk (offset/4) hc (by omega))
  rw [ByteMemory.byte_load32 _ _ _ (by omega), ByteMemory.byte_load32 _ _ _ (by omega)] at copied
  simpa only [show inputBase+16*chunk+4*(offset/4)+offset%4=inputBase+16*chunk+offset by omega,
    show 16*GateUpCodebook.stagedChunk chunk+4*(offset/4)+offset%4=16*GateUpCodebook.stagedChunk chunk+offset by omega] using copied

structure Trace (tableBase : Nat) (input : Nat → BitVec 16) where
  before : ByteMemory.Bytes
  inputBase : Nat
  separate : Separate tableBase inputBase
  aligned : inputBase%4=0
  schedule : List Store
  remaining : List (List Store)
  execution : ThreadgroupWrites.Executes (programs tableBase inputBase input) schedule remaining
  barrier : ThreadgroupWrites.AtBarrier remaining

def Trace.memory (trace : Trace tableBase input) : RawMemory :=
  ByteMemory.view (ByteMemory.execute trace.schedule trace.before)

theorem Trace.ready (trace : Trace tableBase input) : Ready trace.memory tableBase trace.inputBase input :=
  ready_bytes trace.before tableBase trace.inputBase input trace.separate trace.schedule trace.remaining trace.execution trace.barrier

def Trace.canonical (tableBase : Nat) (input : Nat → BitVec 16) (before : ByteMemory.Bytes)
    (inputBase : Nat) (aligned : inputBase%4=0) (separate : Separate tableBase inputBase) : Trace tableBase input :=
  let threads := programs tableBase inputBase input
  ⟨before, inputBase, separate, aligned, threads.flatten, List.replicate threads.length [],
    ThreadgroupWrites.canonical threads, ThreadgroupWrites.canonical_barrier threads⟩

end Inference.Kernels.Trellis.GateUpBytes
