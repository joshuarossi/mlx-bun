import host.mlx.NativeConvRetained
import host.ts.RenameKernelRfl

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated.ConvRetainedTest
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem history_geometry (ν : Nat → F64) :
    ConvGeometry ν (constantShape [1,4,10240]) (constantShape [10240,4,1])
      (constantShape [1,1,10240]) 1 0 1 10240 :=
  .constants ν 1 0 1 10240 1 4 10240 10240 4 1
    (by decide +kernel) (by decide +kernel) (by decide +kernel)
    (by decide +kernel) (by decide +kernel) (by decide +kernel)

theorem bad_channel_group_rejected :
    infer (.conv1d 1 0 1 10239) [([1,4,10240].map Dim.lit,12),([10240,4,1].map Dim.lit,12)] =
      M.pure none := rfl

def sumFour : SymE := .bin .add (.lit (F64.ofInt 3)) (.lit (F64.ofInt 1))

theorem closed_parameter_expression : ClosedLiteralNote (.literal sumFour) := rfl

theorem closed_current_argument {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {target : Val}
    (source : (Value.literal sumFour).Holds ν₀ C₀ identity (.num (.lit (F64.ofInt 4))))
    (held : (Value.literal sumFour).Holds ν C R target) :
    (Value.literal (.lit (F64.ofInt 4))).Holds ν C R target :=
  closed_parameter_expression.exact source held

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd Lean.Elab.Command.liftTermElabM do
  let saved ← Lean.getEnv
  try
    let source ← Lean.Elab.Term.elabTerm (← `(infer (.conv1d 1 0 1 10239)
      [([1,4,10240].map Dim.lit,12),([10240,4,1].map Dim.lit,12)])) none
    let wrong ← Lean.Elab.Term.elabTermEnsuringType
      (← `(M.pure (some (.node ([1,1,10240].map Dim.lit) 12)))) (← Lean.Meta.inferType source)
    Lean.Elab.Term.synthesizeSyntheticMVarsNoPostponing
    let source ← Lean.instantiateMVars source
    let wrong ← Lean.instantiateMVars wrong
    let scopeName ← Lean.getCurrNamespace
    let type ← Lean.Meta.mkEq source wrong
    let value ← Lean.Meta.mkEqRefl source
    Lean.addDecl (.thmDecl {name := scopeName ++ `reject_bad_channel_guard,levelParams := [],type := type,value := value})
  finally Lean.setEnv saved

end Host.Mlx.Ffi.Annotated.ConvRetainedTest
