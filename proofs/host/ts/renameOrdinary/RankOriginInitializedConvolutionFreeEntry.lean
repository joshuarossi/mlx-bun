import host.ts.renameOrdinary.RankOriginConvolutionDisposalFacts
import host.load.RuntimePostConvCleanupFree

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedConvolutionFreeEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open ConvolutionDisposalFacts

open Lean Elab Command Meta in
run_cmd do
  let arguments : Array (Array Lean.Name) ← liftTermElabM do
    let info ← getConstInfo ``PostConvCleanup.retained_store_to_free
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
        let mut allNames := #[]
        for (name,index) in [(`connectedNotes,1),(`connectedLive,7)] do
          let value := retained.getAppArgs[index]!
          let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
          let names ← used.mapM fun a => do pure (← a.fvarId!.getDecl).userName
          Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)
          allNames := allNames.push names
        pure allNames
  let noteArgument (name : Lean.Name) : CommandElabM String :=
    match name with
    | `notes => pure "(ConvolutionDisposalFacts.inputNotes notes caller)"
    | `role => pure "(Annotated.Value.bool true)"
    | `headNote => pure "(ConvolutionDisposalFacts.headNote notes caller)"
    | `tailNotes => pure "(ConvolutionDisposalFacts.tailNotes notes caller)"
    | `disposeThis => pure "(Annotated.Value.obj 3126703)"
    | `inputRole => pure "(Annotated.Value.handle 29372)"
    | _ => throwError "unresolved current annotation argument: {name}"
  let actualNotes ← arguments[0]!.mapM noteArgument
  Parametric.Driver.emit ("noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) := connectedNotes " ++
    String.intercalate " " actualNotes.toList)
  unless arguments[1]! == #[`live] do throwError "unexpected live-set arguments: {arguments[1]!}"

noncomputable def live := connectedLive InitializedConvolutionCleanup.live

theorem native_frame : PostConvCleanup.Region.s121.ffi.mlx = PostConvCleanup.Region.s99.ffi.mlx := by
  host_kernel_rfl

/-- The initialized convolution cleanup reaches the actual free call. Every
store/receiver premise is derived from the retained initialization notes. -/
theorem initialized_free_entry (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743833 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          InitializedCacheConvolution.roles NativeSeed.boundary InitializedCacheConvolution.objects
          InitializedCacheConvolution.handles InitializedCacheConvolution.nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace PostConvCleanup.Region.s121 result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live PostConvCleanup.Region.s121 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheConvolution.handles InitializedCacheConvolution.nodes
        InitializedCacheConvolution.roles InitializedCacheConvolution.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheConvolution.handles InitializedCacheConvolution.nodes PostConvCleanup.Region.s121.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit))
        (numberServer (PostConvCleanup.Region.S121.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1956,run1956,state1956,inventory1956,policy,support,inst1956⟩ :=
    InitializedConvolutionCleanup.initialized_cleanup ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have budget : s1956.next+64 ≤ 2^64 := by
    have next := state1956.heap.fresh 0
    change PostConvCleanup.Region.s99.next = s1956.next at next
    rw [← next]
    decide +kernel
  obtain ⟨result,run22,post,retained,inst1978⟩ := PostConvCleanup.retained_store_to_free
    (inputNotes notes caller)
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheConvolution.roles NativeSeed.boundary InitializedCacheConvolution.objects
      InitializedCacheConvolution.handles InitializedCacheConvolution.nodes [] InitializedCache.hostRelation)
    InitializedConvolutionCleanup.live (fun _ => False) [] [] input.trace input.trace s1956
    (source_server.symm ▸ inst1956) state1956 inventory1956
    (.bool true) (headNote notes caller) (tailNotes notes caller)
    (current_control notes caller) (current_stack notes caller) budget
    ⟨4852,chars!"handle",.handle 29372⟩ (current_handle notes caller) different_name
    (.obj 3126703) (current_receiver notes caller) (.handle 29372) (current_handle notes caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,?_,inst1978⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run1956; cases run1956
    | some start =>
      simp only [boot,Option.bind_some] at run1956 ⊢
      exact runC_join P.F (m:=32743811) (n:=22) run1956 run22
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedConvolutionFreeEntry
