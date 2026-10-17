import kernels.attention.MlxOutputGateScheduled

namespace Inference.Kernels.Attention.MlxOutputGateHostSelection

-- Reviewed translation of pinned common/binary.h and metal host metadata
-- branches. Descriptor extraction, donation eligibility, allocation and native
-- operator/type attachment remain explicit; this does not query a GPU.
structure Descriptor where
  base : Nat
  dataSize : Nat
  contiguous : Bool
  rowContiguous : Bool
  colContiguous : Bool
  deriving DecidableEq, Repr

inductive BinaryType where
  | scalarScalar | scalarVector | vectorScalar | vectorVector | general
  deriving DecidableEq, Repr

def classify (a b : Descriptor) : BinaryType :=
  if a.dataSize=1 ∧ b.dataSize=1 then .scalarScalar
  else if a.dataSize=1 ∧ b.contiguous then .scalarVector
  else if b.dataSize=1 ∧ a.contiguous then .vectorScalar
  else if (a.rowContiguous && b.rowContiguous) || (a.colContiguous && b.colContiguous) then .vectorVector
  else .general

inductive VectorRoute where | scalar | wide | large | general deriving DecidableEq, Repr

def unaryRoute (input : Descriptor) : VectorRoute :=
  if ¬input.contiguous then .general
  else if input.dataSize>4294967295 then .large
  else if MlxOutputGateUnaryLoop.hostWidth 2 input.dataSize>1 then .wide else .scalar

def binaryRoute (a b output : Descriptor) : VectorRoute :=
  if classify a b=.general then .general
  else if output.dataSize>4294967295 then .large
  else if MlxOutputGateUnaryLoop.hostWidth 2 output.dataSize>1 then .wide else .scalar

def unaryOutput (input : Descriptor) (donatable : Bool) (allocation : Nat) : Descriptor :=
  if donatable then input else {input with base := allocation}

def binaryOutput (a b : Descriptor) (donatableA donatableB : Bool) (allocation : Nat) : Descriptor :=
  if donatableA then a else if donatableB then b else {a with base := allocation}

def selected (base : Nat) : Descriptor := ⟨base,6144,true,true,false⟩

theorem unary_selected (base : Nat) : unaryRoute (selected base)=.scalar := by rfl

theorem binary_selected (a b out : Nat) :
    classify (selected a) (selected b)=.vectorVector ∧
      binaryRoute (selected a) (selected b) (selected out)=.scalar := ⟨rfl,rfl⟩

theorem unary_output_selected (base allocation : Nat) (donatable : Bool) :
    unaryOutput (selected base) donatable allocation=
      selected (if donatable then base else allocation) := by cases donatable <;> rfl

theorem binary_output_selected (a b allocation : Nat) (donatableA donatableB : Bool) :
    binaryOutput (selected a) (selected b) donatableA donatableB allocation=
      selected (if donatableA then a else if donatableB then b else allocation) := by
  cases donatableA <;> cases donatableB <;> rfl

-- The admitted threadgroup maximum affects grouping, while the thread grid
-- remains exactly 6144 scalar owners in both selected host branches.
def threadGrid (dataSize width : Nat) : Nat := (dataSize+width-1)/width

theorem selected_grid : threadGrid 6144 (MlxOutputGateUnaryLoop.hostWidth 2 6144)=6144 := by decide

theorem selected_ownership (thread : Fin 6144) :
    MlxOutputGateUnaryLoop.visits .vector 6144 (MlxOutputGateUnaryLoop.hostWidth 2 6144) thread.val=[thread.val] ∧
      MlxOutputGateBinaryLoop.visits .vectors 6144 (MlxOutputGateUnaryLoop.hostWidth 2 6144) thread.val=[thread.val] :=
  ⟨MlxOutputGateUnaryLoop.selected_visits thread,MlxOutputGateBinaryLoop.selected_visits thread⟩

end Inference.Kernels.Attention.MlxOutputGateHostSelection
