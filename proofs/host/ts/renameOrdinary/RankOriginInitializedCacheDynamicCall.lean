import host.ts.renameOrdinary.RankOriginInitializedCacheDynamicSliceAllocationEntry
import host.ts.renameOrdinary.RankOriginDynamicSliceStartSeed
import host.load.RuntimeNamespacedDecodeDynamicCallEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheDynamicCall
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedOracleConvolutionBatch NamespacedDecode
open InitializedCacheWeightRank (identity_budget)

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``NamespacedDecode.allocation_to_dynamic_call
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
noncomputable def live := connectedLive InitializedCacheDynamicSliceAllocationEntry.live

theorem native_frame : Plan1438.Block110.output.ffi.mlx = Plan1362.Block75.output.ffi.mlx := by
  host_kernel_rfl
theorem source_endpoint : Plan1438.Block110.output = Region1438.s111 := by host_kernel_rfl
theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (resultNotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_dynamic_call (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743404 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          InitializedCacheSlice.roles NativeSeed.boundary InitializedCacheSlice.objects InitializedCacheSlice.handles InitializedCacheSlice.nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace Plan1438.Block110.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live Plan1438.Block110.output result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheSlice.handles InitializedCacheSlice.nodes
        InitializedCacheSlice.roles InitializedCacheSlice.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheSlice.handles InitializedCacheSlice.nodes Plan1438.Block110.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) Plan1438.Block110.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1438,run1438,h1438,inventory1438,policy,support,inst1438⟩ :=
    InitializedCacheDynamicSliceAllocationEntry.initialized_dynamic_slice_allocation_entry ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic (a : Nat) (small : a < 100) : InitializedCacheDynamicSliceAllocationEntry.live a :=
    InitializedCacheDynamicSliceAllocationEntry.live_grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  have startNote : notes.privates.owners 2674420 = some ⟨4852,chars!"handle",.handle 18170⟩ := by
    change (PrivateSeed.notes.owners 2674420).map
      (fun note => {note with role := note.role.subst LoopVariables.oracleVariables}) = _
    rw [DynamicSliceStartSeed.initial_note]
    rfl
  have budget : s1438.next+64 ≤ 2^64 := by
    have fresh := h1438.heap.fresh 0
    change Plan1362.Block75.output.next = s1438.next at fresh
    rw [← fresh]
    decide +kernel
  obtain ⟨result,run111,post,retained,inst1549⟩ := allocation_to_dynamic_call notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    NativeSeed.boundary InitializedCacheSlice.objects InitializedCacheSlice.handles InitializedCacheSlice.nodes [] InitializedCache.hostRelation
    InitializedCacheDynamicSliceAllocationEntry.live (fun _ => False) [] [] input.trace input.trace s1438 inst1438 h1438 inventory1438
    budget
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (fun impossible => impossible) startNote (InitializedCacheConcatEntry.constructor_selected ic is control fnRole thisRole saved caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,?_,inst1549⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run1438; cases run1438
    | some start =>
      simp only [boot,Option.bind_some] at run1438 ⊢
      exact runC_join P.F (m:=32743293) (n:=111) run1438 run111
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheDynamicCall
