import host.mlx.NativeKvAppendGeometry
import host.mlx.NativeSliceRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned NativeRoles

/-- The fixed prefix-view roles retain their exact integer meanings. The
equality guard selects aliasing explicitly; it may not be replaced by the
ordinary strict-prefix branch when capacity is reached. -/
structure KvViewValues (ν : Nat → F64) (input output starts stops strides : Shape) (kind : SliceResult) where
  batch : Int
  heads : Int
  capacity : Int
  used : Int
  width : Int
  inputValues : LiteralDimensions ν input [batch,heads,capacity,width]
  outputValues : LiteralDimensions ν output [batch,heads,used,width]
  startValues : LiteralDimensions ν starts [0,0,0,0]
  stopValues : LiteralDimensions ν stops [batch,heads,used,width]
  strideValues : LiteralDimensions ν strides [1,1,1,1]
  batchNonnegative : 0 ≤ batch
  headsNonnegative : 0 ≤ heads
  usedNonnegative : 0 ≤ used
  widthNonnegative : 0 ≤ width
  bound : used ≤ capacity
  branch : decide (used = capacity) = kind.same

theorem KvViewValues.geometry {ν : Nat → F64} {input output starts stops strides : Shape} {kind : SliceResult}
    (values : KvViewValues ν input output starts stops strides kind) :
    SliceGeometry ν input output starts stops strides kind.same := by
  rw [←values.branch]
  exact SliceGeometry.kv4 values.batch values.heads values.capacity values.used values.width
    values.inputValues.literalValues values.startValues.literalValues values.stopValues.literalValues
    values.strideValues.literalValues values.outputValues values.batchNonnegative values.headsNonnegative
    values.usedNonnegative values.widthNonnegative values.bound

def KvViewValues.subst {ν : Nat → F64} {input output starts stops strides : Shape} {kind : SliceResult}
    (θ : Nat → SymE)
    (values : KvViewValues (Owned.Annotated.nextValuation θ ν) input output starts stops strides kind) :
    KvViewValues ν (Shape.subst θ input) (Shape.subst θ output) (Shape.subst θ starts)
      (Shape.subst θ stops) (Shape.subst θ strides) kind :=
  ⟨values.batch,values.heads,values.capacity,values.used,values.width,
    values.inputValues.subst θ,values.outputValues.subst θ,values.startValues.subst θ,
    values.stopValues.subst θ,values.strideValues.subst θ,values.batchNonnegative,values.headsNonnegative,
    values.usedNonnegative,values.widthNonnegative,values.bound,values.branch⟩

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts

theorem SliceResult.state_counters (kind : SliceResult) (s : St) (input : Nat)
    (starts stops strides shape : List Dim) (dtype : Nat) :
    (kind.state s input starts stops strides shape dtype).next = s.next+1 ∧
    (kind.state s input starts stops strides shape dtype).nnext = s.nnext + (match kind with | .fresh => 1 | .alias => 0) := by
  cases kind <;> exact ⟨rfl,rfl⟩

end Host.Mlx.Ffi.NativeRoles
