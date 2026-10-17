import kernels.trellis.CodebookBarrier
import kernels.trellis.GateUpExecution
import contracts.mlx.MemoryCells
import FloatLib.Floats.Formats.IEEE754.Native.Model

namespace Inference.Kernels.Trellis.GateUpBarrier
open Contracts.Mlx Contracts.Mlx.M1Max GateUpExecution
abbrev RawMemory := Nat → BitVec 32
abbrev Store := MemoryCells.Store (BitVec 32)

-- Both arrays share raw word storage. Codebook floats are serialized once;
-- the uint4 input words retain every bit, including possible NaN encodings.
def codeEntry (base thread iteration : Nat) : Store :=
  let entry := CodebookInitialization.entry base 1024 thread iteration
  ⟨entry.word, entry.value.toBits.toBitVec⟩
def inputEntry (base : Nat) (x : Nat → BitVec 16) (chunk word : Nat) : Store :=
  ⟨base/4+4*chunk+word, pack (x (GateUpCodebook.stagedChunk chunk*8+2*word))
    (x (GateUpCodebook.stagedChunk chunk*8+2*word+1))⟩

def programs (tableBase inputBase : Nat) (x : Nat → BitVec 16) : List (List Store) :=
  (List.range 1024).map fun thread =>
    (List.range 4).map (codeEntry tableBase thread) ++
      if thread<640 then (List.range 4).map (inputEntry inputBase x thread) else []

theorem input_loop (thread iteration : Nat) (ht : thread<1024) :
    thread+1024*iteration<640 ↔ thread<640 ∧ iteration=0 := by omega

theorem source_cases (tableBase inputBase : Nat) (x : Nat → BitVec 16) (store : Store)
    (member : store ∈ (programs tableBase inputBase x).flatten) :
    (∃ thread iteration, thread<1024 ∧ iteration<4 ∧ store=codeEntry tableBase thread iteration) ∨
      ∃ chunk word, chunk<640 ∧ word<4 ∧ store=inputEntry inputBase x chunk word := by
  obtain ⟨threadStores, hm, hs⟩ := List.mem_flatten.mp member
  obtain ⟨thread, ht, rfl⟩ := List.mem_map.mp hm
  rcases List.mem_append.mp hs with code | input
  · obtain ⟨iteration, hi, equal⟩ := List.mem_map.mp code
    exact Or.inl ⟨thread, iteration, List.mem_range.mp ht, List.mem_range.mp hi, equal.symm⟩
  · right
    split at input
    next hc =>
      obtain ⟨word, hw, equal⟩ := List.mem_map.mp input
      exact ⟨thread, word, hc, List.mem_range.mp hw, equal.symm⟩
    next hc => simp at input

theorem codebook_member (tableBase inputBase : Nat) (x : Nat → BitVec 16)
    (thread iteration : Nat) (ht : thread<1024) (hi : iteration<4) :
    codeEntry tableBase thread iteration ∈ (programs tableBase inputBase x).flatten := by
  apply List.mem_flatten.mpr
  refine ⟨_, List.mem_map.mpr ⟨thread, List.mem_range.mpr ht, rfl⟩, ?_⟩
  exact List.mem_append.mpr (Or.inl (List.mem_map.mpr ⟨iteration, List.mem_range.mpr hi, rfl⟩))

theorem input_member (tableBase inputBase : Nat) (x : Nat → BitVec 16)
    (chunk word : Nat) (hc : chunk<640) (hw : word<4) :
    inputEntry inputBase x chunk word ∈ (programs tableBase inputBase x).flatten := by
  apply List.mem_flatten.mpr
  refine ⟨_, List.mem_map.mpr ⟨chunk, List.mem_range.mpr (by omega), rfl⟩, ?_⟩
  apply List.mem_append.mpr
  right
  rw [ite_eq_left hc]
  exact List.mem_map.mpr ⟨word, List.mem_range.mpr hw, rfl⟩

theorem input_bounds (base : Nat) (x : Nat → BitVec 16) (chunk word : Nat) (hc : chunk<640) (hw : word<4) :
    base/4 ≤ (inputEntry base x chunk word).word ∧ (inputEntry base x chunk word).word < base/4+2560 := by
  simp only [inputEntry]
  omega

theorem input_injective (base : Nat) (x : Nat → BitVec 16) (c₁ c₂ w₁ w₂ : Nat) (h₁ : w₁<4) (h₂ : w₂<4)
    (equal : (inputEntry base x c₁ w₁).word=(inputEntry base x c₂ w₂).word) : c₁=c₂ ∧ w₁=w₂ := by
  simp only [inputEntry] at equal
  omega

-- Native allocation/compiled layout supplies this static placement contract.
def Separate (tableBase inputBase : Nat) : Prop :=
  tableBase/4+4096 ≤ inputBase/4 ∨ inputBase/4+2560 ≤ tableBase/4

def floatMemory (memory : RawMemory) : WordMemory := fun word => asFloat (memory word)

theorem asFloat_toBits (value : Float32) : asFloat value.toBits.toBitVec=value := by
  cases value with
  | ofModel value =>
    change Float32.ofModel (FloatLib.Floats.Formats.BinaryInterchange.Model.toFloat32Model
      (FloatLib.Floats.Formats.BinaryInterchange.Model.ofFloat32Model value)) = Float32.ofModel value
    rw [FloatLib.Floats.Formats.BinaryInterchange.Model.toFloat32Model_ofFloat32Model]

theorem codebook_initialized (before : RawMemory) (tableBase inputBase : Nat) (x : Nat → BitVec 16)
    (separate : Separate tableBase inputBase)
    (schedule : List Store) (remaining : List (List Store))
    (execution : ThreadgroupWrites.Executes (programs tableBase inputBase x) schedule remaining)
    (barrier : ThreadgroupWrites.AtBarrier remaining) :
    CodebookLoad.Initialized (floatMemory (MemoryCells.execute schedule before)) tableBase := by
  intro i hi
  have stored : MemoryCells.execute schedule before (tableBase/4+i) =
      (CodebookLoad.codeValue (BitVec.ofNat 32 i)).toBits.toBitVec := by
    apply MemoryCells.completed_value execution barrier before _ _
    · intro store member equal
      rcases source_cases tableBase inputBase x store member with
        ⟨thread, iteration, ht, hit, rfl⟩ | ⟨chunk, word, hc, hw, rfl⟩
      · have index : thread+1024*iteration=i := by
          simp only [codeEntry, CodebookInitialization.entry] at equal
          omega
        simp only [codeEntry, CodebookInitialization.entry, index]
      · have h := input_bounds inputBase x chunk word hc hw
        unfold Separate at separate
        omega
    · refine ⟨codeEntry tableBase (i%1024) (i/1024),
        codebook_member tableBase inputBase x _ _ (by omega) (by omega), ?_⟩
      simp only [codeEntry, CodebookInitialization.entry]
      omega
  change asFloat (MemoryCells.execute schedule before (tableBase/4+i)) = _
  rw [stored, asFloat_toBits]

theorem input_written (before : RawMemory) (tableBase inputBase : Nat) (x : Nat → BitVec 16)
    (separate : Separate tableBase inputBase)
    (schedule : List Store) (remaining : List (List Store))
    (execution : ThreadgroupWrites.Executes (programs tableBase inputBase x) schedule remaining)
    (barrier : ThreadgroupWrites.AtBarrier remaining) (chunk word : Nat) (hc : chunk<640) (hw : word<4) :
    MemoryCells.execute schedule before (inputBase/4+4*chunk+word)=(inputEntry inputBase x chunk word).value := by
  apply MemoryCells.completed_value execution barrier before _ _
  · intro store member equal
    rcases source_cases tableBase inputBase x store member with
      ⟨thread, iteration, ht, hit, rfl⟩ | ⟨other, index, ho, hi, rfl⟩
    · simp only [codeEntry, CodebookInitialization.entry] at equal
      unfold Separate at separate
      omega
    · have same := input_injective inputBase x other chunk index word hi hw equal
      rcases same with ⟨rfl, rfl⟩
      rfl
  · exact ⟨inputEntry inputBase x chunk word, input_member tableBase inputBase x chunk word hc hw, rfl⟩

def read (memory : RawMemory) (inputBase run q p : Nat) : Float32 :=
  let bits := memory (inputBase/4+4*(q*160+run)+p/2)
  asFloat (if p%2=1 then bits &&& 0xffff0000#32 else bits <<< 16)

theorem read_correct (before : RawMemory) (tableBase inputBase : Nat) (x : Nat → BitVec 16)
    (separate : Separate tableBase inputBase)
    (schedule : List Store) (remaining : List (List Store))
    (execution : ThreadgroupWrites.Executes (programs tableBase inputBase x) schedule remaining)
    (barrier : ThreadgroupWrites.AtBarrier remaining) (run q p : Nat) (hr : run<160) (hq : q<4) (hp : p<8) :
    read (MemoryCells.execute schedule before) inputBase run q p = widen (x (run*32+q*8+p)) := by
  unfold read
  rw [input_written before tableBase inputBase x separate schedule remaining execution barrier
    (q*160+run) (p/2) (by omega) (by omega)]
  simpa only [inputEntry, Nat.mul_comm 2 (p/2), stagedRead] using
    stagedRead_correct x run q p hr hq hp

structure Ready (memory : RawMemory) (tableBase inputBase : Nat) (x : Nat → BitVec 16) : Prop where
  codebook : CodebookLoad.Initialized (floatMemory memory) tableBase
  input : ∀ run q p, run<160 → q<4 → p<8 → read memory inputBase run q p=stagedRead x run q p

theorem ready (before : RawMemory) (tableBase inputBase : Nat) (x : Nat → BitVec 16)
    (separate : Separate tableBase inputBase)
    (schedule : List Store) (remaining : List (List Store))
    (execution : ThreadgroupWrites.Executes (programs tableBase inputBase x) schedule remaining)
    (barrier : ThreadgroupWrites.AtBarrier remaining) :
    Ready (MemoryCells.execute schedule before) tableBase inputBase x := by
  refine ⟨codebook_initialized before tableBase inputBase x separate schedule remaining execution barrier, ?_⟩
  intro run q p hr hq hp
  exact (read_correct before tableBase inputBase x separate schedule remaining execution barrier run q p hr hq hp).trans
    (stagedRead_correct x run q p hr hq hp).symm

end Inference.Kernels.Trellis.GateUpBarrier
