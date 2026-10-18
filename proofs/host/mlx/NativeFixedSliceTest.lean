import host.mlx.NativeLiteralSliceRetained
import host.ts.RenameKernelRfl

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated.FixedSliceTest
open Host.Ts Host.Ts.Owned NativeRoles

def historyValues (ν : Nat → F64) :
    LiteralSliceValues ν (constantShape [1,4,10240]) (constantShape [1,3,10240])
      (constantShape [0,1,0]) (constantShape [1,4,10240]) (constantShape [1,1,1]) .fresh :=
  .constants ν [1,4,10240] [0,1,0] [1,4,10240] .fresh
    (by decide +kernel) (by decide +kernel) (by decide +kernel) (by decide +kernel)
    (by decide +kernel) (by decide +kernel)

theorem history_geometry (ν : Nat → F64) :
    SliceGeometry ν (constantShape [1,4,10240]) (constantShape [1,3,10240])
      (constantShape [0,1,0]) (constantShape [1,4,10240]) (constantShape [1,1,1]) false :=
  (historyValues ν).geometry

theorem original_infer :
    infer (.slice ([0,1,0].map Dim.lit) ([1,4,10240].map Dim.lit) ([1,1,1].map Dim.lit))
      [([1,4,10240].map Dim.lit,12)] = M.pure (some (.node ([1,3,10240].map Dim.lit) 12)) := rfl

def widthSplitValues (ν : Nat → F64) :
    LiteralSliceValues ν (constantShape [1,1,24,512]) (constantShape [1,1,24,256])
      (constantShape [0,0,0,256]) (constantShape [1,1,24,512]) (constantShape [1,1,1,1]) .fresh :=
  .constants ν [1,1,24,512] [0,0,0,256] [1,1,24,512] .fresh
    (by decide +kernel) (by decide +kernel) (by decide +kernel) (by decide +kernel)
    (by decide +kernel) (by decide +kernel)

theorem width_split_geometry (ν : Nat → F64) :
    SliceGeometry ν (constantShape [1,1,24,512]) (constantShape [1,1,24,256])
      (constantShape [0,0,0,256]) (constantShape [1,1,24,512]) (constantShape [1,1,1,1]) false :=
  (widthSplitValues ν).geometry

theorem rounded_integer_rejected : ¬ ExactDimensions [9007199254740993] := by decide +kernel

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd Lean.Elab.Command.liftTermElabM do
  let saved ← Lean.getEnv
  try
    let source ← Lean.Elab.Term.elabTerm (← `(F64.toInt? (F64.ofInt 9007199254740993))) none
    let wrong ← Lean.Elab.Term.elabTermEnsuringType (← `(some (9007199254740993 : Int)))
      (← Lean.Meta.inferType source)
    Lean.Elab.Term.synthesizeSyntheticMVarsNoPostponing
    let source ← Lean.instantiateMVars source
    let wrong ← Lean.instantiateMVars wrong
    let scopeName ← Lean.getCurrNamespace
    let type ← Lean.Meta.mkEq source wrong
    let value ← Lean.Meta.mkEqRefl source
    Lean.addDecl (.thmDecl {name := scopeName ++ `reject_rounded_integer,levelParams := [],type := type,value := value})
  finally Lean.setEnv saved

end Host.Mlx.Ffi.Annotated.FixedSliceTest
