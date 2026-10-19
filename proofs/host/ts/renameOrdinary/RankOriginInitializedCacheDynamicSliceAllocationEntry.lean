import host.ts.renameOrdinary.RankOriginInitializedCacheDynamicSliceEntry
import host.load.RuntimeNamespacedDecodeDynamicSliceAllocationEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheDynamicSliceAllocationEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedOracleConvolutionBatch NamespacedDecode
open InitializedCacheWeightRank (identity_budget)

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``NamespacedDecode.dynamic_slice_to_allocation
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
noncomputable def live := connectedLive InitializedCacheDynamicSliceEntry.live

theorem live_grow (a : Nat) (alive : InitialRetained.live a) : live a := by
  unfold live connectedLive
  apply CellsLive.grow
  apply ClosureLive.grow
  apply Or.inl
  apply Or.inl
  apply Or.inl
  apply Or.inl
  apply Or.inl
  apply CellsLive.grow
  apply ClosureLive.grow
  exact InitializedCacheDynamicSliceEntry.live_grow a alive

theorem native_frame : Plan1362.Block75.output.ffi.mlx = Plan1331.Block30.output.ffi.mlx := by
  host_kernel_rfl
theorem source_endpoint : Plan1362.Block75.output = Region1362.s76 := by host_kernel_rfl
theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (resultNotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_dynamic_slice_allocation_entry (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743293 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          InitializedCacheSlice.roles NativeSeed.boundary InitializedCacheSlice.objects InitializedCacheSlice.handles InitializedCacheSlice.nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace Plan1362.Block75.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live Plan1362.Block75.output result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheSlice.handles InitializedCacheSlice.nodes
        InitializedCacheSlice.roles InitializedCacheSlice.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheSlice.handles InitializedCacheSlice.nodes Plan1362.Block75.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) Plan1362.Block75.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1362,run1362,h1362,inventory1362,policy,support,inst1362⟩ :=
    InitializedCacheDynamicSliceEntry.initialized_dynamic_slice_entry ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic (a : Nat) (small : a < 100) : InitializedCacheDynamicSliceEntry.live a :=
    InitializedCacheDynamicSliceEntry.live_grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  have streamAddress : Plan1362.Block10.address = Parameter45.address := by host_kernel_rfl
  have streamEntry : notes.runtime.cells.cells Plan1362.Block10.address = some (.handle 2) := by
    rw [streamAddress]
    exact (InitializedCache.entry_seeds ic is control fnRole thisRole saved caller).streamEntry
  have capture : notes.captures.owners 90 = some InitialRetained.constructorMetadata :=
    InitializedCacheWeightTail.constructor_selected ic is control fnRole thisRole saved caller
  obtain ⟨result,run76,post,retained,inst1438⟩ := dynamic_slice_to_allocation notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheSlice.roles NativeSeed.boundary InitializedCacheSlice.objects InitializedCacheSlice.handles InitializedCacheSlice.nodes [] InitializedCache.hostRelation)
    InitializedCacheDynamicSliceEntry.live (fun _ => False) [] [] input.trace input.trace s1362 inst1362 h1362 inventory1362
    (identity_budget h1362 (by decide +kernel))
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    streamEntry capture
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,?_,inst1438⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run1362; cases run1362
    | some start =>
      simp only [boot,Option.bind_some] at run1362 ⊢
      exact runC_join P.F (m:=32743217) (n:=76) run1362 run76
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheDynamicSliceAllocationEntry
