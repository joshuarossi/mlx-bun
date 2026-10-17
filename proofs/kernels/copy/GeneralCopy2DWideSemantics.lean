import kernels.copy.GeneralCopy2DSemantics

namespace Inference.Kernels.Copy.GeneralCopy2DWideSemantics
open Contracts.Mlx GeneralCopy2DSyntax
open GeneralCopy2DSemantics (helperNumber helper_value Environment set)
set_option maxRecDepth 10000

variable {rows width : Nat}
abbrev Label (rows width : Nat) := Copy2D.Label rows width

def sourceIndex (layout : Copy2D.Layout) (label : Label rows width) : Nat :=
  label.2.val*layout.sourceColumn+label.1.val*layout.sourceRow

def destinationIndex (layout : Copy2D.Layout) (label : Label rows width) : Nat :=
  label.2.val+label.1.val*layout.destinationRow

-- Arithmetic/range premises concern original pointers and reached indices;
-- they contain no load values or desired post-execution memory.
structure Bounds (layout : Copy2D.Layout) (rows width : Nat) : Prop where
  sourceAligned : layout.sourceBase%2=0
  destinationAligned : layout.destinationBase%2=0
  sourceRow : layout.sourceRow<2^32
  sourceColumn : layout.sourceColumn<2^32
  destinationRow : layout.destinationRow<2^32
  sourceIndex : ∀ label : Label rows width, sourceIndex layout label<2^31
  destinationIndex : ∀ label : Label rows width, destinationIndex layout label<2^31
  sourceAddress : ∀ label : Label rows width,
    layout.sourceBase+2*GeneralCopy2DWideSemantics.sourceIndex layout label+2≤2^64
  destinationAddress : ∀ label : Label rows width,
    layout.destinationBase+2*GeneralCopy2DWideSemantics.destinationIndex layout label+2≤2^64
  rowRoom : width≤layout.destinationRow

def number (layout : Copy2D.Layout) (label : Label rows width) (environment : Environment) : Expr → Option Nat
  | .var name => some (environment name)
  | .nat value => some value
  | .call2 "elem_to_loc_2" "IdxT" "index" "src_strides" =>
      helperNumber label.2.val label.1.val layout.sourceRow layout.sourceColumn helper
  | .call2 "elem_to_loc_2" "IdxT" "index" "dst_strides" =>
      helperNumber label.2.val label.1.val layout.destinationRow 1 helper
  | _ => none

def scalar (layout : Copy2D.Layout) (label : Label rows width) (environment : Environment)
    (memory : ByteMemory.Bytes) : Expr → Option (BitVec 16)
  | .index "src" index => do
      let offset ← number layout label environment index
      pure (HalfMemory.load memory (layout.sourceBase+2*offset))
  | .cast "U" value => scalar layout label environment memory value
  | _ => none

abbrev Machine := GeneralCopy2DSemantics.Machine

def statement (layout : Copy2D.Layout) (label : Label rows width) (before : Machine) : Stmt → Option Machine
  | .declare name expression => do
      let value ← number layout label before.environment expression
      pure ⟨set before.environment name value,before.memory⟩
  | .store (.index "dst" expression) value => do
      let index ← number layout label before.environment expression
      let raw ← scalar layout label before.environment before.memory value
      pure ⟨before.environment,HalfMemory.store before.memory (layout.destinationBase+2*index) raw⟩
  | _ => none

def execute (layout : Copy2D.Layout) (label : Label rows width) : List Stmt → Machine → Option Machine
  | [], before => some before
  | first::rest, before => do
      let middle ← statement layout label before first
      execute layout label rest middle

def afterBody (layout : Copy2D.Layout) (label : Label rows width) (before : Machine) : Machine where
  environment := set (set before.environment "src_idx" (sourceIndex layout label)) "dst_idx" (destinationIndex layout label)
  memory := HalfMemory.store before.memory (layout.destinationBase+2*destinationIndex layout label)
    (HalfMemory.load before.memory (layout.sourceBase+2*sourceIndex layout label))

theorem source_helper (bounds : Bounds layout rows width) (label : Label rows width) :
    helperNumber label.2.val label.1.val layout.sourceRow layout.sourceColumn helper=some (sourceIndex layout label) :=
  helper_value _ _ _ _ bounds.sourceRow bounds.sourceColumn ((bounds.sourceIndex label).trans (by decide))

theorem destination_helper (bounds : Bounds layout rows width) (label : Label rows width) :
    helperNumber label.2.val label.1.val layout.destinationRow 1 helper=some (destinationIndex layout label) := by
  simpa only [Nat.mul_one,destinationIndex] using
    helper_value label.2.val label.1.val layout.destinationRow 1 bounds.destinationRow (by decide)
      (by simpa only [Nat.mul_one,destinationIndex] using (bounds.destinationIndex label).trans (by decide))

theorem body_execution (bounds : Bounds layout rows width) (label : Label rows width) (before : Machine) :
    execute layout label body before=some (afterBody layout label before) := by
  simp [body,execute,statement,number,source_helper bounds,destination_helper bounds,
    scalar,GeneralCopy2DSemantics.set,afterBody]

theorem parsed_execution (bounds : Bounds layout rows width) (label : Label rows width) (before : Machine) :
    ((parseBody sourceBody).bind (fun code => execute layout label code before))=some (afterBody layout label before) := by
  rw [parsed_body]
  exact body_execution bounds label before

theorem source_word_address (bounds : Bounds layout rows width) (label : Label rows width) :
    2*(Copy2DMemory.operation layout label).source=layout.sourceBase+2*sourceIndex layout label := by
    have aligned := Copy2DMemory.source_aligned layout bounds.sourceAligned label
    unfold Copy2DMemory.operation Copy2D.sourceAddress
    change 2*((layout.sourceBase+2*sourceIndex layout label)/2)=_
    change (layout.sourceBase+2*sourceIndex layout label)%2=0 at aligned
    omega
theorem destination_word_address (bounds : Bounds layout rows width) (label : Label rows width) :
    2*(Copy2DMemory.operation layout label).destination=layout.destinationBase+2*destinationIndex layout label := by
    have := bounds.destinationAligned
    change 2*(layout.destinationBase/2+(label.2.val+label.1.val*layout.destinationRow))=
      layout.destinationBase+2*(label.2.val+label.1.val*layout.destinationRow)
    omega
theorem body_memory (bounds : Bounds layout rows width) (label : Label rows width) (before : Machine) :
    (afterBody layout label before).memory=CopyExecution.execute [Copy2DMemory.operation layout label] before.memory := by
  simp only [afterBody,CopyExecution.execute,source_word_address bounds,destination_word_address bounds]

end Inference.Kernels.Copy.GeneralCopy2DWideSemantics
