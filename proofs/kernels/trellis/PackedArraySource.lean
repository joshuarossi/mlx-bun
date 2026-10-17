import kernels.trellis.PackedArrayWeights
namespace Inference.Kernels.Trellis.PackedArraySource
open Contracts.Mlx Contracts.Mlx.M1Max Models.Qwen PackedArraySyntax PackedArraySemantics PackedArrayPrograms
set_option maxRecDepth 10000

def downResult (paired : Bool) (k lane row : Nat) : Option State := do
  let state ←sourceExecute [downIndexDeclaration,downIndex] (PackedArrayDown.initial k lane)
  let state ←if paired then do
    let loaded ←sourceExecute [downPairDeclaration,downPairLoad] state
    sourceExecute [downPairLoad] (PackedArrayDown.selectRow loaded 1)
    else sourceExecute [downTailDeclaration,downTailLoad] state
  sourceExecute [downWordsDeclaration,(if paired then downPairAlign else downTailAlign),downVirtualZero,downVirtual]
    (PackedArrayDown.selectRow state row)

theorem parsed_down_load : parsedFragments [downPairLoad]=some [downLoadAST true] := rfl

theorem down_from_source (paired : Bool) (k lane row : Nat) :
    downResult paired k lane row=PackedArrayDown.result paired k lane row := by
  cases paired <;> simp only [Bool.false_eq_true, ite_false, ite_true, bind_assoc,downResult,PackedArrayDown.result,PackedArrayDown.pairLoads,
    PackedArrayDown.tailLoads,PackedArrayDown.indexResult,sourceExecute_parsed _ _ parsed_down_index,
    sourceExecute_parsed _ _ parsed_down_pair_load,sourceExecute_parsed _ _ parsed_down_tail_load,
    sourceExecute_parsed _ _ parsed_down_load,sourceExecute_parsed _ _ parsed_down_pair_align,
    sourceExecute_parsed _ _ parsed_down_tail_align]

-- These bounds apply to the actual original global load addresses. Array
-- construction and the subsequent window proofs establish every private read
-- is initialized and inside its declared dimensions.
theorem gate_global_bounds (input : PackedArrayMaterialization.GateInput kg ku)
    (row run index : Nat) (rowBound : row<17408) (runBound : run<160) (bound : index≤kg) :
    let address:=input.gate.code.base+4*CheckpointTrellisMemory.gateIndex row run kg index
    address%4=0 ∧ input.gate.code.base≤address ∧
      address+4≤ input.gate.code.base+4*(17408*20*(8*kg)) ∧ address+4≤ 2^64 :=
  CheckpointTrellisMemory.gate_byte_bounds _ row run kg index input.validG rowBound runBound bound
    input.gate.codeAligned input.gate.code.bounded

theorem up_global_bounds (input : PackedArrayMaterialization.GateInput kg ku)
    (row run index : Nat) (rowBound : row<17408) (runBound : run<160) (bound : index≤ku) :
    let address:=input.up.code.base+4*CheckpointTrellisMemory.gateIndex row run ku index
    address%4=0 ∧ input.up.code.base≤address ∧
      address+4≤ input.up.code.base+4*(17408*20*(8*ku)) ∧ address+4≤ 2^64 :=
  CheckpointTrellisMemory.gate_byte_bounds _ row run ku index input.validU rowBound runBound bound
    input.up.codeAligned input.up.code.bounded

theorem down_global_bounds (input : PackedArrayDownMaterialization.Input k)
    (row block word : Nat) (rowBound : row<17408) (blockBound : block<20) (wordBound : word<8*k) :
    let address:=input.storage.code.base+4*CheckpointTrellisMemory.downIndex row block word k
    address%4=0 ∧ input.storage.code.base≤address ∧
      address+4≤ input.storage.code.base+4*(17408*20*(8*k)) ∧ address+4≤ 2^64 :=
  CheckpointTrellisMemory.down_byte_bounds _ row block word k input.valid rowBound blockBound wordBound
    input.storage.codeAligned input.storage.code.bounded
theorem original_gate_read {mlp : WrittenLayers.GateDown} {memory : ByteMemory.Bytes}
    (weights : TrellisWeightsMemory.Weights mlp memory) (row run j : Nat) (isUp : Bool)
    (rowBound : row<17408) (runBound : run<160) (column : j<32)
    (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : WordMemory) (base : Nat) (completed : CodebookTableSource.ParsedCompleted base 1024)
    (aligned : base%4=0) (room : base+16384≤2^64) :
    CodebookWindowSource.readActual load (Memory.execute completed.schedule before) base
      ((PackedArrayWeights.gate weights).arrays row run isUp) ((31-j)*(if isUp then mlp.up.width else mlp.gate.width))=
      some (CodebookLoad.mathematicalCode (Codebook.PackedState.read
        ((if isUp then mlp.up.words else mlp.gate.words) row (run/8)) (if isUp then mlp.up.width else mlp.gate.width) (run%8*32+j))) := by
  have result:=PackedArrayConsumer.gate_read (PackedArrayWeights.gate weights) row run j isUp rowBound runBound column load hardware before base completed aligned room
  rw [PackedArrayWeights.gate_matrix] at result
  exact result

theorem original_down_read {mlp : WrittenLayers.GateDown} {memory : ByteMemory.Bytes}
    (weights : TrellisWeightsMemory.Weights mlp memory) (row0 row1 block lane u i : Nat) (paired : Bool)
    (row0Bound : row0<17408) (row1Bound : row1<17408) (blockBound : block<20)
    (laneBound : lane<16) (rowBound : if paired then u<2 else u=0) (column : i<16)
    (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : WordMemory) (base : Nat) (completed : CodebookTableSource.ParsedCompleted base 256)
    (aligned : base%4=0) (room : base+16384≤2^64) :
    CodebookWindowSource.readActual load (Memory.execute completed.schedule before) base
      ((PackedArrayWeights.down weights).arrays row0 row1 block lane u paired) (i*mlp.down.width)=
      some (CodebookLoad.mathematicalCode (Codebook.PackedState.read
        (mlp.down.words (PackedArrayDownMaterialization.selectedRow row0 row1 u) block) mlp.down.width (255-(lane*16+i)))) := by
  have result:=PackedArrayConsumer.down_read (PackedArrayWeights.down weights) row0 row1 block lane u i paired row0Bound row1Bound blockBound laneBound rowBound column load hardware before base completed aligned room
  rw [PackedArrayWeights.down_matrix] at result
  exact result

end Inference.Kernels.Trellis.PackedArraySource
