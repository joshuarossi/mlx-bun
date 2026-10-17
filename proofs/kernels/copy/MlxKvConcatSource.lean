import kernels.copy.GeneralCopy2DWideSourceRefinement
import state.KvConcatMemory

namespace Inference.Kernels.Copy.MlxKvConcatSource
open Contracts.Mlx State GeneralCopy2DWideSemantics
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2DMemory.programs KvConcatMemory.programs

variable {capacity : Nat}

def oldLayout (layout : KvConcatMemory.Layout capacity) : Copy2D.Layout :=
  ⟨2*layout.oldBase,capacity*256,1,2*layout.destination,(capacity+256)*256⟩

def newLayout (layout : KvConcatMemory.Layout capacity) : Copy2D.Layout :=
  ⟨2*layout.zeroBase,256*256,1,2*(layout.destination+capacity*256),(capacity+256)*256⟩

private theorem operation_ext {a b : CopyExecution.Operation}
    (source : a.source=b.source) (destination : a.destination=b.destination) : a=b := by
  cases a
  cases b
  simp_all

theorem old_operation (layout : KvConcatMemory.Layout capacity) (label : Copy2D.Label 4 (capacity*256)) :
    Copy2DMemory.operation (oldLayout layout) label=KvConcatMemory.oldOperation layout label := by
  apply operation_ext
  · have bound := KvConcatMemory.old_source_address layout label
    dsimp [Copy2D.sourceAddress,KvConcat.oldLayout] at bound
    change (2*layout.oldBase+2*(label.2.val*1+label.1.val*(capacity*256)))/2=_
    omega
  · have bound := KvConcatMemory.old_destination_address layout label
    dsimp [Copy2D.entry,KvConcat.oldLayout,Copy2D.destination] at bound
    change 2*layout.destination/2+(label.2.val+label.1.val*((capacity+256)*256))=_
    omega

theorem new_operation (layout : KvConcatMemory.Layout capacity) (label : Copy2D.Label 4 (256*256)) :
    Copy2DMemory.operation (newLayout layout) label=KvConcatMemory.newOperation layout label := by
  apply operation_ext
  · have bound := KvConcatMemory.new_source_address layout label
    dsimp [Copy2D.sourceAddress,KvConcat.newLayout] at bound
    change (2*layout.zeroBase+2*(label.2.val*1+label.1.val*(256*256)))/2=_
    omega
  · have bound := KvConcatMemory.new_destination_address layout label
    dsimp [Copy2D.entry,KvConcat.newLayout,Copy2D.destination] at bound
    change 2*(layout.destination+capacity*256)/2+(label.2.val+label.1.val*((capacity+256)*256))=_
    omega

private theorem packed_bounds (source destination width stride : Nat)
    (sourceAligned : source%2=0) (destinationAligned : destination%2=0)
    (room : width≤stride) (small : 4*stride<2^31)
    (sourceBound : source+2*(4*width)≤2^64)
    (destinationBound : destination+2*(3*stride+width)≤2^64) :
    Bounds ⟨source,width,1,destination,stride⟩ 4 width where
  sourceAligned := sourceAligned
  destinationAligned := destinationAligned
  sourceRow := by dsimp; omega
  sourceColumn := by change 1<2^32; decide
  destinationRow := by dsimp; omega
  sourceIndex := by
    intro label
    have head := Nat.mul_le_mul_right width (show label.1.val≤3 by have := label.1.isLt; omega)
    have col := label.2.isLt
    dsimp [sourceIndex]
    omega
  destinationIndex := by
    intro label
    have head := Nat.mul_le_mul_right stride (show label.1.val≤3 by have := label.1.isLt; omega)
    have col := label.2.isLt
    dsimp [destinationIndex]
    omega
  sourceAddress := by
    intro label
    have head := Nat.mul_le_mul_right width (show label.1.val≤3 by have := label.1.isLt; omega)
    have col := label.2.isLt
    dsimp [sourceIndex]
    omega
  destinationAddress := by
    intro label
    have head := Nat.mul_le_mul_right stride (show label.1.val≤3 by have := label.1.isLt; omega)
    have col := label.2.isLt
    dsimp [destinationIndex]
    omega
  rowRoom := room

-- Bounds cover original source/destination allocations, never their contents.
structure Allocation (layout : KvConcatMemory.Layout capacity) : Prop where
  supported : capacity≤262144
  oldBound : 2*layout.oldBase+2*(4*capacity*256)≤2^64
  zeroBound : 2*layout.zeroBase+524288≤2^64
  destinationBound : 2*layout.destination+2*(4*(capacity+256)*256)≤2^64

theorem old_bounds (layout : KvConcatMemory.Layout capacity) (allocation : Allocation layout) :
    Bounds (oldLayout layout) 4 (capacity*256) := by
  apply packed_bounds
  · omega
  · omega
  · omega
  · have := allocation.supported; omega
  · simpa only [Nat.mul_assoc] using allocation.oldBound
  · have bound := allocation.destinationBound
    clear allocation
    nlinarith only [bound]

theorem new_bounds (layout : KvConcatMemory.Layout capacity) (allocation : Allocation layout) :
    Bounds (newLayout layout) 4 (256*256) := by
  apply packed_bounds
  · omega
  · omega
  · omega
  · have := allocation.supported; omega
  · exact allocation.zeroBound
  · have bound := allocation.destinationBound
    clear allocation
    nlinarith only [bound]

theorem old_parsed (layout : KvConcatMemory.Layout capacity) (allocation : Allocation layout)
    (label : Copy2D.Label 4 (capacity*256)) (before : Machine) :
    ((GeneralCopy2DSyntax.parseBody GeneralCopy2DSyntax.sourceBody).bind
      (fun code => execute (oldLayout layout) label code before))=
      some (afterBody (oldLayout layout) label before) ∧
    (afterBody (oldLayout layout) label before).memory=
      CopyExecution.execute [KvConcatMemory.oldOperation layout label] before.memory := by
  constructor
  · exact parsed_execution (old_bounds layout allocation) label before
  · rw [body_memory (old_bounds layout allocation),old_operation]

theorem new_parsed (layout : KvConcatMemory.Layout capacity) (allocation : Allocation layout)
    (label : Copy2D.Label 4 (256*256)) (before : Machine) :
    ((GeneralCopy2DSyntax.parseBody GeneralCopy2DSyntax.sourceBody).bind
      (fun code => execute (newLayout layout) label code before))=
      some (afterBody (newLayout layout) label before) ∧
    (afterBody (newLayout layout) label before).memory=
      CopyExecution.execute [KvConcatMemory.newOperation layout label] before.memory := by
  constructor
  · exact parsed_execution (new_bounds layout allocation) label before
  · rw [body_memory (new_bounds layout allocation),new_operation]

end Inference.Kernels.Copy.MlxKvConcatSource
