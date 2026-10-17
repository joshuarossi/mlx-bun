import kernels.quantization.AffineLoads
import kernels.quantization.MlxQmvDevice
import contracts.mlx.TensorMemory
import Mathlib.Logic.Equiv.Fin.Basic

namespace Inference.Kernels.Quantization.AffineStorage
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := ArrayStorage.BF

def packed3Equiv (rows steps : Nat) :
    (Fin rows × Fin steps × Fin 32 × Fin 2 × Fin 3) ≃ Fin (rows*(steps*64*3)) :=
  ((Equiv.prodCongr (Equiv.refl (Fin rows))
    ((Equiv.prodCongr (Equiv.refl (Fin steps))
      ((Equiv.prodCongr (Equiv.refl (Fin 32)) finProdFinEquiv).trans finProdFinEquiv)).trans finProdFinEquiv)).trans finProdFinEquiv).trans
    (finCongr (by ring))

def packed4Equiv (rows steps : Nat) :
    (Fin rows × Fin steps × Fin 32 × Fin 4) ≃ Fin (rows*(steps*128)) :=
  ((Equiv.prodCongr (Equiv.refl (Fin rows))
    ((Equiv.prodCongr (Equiv.refl (Fin steps)) finProdFinEquiv).trans finProdFinEquiv)).trans finProdFinEquiv).trans
    (finCongr (by ring))

theorem packed3_index (row : Fin rows) (step : Fin steps) (lane : Fin 32) (chunk : Fin 2) (byte : Fin 3) :
    (packed3Equiv rows steps (row, step, lane, chunk, byte)).val=
      AffineLayout.weightOffset 3 row.val steps step.val lane.val (chunk.val*3+byte.val) := by
  change byte.val+3*chunk.val+6*lane.val+192*step.val+(steps*192)*row.val=_
  unfold AffineLayout.weightOffset
  ring

theorem packed4_index (row : Fin rows) (step : Fin steps) (lane : Fin 32) (chunk : Fin 4) :
    2*(packed4Equiv rows steps (row, step, lane, chunk)).val=
      AffineLayout.weightOffset 4 row.val steps step.val lane.val (chunk.val*2) := by
  change 2*(chunk.val+4*lane.val+128*step.val+(steps*128)*row.val)=_
  unfold AffineLayout.weightOffset
  ring

def payload3 (weights : Fin rows → AffineRow.Weights3 steps) (i : Fin (rows*(steps*64*3))) : BitVec 8 :=
  let p := (packed3Equiv rows steps).symm i
  (weights p.1).bytes p.2.1 p.2.2.1 p.2.2.2.1 p.2.2.2.2

def payload4 (weights : Fin rows → AffineRow.Weights4 steps) (i : Fin (rows*(steps*128))) : BitVec 16 :=
  let p := (packed4Equiv rows steps).symm i
  (weights p.1).words p.2.1 p.2.2.1 p.2.2.2

theorem payload3_read (weights : Fin rows → AffineRow.Weights3 steps)
    (row : Fin rows) (step : Fin steps) (lane : Fin 32) (chunk : Fin 2) (byte : Fin 3) :
    payload3 weights (packed3Equiv rows steps (row, step, lane, chunk, byte))=(weights row).bytes step lane chunk byte := by
  simp only [payload3, Equiv.symm_apply_apply]

theorem payload4_read (weights : Fin rows → AffineRow.Weights4 steps)
    (row : Fin rows) (step : Fin steps) (lane : Fin 32) (chunk : Fin 4) :
    payload4 weights (packed4Equiv rows steps (row, step, lane, chunk))=(weights row).words step lane chunk := by
  simp only [payload4, Equiv.symm_apply_apply]

def matrix (values : Fin rows → Fin columns → BF) (i : Fin (rows*columns)) : BF :=
  let p := finProdFinEquiv.symm i
  values p.1 p.2

theorem matrix_read (values : Fin rows → Fin columns → BF) (bound : 2*(rows*columns) ≤ 2^64)
    (row : Fin rows) (column : Fin columns) :
    (Model.ofBits (HalfMemory.load (ArrayStorage.BFBuffer.canonical (matrix values) bound).bytes
      (0+2*(row.val*columns+column.val))) : BF)=values row column := by
  let i := finProdFinEquiv (row, column)
  have index : i.val=row.val*columns+column.val := by change column.val+columns*row.val=_; ring
  have value : matrix values i=values row column := by simp only [matrix, i, Equiv.symm_apply_apply]
  have raw := (ArrayStorage.BFBuffer.canonical (matrix values) bound).attached i
  rw [value, index] at raw
  exact congrArg (fun word : BitVec 16 => (Model.ofBits word : BF)) raw

def canonical3 (weights : Fin rows → AffineRow.Weights3 steps) (bound : 2*(rows*(steps*8)) ≤ 2^64) : AffineLoads.Buffers :=
  ⟨TensorMemory.place (payload3 weights) 0 (fun _ => 0), 0,
    (ArrayStorage.BFBuffer.canonical (matrix (fun row => (weights row).scale)) bound).bytes, 0,
    (ArrayStorage.BFBuffer.canonical (matrix (fun row => (weights row).bias)) bound).bytes, 0⟩

def wordPayload4 (weights : Fin rows → AffineRow.Weights4 steps) (word : Nat) : BitVec 16 :=
  if h : word<rows*(steps*128) then payload4 weights ⟨word, h⟩ else 0

def canonical4 (weights : Fin rows → AffineRow.Weights4 steps) (bound : 2*(rows*(steps*8)) ≤ 2^64) : AffineLoads.Buffers :=
  ⟨HalfMemory.encode (wordPayload4 weights), 0,
    (ArrayStorage.BFBuffer.canonical (matrix (fun row => (weights row).scale)) bound).bytes, 0,
    (ArrayStorage.BFBuffer.canonical (matrix (fun row => (weights row).bias)) bound).bytes, 0⟩

theorem packed3_read (weights : Fin rows → AffineRow.Weights3 steps) (bound : 2*(rows*(steps*8)) ≤ 2^64)
    (row : Fin rows) (step : Fin steps) (lane : Fin 32) (chunk : Fin 2) (byte : Fin 3) :
    (AffineLoads.weights3 (canonical3 weights bound) row).bytes step lane chunk byte=(weights row).bytes step lane chunk byte := by
  have read := TensorMemory.placed_byte (payload3 weights) 0 (fun _ => 0) (packed3Equiv rows steps (row, step, lane, chunk, byte))
  rw [payload3_read, packed3_index] at read
  exact read

theorem packed4_read (weights : Fin rows → AffineRow.Weights4 steps) (bound : 2*(rows*(steps*8)) ≤ 2^64)
    (row : Fin rows) (step : Fin steps) (lane : Fin 32) (chunk : Fin 4) :
    (AffineLoads.weights4 (canonical4 weights bound) row).words step lane chunk=(weights row).words step lane chunk := by
  let i := packed4Equiv rows steps (row, step, lane, chunk)
  have read := HalfMemory.load_encode (wordPayload4 weights) (2*i.val) (by omega)
  rw [show 2*i.val/2=i.val by omega] at read
  simp only [wordPayload4, i.isLt, ↓reduceDIte] at read
  change HalfMemory.load (HalfMemory.encode (wordPayload4 weights)) (2*i.val)=payload4 weights i at read
  rw [payload4_read, packed4_index] at read
  simpa only [AffineLoads.weights4, canonical4, Nat.zero_add] using read

theorem weights3_eq (weights : Fin rows → AffineRow.Weights3 steps) (bound : 2*(rows*(steps*8)) ≤ 2^64) (row : Fin rows) :
    AffineLoads.weights3 (canonical3 weights bound) row=weights row := by
  have a : (AffineLoads.weights3 (canonical3 weights bound) row).bytes=(weights row).bytes :=
    funext fun step => funext fun lane => funext fun chunk => funext fun byte => packed3_read weights bound row step lane chunk byte
  have b : (AffineLoads.weights3 (canonical3 weights bound) row).scale=(weights row).scale :=
    funext fun group => matrix_read (fun row => (weights row).scale) bound row group
  have c : (AffineLoads.weights3 (canonical3 weights bound) row).bias=(weights row).bias :=
    funext fun group => matrix_read (fun row => (weights row).bias) bound row group
  have bc : ((AffineLoads.weights3 (canonical3 weights bound) row).scale, (AffineLoads.weights3 (canonical3 weights bound) row).bias)=
      ((weights row).scale, (weights row).bias) := Prod.ext b c
  exact congrArg₂ (fun bytes pair => (⟨bytes, pair.1, pair.2⟩ : AffineRow.Weights3 steps)) a bc

theorem weights4_eq (weights : Fin rows → AffineRow.Weights4 steps) (bound : 2*(rows*(steps*8)) ≤ 2^64) (row : Fin rows) :
    AffineLoads.weights4 (canonical4 weights bound) row=weights row := by
  have a : (AffineLoads.weights4 (canonical4 weights bound) row).words=(weights row).words :=
    funext fun step => funext fun lane => funext fun chunk => packed4_read weights bound row step lane chunk
  have b : (AffineLoads.weights4 (canonical4 weights bound) row).scale=(weights row).scale :=
    funext fun group => matrix_read (fun row => (weights row).scale) bound row group
  have c : (AffineLoads.weights4 (canonical4 weights bound) row).bias=(weights row).bias :=
    funext fun group => matrix_read (fun row => (weights row).bias) bound row group
  have bc : ((AffineLoads.weights4 (canonical4 weights bound) row).scale, (AffineLoads.weights4 (canonical4 weights bound) row).bias)=
      ((weights row).scale, (weights row).bias) := Prod.ext b c
  exact congrArg₂ (fun words pair => (⟨words, pair.1, pair.2⟩ : AffineRow.Weights4 steps)) a bc

theorem geometry3 (weights : Fin rows → AffineRow.Weights3 steps) (bound : 2*(rows*(steps*8)) ≤ 2^64)
    (packed : rows*(steps*64*3) ≤ 2^64) : MlxQmvDevice.Geometry .three (canonical3 weights bound) steps rows where
  packedAligned := by rfl
  packedBounded := by simpa only [canonical3, MlxQmvDevice.Bits.width, Nat.zero_add] using packed
  scaleAligned := by rfl
  biasAligned := by rfl
  scaleBounded := by simpa only [canonical3, Nat.zero_add] using bound
  biasBounded := by simpa only [canonical3, Nat.zero_add] using bound

theorem geometry4 (weights : Fin rows → AffineRow.Weights4 steps) (bound : 2*(rows*(steps*8)) ≤ 2^64)
    (packed : rows*(steps*64*4) ≤ 2^64) : MlxQmvDevice.Geometry .four (canonical4 weights bound) steps rows where
  packedAligned := by rfl
  packedBounded := by simpa only [canonical4, MlxQmvDevice.Bits.width, Nat.zero_add] using packed
  scaleAligned := by rfl
  biasAligned := by rfl
  scaleBounded := by simpa only [canonical4, Nat.zero_add] using bound
  biasBounded := by simpa only [canonical4, Nat.zero_add] using bound

end Inference.Kernels.Quantization.AffineStorage
