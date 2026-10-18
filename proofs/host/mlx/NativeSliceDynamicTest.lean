import host.mlx.NativeSliceDynamicRetained
import host.ts.RenameKernelRfl

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated.DynamicSliceTest
open Host.Ts Host.Ts.Owned NativeRoles

theorem output_role_subst (θ : Nat → SymE) (roles : Nat → GraphNode)
    (input start : Nat) (axes : List Nat) (sizes : Shape) :
    (sliceDynamicRole roles input start axes sizes).subst θ =
      sliceDynamicRole (fun i => (roles i).subst θ) input start axes (Shape.subst θ sizes) := by
  simp only [sliceDynamicRole,GraphNode.subst,Option.map_some,Primitive.subst]

theorem original_history_infer :
    infer (.sliceDynamic [0] ([1,3,10240].map Dim.lit))
      [([1,3,10240].map Dim.lit,12),([],7)] = M.pure (some (.node ([1,3,10240].map Dim.lit) 12)) := rfl

theorem varying_size_infer :
    infer (.sliceDynamic [1] ([1,257,256].map Dim.lit))
      [([1,512,256].map Dim.lit,12),([1].map Dim.lit,7)] = M.pure (some (.node ([1,257,256].map Dim.lit) 12)) := rfl

theorem floating_start_rejected :
    infer (.sliceDynamic [0] ([1,3,10240].map Dim.lit))
      [([1,3,10240].map Dim.lit,12),([],12)] = M.pure none := rfl

theorem wrong_size_rank_rejected :
    infer (.sliceDynamic [0] ([1,3].map Dim.lit))
      [([1,3,10240].map Dim.lit,12),([],7)] = M.pure none := rfl

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd Lean.Elab.Command.liftTermElabM do
  let saved ← Lean.getEnv
  try
    let source ← Lean.Elab.Term.elabTerm (← `(infer (.sliceDynamic [0] ([1,3,10240].map Dim.lit))
      [([1,3,10240].map Dim.lit,12),([],12)])) none
    let wrong ← Lean.Elab.Term.elabTermEnsuringType
      (← `(M.pure (some (.node ([1,3,10240].map Dim.lit) 12)))) (← Lean.Meta.inferType source)
    Lean.Elab.Term.synthesizeSyntheticMVarsNoPostponing
    let source ← Lean.instantiateMVars source
    let wrong ← Lean.instantiateMVars wrong
    let scopeName ← Lean.getCurrNamespace
    let type ← Lean.Meta.mkEq source wrong
    let value ← Lean.Meta.mkEqRefl source
    Lean.addDecl (.thmDecl {name := scopeName ++ `reject_float_start,levelParams := [],type := type,value := value})
  finally Lean.setEnv saved

end Host.Mlx.Ffi.Annotated.DynamicSliceTest
