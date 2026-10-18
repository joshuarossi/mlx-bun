import host.mlx.NativeSliceGeometry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

theorem LiteralDimensions.literalValues {ν : Nat → F64} {roles : Shape} {integers : List Int}
    (dimensions : LiteralDimensions ν roles integers) : roles.literalValues ν = some integers := by
  induction dimensions with
  | nil => rfl
  | cons e i value exactInteger _ ih =>
    simp only [Shape.literalValues,List.mapM_cons,Dimension.literalValue,exactInteger]
    change Option.bind (Shape.literalValues ν _) (fun rest => some (i::rest)) = _
    rw [ih]
    rfl

theorem LiteralDimensions.length {ν : Nat → F64} {roles : Shape} {integers : List Int}
    (dimensions : LiteralDimensions ν roles integers) : roles.length = integers.length := by
  induction dimensions with
  | nil => rfl
  | cons _ _ _ _ _ ih => exact congrArg Nat.succ ih

/-- The cache append uses the entire batch/head/width range and one time
position. These are pure interpretations of the current fixed roles, not
assumptions about either native execution's inferred result. -/
theorem SliceUpdateGeometry.kv4 {ν : Nat → F64} {input update starts stops strides : Shape}
    (batch heads capacity index width : Int)
    (inputValues : input.literalValues ν = some [batch,heads,capacity,width])
    (updateValues : update.literalValues ν = some [batch,heads,1,width])
    (startValues : starts.literalValues ν = some [0,0,index,0])
    (stopValues : stops.literalValues ν = some [batch,heads,index+1,width])
    (strideValues : strides.literalValues ν = some [1,1,1,1])
    (batchNonnegative : 0 ≤ batch) (headsNonnegative : 0 ≤ heads)
    (indexNonnegative : 0 ≤ index) (widthNonnegative : 0 ≤ width)
    (bound : index+1 ≤ capacity) : SliceUpdateGeometry ν input update starts stops strides := by
  have extents : NativeRoles.sliceExtents [0,0,index,0] [batch,heads,index+1,width] = [batch,heads,1,width] := by
    simp only [NativeRoles.sliceExtents,List.zipWith,Int.sub_zero]
    have one : index+1-index = 1 := by omega
    rw [one]
  refine ⟨[batch,heads,capacity,width],[0,0,index,0],[batch,heads,index+1,width],
    inputValues,startValues,stopValues,?_,strideValues,?_⟩
  · rw [extents]; exact updateValues
  · exact ⟨by omega,batchNonnegative,by omega,by omega,headsNonnegative,by omega,
      indexNonnegative,by omega,bound,by omega,widthNonnegative,by omega,True.intro⟩

/-- A valuation-specific integer witness for the fixed KV append roles.
Time and capacity may change independently between paired executions. -/
structure KvAppendValues (ν : Nat → F64) (input update starts stops strides : Shape) where
  batch : Int
  heads : Int
  capacity : Int
  index : Int
  width : Int
  inputValues : LiteralDimensions ν input [batch,heads,capacity,width]
  updateValues : LiteralDimensions ν update [batch,heads,1,width]
  startValues : LiteralDimensions ν starts [0,0,index,0]
  stopValues : LiteralDimensions ν stops [batch,heads,index+1,width]
  strideValues : LiteralDimensions ν strides [1,1,1,1]
  batchNonnegative : 0 ≤ batch
  headsNonnegative : 0 ≤ heads
  indexNonnegative : 0 ≤ index
  widthNonnegative : 0 ≤ width
  bound : index+1 ≤ capacity

theorem KvAppendValues.geometry {ν : Nat → F64} {input update starts stops strides : Shape}
    (values : KvAppendValues ν input update starts stops strides) :
    SliceUpdateGeometry ν input update starts stops strides :=
  SliceUpdateGeometry.kv4 values.batch values.heads values.capacity values.index values.width
    values.inputValues.literalValues values.updateValues.literalValues values.startValues.literalValues
    values.stopValues.literalValues values.strideValues.literalValues
    values.batchNonnegative values.headsNonnegative values.indexNonnegative values.widthNonnegative values.bound

/-- Reindexing numeric meanings preserves the same current integer witness
and guards, rather than selecting new cache meanings after a replay. -/
def KvAppendValues.subst {ν : Nat → F64} {input update starts stops strides : Shape}
    (θ : Nat → SymE)
    (values : KvAppendValues (Owned.Annotated.nextValuation θ ν) input update starts stops strides) :
    KvAppendValues ν (Shape.subst θ input) (Shape.subst θ update) (Shape.subst θ starts)
      (Shape.subst θ stops) (Shape.subst θ strides) :=
  ⟨values.batch,values.heads,values.capacity,values.index,values.width,
    values.inputValues.subst θ,values.updateValues.subst θ,values.startValues.subst θ,
    values.stopValues.subst θ,values.strideValues.subst θ,values.batchNonnegative,values.headsNonnegative,
    values.indexNonnegative,values.widthNonnegative,values.bound⟩

/-- At capacity, doubling a positive cache makes the same real append safe.
This does not supply the growth allocation or its source reachability. -/
theorem kv_append_after_doubling (capacity : Int) (positive : 0 < capacity) :
    0 ≤ capacity ∧ capacity+1 ≤ capacity+capacity := by omega

end Host.Mlx.Ffi.Annotated
