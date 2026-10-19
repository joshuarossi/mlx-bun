import host.ts.renameOrdinary.RankOriginInitializedCacheSliceStrides
import host.load.RuntimeOracleSliceOutputA

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheSliceOutput
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedOracleConvolutionBatch
open InitializedCacheWeightRank (identity_budget)

def live23 := InitializedCacheSliceStrides.live23
def live24 := stridesBufferLive live23
def live25 := outputALive live24

theorem live23_grow (a : Nat) (alive : InitialRetained.live a) : live23 a := InitializedCacheSliceStrides.live23_grow a alive
theorem live24_grow (a : Nat) (alive : InitialRetained.live a) : live24 a := by
  have base := live23_grow a alive
  unfold live24 stridesBufferLive
  repeat first | exact base | apply Or.inl
theorem live25_grow (a : Nat) (alive : InitialRetained.live a) : live25 a := by
  have base := live24_grow a alive
  unfold live25 outputALive
  repeat first | exact base | apply Or.inl

theorem native_frame : P.RestStream.micro0.micro9.s80.ffi = P.RestStream.micro0.micro9.s36.ffi := by host_kernel_rfl

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (outputANotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_slice_output (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742835 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' InitializedCacheConcat.roles NativeSeed.boundary
          InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
        identity live25 (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro9.s80 result ∧
      RetainedInventory (outputANotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity live25 P.RestStream.micro0.micro9.s80 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes
        InitializedCacheConcat.roles InitializedCacheConcat.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes P.RestStream.micro0.micro9.s80.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) (numberServer (P.RestStream.micro0.micro9.S80.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s936,run936,h936,inventory936,policy,support,inst936⟩ :=
    InitializedCacheSliceStrides.initialized_slice_strides ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic {live : Nat → Prop} (grow : ∀ a, InitialRetained.live a → live a) (a : Nat) (small : a < 100) : live a :=
    grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  obtain ⟨s937,run1,h937,inventory937,inst937⟩ := slice_strides_buffer notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
    live23 (fun _ => False) [] [] input.trace input.trace s936 inst936 h936 inventory936
    (identity_budget h936 (by decide +kernel))
    (intrinsic live23_grow _ (by decide +kernel)) rfl (intrinsic live23_grow _ (by decide +kernel)) rfl
    (intrinsic live23_grow _ (by decide +kernel)) rfl (intrinsic live23_grow _ (by decide +kernel)) rfl
    (intrinsic live23_grow _ (by decide +kernel)) rfl (intrinsic live23_grow _ (by decide +kernel)) rfl
    (InitializedCacheWeightTail.constructor_selected ic is control fnRole thisRole saved caller)
  obtain ⟨s980,run43,h980,inventory980,inst980⟩ := slice_output_a notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
    live24 (fun _ => False) [] [] input.trace input.trace s937 inst937 h937 inventory937
    (identity_budget h937 (by decide +kernel))
    (intrinsic live24_grow _ (by decide +kernel)) rfl (intrinsic live24_grow _ (by decide +kernel)) rfl
    (intrinsic live24_grow _ (by decide +kernel)) rfl (intrinsic live24_grow _ (by decide +kernel)) rfl
    (intrinsic live24_grow _ (by decide +kernel)) rfl (intrinsic live24_grow _ (by decide +kernel)) rfl
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s980,?_,h980,inventory980,policy,?_,inst980⟩
  · have run44 := runC_join P.F (m:=1) (n:=43) run1 run43
    cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run936; cases run936
    | some start =>
      simp only [boot,Option.bind_some] at run936 ⊢
      exact runC_join P.F (m:=32742791) (n:=44) run936 run44
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheSliceOutput
