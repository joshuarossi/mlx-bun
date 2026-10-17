import kernels.quantization.MlxQmvPrivate4Memory
import kernels.quantization.MlxQmvFast4Output
namespace Inference.Kernels.Quantization.MlxQmvFast4Pointers
open Contracts.Mlx
open FloatLib.Floats.Formats.BinaryInterchange
open Sampling.ArgmaxShuffleSyntax (acceptMany)
set_option maxRecDepth 10000

-- Restricted parsers retain the exact native pointer arithmetic operations.
-- Template constants are bits=4, group_size=64, packs=2, pack_factor=8,
-- bytes_per_pack=4, values=16, block=512. Native descriptor attachment and
-- compiler pointer representation remain boundary contracts.
def parsePointers (source : String) : Option Unit := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←acceptMany ["ws","+=","out_row","*","in_vec_size_w","+","simd_lid","*","packs_per_thread","*","bytes_per_pack",";",
    "scales","+=","out_row","*","in_vec_size_g","+","simd_lid","/","scale_step_per_thread",";",
    "biases","+=","out_row","*","in_vec_size_g","+","simd_lid","/","scale_step_per_thread",";",
    "x","+=","tid",".","x","*","in_vec_size","+","simd_lid","*","values_per_thread",";",
    "y","+=","tid",".","x","*","out_vec_size","+","out_row",";"] ts
  if ts=[] then some () else none

def parseUpdates (source : String) : Option Unit := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←acceptMany ["ws","+=","block_size","*","bytes_per_pack","/","pack_factor",";",
    "scales","+=","block_size","/","group_size",";",
    "biases","+=","block_size","/","group_size",";","x","+=","block_size",";"] ts
  if ts=[] then some () else none

def parseReads (source : String) : Option Unit := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←acceptMany ["auto","wl","=","(","const","device","uint8_t","*",")","(","ws","+","row","*","in_vec_size_w",")",";",
    "const","device","T","*","sl","=","scales","+","row","*","in_vec_size_g",";",
    "const","device","T","*","bl","=","biases","+","row","*","in_vec_size_g",";",
    "U","s","=","sl","[","0","]",";","U","b","=","bl","[","0","]",";"] ts
  if ts=[] then some () else none

def pointersSource : String := "ws += out_row * in_vec_size_w + simd_lid * packs_per_thread * bytes_per_pack;\n  scales += out_row * in_vec_size_g + simd_lid / scale_step_per_thread;\n  biases += out_row * in_vec_size_g + simd_lid / scale_step_per_thread;\n  x += tid.x * in_vec_size + simd_lid * values_per_thread;\n  y += tid.x * out_vec_size + out_row;"
def updatesSource : String := "ws += block_size * bytes_per_pack / pack_factor;\n    scales += block_size / group_size;\n    biases += block_size / group_size;\n    x += block_size;"
def readsSource : String := "auto wl = (const device uint8_t*)(ws + row * in_vec_size_w);\n      const device T* sl = scales + row * in_vec_size_g;\n      const device T* bl = biases + row * in_vec_size_g;\n\n      U s = sl[0];\n      U b = bl[0];"
theorem parsed_pointers : parsePointers pointersSource=some () := by decide +kernel
theorem parsed_updates : parseUpdates updatesSource=some () := by decide +kernel
theorem parsed_reads : parseReads readsSource=some () := by decide +kernel
attribute [local irreducible] parsePointers parseUpdates parseReads

def packedOffset (steps group row step lane : Nat) : Nat :=
  (group*4)*(steps*512*4/8)+lane*2*4+step*(512*4/8)+row*(steps*512*4/8)
def parameterOffset (steps group row step lane : Nat) : Nat :=
  (group*4)*(steps*512/64)+lane/(64/16)+step*(512/64)+row*(steps*512/64)
def inputOffset (step lane : Nat) : Nat := lane*16+step*512

def memory (buffers : AffineLoads.Buffers) (group : Fin groups) (row : Fin 4)
    (step : Fin steps) (lane : Fin 32) (cells : Nat→Float32) : MlxQmvDot4Source.Memory :=
  ⟨buffers.packed,buffers.packedBase+packedOffset steps group.val row.val step.val lane.val,cells,0⟩

theorem memory_eq (buffers : AffineLoads.Buffers) (group : Fin groups) (row : Fin 4)
    (step : Fin steps) (lane : Fin 32) (cells : Nat→Float32) :
    memory buffers group row step lane cells=MlxQmvDot4TileMemory.view buffers (CopyContiguous.index group row) step lane cells 0 := by
  unfold memory MlxQmvDot4TileMemory.view
  congr 1
  simp only [packedOffset,AffineLayout.weightOffset,CopyContiguous.index]
  have width : steps*512*4/8=steps*256 := by omega
  rw [width]
  ring

theorem parameter_eq (group : Fin groups) (row : Fin 4) (step : Fin steps) (lane : Fin 32) :
    parameterOffset steps group.val row.val step.val lane.val=
      (CopyContiguous.index group row).val*(steps*8)+(AffineRow.groupIndex step lane).val := by
  simp only [parameterOffset,CopyContiguous.index,AffineRow.groupIndex]
  have width : steps*512/64=steps*8 := by omega
  rw [width]
  norm_num only
  ring

def scale (buffers : AffineLoads.Buffers) (group : Fin groups) (row : Fin 4) (step : Fin steps) (lane : Fin 32) : ArrayStorage.BF :=
  Model.ofBits (HalfMemory.load buffers.scales (buffers.scaleBase+2*parameterOffset steps group.val row.val step.val lane.val))
def bias (buffers : AffineLoads.Buffers) (group : Fin groups) (row : Fin 4) (step : Fin steps) (lane : Fin 32) : ArrayStorage.BF :=
  Model.ofBits (HalfMemory.load buffers.biases (buffers.biasBase+2*parameterOffset steps group.val row.val step.val lane.val))
theorem scale_eq (buffers : AffineLoads.Buffers) (group : Fin groups) (row : Fin 4) (step : Fin steps) (lane : Fin 32) :
    scale buffers group row step lane=AffineLoads.scale buffers (CopyContiguous.index group row) (AffineRow.groupIndex step lane) := by
  simp only [scale,parameter_eq,AffineLoads.scale,AffineLoads.groupIndex]
theorem bias_eq (buffers : AffineLoads.Buffers) (group : Fin groups) (row : Fin 4) (step : Fin steps) (lane : Fin 32) :
    bias buffers group row step lane=AffineLoads.bias buffers (CopyContiguous.index group row) (AffineRow.groupIndex step lane) := by
  simp only [bias,parameter_eq,AffineLoads.bias,AffineLoads.groupIndex]

theorem advance (steps group row step lane : Nat) :
    packedOffset steps group row (step+1) lane=packedOffset steps group row step lane+256 ∧
    parameterOffset steps group row (step+1) lane=parameterOffset steps group row step lane+8 ∧
    inputOffset (step+1) lane=inputOffset step lane+512 := by
  simp only [packedOffset,parameterOffset,inputOffset]
  omega

theorem input_eq (step : Fin steps) (lane : Fin 32) : inputOffset step.val lane.val=step.val*512+lane.val*16 := by
  simp [inputOffset,Nat.add_comm]

theorem signed_offsets (limit : groups≤62080) (hsteps : steps≤15) (group : Fin groups)
    (row : Fin 4) (step : Fin steps) (lane : Fin 32) :
    packedOffset steps group.val row.val step.val lane.val+8<2^31 ∧
    parameterOffset steps group.val row.val step.val lane.val<2^31 ∧
    inputOffset step.val lane.val+16<2^31 := by
  have g := group.isLt;have r := row.isLt;have s := step.isLt;have l := lane.isLt
  have gr : group.val*4+row.val<248320 := by omega
  have product := Nat.mul_le_mul (show group.val*4+row.val≤248320 by omega) (show steps*256≤3840 by omega)
  have product2 := Nat.mul_le_mul (show group.val*4+row.val≤248320 by omega) (show steps*8≤120 by omega)
  simp only [packedOffset,parameterOffset,inputOffset] at *
  constructor
  · have eq : group.val*4*(steps*512*4/8)+row.val*(steps*512*4/8)=(group.val*4+row.val)*(steps*256) := by
      have width : steps*512*4/8=steps*256 := by omega
      rw [width]
      ring
    omega
  · constructor
    · have eq : group.val*4*(steps*512/64)+row.val*(steps*512/64)=(group.val*4+row.val)*(steps*8) := by
        have width : steps*512/64=steps*8 := by omega
        rw [width]
        ring
      omega
    · omega
end Inference.Kernels.Quantization.MlxQmvFast4Pointers
