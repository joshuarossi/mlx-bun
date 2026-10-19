import host.ts.renameOrdinary.RankOriginPostConcatFacts

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedPostConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open PostConcatFacts

open Lean Elab Command Meta in
run_cmd do
  let arguments : Array (Array Lean.Name) ← liftTermElabM do
    let info ← getConstInfo ``PostConcatCleanup.retained_to_free
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
    | `notes => pure "(PostConcatFacts.inputNotes notes caller)"
    | `returned => pure "nativeStatusRole"
    | `outerRole => pure "PostConcatFacts.outerRole"
    | `localRole => pure "PostConcatFacts.localRole"
    | `handleRole => pure "(Annotated.Value.handle 25732)"
    | _ => throwError "unresolved current annotation argument: {name}"
  let actualNotes ← arguments[0]!.mapM noteArgument
  Parametric.Driver.emit ("noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) := connectedNotes " ++
    String.intercalate " " actualNotes.toList)
  unless arguments[1]! == #[`live] do throwError "unexpected live-set arguments: {arguments[1]!}"

noncomputable def live := connectedLive InitializedConvolutionFree.live

theorem native_frame : PostConcatCleanup.Region.s77.ffi.mlx = NamespacedDecode.Free1978.output.ffi.mlx := by
  host_kernel_rfl

/-- The actual initialized execution reaches the second disposal call. Its
current cell and handle premises are supplied by the preceding execution. -/
theorem initialized_post_concat (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743911 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          InitializedConvolutionFree.roles NativeSeed.boundary InitializedConvolutionFree.objects
          InitializedConvolutionFree.handles InitializedConvolutionFree.nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace PostConcatCleanup.Region.s77 result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live PostConcatCleanup.Region.s77 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedConvolutionFree.handles InitializedConvolutionFree.nodes
        InitializedConvolutionFree.roles InitializedConvolutionFree.objects ∧
      ProducerSupport ObjectSeed.roots InitializedConvolutionFree.handles InitializedConvolutionFree.nodes PostConcatCleanup.Region.s77.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit))
        (numberServer (PostConcatCleanup.Region.S77.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1979,run1979,h1979,inventory1979,policy,support,inst1979⟩ :=
    InitializedConvolutionFree.initialized_free ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have budget : s1979.next+64 ≤ 2^64 := by
    have next := h1979.heap.fresh 0
    change NamespacedDecode.Free1978.output.next = s1979.next at next
    rw [← next]
    decide +kernel
  obtain ⟨result,run77,post,retained,inst2056⟩ := PostConcatCleanup.retained_to_free
    (inputNotes notes caller)
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedConvolutionFree.roles NativeSeed.boundary InitializedConvolutionFree.objects
      InitializedConvolutionFree.handles InitializedConvolutionFree.nodes [] InitializedCache.hostRelation)
    InitializedConvolutionFree.live (fun _ => False) [] [] input.trace input.trace s1979
    (source_server.symm ▸ inst1979) (source_entry.symm ▸ h1979) (source_entry.symm ▸ inventory1979) budget
    (intrinsic_live _ (by decide +kernel)) rfl (intrinsic_live _ (by decide +kernel)) rfl
    (intrinsic_live _ (by decide +kernel)) rfl (intrinsic_live _ (by decide +kernel)) rfl
    nativeStatusRole (current_control notes caller) outerRole (current_outer ic is control fnRole thisRole saved caller)
    localRole (current_local ic is control fnRole thisRole saved caller) (.handle 25732)
    (current_handle ic is control fnRole thisRole saved caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,?_,inst2056⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run1979; cases run1979
    | some start =>
      simp only [boot,Option.bind_some] at run1979 ⊢
      exact runC_join P.F (m:=32743834) (n:=77) run1979 run77
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedPostConcat
