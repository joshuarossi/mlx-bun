import host.ts.renameOrdinary.RankOriginInitializedCacheShapeRankEntry
import host.load.RuntimeNamespacedDecodeShapePointerEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheShapePointerEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedOracleConvolutionBatch NamespacedDecode
open InitializedCacheWeightRank (identity_budget)

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``NamespacedDecode.rank_to_shape_call
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

noncomputable def inputNotes := InitializedCacheShapeRankEntry.resultNotes
noncomputable def inputStack (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  (inputNotes notes caller).runtime.stack
noncomputable def frame (notes : RetainedNotes) (caller : List Annotated.Tree) (index : Nat) :=
  (inputStack notes caller).getD index (.node "" [])
noncomputable def continuation (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  (inputStack notes caller).drop 5
noncomputable def functionRole : Annotated.Value := .obj Meta1285.address
noncomputable def receiverRole : Annotated.Value :=
  match Meta1285.sourceThis with | .obj a => .obj a | _ => .undef
noncomputable def numberFunctionRole : Annotated.Value := .obj Plan1286.Block0.sourceFn
noncomputable def numberReceiverRole : Annotated.Value :=
  match Plan1286.Block0.sourceReceiver with | .obj a => .obj a | _ => .undef
noncomputable def resultNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  connectedNotes (inputNotes notes caller) (continuation notes caller)
noncomputable def live := connectedLive InitializedCacheShapeRankEntry.live

theorem live_grow (a : Nat) (alive : InitialRetained.live a) : live a := by
  unfold live connectedLive Plan1286.Block26.endLive
  apply CellsLive.grow
  apply ClosureLive.grow
  exact InitializedCacheShapeRankEntry.live_grow a alive

theorem control_shape (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.control =
      callNote functionRole receiverRole [.handle Meta1285.handle] := by host_kernel_rfl
theorem stack_shape (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.stack =
      argumentFrameNote false 0 numberFunctionRole numberReceiverRole [] [] Plan1286.Block0.sourceArgEnv ::
      frame notes caller 1::frame notes caller 2::frame notes caller 3::frame notes caller 4::
      continuation notes caller := by host_kernel_rfl
theorem receiver_entry (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.cells.cells Plan1286.Block24.sourceAddress =
      some (.obj Plan1286.Block26.sourceOwner) := by host_kernel_rfl
theorem private_entry (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).privates.owners Plan1286.Block26.sourceOwner =
      some ⟨Plan1286.Block26.sourceBrand,Plan1286.Block26.sourceHandleName,.handle Meta1285.handle⟩ := by
  host_kernel_rfl
theorem native_frame : Plan1286.Block43.output.ffi.mlx = Plan1220.Block64.output.ffi.mlx := by
  host_kernel_rfl
theorem source_endpoint : Plan1286.Block43.output = Region1286.s44 := by host_kernel_rfl
theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (resultNotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_shape_pointer_entry (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32743185 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          InitializedCacheSlice.roles NativeSeed.boundary InitializedCacheSlice.objects InitializedCacheSlice.handles InitializedCacheSlice.nodes [] InitializedCache.hostRelation)
        identity live (fun _ => False) [] [] input.trace input.trace Plan1286.Block43.output result ∧
      RetainedInventory (resultNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity live Plan1286.Block43.output result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheSlice.handles InitializedCacheSlice.nodes
        InitializedCacheSlice.roles InitializedCacheSlice.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheSlice.handles InitializedCacheSlice.nodes Plan1286.Block43.output.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) Plan1286.Block43.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1285,run1285,h1285,inventory1285,policy,support,inst1285⟩ :=
    InitializedCacheShapeRankEntry.initialized_shape_rank_entry ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic (a : Nat) (small : a < 100) : InitializedCacheShapeRankEntry.live a :=
    InitializedCacheShapeRankEntry.live_grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  have owned : InitializedCacheSlice.handles Meta1285.handle := by
    exact InitializedCacheSlice.output_owned
  have budget : s1285.next+16 ≤ 2^64 := by
    have room := identity_budget h1285 (by decide +kernel)
    omega
  obtain ⟨result,run45,post,retained,inst1330⟩ := rank_to_shape_call
    (inputNotes notes caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    InitializedCacheSlice.roles NativeSeed.boundary InitializedCacheSlice.objects InitializedCacheSlice.handles InitializedCacheSlice.nodes [] InitializedCache.hostRelation
    InitializedCacheShapeRankEntry.live (fun _ => False) [] [] input.trace input.trace s1285 inst1285 h1285 inventory1285
    functionRole receiverRole (control_shape notes caller) numberFunctionRole numberReceiverRole
    (frame notes caller 1) (frame notes caller 2) (frame notes caller 3) (frame notes caller 4)
    (continuation notes caller) (stack_shape notes caller) (receiver_entry notes caller) (private_entry notes caller)
    budget (intrinsic _ (by decide +kernel)) rfl
    (fun impossible => impossible) owned
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,?_,inst1330⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run1285; cases run1285
    | some start =>
      simp only [boot,Option.bind_some] at run1285 ⊢
      exact runC_join P.F (m:=32743140) (n:=45) run1285 run45
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheShapePointerEntry
