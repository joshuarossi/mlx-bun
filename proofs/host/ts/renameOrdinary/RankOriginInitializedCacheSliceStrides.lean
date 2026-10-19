import host.ts.renameOrdinary.RankOriginInitializedCacheSliceMap
import host.load.RuntimeOracleSliceStridesE

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheSliceStrides
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedOracleConvolutionBatch
open InitializedCacheWeightRank (identity_budget)

def live18 := InitializedCacheSliceMap.live18
def live19 := stridesALive live18
def live20 := stridesBLive live19
def live21 := stridesCLive live20
def live22 := stridesDLive live21
def live23 := stridesELive live22

theorem live18_grow (a : Nat) (alive : InitialRetained.live a) : live18 a := InitializedCacheSliceMap.live18_grow a alive
theorem live19_grow (a : Nat) (alive : InitialRetained.live a) : live19 a := by
  have base := live18_grow a alive
  unfold live19 stridesALive
  repeat first | exact base | apply Or.inl
theorem live20_grow (a : Nat) (alive : InitialRetained.live a) : live20 a := by
  have base := live19_grow a alive
  unfold live20 stridesBLive
  repeat first | exact base | apply Or.inl
theorem live21_grow (a : Nat) (alive : InitialRetained.live a) : live21 a := by
  have base := live20_grow a alive
  unfold live21 stridesCLive
  repeat first | exact base | apply Or.inl
theorem live22_grow (a : Nat) (alive : InitialRetained.live a) : live22 a := by
  have base := live21_grow a alive
  unfold live22 stridesDLive
  repeat first | exact base | apply Or.inl
theorem live23_grow (a : Nat) (alive : InitialRetained.live a) : live23 a := by
  have base := live22_grow a alive
  unfold live23 stridesELive
  repeat first | exact base | apply Or.inl

theorem native_frame : P.RestStream.micro0.micro9.s36.ffi = P.RestStream.micro0.micro7.s79.ffi := by host_kernel_rfl

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (stridesENotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_slice_strides (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742791 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' InitializedCacheConcat.roles NativeSeed.boundary
          InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
        identity live23 (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro9.s36 result ∧
      RetainedInventory (stridesENotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity live23 P.RestStream.micro0.micro9.s36 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes
        InitializedCacheConcat.roles InitializedCacheConcat.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes P.RestStream.micro0.micro9.s36.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) (numberServer (P.RestStream.micro0.micro9.S36.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s779,run779,h779,inventory779,policy,support,inst779⟩ :=
    InitializedCacheSliceMap.initialized_slice_map ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic {live : Nat → Prop} (grow : ∀ a, InitialRetained.live a → live a) (a : Nat) (small : a < 100) : live a :=
    grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  obtain ⟨s809,run30,h809,inventory809,inst809⟩ := slice_strides_a notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
    live18 (fun _ => False) [] [] input.trace input.trace s779 inst779 h779 inventory779
    (identity_budget h779 (by decide +kernel))
    (intrinsic live18_grow _ (by decide +kernel)) rfl (intrinsic live18_grow _ (by decide +kernel)) rfl
    (intrinsic live18_grow _ (by decide +kernel)) rfl (intrinsic live18_grow _ (by decide +kernel)) rfl
    (intrinsic live18_grow _ (by decide +kernel)) rfl (intrinsic live18_grow _ (by decide +kernel)) rfl 
  obtain ⟨s838,run29,h838,inventory838,inst838⟩ := slice_strides_b notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
    live19 (fun _ => False) [] [] input.trace input.trace s809 inst809 h809 inventory809
    (identity_budget h809 (by decide +kernel))
    (intrinsic live19_grow _ (by decide +kernel)) rfl (intrinsic live19_grow _ (by decide +kernel)) rfl
    (intrinsic live19_grow _ (by decide +kernel)) rfl (intrinsic live19_grow _ (by decide +kernel)) rfl
    (intrinsic live19_grow _ (by decide +kernel)) rfl (intrinsic live19_grow _ (by decide +kernel)) rfl (by trivial) 
  obtain ⟨s874,run36,h874,inventory874,inst874⟩ := slice_strides_c notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
    live20 (fun _ => False) [] [] input.trace input.trace s838 inst838 h838 inventory838
    (identity_budget h838 (by decide +kernel))
    (intrinsic live20_grow _ (by decide +kernel)) rfl (intrinsic live20_grow _ (by decide +kernel)) rfl
    (intrinsic live20_grow _ (by decide +kernel)) rfl (intrinsic live20_grow _ (by decide +kernel)) rfl
    (intrinsic live20_grow _ (by decide +kernel)) rfl (intrinsic live20_grow _ (by decide +kernel)) rfl (by trivial) (by trivial) 
  obtain ⟨s910,run36b,h910,inventory910,inst910⟩ := slice_strides_d notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
    live21 (fun _ => False) [] [] input.trace input.trace s874 inst874 h874 inventory874
    (identity_budget h874 (by decide +kernel))
    (intrinsic live21_grow _ (by decide +kernel)) rfl (intrinsic live21_grow _ (by decide +kernel)) rfl
    (intrinsic live21_grow _ (by decide +kernel)) rfl (intrinsic live21_grow _ (by decide +kernel)) rfl
    (intrinsic live21_grow _ (by decide +kernel)) rfl (intrinsic live21_grow _ (by decide +kernel)) rfl (by trivial) (by trivial) 
  obtain ⟨s936,run26,h936,inventory936,inst936⟩ := slice_strides_e notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
    live22 (fun _ => False) [] [] input.trace input.trace s910 inst910 h910 inventory910
    (identity_budget h910 (by decide +kernel))
    (intrinsic live22_grow _ (by decide +kernel)) rfl (intrinsic live22_grow _ (by decide +kernel)) rfl
    (intrinsic live22_grow _ (by decide +kernel)) rfl (intrinsic live22_grow _ (by decide +kernel)) rfl
    (intrinsic live22_grow _ (by decide +kernel)) rfl (intrinsic live22_grow _ (by decide +kernel)) rfl (by trivial) 
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s936,?_,h936,inventory936,policy,?_,inst936⟩
  · have run59 := runC_join P.F (m:=30) (n:=29) run30 run29
    have run95 := runC_join P.F (m:=59) (n:=36) run59 run36
    have run131 := runC_join P.F (m:=95) (n:=36) run95 run36b
    have run157 := runC_join P.F (m:=131) (n:=26) run131 run26
    cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run779; cases run779
    | some start =>
      simp only [boot,Option.bind_some] at run779 ⊢
      exact runC_join P.F (m:=32742634) (n:=157) run779 run157
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheSliceStrides
