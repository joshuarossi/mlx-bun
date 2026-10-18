import host.ts.renameOrdinary.RankOriginInitializedCacheConvolutionShape
import host.load.RuntimeOracleConvolutionSliceCallEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheSliceCall
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedOracleConvolutionBatch
open InitializedCacheWeightRank (identity_budget)
open InitializedCacheConvolutionRank (owned_input)

def live14 := InitializedCacheConvolutionShape.live14
def live15 := shapeBufferLive live14
def live16 := shapeSpreadEntryLive live15
def live17 := sliceCallLive live16

theorem live14_grow (a : Nat) (alive : InitialRetained.live a) : live14 a := InitializedCacheConvolutionShape.live14_grow a alive
theorem live15_grow (a : Nat) (alive : InitialRetained.live a) : live15 a := by
  have base := live14_grow a alive
  unfold live15 shapeBufferLive
  repeat first | exact base | apply Or.inl
theorem live16_grow (a : Nat) (alive : InitialRetained.live a) : live16 a := by
  have base := live15_grow a alive
  unfold live16 shapeSpreadEntryLive
  repeat first | exact base | apply Or.inl
theorem live17_grow (a : Nat) (alive : InitialRetained.live a) : live17 a := by
  have base := live16_grow a alive
  unfold live17 sliceCallLive
  repeat first | exact base | apply Or.inl

theorem native_frame : P.RestStream.micro0.micro7.s36.ffi = P.RestStream.micro0.micro6.s69.ffi := by host_kernel_rfl

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (sliceCallNotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_slice_call (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742591 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' InitializedCacheConcat.roles NativeSeed.boundary
          InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
        identity live17 (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro7.s36 result ∧
      RetainedInventory (sliceCallNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity live17 P.RestStream.micro0.micro7.s36 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes
        InitializedCacheConcat.roles InitializedCacheConcat.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes P.RestStream.micro0.micro7.s36.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) (numberServer (P.RestStream.micro0.micro7.S36.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s669,run669,h669,inventory669,policy,support,inst669⟩ :=
    InitializedCacheConvolutionShape.initialized_convolution_shape ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic {live : Nat → Prop} (grow : ∀ a, InitialRetained.live a → live a) (a : Nat) (small : a < 100) : live a :=
    grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  obtain ⟨s691,run22,h691,inventory691,inst691⟩ := shape_to_slice_buffer notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation
    live14 (fun _ => False) [] [] input.trace input.trace s669 inst669 h669 inventory669
    (identity_budget h669 (by decide +kernel))
    (intrinsic live14_grow _ (by decide +kernel)) rfl (intrinsic live14_grow _ (by decide +kernel)) rfl
    (intrinsic live14_grow _ (by decide +kernel)) rfl (intrinsic live14_grow _ (by decide +kernel)) rfl
    (intrinsic live14_grow _ (by decide +kernel)) rfl (intrinsic live14_grow _ (by decide +kernel)) rfl
    owned_input rfl (InitializedCacheWeightTail.constructor_selected ic is control fnRole thisRole saved caller)
  obtain ⟨s694,run3,h694,inventory694,inst694⟩ := slice_buffer_to_spread notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation
    live15 (fun _ => False) [] [] input.trace input.trace s691 inst691 h691 inventory691
    (identity_budget h691 (by decide +kernel))
    (intrinsic live15_grow _ (by decide +kernel)) rfl (intrinsic live15_grow _ (by decide +kernel)) rfl
    (intrinsic live15_grow _ (by decide +kernel)) rfl (intrinsic live15_grow _ (by decide +kernel)) rfl
    (intrinsic live15_grow _ (by decide +kernel)) rfl (intrinsic live15_grow _ (by decide +kernel)) rfl
    owned_input rfl (InitializedCacheWeightTail.constructor_selected ic is control fnRole thisRole saved caller)
  obtain ⟨result,run42,h736,inventory736,inst736⟩ := slice_spread_to_call notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation
    live16 (fun _ => False) [] [] input.trace input.trace s694 inst694 h694 inventory694
    (identity_budget h694 (by decide +kernel))
    (intrinsic live16_grow _ (by decide +kernel)) rfl (intrinsic live16_grow _ (by decide +kernel)) rfl
    (intrinsic live16_grow _ (by decide +kernel)) rfl (intrinsic live16_grow _ (by decide +kernel)) rfl
    (intrinsic live16_grow _ (by decide +kernel)) rfl (intrinsic live16_grow _ (by decide +kernel)) rfl
    owned_input rfl (InitializedCacheWeightTail.constructor_selected ic is control fnRole thisRole saved caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,h736,inventory736,policy,?_,inst736⟩
  · have run67 := runC_join P.F (m:=25) (n:=42) (runC_join P.F (m:=22) (n:=3) run22 run3) run42
    cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run669; cases run669
    | some start =>
      simp only [boot,Option.bind_some] at run669 ⊢
      exact runC_join P.F (m:=32742524) (n:=67) run669 run67
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheSliceCall
