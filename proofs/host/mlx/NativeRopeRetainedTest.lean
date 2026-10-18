import host.mlx.NativeRopeRetained
import host.ts.RenameKernelRfl

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated.RopeRetainedTest
open Host.Ts Host.Ts.Owned NativeRoles.Arguments

theorem decoder_literal_pure (C : CSrv) (x : F64) :
    interpC (NumericDecoder.i32.action (.lit x)).run C = some (.lit (F64.un .int32 x),C) := rfl

theorem current_and_later_offsets (C₀ C : CSrv) :
    interpC (NumericDecoder.i32.action (.lit (F64.ofInt 3))).run C₀ = some (.lit (F64.ofInt 3),C₀) ∧
    interpC (NumericDecoder.i32.action (.lit (F64.ofInt 257))).run C = some (.lit (F64.ofInt 257),C) := ⟨rfl,rfl⟩

theorem offset_expression_retained : (Number.literal (.var 0)).decoded .i32 = .literal (.un .int32 (.var 0)) := rfl

theorem offset_rebase (θ : Nat → SymE) : ((Number.literal (.var 0)).decoded .i32).subst θ =
    (Number.literal (θ 0)).decoded .i32 := rfl

theorem varying_literal_meaning (ν : Nat → F64) (C : CSrv) (e : SymE) (x : F64)
    (held : (Number.literal e).Holds ν C (.lit x)) :
    ((Number.literal e).decoded .i32).Holds ν C (.lit (F64.un .int32 x)) := by
  cases held with | literal _ _ meaning =>
    refine .literal _ _ ?_
    change some (F64.un .int32 x) = some (F64.un .int32 (e.eval ν))
    exact congrArg (fun v => some (F64.un .int32 v)) (Option.some.inj meaning)

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd Lean.Elab.Command.liftTermElabM do
  let saved ← Lean.getEnv
  try
    let source ← Lean.Elab.Term.elabTerm (← `((Number.literal (.var 0)).decoded .i32)) none
    let wrong ← Lean.Elab.Term.elabTermEnsuringType (← `(Number.literal (.lit (F64.ofInt 3)))) (← Lean.Meta.inferType source)
    Lean.Elab.Term.synthesizeSyntheticMVarsNoPostponing
    let source ← Lean.instantiateMVars source
    let wrong ← Lean.instantiateMVars wrong
    let scopeName ← Lean.getCurrNamespace
    let type ← Lean.Meta.mkEq source wrong
    let value ← Lean.Meta.mkEqRefl source
    Lean.addDecl (.thmDecl {name := scopeName ++ `reject_frozen_offset_role,levelParams := [],type := type,value := value})
  finally Lean.setEnv saved

end Host.Mlx.Ffi.Annotated.RopeRetainedTest
