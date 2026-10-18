import host.ts.renameOrdinary.RankOriginInitializedCacheConvolutionRank
import host.load.RuntimeOracleConvolutionShapeQuery

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConvolutionShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedOracleConvolutionBatch
open InitializedCacheWeightRank (identity_budget)
open InitializedCacheConvolutionRank (owned_input)

def live12 := InitializedCacheConvolutionRank.live12
def live13 := shapeEntryLive live12
def live14 := shapeQueryLive live13

theorem live12_grow (a : Nat) (alive : InitialRetained.live a) : live12 a := InitializedCacheConvolutionRank.live12_grow a alive
theorem live13_grow (a : Nat) (alive : InitialRetained.live a) : live13 a := by
  have base := live12_grow a alive
  unfold live13 shapeEntryLive
  repeat first | exact base | apply Or.inl
theorem live14_grow (a : Nat) (alive : InitialRetained.live a) : live14 a := by
  have base := live13_grow a alive
  unfold live14 shapeQueryLive
  repeat first | exact base | apply Or.inl

theorem native_frame : P.RestStream.micro0.micro6.s69.ffi = P.RestStream.micro0.micro6.s24.ffi := by host_kernel_rfl

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (shapeQueryNotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_convolution_shape (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742524 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' InitializedCacheConcat.roles NativeSeed.boundary
          InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
        identity live14 (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro6.s69 result ∧
      RetainedInventory (shapeQueryNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity live14 P.RestStream.micro0.micro6.s69 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes
        InitializedCacheConcat.roles InitializedCacheConcat.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes P.RestStream.micro0.micro6.s69.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) (numberServer (P.RestStream.micro0.micro6.S69.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s624,run624,h624,inventory624,policy,support,inst624⟩ :=
    InitializedCacheConvolutionRank.initialized_convolution_rank ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic {live : Nat → Prop} (grow : ∀ a, InitialRetained.live a → live a) (a : Nat) (small : a < 100) : live a :=
    grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  obtain ⟨s668,run44,h668,inventory668,inst668⟩ := rank_to_shape_entry notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity _
    live12 (fun _ => False) [] [] input.trace input.trace s624 inst624 h624 inventory624
    (identity_budget h624 (by decide +kernel))
    (intrinsic live12_grow _ (by decide +kernel)) rfl (intrinsic live12_grow _ (by decide +kernel)) rfl
    (intrinsic live12_grow _ (by decide +kernel)) rfl (intrinsic live12_grow _ (by decide +kernel)) rfl
  obtain ⟨result,run1,h669,inventory669,inst669⟩ := convolution_shape_query notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation
    live13 (fun _ => False) [] [] input.trace input.trace s668 inst668 h668 inventory668
    (fun impossible => impossible) owned_input rfl
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,h669,inventory669,policy,?_,inst669⟩
  · have run45 := runC_join P.F (m:=44) (n:=1) run44 run1
    cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run624; cases run624
    | some start =>
      simp only [boot,Option.bind_some] at run624 ⊢
      exact runC_join P.F (m:=32742479) (n:=45) run624 run45
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConvolutionShape
