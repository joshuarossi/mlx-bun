import host.mlx.NativeClosedShapeBuffer
import host.mlx.NativeClosedProducer

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated.ClosedShapeTest
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def sumHistory : SymE := .bin .add (.lit (F64.ofInt 3)) (.lit (F64.ofInt 1))
def historyShape : Shape := [constantDimension 1,.literal sumHistory,constantDimension 10240]
def startExpressions : List SymE := [.lit (F64.ofInt 0),.bin .sub sumHistory (.lit (F64.ofInt 3)),.lit (F64.ofInt 0)]

theorem history_closed : closedLiteralShape historyShape = true := rfl

theorem target_shape_from_current_source (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (held : Shape.Holds ν₀ C₀ historyShape ([1,4,10240].map Dim.lit)) :
    Shape.Holds ν C historyShape ([1,4,10240].map Dim.lit) :=
  ((LiteralDimensions.of_holds held).closed_transfer history_closed).holds C

theorem source_starts (ν : Nat → F64) :
    LiteralDimensions ν (startExpressions.map Dimension.literal) [0,1,0] := by
  refine .cons _ _ rfl (by change F64.toInt? (F64.ofInt 0) = some 0; decide +kernel)
    (.cons _ _ ?_ ?_ (.cons _ _ rfl (by change F64.toInt? (F64.ofInt 0) = some 0; decide +kernel) .nil))
  · change F64.bin .sub (F64.bin .add (F64.ofInt 3) (F64.ofInt 1)) (F64.ofInt 3) = F64.ofInt 1
    decide +kernel
  · change F64.toInt? (F64.bin .sub (F64.bin .add (F64.ofInt 3) (F64.ofInt 1)) (F64.ofInt 3)) = some 1
    decide +kernel

theorem source_start_bytes (ν : Nat → F64) (C : CSrv) (R : Ren) :
    ListR (fun role byte => role.Holds ν C R byte) (Owned.Annotated.literalShapeByteNotes startExpressions)
      (shapeBytes ([0,1,0].map Dim.lit)) :=
  Owned.Annotated.literal_shape_bytes_holds _ _ (source_starts ν)

theorem start_values_recovered (ν : Nat → F64) (C : CSrv) (R : Ren) :
    LiteralDimensions ν (startExpressions.map Dimension.literal) [0,1,0] :=
  Owned.Annotated.literal_shape_values_from_bytes startExpressions [0,1,0] (by decide +kernel)
    (source_start_bytes ν C R)

theorem variable_occurrence_rejected : closedLiteralShape [.literal (.var 0)] = false := rfl

theorem symbolic_occurrence_rejected : closedLiteralShape [.symbolic (.literal (.lit (F64.ofInt 4)))] = false := rfl

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd Lean.Elab.Command.liftTermElabM do
  let saved ← Lean.getEnv
  try
    let source ← Lean.Elab.Term.elabTerm (← `(closedLiteralShape [.literal (.var 0)])) none
    Lean.Elab.Term.synthesizeSyntheticMVarsNoPostponing
    let source ← Lean.instantiateMVars source
    let type ← Lean.Meta.mkEq source (Lean.mkConst ``Bool.true)
    let value ← Lean.Meta.mkEqRefl source
    let scopeName ← Lean.getCurrNamespace
    Lean.addDecl (.thmDecl {name := scopeName ++ `reject_open_meaning,levelParams := [],type := type,value := value})
  finally Lean.setEnv saved

end Host.Mlx.Ffi.Annotated.ClosedShapeTest
