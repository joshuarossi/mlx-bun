import host.load.RuntimeNamespacedDecodeDynamicSliceCleanup
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheDynamicSliceCleanup
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open NamespacedDecode
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``NamespacedDecode.dynamic_slice_to_free
  forallTelescope info.type fun args tail => do
    let tail ← whnf tail
    unless tail.isAppOfArity ``Exists 2 do throwError "expected connected reached state"
    lambdaTelescope tail.getAppArgs[1]! fun _ body => do
      let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
        if p.getAppFn.isConstOf ``RetainedInventory then return p
        if p.isAppOfArity ``And 2 then
          try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
        else throwError "missing full retained inventory"
      let retained ← inventory body
      for (name,index) in [(`connectedNotes,1),(`connectedLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  connectedNotes notes caller
noncomputable def live := connectedLive InitializedCacheDynamicSlice.live

theorem native_frame : Plan1550.Block126.output.ffi.mlx = Slice1549.output.ffi.mlx := by host_kernel_rfl
theorem source_endpoint : Plan1550.Block126.output = Region1550.s127 := by host_kernel_rfl
theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (resultNotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_dynamic_slice_cleanup (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743532 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          InitializedCacheDynamicSlice.roles NativeSeed.boundary InitializedCacheDynamicSlice.objects InitializedCacheDynamicSlice.handles InitializedCacheDynamicSlice.nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace Plan1550.Block126.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live Plan1550.Block126.output result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheDynamicSlice.handles InitializedCacheDynamicSlice.nodes
        InitializedCacheDynamicSlice.roles InitializedCacheDynamicSlice.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheDynamicSlice.handles InitializedCacheDynamicSlice.nodes Plan1550.Block126.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) Plan1550.Block126.nextServer C' := by

  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1550,run1550,h1550,inventory1550,policy,support,inst1550⟩ :=
    InitializedCacheDynamicSlice.initialized_dynamic_slice ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic (a : Nat) (small : a < 100) : InitializedCacheDynamicSlice.live a :=
    InitializedCacheDynamicCall.live_grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  have budget : s1550.next+64 ≤ 2^64 := by
    have fresh := h1550.heap.fresh 0
    change Slice1549.output.next = s1550.next at fresh
    rw [← fresh]
    decide +kernel
  obtain ⟨result,run127,post,retained,inst1677⟩ := dynamic_slice_to_free notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheDynamicSlice.roles NativeSeed.boundary InitializedCacheDynamicSlice.objects InitializedCacheDynamicSlice.handles InitializedCacheDynamicSlice.nodes [] InitializedCache.hostRelation)
    InitializedCacheDynamicSlice.live (fun _ => False) [] [] input.trace input.trace s1550 inst1550 h1550 inventory1550 budget
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,?_,inst1677⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run1550; cases run1550
    | some start =>
      simp only [boot,Option.bind_some] at run1550 ⊢
      exact runC_join P.F (m:=32743405) (n:=127) run1550 run127
  · simpa only [native_frame] using support
end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheDynamicSliceCleanup
