import kernels.copy.GeneralCopy2DSemantics
import kernels.normalization.MlxRmsLoopSyntax

namespace Inference.Kernels.Attention.MlxAttentionGateCopySyntax
open Contracts.Mlx
open Copy.GeneralCopy2DSyntax
open Normalization.MlxRmsLoopSyntax (acceptAll)
set_option maxRecDepth 10000

inductive Program where | general2D deriving DecidableEq, Repr

def parse (source : String) : Option Program := do
  let tokens ←tokenize source
  let rest ←acceptAll ["{","auto","src_idx","=","elem_to_loc_2","<","IdxT",">","(","index",",","src_strides",")",";",
    "IdxT","dst_idx","=","index",".","x","+","IdxT","(","grid_dim",".","x",")","*","index",".","y",";",
    "dst","[","dst_idx","]","=","cast_to","<","U",">","(","src","[","src_idx","]",")",";","}"] tokens
  if rest=[] then some .general2D else none

def sourceBody : String := r#"{
  auto src_idx = elem_to_loc_2<IdxT>(index, src_strides);
  IdxT dst_idx = index.x + IdxT(grid_dim.x) * index.y;
  dst[dst_idx] = cast_to<U>(src[src_idx]);
}"#

theorem parsed : parse sourceBody=some .general2D := by decide +kernel

abbrev Label := Copy2D.Label 24 256

def sourceIndex (_ : Program) (label : Label) : Option Nat :=
  Copy.GeneralCopy2DSemantics.helperNumber label.2.val label.1.val 512 1 helper

def destinationIndex (_ : Program) (label : Label) : Nat :=
  (label.2.val+(256%2^32)*label.1.val)%2^32

theorem source_index (label : Label) : sourceIndex .general2D label=some (label.1.val*512+label.2.val) := by
  have h := label.1.isLt
  have i := label.2.isLt
  simpa only [sourceIndex,Nat.mul_one,Nat.add_comm,Nat.mul_comm] using
    Copy.GeneralCopy2DSemantics.helper_value label.2.val label.1.val 512 1 (by decide) (by decide) (by omega)

theorem destination_index (label : Label) : destinationIndex .general2D label=label.1.val*256+label.2.val := by
  have h := label.1.isLt
  have i := label.2.isLt
  unfold destinationIndex
  norm_num
  omega

-- Selected U=T=BF16 copy casts preserve every payload bit.
def operation (code : Program) (sourceBase destinationBase : Nat) (label : Label) : Option CopyExecution.Operation := do
  let source ←sourceIndex code label
  pure ⟨(sourceBase+2*source)/2,destinationBase/2+destinationIndex code label⟩

def layout (sourceBase destinationBase : Nat) : Copy2D.Layout :=
  ⟨sourceBase,512,1,destinationBase,256⟩

theorem operation_eq (sourceBase destinationBase : Nat) (label : Label) :
    operation .general2D sourceBase destinationBase label=
      some (Copy2DMemory.operation (layout sourceBase destinationBase) label) := by
  unfold operation
  rw [source_index,destination_index]
  simp [Copy2DMemory.operation,layout,Copy2D.sourceAddress,Copy2D.destination,Nat.add_comm,Nat.mul_comm]

end Inference.Kernels.Attention.MlxAttentionGateCopySyntax
