import host.ts.renameOrdinary.RankOriginInitializedCacheWeightTail
import host.load.RuntimeOracleConvolutionRankQuery

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConvolutionRank
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedVectorOracleBatch RetainedOracleConcatReturnBatch RetainedOracleConvolutionBatch
open InitializedCacheWeightRank (identity_budget)

def live10 := InitializedCacheWeightTail.live10
def live11 := rankEntryLive live10
def live12 := rankLive live11

theorem live10_grow (a : Nat) (alive : InitialRetained.live a) : live10 a := InitializedCacheWeightTail.live10_grow a alive
theorem live11_grow (a : Nat) (alive : InitialRetained.live a) : live11 a := by
  have base := live10_grow a alive
  unfold live11 rankEntryLive
  repeat first | exact base | apply Or.inl
theorem live12_grow (a : Nat) (alive : InitialRetained.live a) : live12 a := by
  have base := live11_grow a alive
  unfold live12 rankLive
  repeat first | exact base | apply Or.inl

theorem owned_input : InitializedCacheConcat.handles 29372 := Or.inl (by host_kernel_rfl)
theorem native_frame : P.RestStream.micro0.micro6.s24.ffi = P.RestStream.micro0.micro5.s70.ffi := by host_kernel_rfl

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (rankNotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_convolution_rank (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742479 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' InitializedCacheConcat.roles NativeSeed.boundary
          InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
        identity live12 (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro6.s24 result ∧
      RetainedInventory (rankNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity live12 P.RestStream.micro0.micro6.s24 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes
        InitializedCacheConcat.roles InitializedCacheConcat.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes P.RestStream.micro0.micro6.s24.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) (numberServer (P.RestStream.micro0.micro6.S24.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s570,run570,h570,inventory570,policy,support,inst570⟩ :=
    InitializedCacheWeightTail.initialized_weight_tail ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic {live : Nat → Prop} (grow : ∀ a, InitialRetained.live a → live a) (a : Nat) (small : a < 100) : live a :=
    grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  obtain ⟨s623,run53,h623,inventory623,inst623⟩ := tail_to_rank_entry notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity _
    live10 (fun _ => False) [] [] input.trace input.trace s570 inst570 h570 inventory570
    (identity_budget h570 (by decide +kernel))
    (intrinsic live10_grow _ (by decide +kernel)) rfl (intrinsic live10_grow _ (by decide +kernel)) rfl
    (intrinsic live10_grow _ (by decide +kernel)) rfl (intrinsic live10_grow _ (by decide +kernel)) rfl
  obtain ⟨result,run1,h624,inventory624,inst624⟩ := convolution_rank_query notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation
    live11 (fun _ => False) [] [] input.trace input.trace s623 inst623 h623 inventory623
    (fun impossible => impossible) owned_input
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,h624,inventory624,policy,?_,inst624⟩
  · have run54 := runC_join P.F (m:=53) (n:=1) run53 run1
    cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run570; cases run570
    | some start =>
      simp only [boot,Option.bind_some] at run570 ⊢
      exact runC_join P.F (m:=32742425) (n:=54) run570 run54
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConvolutionRank
