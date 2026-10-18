import host.mlx.NativeAttentionRetained
import host.ts.RenameKernelRfl

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated.AttentionTest
open Host.Ts Host.Ts.Owned NativeRoles

/-- The original rank check and shape inference work for an arbitrary used
cache-prefix dimension, including symbolic dimensions and growth outputs. -/
theorem infer_variable_prefix (time : Dim) (scale : NumV) (mask : Name) :
    infer (.sdpa scale mask)
      [([.lit 1,.lit 24,.lit 1,.lit 256],12),
        ([.lit 1,.lit 4,time,.lit 256],12),([.lit 1,.lit 4,time,.lit 256],12)] =
      M.pure (some (.node [.lit 1,.lit 24,.lit 1,.lit 256] 12)) := rfl

theorem ordinary_prefix (scale : NumV) (mask : Name) :
    infer (.sdpa scale mask)
      [([1,24,1,256].map Dim.lit,12),([1,4,4,256].map Dim.lit,12),([1,4,4,256].map Dim.lit,12)] =
      M.pure (some (.node ([1,24,1,256].map Dim.lit) 12)) := infer_variable_prefix (.lit 4) scale mask

theorem grown_prefix (scale : NumV) (mask : Name) :
    infer (.sdpa scale mask)
      [([1,24,1,256].map Dim.lit,12),([1,4,257,256].map Dim.lit,12),([1,4,257,256].map Dim.lit,12)] =
      M.pure (some (.node ([1,24,1,256].map Dim.lit) 12)) := infer_variable_prefix (.lit 257) scale mask

theorem wrong_rank_rejects (scale : NumV) (mask : Name) :
    infer (.sdpa scale mask)
      [([1,24,1,256].map Dim.lit,12),([1,4,256].map Dim.lit,12),([1,4,4,256].map Dim.lit,12)] =
      M.pure none := rfl

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd Lean.Elab.Command.liftTermElabM do
  let saved ← Lean.getEnv
  try
    let source ← Lean.Elab.Term.elabTerm (← `(infer (.sdpa (.lit (F64.zero false)) [])
      [([1,24,1,256].map Dim.lit,12),([1,4,256].map Dim.lit,12),([1,4,4,256].map Dim.lit,12)])) none
    let wrong ← Lean.Elab.Term.elabTermEnsuringType
      (← `(M.pure (some (.node ([1,24,1,256].map Dim.lit) 12)))) (← Lean.Meta.inferType source)
    Lean.Elab.Term.synthesizeSyntheticMVarsNoPostponing
    let source ← Lean.instantiateMVars source
    let wrong ← Lean.instantiateMVars wrong
    let scopeName ← Lean.getCurrNamespace
    let type ← Lean.Meta.mkEq source wrong
    let value ← Lean.Meta.mkEqRefl source
    Lean.addDecl (.thmDecl {name := scopeName ++ `reject_rank_three,levelParams := [],type := type,value := value})
  finally Lean.setEnv saved

end Host.Mlx.Ffi.Annotated.AttentionTest
