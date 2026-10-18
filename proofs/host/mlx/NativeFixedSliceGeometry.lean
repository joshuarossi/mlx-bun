import host.mlx.NativeKvViewGeometry
import host.mlx.NativeQuantizedRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned NativeRoles

def sliceRangesDecidable : (sizes first last : List Int) → Decidable (SliceRanges sizes first last)
  | [],[],[] => isTrue True.intro
  | [],[],_::_ => isFalse id
  | [],_::_,_ => isFalse id
  | _::_,[],_ => isFalse id
  | _::_,_::_,[] => isFalse id
  | _n::ns,_start::ss,_stop::es =>
    @instDecidableAnd _ _ (inferInstance) (@instDecidableAnd _ _ (inferInstance)
      (@instDecidableAnd _ _ (inferInstance) (sliceRangesDecidable ns ss es)))

instance (sizes first last : List Int) : Decidable (SliceRanges sizes first last) :=
  sliceRangesDecidable sizes first last

/-- Fixed dimensions retain exact integer conversion, separately from
rounded F64 equality. -/
def ExactDimensions : List Int → Prop
  | [] => True
  | i::rest => F64.toInt? (F64.ofInt i) = some i ∧ ExactDimensions rest

def exactDimensionsDecidable : (xs : List Int) → Decidable (ExactDimensions xs)
  | [] => isTrue True.intro
  | _i::rest => @instDecidableAnd _ _ (inferInstance) (exactDimensionsDecidable rest)

instance (xs : List Int) : Decidable (ExactDimensions xs) := exactDimensionsDecidable xs

def constantShape (xs : List Int) : Shape := xs.map constantDimension

theorem constantShape_subst (θ : Nat → SymE) (xs : List Int) :
    Shape.subst θ (constantShape xs) = constantShape xs := by
  induction xs with
  | nil => rfl
  | cons i rest ih => exact congrArg (constantDimension i :: ·) ih

theorem LiteralDimensions.constants (ν : Nat → F64) (xs : List Int) (exact : ExactDimensions xs) :
    LiteralDimensions ν (constantShape xs) xs := by
  induction xs with
  | nil => exact .nil
  | cons i rest ih => exact .cons (.lit (F64.ofInt i)) i rfl exact.1 (ih exact.2)

theorem ExactDimensions.ones (n : Nat) : ExactDimensions (List.replicate n 1) := by
  induction n with
  | zero => trivial
  | succ n ih => exact ⟨by decide +kernel,ih⟩

/-- Exact current slice meanings, independent of the physical representation
of future graph nodes. -/
structure LiteralSliceValues (ν : Nat → F64) (input output starts stops strides : Shape) (kind : SliceResult) where
  sizes : List Int
  first : List Int
  last : List Int
  inputValues : LiteralDimensions ν input sizes
  outputValues : LiteralDimensions ν output (sliceExtents first last)
  startValues : LiteralDimensions ν starts first
  stopValues : LiteralDimensions ν stops last
  strideValues : LiteralDimensions ν strides (List.replicate sizes.length 1)
  bounds : SliceRanges sizes first last
  branch : decide (sliceExtents first last = sizes) = kind.same

theorem LiteralSliceValues.geometry {ν : Nat → F64} {input output starts stops strides : Shape} {kind : SliceResult}
    (values : LiteralSliceValues ν input output starts stops strides kind) :
    SliceGeometry ν input output starts stops strides kind.same :=
  ⟨values.sizes,values.first,values.last,values.inputValues.literalValues,values.startValues.literalValues,
    values.stopValues.literalValues,values.outputValues,values.strideValues.literalValues,values.bounds,values.branch⟩

def LiteralSliceValues.constants (ν : Nat → F64) (sizes first last : List Int) (kind : SliceResult)
    (inputExact : ExactDimensions sizes) (startExact : ExactDimensions first) (stopExact : ExactDimensions last)
    (outputExact : ExactDimensions (sliceExtents first last)) (bounds : SliceRanges sizes first last)
    (branch : decide (sliceExtents first last = sizes) = kind.same) :
    LiteralSliceValues ν (constantShape sizes) (constantShape (sliceExtents first last))
      (constantShape first) (constantShape last) (constantShape (List.replicate sizes.length 1)) kind :=
  ⟨sizes,first,last,.constants ν sizes inputExact,.constants ν _ outputExact,.constants ν first startExact,
    .constants ν last stopExact,.constants ν _ (.ones sizes.length),bounds,branch⟩

def constantExpressions (xs : List Int) : List SymE := xs.map fun i => .lit (F64.ofInt i)

theorem constantExpressions_shape (xs : List Int) :
    (constantExpressions xs).map Dimension.literal = constantShape xs := by
  rw [constantExpressions,List.map_map]
  rfl

end Host.Mlx.Ffi.Annotated
