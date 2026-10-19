import host.ts.renameOrdinary.RankOriginCompiledArgumentFacts
import host.load.RuntimeCompiledArgumentEntryThrough279Joined
import host.ts.renameOrdinary.RankOriginCompiledArgumentBounds

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCompiledArgumentFull
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open CompiledArgumentFacts

open Lean Elab Command Meta in
run_cmd do
  let arguments : Array (Array Lean.Name) ← liftTermElabM do
    let info ← getConstInfo ``CompiledArgumentEntry.retained_through279
    forallTelescope info.type fun args tail => do
      let tail ← whnf tail
      unless tail.isAppOfArity ``Exists 2 do throwError "expected the reached state"
      lambdaTelescope tail.getAppArgs[1]! fun _ body => do
        let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
          if p.getAppFn.isConstOf ``RetainedInventory then return p
          if p.isAppOfArity ``And 2 then
            try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
          else throwError "missing retained inventory"
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
    | `notes => pure "(CompiledArgumentFacts.inputNotes notes caller)"
    | `role => pure "nativeStatusRole"
    | `cellRole => pure "CompiledArgumentFacts.cellRole"
    | `receiverRole => pure "CompiledArgumentFacts.receiverRole"
    | `metadata => pure "InitializedHandleBuffer.constructorMetadata"
    | _ => throwError "unresolved current annotation argument: {name}"
  let actualNotes ← arguments[0]!.mapM noteArgument
  Parametric.Driver.emit ("noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) := connectedNotes " ++
    String.intercalate " " actualNotes.toList)
  unless arguments[1]! == #[`live] do throwError "unexpected live-set arguments: {arguments[1]!}"

noncomputable def live := connectedLive InitializedPostConcatFree.live

theorem native_frame : CompiledArgumentEntry.Region.s279.ffi.mlx = NamespacedDecode.Free2056.output.ffi.mlx := by
  host_kernel_rfl

/-- All 279 actual compiled-argument steps after the initialized disposal. The
current control and both cell roles come from the preceding reached state. -/
theorem initialized_compiled_arguments (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32744191 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          InitializedPostConcatFree.roles NativeSeed.boundary InitializedPostConcatFree.objects
          InitializedPostConcatFree.handles InitializedPostConcatFree.nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace CompiledArgumentEntry.Region.s279 result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live CompiledArgumentEntry.Region.s279 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedPostConcatFree.handles InitializedPostConcatFree.nodes
        InitializedPostConcatFree.roles InitializedPostConcatFree.objects ∧
      ProducerSupport ObjectSeed.roots InitializedPostConcatFree.handles InitializedPostConcatFree.nodes CompiledArgumentEntry.Region.s279.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit))
        (numberServer (CompiledArgumentEntry.Region.S279.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s2057,run2057,h2057,inventory2057,policy,support,inst2057⟩ :=
    InitializedPostConcatFree.initialized_post_concat_free ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have budget : s2057.next+40 ≤ 2^64 := by
    have next := h2057.heap.fresh 0
    change NamespacedDecode.Free2056.output.next = s2057.next at next
    rw [← next]
    decide +kernel
  obtain ⟨result,run279,post,retained,inst2336⟩ := CompiledArgumentEntry.retained_through279
    (inputNotes notes caller)
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedPostConcatFree.roles NativeSeed.boundary InitializedPostConcatFree.objects
      InitializedPostConcatFree.handles InitializedPostConcatFree.nodes [] InitializedCache.hostRelation)
    InitializedPostConcatFree.live (fun _ => False) [] [] input.trace input.trace s2057
    (source_server.symm ▸ inst2057) (source_entry.symm ▸ h2057) (source_entry.symm ▸ inventory2057)
    nativeStatusRole (current_control notes caller) cellRole (current_cell ic is control fnRole thisRole saved caller)
    receiverRole (current_receiver ic is control fnRole thisRole saved caller)
    InitializedHandleBuffer.constructorMetadata
    (CompiledArgumentInputFacts.current_constructor ic is control fnRole thisRole saved caller) rfl rfl
    (CompiledArgumentInputFacts.current_input ic is control fnRole thisRole saved caller)
    (CompiledArgumentInputFacts.current_weight ic is control fnRole thisRole saved caller)
    (CompiledArgumentInputFacts.current_bias ic is control fnRole thisRole saved caller)
    (by decide +kernel) (by decide +kernel) (by decide +kernel)
    (CompiledArgumentInputFacts.current_intrinsic _ (by decide +kernel)) rfl
    (CompiledArgumentInputFacts.current_intrinsic _ (by decide +kernel)) rfl
    (CompiledArgumentInputFacts.current_intrinsic _ (by decide +kernel)) rfl
    (CompiledArgumentInputFacts.current_intrinsic _ (by decide +kernel)) rfl budget
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,?_,inst2336⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run2057; cases run2057
    | some start =>
      simp only [boot,Option.bind_some] at run2057 ⊢
      exact runC_join P.F (m:=32743912) (n:=279) run2057 run279
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCompiledArgumentFull
