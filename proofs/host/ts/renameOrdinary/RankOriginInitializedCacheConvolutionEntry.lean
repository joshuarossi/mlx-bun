import host.ts.renameOrdinary.RankOriginInitializedCacheDynamicFree
import host.load.RuntimeNamespacedDecodeConvolutionEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConvolutionEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedOracleConvolutionBatch NamespacedDecode
open InitializedCacheWeightRank (identity_budget)

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``NamespacedDecode.convolution_to_allocation
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
noncomputable def live := connectedLive InitializedCacheDynamicFree.live

theorem free_live_grow (a : Nat) (alive : InitialRetained.live a) : InitializedCacheDynamicFree.live a := by
  unfold InitializedCacheDynamicFree.live InitializedCacheDynamicSliceCleanup.live InitializedCacheDynamicSliceCleanup.connectedLive
  apply CellsLive.grow
  apply ClosureLive.grow
  apply CellsLive.grow
  apply ClosureLive.grow
  apply Or.inl
  apply Or.inl
  apply Or.inl
  apply Or.inl
  apply Or.inl
  exact InitializedCacheDynamicCall.live_grow a alive

theorem live_grow (a : Nat) (alive : InitialRetained.live a) : live a := by
  unfold live connectedLive
  apply CellsLive.grow
  apply ClosureLive.grow
  apply Or.inl
  apply CellsLive.grow
  apply ClosureLive.grow
  exact free_live_grow a alive

theorem native_frame : Plan1678.Block90.output.ffi.mlx = Free1677.output.ffi.mlx := by
  host_kernel_rfl
theorem source_endpoint : Plan1678.Block90.output = Region1678.s91 := by host_kernel_rfl
theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (resultNotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_convolution_entry (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743624 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          InitializedCacheDynamicFree.roles NativeSeed.boundary InitializedCacheDynamicFree.objects InitializedCacheDynamicFree.handles InitializedCacheDynamicFree.nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace Plan1678.Block90.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live Plan1678.Block90.output result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheDynamicFree.handles InitializedCacheDynamicFree.nodes
        InitializedCacheDynamicFree.roles InitializedCacheDynamicFree.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheDynamicFree.handles InitializedCacheDynamicFree.nodes Plan1678.Block90.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) Plan1678.Block90.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1678,run1678,h1678,inventory1678,policy,support,inst1678⟩ :=
    InitializedCacheDynamicFree.initialized_dynamic_free ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic (a : Nat) (small : a < 100) : InitializedCacheDynamicFree.live a :=
    free_live_grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  have streamAddress : Plan1678.Block47.address = Parameter45.address := by host_kernel_rfl
  have streamEntry : notes.runtime.cells.cells Plan1678.Block47.address = some (.handle 2) := by
    rw [streamAddress]
    exact (InitializedCache.entry_seeds ic is control fnRole thisRole saved caller).streamEntry
  have budget : s1678.next+64 ≤ 2^64 := by
    have fresh := h1678.heap.fresh 0
    change Free1677.output.next = s1678.next at fresh
    rw [← fresh]
    decide +kernel
  obtain ⟨result,run91,post,retained,inst1769⟩ := convolution_to_allocation notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheDynamicFree.roles NativeSeed.boundary InitializedCacheDynamicFree.objects InitializedCacheDynamicFree.handles InitializedCacheDynamicFree.nodes [] InitializedCache.hostRelation)
    InitializedCacheDynamicFree.live (fun _ => False) [] [] input.trace input.trace s1678 inst1678 h1678 inventory1678
    budget
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    streamEntry
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,?_,inst1769⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run1678; cases run1678
    | some start =>
      simp only [boot,Option.bind_some] at run1678 ⊢
      exact runC_join P.F (m:=32743533) (n:=91) run1678 run91
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConvolutionEntry
