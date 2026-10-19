import host.ts.renameOrdinary.RankOriginInitializedCacheSlice
import host.load.RuntimeNamespacedDecodeShapeRankEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheShapeRankEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedOracleConvolutionBatch NamespacedDecode
open InitializedCacheWeightRank (identity_budget)

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``NamespacedDecode.slice_to_shape_rank_call
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

noncomputable def inputNotes := InitializedCacheSlice.normalizedNotes
noncomputable def inputStack (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  (inputNotes notes caller).runtime.stack
noncomputable def frame (notes : RetainedNotes) (caller : List Annotated.Tree) (index : Nat) :=
  (inputStack notes caller).getD index (.node "" [])
noncomputable def continuation (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  (inputStack notes caller).drop 8
noncomputable def functionRole : Annotated.Value := .obj SliceOutput.Block944.sourceAddress
noncomputable def receiverRole := callReceiverNote SliceOutput.Block944.sourceMode Annotated.Value.undef
noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  connectedNotes (inputNotes notes caller) (continuation notes caller)
noncomputable def live := connectedLive InitializedCacheSlice.live28

theorem live_grow (a : Nat) (alive : InitialRetained.live a) : live a := by
  have base := InitializedCacheSliceReady.live28_grow a alive
  unfold live connectedLive Plan1220.Block47.endLive
  apply CellsLive.grow
  apply ClosureLive.grow
  apply CellsLive.grow
  apply ClosureLive.grow
  apply CellsLive.grow
  apply ClosureLive.grow
  apply Or.inl
  unfold Plan1200.Block1.endLive
  apply CellsLive.grow
  apply ClosureLive.grow
  apply CellsLive.grow
  apply ClosureLive.grow
  apply CellsLive.grow
  apply ClosureLive.grow
  unfold MlxConstruction.ParametersLive ConstructorBodyLive
  apply CellsLive.grow
  apply Or.inl
  unfold MlxConstruction.FieldsLive
  apply Or.inl
  unfold BaseClassLive
  exact Or.inl (Or.inl base)

theorem stack_shape (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.stack =
      frame notes caller 0::frame notes caller 1::frame notes caller 2::frame notes caller 3::
      frame notes caller 4::frame notes caller 5::
      argumentFrameNote false Plan1100.Block21.sourceKind functionRole receiverRole []
        Plan1100.Block21.sourceRest Plan1100.Block21.sourceEnv::
      frame notes caller 7::continuation notes caller := by host_kernel_rfl

theorem pointer_entry (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.cells.cells AfterSlice.Block1098.address =
      some (.ptr (.js 3126780) 0) := by host_kernel_rfl

theorem native_frame : Plan1220.Block64.output.ffi.mlx = P.RestStream.micro0.micro10.s87.ffi.mlx := by
  host_kernel_rfl

theorem source_endpoint : Plan1220.Block64.output = Region1220.s65 := by
  host_kernel_rfl

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (resultNotes notes caller).publicFields = notes.publicFields := rfl

theorem offsets (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree)
    (owner : Nat) (selected : owner ∈ CacheEntry.cacheOwners) :
    (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
      control fnRole thisRole saved caller) caller).publicFields.fields owner chars!"offset" =
        some (.literal (CacheEntry.offsetMeaning LoopVariables.cacheIndex owner)) :=
  InitializedCache.entry_offset_selected ic is owner selected

theorem initialized_shape_rank_entry (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743140 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          InitializedCacheSlice.roles NativeSeed.boundary InitializedCacheSlice.objects InitializedCacheSlice.handles InitializedCacheSlice.nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace Plan1220.Block64.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live Plan1220.Block64.output result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheSlice.handles InitializedCacheSlice.nodes
        InitializedCacheSlice.roles InitializedCacheSlice.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheSlice.handles InitializedCacheSlice.nodes Plan1220.Block64.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) Plan1220.Block64.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1087,run1087,h1087,inventory1087,policy,support,inst1087⟩ :=
    InitializedCacheSlice.initialized_slice ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic (a : Nat) (small : a < 100) : InitializedCacheSlice.live28 a :=
    InitializedCacheSliceReady.live28_grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  have outSlot : Slice1086.Normalized.out = 3126780 := by host_kernel_rfl
  have inventory : RetainedInventory ((inputNotes notes caller).nativeHandleResult 3126780 29373)
      (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      identity InitializedCacheSlice.live28 P.RestStream.micro0.micro10.s87 s1087 := by
    simpa only [notes,inputNotes,InitializedCacheSlice.resultNotes,InitializedCacheSlice.output_handle,outSlot] using inventory1087
  obtain ⟨result,run198,post,retained,inst1285⟩ := slice_to_shape_rank_call
    (inputNotes notes caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    InitializedCacheSlice.roles NativeSeed.boundary InitializedCacheSlice.objects InitializedCacheSlice.handles InitializedCacheSlice.nodes [] InitializedCache.hostRelation
    InitializedCacheSlice.live28 (fun _ => False) [] [] input.trace input.trace s1087 inst1087 h1087 inventory
    (frame notes caller 0) (frame notes caller 1) (frame notes caller 2) (frame notes caller 3)
    (frame notes caller 4) (frame notes caller 5) (frame notes caller 7) (continuation notes caller)
    functionRole receiverRole (stack_shape notes caller) (pointer_entry notes caller)
    (identity_budget h1087 (by decide +kernel))
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (fun impossible => impossible) InitializedCacheSlice.output_owned
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,?_,inst1285⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run1087; cases run1087
    | some start =>
      simp only [boot,Option.bind_some] at run1087 ⊢
      exact runC_join P.F (m:=32742942) (n:=198) run1087 run198
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheShapeRankEntry
