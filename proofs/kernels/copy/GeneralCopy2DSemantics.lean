import kernels.copy.GeneralCopy2DSyntax
import contracts.mlx.Copy2DMemory

namespace Inference.Kernels.Copy.GeneralCopy2DSemantics
open Contracts.Mlx GeneralCopy2DSyntax
set_option maxRecDepth 10000

abbrev Label := Copy2D.Label 4 256

-- IdxT is the small int32 specialization. Positive stride conversions and
-- unsigned grid arithmetic are modeled as 32-bit operations; the obligations
-- below prove that every reached result also fits the signed return type.
def helperNumber (x y rowStride columnStride : Nat) : Expr → Option Nat
  | .nat n => some n
  | .field "elem" "x" => some x
  | .field "elem" "y" => some y
  | .index "strides" (.nat 0) => some rowStride
  | .index "strides" (.nat 1) => some columnStride
  | .cast "IdxT" value => do
      let value ← helperNumber x y rowStride columnStride value
      pure (value%2^32)
  | .add left right => do
      let left ← helperNumber x y rowStride columnStride left
      let right ← helperNumber x y rowStride columnStride right
      pure ((left+right)%2^32)
  | .mul left right => do
      let left ← helperNumber x y rowStride columnStride left
      let right ← helperNumber x y rowStride columnStride right
      pure ((left*right)%2^32)
  | _ => none

theorem helper_value (x y rowStride columnStride : Nat)
    (_rowBound : rowStride<2^32) (_columnBound : columnStride<2^32)
    (bound : x*columnStride+y*rowStride<2^32) :
    helperNumber x y rowStride columnStride helper=some (x*columnStride+y*rowStride) := by
  simpa [helper,helperNumber] using bound

def sourceIndex (layout : Copy2D.Layout) (label : Label) : Nat :=
  label.2.val*layout.sourceColumn+label.1.val*layout.sourceRow

def destinationIndex (layout : Copy2D.Layout) (label : Label) : Nat :=
  label.2.val+label.1.val*layout.destinationRow

structure Bounds (layout : Copy2D.Layout) : Prop where
  sourceAligned : layout.sourceBase%2=0
  destinationAligned : layout.destinationBase%2=0
  sourceIndex : 3*layout.sourceRow+255*layout.sourceColumn<2^31
  destinationIndex : 3*layout.destinationRow+255<2^31
  sourceAddress : layout.sourceBase+2*(3*layout.sourceRow+255*layout.sourceColumn+1)≤2^64
  destinationAddress : layout.destinationBase+2*(3*layout.destinationRow+256)≤2^64
  rowRoom : 256≤layout.destinationRow

theorem source_index_bound (bounds : Bounds layout) (label : Label) : sourceIndex layout label<2^31 := by
  have head := Nat.mul_le_mul_right layout.sourceRow (Nat.le_of_lt_succ label.1.isLt)
  have column := Nat.mul_le_mul_right layout.sourceColumn (Nat.le_of_lt_succ label.2.isLt)
  have := bounds.sourceIndex
  unfold sourceIndex
  omega

theorem destination_index_bound (bounds : Bounds layout) (label : Label) : destinationIndex layout label<2^31 := by
  have head := Nat.mul_le_mul_right layout.destinationRow (Nat.le_of_lt_succ label.1.isLt)
  have := label.2.isLt
  have := bounds.destinationIndex
  unfold destinationIndex
  omega

theorem source_helper (bounds : Bounds layout) (label : Label) :
    helperNumber label.2.val label.1.val layout.sourceRow layout.sourceColumn helper=some (sourceIndex layout label) :=
  helper_value _ _ _ _ (by have := bounds.sourceIndex; omega)
    (by have := bounds.sourceIndex; omega) ((source_index_bound bounds label).trans (by decide))

theorem destination_helper (bounds : Bounds layout) (label : Label) :
    helperNumber label.2.val label.1.val layout.destinationRow 1 helper=some (destinationIndex layout label) := by
  have value := helper_value label.2.val label.1.val layout.destinationRow 1
    (by have := bounds.destinationIndex; omega) (by decide)
    (by simpa only [Nat.mul_one,destinationIndex] using (destination_index_bound bounds label).trans (by decide))
  simpa only [Nat.mul_one,destinationIndex] using value

abbrev Environment := String → Nat

def set (environment : Environment) (name : String) (value : Nat) : Environment :=
  fun key => if key=name then value else environment key

def number (layout : Copy2D.Layout) (label : Label) (environment : Environment) : Expr → Option Nat
  | .var name => some (environment name)
  | .nat value => some value
  | .call2 "elem_to_loc_2" "IdxT" "index" "src_strides" =>
      helperNumber label.2.val label.1.val layout.sourceRow layout.sourceColumn helper
  | .call2 "elem_to_loc_2" "IdxT" "index" "dst_strides" =>
      helperNumber label.2.val label.1.val layout.destinationRow 1 helper
  | _ => none

def scalar (layout : Copy2D.Layout) (label : Label) (environment : Environment)
    (memory : ByteMemory.Bytes) : Expr → Option (BitVec 16)
  | .index "src" index => do
      let offset ← number layout label environment index
      pure (HalfMemory.load memory (layout.sourceBase+2*offset))
  | .cast "U" value => scalar layout label environment memory value
  | _ => none

structure Machine where
  environment : Environment
  memory : ByteMemory.Bytes

def statement (layout : Copy2D.Layout) (label : Label) (before : Machine) : Stmt → Option Machine
  | .declare name expression => do
      let value ← number layout label before.environment expression
      pure ⟨set before.environment name value,before.memory⟩
  | .store (.index "dst" expression) value => do
      let index ← number layout label before.environment expression
      let raw ← scalar layout label before.environment before.memory value
      pure ⟨before.environment,HalfMemory.store before.memory (layout.destinationBase+2*index) raw⟩
  | _ => none

def execute (layout : Copy2D.Layout) (label : Label) : List Stmt → Machine → Option Machine
  | [], before => some before
  | first::rest, before => do
      let middle ← statement layout label before first
      execute layout label rest middle

def afterBody (layout : Copy2D.Layout) (label : Label) (before : Machine) : Machine where
  environment := set (set before.environment "src_idx" (sourceIndex layout label)) "dst_idx" (destinationIndex layout label)
  memory := HalfMemory.store before.memory (layout.destinationBase+2*destinationIndex layout label)
    (HalfMemory.load before.memory (layout.sourceBase+2*sourceIndex layout label))

theorem body_execution (bounds : Bounds layout) (label : Label) (before : Machine) :
    execute layout label body before=some (afterBody layout label before) := by
  simp [body,execute,statement,number,source_helper bounds,destination_helper bounds,
    scalar,set,afterBody]

theorem source_word_address (bounds : Bounds layout) (label : Label) :
    2*(Copy2DMemory.operation layout label).source=layout.sourceBase+2*sourceIndex layout label := by
  have aligned := Copy2DMemory.source_aligned layout bounds.sourceAligned label
  unfold Copy2DMemory.operation Copy2D.sourceAddress
  change 2*((layout.sourceBase+2*sourceIndex layout label)/2)=_
  change (layout.sourceBase+2*sourceIndex layout label)%2=0 at aligned
  omega

theorem destination_word_address (bounds : Bounds layout) (label : Label) :
    2*(Copy2DMemory.operation layout label).destination=layout.destinationBase+2*destinationIndex layout label := by
  have := bounds.destinationAligned
  change 2*(layout.destinationBase/2+(label.2.val+label.1.val*layout.destinationRow))=
    layout.destinationBase+2*(label.2.val+label.1.val*layout.destinationRow)
  omega

theorem body_memory (bounds : Bounds layout) (label : Label) (before : Machine) :
    (afterBody layout label before).memory=CopyExecution.execute [Copy2DMemory.operation layout label] before.memory := by
  simp only [afterBody,CopyExecution.execute,source_word_address bounds,destination_word_address bounds]

theorem execution_refines (bounds : Bounds layout) (label : Label) (before after : Machine)
    (execution : execute layout label body before=some after) :
    after.memory=CopyExecution.execute [Copy2DMemory.operation layout label] before.memory := by
  rw [body_execution bounds label before] at execution
  have same := Option.some.inj execution
  exact (congrArg Machine.memory same).symm.trans (body_memory bounds label before)

theorem parsed_execution (bounds : Bounds layout) (label : Label) (before : Machine) :
    ((parseBody sourceBody).bind (fun statements => execute layout label statements before))=
      some (afterBody layout label before) := by
  rw [parsed_body]
  exact body_execution bounds label before

end Inference.Kernels.Copy.GeneralCopy2DSemantics
