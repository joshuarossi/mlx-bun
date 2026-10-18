import host.ts.renameOrdinary.RankOriginInitializedCacheWeightRank
import host.load.RuntimeOracleWeightShapeQuery

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheWeightShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedVectorOracleBatch RetainedOracleConcatReturnBatch
open InitializedCacheWeightRank (identity_budget weight_note)

def live4 := InitializedCacheWeightRank.live4
def live5 := rankQueryLive live4
def live6 := shapeEntryLive live5
def live7 := shapeQueryLive live6

theorem live4_grow (a : Nat) (alive : InitialRetained.live a) : live4 a := by
  have base := InitializedCacheWeightRank.live3_grow a alive
  unfold live4 InitializedCacheWeightRank.live4 weightRankLive
  repeat first | exact base | apply Or.inl
theorem live5_grow (a : Nat) (alive : InitialRetained.live a) : live5 a := by
  have base := live4_grow a alive
  unfold live5 rankQueryLive
  repeat first | exact base | apply Or.inl
theorem live6_grow (a : Nat) (alive : InitialRetained.live a) : live6 a := by
  have base := live5_grow a alive
  unfold live6 shapeEntryLive
  repeat first | exact base | apply Or.inl
theorem live7_grow (a : Nat) (alive : InitialRetained.live a) : live7 a := by
  have base := live6_grow a alive
  unfold live7 shapeQueryLive
  repeat first | exact base | apply Or.inl

theorem owned_weight : InitializedCacheConcat.handles 1365 := Or.inr (Or.inr (by change 1365 < NativeSeed.native.next; decide +kernel))
theorem native_frame : P.RestStream.micro0.micro5.s30.ffi = P.RestStream.micro0.micro4.s84.ffi := by host_kernel_rfl

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (shapeQueryNotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_weight_shape (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742385 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' InitializedCacheConcat.roles NativeSeed.boundary
          InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
        identity live7 (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro5.s30 result ∧
      RetainedInventory (shapeQueryNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity live7 P.RestStream.micro0.micro5.s30 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes
        InitializedCacheConcat.roles InitializedCacheConcat.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes P.RestStream.micro0.micro5.s30.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) (numberServer (P.RestStream.micro0.micro5.S30.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s484,run484,h484,inventory484,policy,support,inst484⟩ :=
    InitializedCacheWeightRank.initialized_weight_rank ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic {live : Nat → Prop} (grow : ∀ a, InitialRetained.live a → live a) (a : Nat) (small : a < 100) : live a :=
    grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  obtain ⟨s485,run1,h485,inventory485,inst485⟩ := weight_rank_query notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation
    live4 (fun _ => False) [] [] input.trace input.trace s484 inst484 h484 inventory484
    (fun impossible => impossible) owned_weight
  obtain ⟨s529,run44,h529,inventory529,inst529⟩ := weight_rank_to_shape_entry notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity _
    live5 (fun _ => False) [] [] input.trace input.trace s485 inst485 h485 inventory485
    (identity_budget h485 (by decide +kernel))
    (intrinsic live5_grow _ (by decide +kernel)) rfl (intrinsic live5_grow _ (by decide +kernel)) rfl
    (intrinsic live5_grow _ (by decide +kernel)) rfl (intrinsic live5_grow _ (by decide +kernel)) rfl
    (weight_note ic is control fnRole thisRole saved caller)
  obtain ⟨result,runLast,h530,inventory530,inst530⟩ := weight_shape_query notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation
    live6 (fun _ => False) [] [] input.trace input.trace s529 inst529 h529 inventory529
    (fun impossible => impossible) owned_weight rfl
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,h530,inventory530,policy,?_,inst530⟩
  · have run46 := runC_join P.F (m:=45) (n:=1) (runC_join P.F (m:=1) (n:=44) run1 run44) runLast
    cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run484; cases run484
    | some start =>
      simp only [boot,Option.bind_some] at run484 ⊢
      exact runC_join P.F (m:=32742339) (n:=46) run484 run46
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheWeightShape
