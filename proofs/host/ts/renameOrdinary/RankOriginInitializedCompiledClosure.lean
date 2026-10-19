import host.ts.renameOrdinary.RankOriginCompiledClosureFacts

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCompiledClosure
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open CompiledClosureFacts

open Lean Elab Command Meta in
run_cmd do
  let arguments : Array (Array Lean.Name) ← liftTermElabM do
    let info ← getConstInfo ``ClosureApplyBridge.retained_to_call
    forallTelescope info.type fun args tail => do
      let tail ← whnf tail
      unless tail.isAppOfArity ``Exists 2 do throwError "expected reached closure-call state"
      lambdaTelescope tail.getAppArgs[1]! fun _ body => do
        let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
          if p.getAppFn.isConstOf ``RetainedInventory then return p
          if p.isAppOfArity ``And 2 then
            try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
          else throwError "missing retained closure inventory"
        let retained ← inventory body
        let mut names := #[]
        for (name,index) in [(`connectedNotes,1),(`connectedLive,7)] do
          let value := retained.getAppArgs[index]!
          let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
          let usedNames ← used.mapM fun a => do pure (← a.fvarId!.getDecl).userName
          Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)
          names := names.push usedNames
        pure names
  let noteArgument (name : Lean.Name) : CommandElabM String :=
    match name with
    | `notes => pure "(InitializedCompiledVector.resultNotes notes caller)"
    | `role => pure "(.handle 29376)"
    | `metadata => pure "InitializedHandleBuffer.constructorMetadata"
    | `thisRole => pure "CompiledClosureFacts.thisRole"
    | `compiledRole => pure "CompiledClosureFacts.compiledRole"
    | _ => throwError "unresolved current closure annotation argument: {name}"
  let actualNotes ← arguments[0]!.mapM noteArgument
  Parametric.Driver.emit ("noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) := connectedNotes " ++
    String.intercalate " " actualNotes.toList)
  unless arguments[1]! == #[`live] do throwError "unexpected live-set arguments: {arguments[1]!}"

noncomputable def live := connectedLive InitializedCompiledVector.live
noncomputable def roles := InitializedCompiledVector.roles
noncomputable def nodes := InitializedCompiledVector.nodes
noncomputable def objects := objectWrite InitializedCompiledVector.objects 29377 (.vec [])
noncomputable def handles (a : Nat) : Prop := a = 29377 ∨ InitializedCompiledVector.handles a

theorem initialized_compiled_closure (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32744237 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          roles NativeSeed.boundary objects handles nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace ClosureApplyBridge.After.Block2381.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live ClosureApplyBridge.After.Block2381.output result ∧
      ProducerAnnotations ObjectSeed.roots handles nodes roles objects ∧
      ProducerSupport ObjectSeed.roots handles nodes ClosureApplyBridge.After.Block2381.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) ClosureApplyBridge.After.Block2381.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s2337,run2337,h2337,inventory2337,policy,support,inst2337⟩ :=
    InitializedCompiledVector.initialized_compiled_vector ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have budget : s2337.next+256 ≤ 2^64 := by
    have next := h2337.heap.fresh 0
    change NamespacedDecode.Vector2336.output.next = s2337.next at next
    rw [← next]
    decide +kernel
  have nativeBudget : s2337.ffi.mlx.next+1 < 2^64 := by
    have next := h2337.native.2.handleMap.head
    change NamespacedDecode.Vector2336.output.ffi.mlx.next = s2337.ffi.mlx.next at next
    rw [← next]
    decide +kernel
  obtain ⟨result,run45,post,retained,inst2382,newPolicy,newSupport,targetSupport⟩ := ClosureApplyBridge.retained_to_call
    (InitializedCompiledVector.resultNotes notes caller)
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    roles NativeSeed.boundary InitializedCompiledVector.objects ObjectSeed.roots InitializedCompiledVector.handles nodes [] InitializedCache.hostRelation
    InitializedCompiledVector.live (fun _ => False) [] [] input.trace input.trace s2337
    (source_server ▸ inst2337) (source_entry ▸ h2337) (source_entry ▸ inventory2337) policy
    (.handle 29376) (current_control notes caller) budget
    (current_intrinsic _ (by decide +kernel)) rfl (current_intrinsic _ (by decide +kernel)) rfl
    (current_intrinsic _ (by decide +kernel)) rfl (current_intrinsic _ (by decide +kernel)) rfl
    (current_intrinsic _ (by decide +kernel)) rfl
    InitializedHandleBuffer.constructorMetadata (current_constructor ic is control fnRole thisRole saved caller)
    constructor_code constructor_proto
    (current_intrinsic _ (by decide +kernel)) rfl
    CompiledClosureFacts.thisRole (current_this notes caller)
    CompiledClosureFacts.compiledRole (current_compiled ic is control fnRole thisRole saved caller)
    (fun impossible => impossible) nativeBudget
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,newPolicy,newSupport,inst2382⟩
  cases boot : bootL Route.cx Decode.world 2000 with
  | none => simp only [boot,Option.bind_none] at run2337; cases run2337
  | some start =>
    simp only [boot,Option.bind_some] at run2337 ⊢
    exact runC_join P.F (m:=32744192) (n:=45) run2337 run45

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCompiledClosure
