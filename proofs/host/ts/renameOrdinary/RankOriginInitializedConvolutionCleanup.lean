import host.ts.renameOrdinary.RankOriginConvolutionCleanupFacts

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedConvolutionCleanup
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open ConvolutionCleanupFacts

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``PostConvCleanup.result_before_disposal
  forallTelescope info.type fun args tail => do
    let tail ← whnf tail
    unless tail.isAppOfArity ``Exists 2 do throwError "expected a reached state"
    lambdaTelescope tail.getAppArgs[1]! fun _ body => do
      let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
        if p.getAppFn.isConstOf ``RetainedInventory then return p
        if p.isAppOfArity ``And 2 then
          try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
        else throwError "missing retained inventory"
      let retained ← inventory body
      for (name,index) in [(`connectedNotes,1),(`connectedLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  connectedNotes (inputNotes notes caller) (remainingCaller caller)
noncomputable def live := connectedLive InitializedCacheConvolution.live

theorem native_frame : PostConvCleanup.Region.s99.ffi.mlx = NamespacedDecode.Conv1856.output.ffi.mlx := by
  host_kernel_rfl

theorem initialized_cleanup (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743811 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          InitializedCacheConvolution.roles NativeSeed.boundary InitializedCacheConvolution.objects
          InitializedCacheConvolution.handles InitializedCacheConvolution.nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace PostConvCleanup.Region.s99 result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live PostConvCleanup.Region.s99 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheConvolution.handles InitializedCacheConvolution.nodes
        InitializedCacheConvolution.roles InitializedCacheConvolution.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheConvolution.handles InitializedCacheConvolution.nodes PostConvCleanup.Region.s99.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit))
        (numberServer (PostConvCleanup.Region.S99.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1857,run1857,h1857,inventory1857,policy,support,inst1857⟩ :=
    InitializedCacheConvolution.initialized_convolution ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic (a : Nat) (small : a < 100) : InitializedCacheConvolution.live a :=
    initial_live_grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  have budget : s1857.next+64 ≤ 2^64 := by
    have next := h1857.heap.fresh 0
    change NamespacedDecode.Conv1856.output.next = s1857.next at next
    rw [← next]
    decide +kernel
  obtain ⟨result,run99,post,retained,inst1956⟩ := PostConvCleanup.result_before_disposal
    (inputNotes notes caller)
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheConvolution.roles NativeSeed.boundary InitializedCacheConvolution.objects
      InitializedCacheConvolution.handles InitializedCacheConvolution.nodes [] InitializedCache.hostRelation)
    InitializedCacheConvolution.live (fun _ => False) [] [] input.trace input.trace s1857
    (source_server.symm ▸ inst1857) (source_entry.symm ▸ h1857) (source_entry.symm ▸ inventory1857) budget
    constructorRole constructorThis (remainingCaller caller) (current_control notes caller) (current_stack notes caller)
    (.handle 29372) (current_slot notes caller) (current_buffer notes caller) (current_input_handle notes caller)
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,?_,inst1956⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run1857; cases run1857
    | some start =>
      simp only [boot,Option.bind_some] at run1857 ⊢
      exact runC_join P.F (m:=32743712) (n:=99) run1857 run99
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedConvolutionCleanup
