import host.ts.renameOrdinary.RankOriginInitializedCacheConvolutionEntry
import host.ts.renameOrdinary.RankOriginConvolutionWeightSeed
import host.load.RuntimeNamespacedDecodeConvolutionCallEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConvolutionCall
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedOracleConvolutionBatch NamespacedDecode
open InitializedCacheWeightRank (identity_budget)

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``NamespacedDecode.allocation_to_convolution_call
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
noncomputable def live := connectedLive InitializedCacheConvolutionEntry.live

theorem native_frame : Plan1770.Block85.output.ffi.mlx = Plan1678.Block90.output.ffi.mlx := by
  host_kernel_rfl
theorem source_endpoint : Plan1770.Block85.output = Region1770.s86 := by host_kernel_rfl
theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (resultNotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_convolution_call (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743711 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          InitializedCacheDynamicFree.roles NativeSeed.boundary InitializedCacheDynamicFree.objects InitializedCacheDynamicFree.handles InitializedCacheDynamicFree.nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace Plan1770.Block85.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live Plan1770.Block85.output result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheDynamicFree.handles InitializedCacheDynamicFree.nodes
        InitializedCacheDynamicFree.roles InitializedCacheDynamicFree.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheDynamicFree.handles InitializedCacheDynamicFree.nodes Plan1770.Block85.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) Plan1770.Block85.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1769,run1769,h1769,inventory1769,policy,support,inst1769⟩ :=
    InitializedCacheConvolutionEntry.initialized_convolution_entry ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic (a : Nat) (small : a < 100) : InitializedCacheConvolutionEntry.live a :=
    InitializedCacheConvolutionEntry.live_grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  have weightNote : notes.privates.owners 329207 = some ⟨4852,chars!"handle",.handle 1365⟩ := by
    change (PrivateSeed.notes.owners 329207).map
      (fun note => {note with role := note.role.subst LoopVariables.oracleVariables}) = _
    rw [ConvolutionWeightSeed.initial_note]
    rfl
  have budget : s1769.next+64 ≤ 2^64 := by
    have fresh := h1769.heap.fresh 0
    change Plan1678.Block90.output.next = s1769.next at fresh
    rw [← fresh]
    decide +kernel
  obtain ⟨result,run87,post,retained,inst1856⟩ := allocation_to_convolution_call notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    NativeSeed.boundary InitializedCacheDynamicFree.objects InitializedCacheDynamicFree.handles InitializedCacheDynamicFree.nodes [] InitializedCache.hostRelation
    InitializedCacheConvolutionEntry.live (fun _ => False) [] [] input.trace input.trace s1769 inst1769 h1769 inventory1769
    budget
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (fun impossible => impossible) weightNote (InitializedCacheConcatEntry.constructor_selected ic is control fnRole thisRole saved caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,?_,inst1856⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run1769; cases run1769
    | some start =>
      simp only [boot,Option.bind_some] at run1769 ⊢
      exact runC_join P.F (m:=32743624) (n:=87) run1769 run87
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConvolutionCall
