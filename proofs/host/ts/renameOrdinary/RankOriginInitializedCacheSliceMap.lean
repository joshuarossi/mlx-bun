import host.ts.renameOrdinary.RankOriginInitializedCacheSliceCall
import host.ts.renameOrdinary.RankOriginInitialStreamSeed
import host.load.RuntimeOracleSliceMapEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheSliceMap
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedOracleConvolutionBatch
open InitializedCacheWeightRank (identity_budget)

def live17 := InitializedCacheSliceCall.live17
def live18 := mapEntryLive live17

theorem live17_grow (a : Nat) (alive : InitialRetained.live a) : live17 a := InitializedCacheSliceCall.live17_grow a alive

theorem live18_grow (a : Nat) (alive : InitialRetained.live a) : live18 a := by
  have base := live17_grow a alive
  unfold live18 mapEntryLive
  repeat first | exact base | apply Or.inl

theorem native_frame : P.RestStream.micro0.micro7.s79.ffi = P.RestStream.micro0.micro7.s36.ffi := by host_kernel_rfl

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (mapEntryNotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_slice_map (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742634 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' InitializedCacheConcat.roles NativeSeed.boundary
          InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
        identity live18 (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro7.s79 result ∧
      RetainedInventory (mapEntryNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity live18 P.RestStream.micro0.micro7.s79 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes
        InitializedCacheConcat.roles InitializedCacheConcat.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes P.RestStream.micro0.micro7.s79.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) (numberServer (P.RestStream.micro0.micro7.S79.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s736,run736,h736,inventory736,policy,support,inst736⟩ :=
    InitializedCacheSliceCall.initialized_slice_call ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic (a : Nat) (small : a < 100) : live17 a :=
    live17_grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  obtain ⟨result,run43,h779,inventory779,inst779⟩ := slice_call_to_map notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
    live17 (fun _ => False) [] [] input.trace input.trace s736 inst736 h736 inventory736
    (identity_budget h736 (by decide +kernel))
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (InitializedCacheWeightTail.constructor_selected ic is control fnRole thisRole saved caller)
    (InitialStreamSeed.entry_selected ic is control fnRole thisRole saved caller) (by trivial)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,h779,inventory779,policy,?_,inst779⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run736; cases run736
    | some start =>
      simp only [boot,Option.bind_some] at run736 ⊢
      exact runC_join P.F (m:=32742591) (n:=43) run736 run43
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheSliceMap
