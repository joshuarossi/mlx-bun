import kernels.trellis.DownReadSource
import kernels.trellis.CodebookWindowSource
namespace Inference.Kernels.Trellis.DownWindowSource
open Contracts.Mlx Contracts.Mlx.M1Max DownStepSyntax PackedArrayDownMaterialization
set_option maxRecDepth 10000

def integers (k i : Nat) : PackedArraySemantics.State := ⟨[
  ("i",.unsigned (BitVec.ofNat 32 i)),("K",.signed k),("L",.signed 12)],[],[]⟩
def integer (k i : Nat) (expression : PackedArraySyntax.Expr) : Option (BitVec 32) :=
  (PackedArraySemantics.evaluate 16 (integers k i) expression).bind PackedArraySemantics.asUInt

theorem offset_selected : ∀ k : Fin 3, ∀ i : Fin 16,
    integer (PackedArrayGate.width k) i.val window.offset=some (BitVec.ofNat 32 (i.val*PackedArrayGate.width k)) := by decide +kernel

theorem level_selected : ∀ k : Fin 3, ∀ i : Fin 16,
    integer (PackedArrayGate.width k) i.val window.level=some 12 := by decide +kernel

def read (input : Input k) (row0 row1 block lane u i : Nat) (paired : Bool)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) (code : Window) : Option Float32 :=
  if code.target="code" ∧ code.function="trellis_codebook_window" ∧ code.table="table" ∧ code.words="w" ∧ code.virtual="v" then
    (integer k i code.level).bind (fun level => if level=12 then
      (integer k i code.offset).bind (fun offset => CodebookWindowSource.readActual load memory base
        (DownPointerArrays.arrays input row0 row1 block lane u paired) offset.toNat)
      else none)
  else none

def code (input : Input k) (row0 row1 block lane u i : Nat) (paired : Bool)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) : Option Float32 :=
  (parse windowTokens windowSource).bind (read input row0 row1 block lane u i paired load memory base)

attribute [local irreducible] integer parse

theorem code_current (input : Input k) (row0 row1 block lane u i : Nat) (paired : Bool)
    (row0Bound : row0<17408) (row1Bound : row1<17408) (blockBound : block<20) (laneBound : lane<16)
    (rowBound : if paired then u<2 else u=0) (column : i<16)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) :
    code input row0 row1 block lane u i paired load memory base=some
      (CodebookLoad.read load memory base
        (DownCodebook.Lane.alignedWord (input.matrix (selectedRow row0 row1 u) block) k lane) (i*k)) := by
  have offset:=offset_selected (PackedArrayMaterialization.widthIndex k input.valid) ⟨i,column⟩
  have level:=level_selected (PackedArrayMaterialization.widthIndex k input.valid) ⟨i,column⟩
  simp only [PackedArrayMaterialization.width_index] at offset level
  have small : i*k<2^32 := by rcases input.valid with h|h|h <;> rw [h] <;> omega
  rw [code,parsed_window,Option.bind_some]
  unfold read
  simp only [window] at offset level
  simp only [window,and_self,ite_true]
  rw [level,Option.bind_some,ite_eq_left rfl,offset,Option.bind_some,BitVec.toNat_ofNat,Nat.mod_eq_of_lt small]
  unfold CodebookWindowSource.readActual
  rw [DownPointerArrays.window input row0 row1 block lane u i paired row0Bound row1Bound blockBound laneBound rowBound column]
  rfl
end Inference.Kernels.Trellis.DownWindowSource
