import kernels.trellis.PackedArrayDownMaterialization
namespace Inference.Kernels.Trellis.PackedArrayConsumer
open Contracts.Mlx Contracts.Mlx.M1Max PackedArrayMaterialization PackedArrayDownMaterialization
set_option maxRecDepth 10000

-- The private arrays below are constructed by the parsed declaration/load/
-- alignment programs, rather than supplied by a caller equality.
theorem gate_read (input : GateInput kg ku) (row run j : Nat) (isUp : Bool)
    (rowBound : row<17408) (runBound : run<160) (column : j<32)
    (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : WordMemory) (base : Nat) (completed : CodebookTableSource.ParsedCompleted base 1024)
    (aligned : base%4=0) (room : base+16384≤2^64) :
    CodebookWindowSource.readActual load (Memory.execute completed.schedule before) base
      (input.arrays row run isUp) ((31-j)*(if isUp then ku else kg))=
      some (CodebookLoad.mathematicalCode (Codebook.PackedState.read
        (input.matrix isUp row (run/8)) (if isUp then ku else kg) (run%8*32+j))) := by
  unfold CodebookWindowSource.readActual
  rw [input.window row run isUp j rowBound runBound column]
  have valid : (if isUp then ku else kg)=2 ∨ (if isUp then ku else kg)=3 ∨ (if isUp then ku else kg)=4 := by
    cases isUp <;> first | exact input.validG | exact input.validU
  change some (CodebookLoad.read load (Memory.execute completed.schedule before) base
    (GateUpCodebook.runWords (input.matrix isUp row (run/8)) run (if isUp then ku else kg))
    ((31-j)*(if isUp then ku else kg)))=_
  exact congrArg some (GateUpCodebook.load_correct load hardware _ base aligned room
    (CodebookTableSource.parsed_initialized before base 1024 (Or.inr rfl) completed)
    _ run (if isUp then ku else kg) j valid column)

theorem down_read (input : Input k) (row0 row1 block lane u i : Nat) (paired : Bool)
    (row0Bound : row0<17408) (row1Bound : row1<17408) (blockBound : block<20)
    (laneBound : lane<16) (rowBound : if paired then u<2 else u=0) (column : i<16)
    (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : WordMemory) (base : Nat) (completed : CodebookTableSource.ParsedCompleted base 256)
    (aligned : base%4=0) (room : base+16384≤2^64) :
    CodebookWindowSource.readActual load (Memory.execute completed.schedule before) base
      (input.arrays row0 row1 block lane u paired) (i*k)=
      some (CodebookLoad.mathematicalCode (Codebook.PackedState.read
        (input.matrix (selectedRow row0 row1 u) block) k (255-(lane*16+i)))) := by
  unfold CodebookWindowSource.readActual
  rw [input.window row0 row1 block lane u i paired row0Bound row1Bound blockBound laneBound rowBound column]
  change some (CodebookLoad.read load (Memory.execute completed.schedule before) base
    (DownCodebook.Lane.alignedWord (input.matrix (selectedRow row0 row1 u) block) k lane) (i*k))=_
  exact congrArg some (DownCodebook.load_correct load hardware _ base aligned room
    (CodebookTableSource.parsed_initialized before base 256 (Or.inl rfl) completed)
    _ k lane i input.valid laneBound column)
end Inference.Kernels.Trellis.PackedArrayConsumer
