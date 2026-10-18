import host.mlx.NativeDataRetained
import host.ts.RenameKernelRfl

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated.DataRetainedTest
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated NativeRoles

def counterCells : List Host.Ts.Owned.Annotated.Byte := cellPartNotes .i32 (.num (.var 0)) 4 0

def counterPayload : List Host.Ts.Owned.Annotated.Byte := counterCells ++ [.lit 17,.lit 23]

theorem copied_counter_role :
    (dataRole [.lit 1] 7 (constantShape [1]) counterPayload).graph = some (.data counterCells,[]) := rfl

theorem varying_counter_bytes (ν : Nat → F64) (C : CSrv) (R : Ren) (number : NumV)
    (meaning : NumDenote ν C (.var 0) number) :
    ListR (Host.Ts.Owned.Annotated.Byte.Holds ν C R) (dataCopy [.lit 1] 7 counterPayload)
      (cellParts .i32 (.num number) 4 0) :=
  cellPartNotes_holds (.num (.var 0) number meaning) .i32 4 0

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd Lean.Elab.Command.liftTermElabM do
  let saved ← Lean.getEnv
  try
    let source ← Lean.Elab.Term.elabTerm (← `((dataRole [.lit 1] 7 (constantShape [1]) counterPayload).graph)) none
    let wrong ← Lean.Elab.Term.elabTermEnsuringType (← `(some (.data counterPayload,[]))) (← Lean.Meta.inferType source)
    Lean.Elab.Term.synthesizeSyntheticMVarsNoPostponing
    let source ← Lean.instantiateMVars source
    let wrong ← Lean.instantiateMVars wrong
    let scopeName ← Lean.getCurrNamespace
    let type ← Lean.Meta.mkEq source wrong
    let value ← Lean.Meta.mkEqRefl source
    Lean.addDecl (.thmDecl {name := scopeName ++ `reject_untruncated_payload,levelParams := [],type := type,value := value})
  finally Lean.setEnv saved

end Host.Mlx.Ffi.Annotated.DataRetainedTest
