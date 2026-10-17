import kernels.trellis.CodebookWindowSemantics
import kernels.trellis.CodebookTableSource
import kernels.trellis.GateUpCodebook
import kernels.trellis.DownCodebook
namespace Inference.Kernels.Trellis.CodebookWindowSource
open Contracts.Mlx Contracts.Mlx.M1Max CodebookWindowSemantics
set_option maxRecDepth 10000

-- Private arrays are immutable during this helper call. Their construction
-- from packed device words is supplied by the existing runWords/alignedWord
-- translations; those caller loops are not parsed by this module.
def read (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (words : Nat → BitVec 32) (offset : Nat) : Option Float32 := do
  let bits ←byteOffset words offset
  pure (load memory (base+bits.toNat))

theorem read_eq (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (words : Nat → BitVec 32) (offset : Nat) (bounded : offset≤124) :
    read load memory base words offset=some (CodebookLoad.read load memory base words offset) := by
  unfold read
  rw [source_byteOffset words offset bounded]
  rfl

theorem offset_bounds (words : Nat → BitVec 32) (offset : Nat) (bounded : offset≤124) :
    ∃ bits, byteOffset words offset=some bits ∧ bits.toNat<16384 ∧ (bits >>> 2).toNat<4096 :=
  ⟨_,source_byteOffset words offset bounded,Codebook.CodebookWindow.byteOffset_bound words offset,
    Codebook.CodebookWindow.index_bound words offset⟩

theorem gate_index (words : Nat → BitVec 32) (run k j : Nat)
    (width : k=2 ∨ k=3 ∨ k=4) (column : j<32) :
    (byteOffset (GateUpCodebook.runWords words run k) ((31-j)*k)).map (fun (bits : BitVec 32) => bits >>> (2 : Nat))=
      some (Codebook.PackedState.read words k (run%8*32+j)) := by
  rw [source_byteOffset _ _ (GateUpCodebook.window_bounds k j width column).1]
  exact congrArg some (GateUpCodebook.window_state words run k j width column)

theorem down_index (words : Nat → BitVec 32) (k lane i : Nat)
    (width : k=2 ∨ k=3 ∨ k=4) (laneBound : lane<16) (column : i<16) :
    (byteOffset (DownCodebook.Lane.alignedWord words k lane) (i*k)).map (fun (bits : BitVec 32) => bits >>> (2 : Nat))=
      some (Codebook.PackedState.read words k (255-(lane*16+i))) := by
  rw [source_byteOffset _ _ (Nat.le_trans (Codebook.CodebookWindow.lane_geometry k i width column).1 (by decide))]
  exact congrArg some (DownCodebook.window_state words k lane i width laneBound column)

-- Parsed table initialization supplies actual table contents. The load's
-- handling of low two byte-address bits remains the explicit M1Max contract.
theorem read_initialized (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : WordMemory) (base threads : Nat) (width : threads=256 ∨ threads=1024)
    (completed : CodebookTableSource.ParsedCompleted base threads)
    (aligned : base%4=0) (room : base+16384≤2^64)
    (words : Nat → BitVec 32) (offset : Nat) (bounded : offset≤124) :
    read load (Memory.execute completed.schedule before) base words offset=
      some (CodebookLoad.mathematicalCode (Codebook.CodebookWindow.byteOffset words offset >>> 2)) := by
  rw [read_eq _ _ _ _ _ bounded]
  exact congrArg some (CodebookTableSource.parsed_read load hardware before base threads width completed aligned room words offset)

theorem gate_read (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : WordMemory) (base : Nat) (completed : CodebookTableSource.ParsedCompleted base 1024)
    (aligned : base%4=0) (room : base+16384≤2^64)
    (words : Nat → BitVec 32) (run k j : Nat) (width : k=2 ∨ k=3 ∨ k=4) (column : j<32) :
    read load (Memory.execute completed.schedule before) base (GateUpCodebook.runWords words run k) ((31-j)*k)=
      some (CodebookLoad.mathematicalCode (Codebook.PackedState.read words k (run%8*32+j))) := by
  rw [read_initialized load hardware before base 1024 (Or.inr rfl) completed aligned room _ _
    (GateUpCodebook.window_bounds k j width column).1]
  rw [GateUpCodebook.window_state words run k j width column]

theorem down_read (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : WordMemory) (base : Nat) (completed : CodebookTableSource.ParsedCompleted base 256)
    (aligned : base%4=0) (room : base+16384≤2^64)
    (words : Nat → BitVec 32) (k lane i : Nat) (width : k=2 ∨ k=3 ∨ k=4)
    (laneBound : lane<16) (column : i<16) :
    read load (Memory.execute completed.schedule before) base (DownCodebook.Lane.alignedWord words k lane) (i*k)=
      some (CodebookLoad.mathematicalCode (Codebook.PackedState.read words k (255-(lane*16+i)))) := by
  rw [read_initialized load hardware before base 256 (Or.inl rfl) completed aligned room _ _
    (Nat.le_trans (Codebook.CodebookWindow.lane_geometry k i width column).1 (by decide))]
  rw [DownCodebook.window_state words k lane i width laneBound column]
def readActual (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (actual : String → Nat → BitVec 32) (offset : Nat) : Option Float32 := do
  let bits ←executeArrays actual offset
  pure (load memory (base+bits.toNat))

theorem actual_read_eq (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (actual : String → Nat → BitVec 32) (words : Nat → BitVec 32)
    (wordLink : actual "w"=words) (virtualLink : actual "v"=Codebook.CodebookWindow.virtualWord words)
    (offset : Nat) (bounded : offset≤124) :
    readActual load memory base actual offset=read load memory base words offset := by
  unfold readActual read
  rw [linked_arrays actual words wordLink virtualLink offset bounded,source_byteOffset words offset bounded]

theorem actual_gate_read (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : WordMemory) (base : Nat) (completed : CodebookTableSource.ParsedCompleted base 1024)
    (aligned : base%4=0) (room : base+16384≤2^64)
    (actual : String → Nat → BitVec 32) (words : Nat → BitVec 32) (run k j : Nat)
    (wordLink : actual "w"=GateUpCodebook.runWords words run k)
    (virtualLink : actual "v"=Codebook.CodebookWindow.virtualWord (GateUpCodebook.runWords words run k))
    (width : k=2 ∨ k=3 ∨ k=4) (column : j<32) :
    readActual load (Memory.execute completed.schedule before) base actual ((31-j)*k)=
      some (CodebookLoad.mathematicalCode (Codebook.PackedState.read words k (run%8*32+j))) := by
  rw [actual_read_eq _ _ _ actual _ wordLink virtualLink _ (GateUpCodebook.window_bounds k j width column).1]
  exact gate_read load hardware before base completed aligned room words run k j width column

theorem actual_down_read (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : WordMemory) (base : Nat) (completed : CodebookTableSource.ParsedCompleted base 256)
    (aligned : base%4=0) (room : base+16384≤2^64)
    (actual : String → Nat → BitVec 32) (words : Nat → BitVec 32) (k lane i : Nat)
    (wordLink : actual "w"=DownCodebook.Lane.alignedWord words k lane)
    (virtualLink : actual "v"=Codebook.CodebookWindow.virtualWord (DownCodebook.Lane.alignedWord words k lane))
    (width : k=2 ∨ k=3 ∨ k=4) (laneBound : lane<16) (column : i<16) :
    readActual load (Memory.execute completed.schedule before) base actual (i*k)=
      some (CodebookLoad.mathematicalCode (Codebook.PackedState.read words k (255-(lane*16+i)))) := by
  rw [actual_read_eq _ _ _ actual _ wordLink virtualLink _
    (Nat.le_trans (Codebook.CodebookWindow.lane_geometry k i width column).1 (by decide))]
  exact down_read load hardware before base completed aligned room words k lane i width laneBound column

end Inference.Kernels.Trellis.CodebookWindowSource
