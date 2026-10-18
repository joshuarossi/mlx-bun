import host.mlx.NativeFixedSliceGeometry

set_option Elab.async false
namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

theorem QmmGeometry.constants (ν : Nat → F64) (tr : Bool) (bits : Nat) (rows cols : Int)
    (input scales : List Int) (weightExact : ExactDimensions [rows,cols]) (scalesExact : ExactDimensions scales)
    (inner : nthD 0 input (len input-1) = qmmInner tr bits rows cols)
    (innerExact : F64.toInt? (F64.ofInt (qmmInner tr bits rows cols)) = some (qmmInner tr bits rows cols)) :
    QmmGeometry ν tr bits rows cols (constantShape input) (constantShape [rows,cols])
      (constantShape scales) (constantShape scales) := by
  refine ⟨(LiteralDimensions.constants ν [rows,cols] weightExact).literalValues,
    ⟨scales,(LiteralDimensions.constants ν scales scalesExact).literalValues,
      (LiteralDimensions.constants ν scales scalesExact).literalValues⟩,?_⟩
  have mapped : nthD (constantDimension 0) (constantShape input) (len (constantShape input)-1) =
      constantDimension (nthD 0 input (len input-1)) := by
    simpa only [constantShape,len_map] using nthD_map constantDimension (0 : Int) input (len input-1)
  rw [mapped,inner]
  exact innerExact

end Host.Mlx.Ffi.Annotated
