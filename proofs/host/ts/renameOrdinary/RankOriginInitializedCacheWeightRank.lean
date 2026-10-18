import host.ts.renameOrdinary.RankOriginInitializedCacheWrapper
import host.ts.renameOrdinary.RankOriginConvolutionWeightSeed
import host.load.RuntimeOracleWeightRankEntryBatch

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheWeightRank
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedVectorOracleBatch RetainedOracleConcatReturnBatch

def live0 := wrapperLive (readyLive InitializedCache.finalLive)
def live1 := cleanupLive live0
def live2 := weightGuardLive live1
def live3 := weightGetterLive live2
def live4 := weightRankLive live3

theorem live0_grow (a : Nat) (alive : InitialRetained.live a) : live0 a := by
  have initial : InitializedCache.finalLive a := by
    rw [InitializedCacheConcatEntry.vector_live_eq]
    exact InitializedVectorPrelude.vector_live_grow a alive
  have base := InitializedCacheWrapper.ready_live_grow _ a initial
  unfold live0 wrapperLive
  repeat first | exact base | apply Or.inl
theorem live1_grow (a : Nat) (alive : InitialRetained.live a) : live1 a := by
  have base := live0_grow a alive
  unfold live1 cleanupLive
  repeat first | exact base | apply Or.inl
theorem live2_grow (a : Nat) (alive : InitialRetained.live a) : live2 a := by
  have base := live1_grow a alive
  unfold live2 weightGuardLive
  repeat first | exact base | apply Or.inl
theorem live3_grow (a : Nat) (alive : InitialRetained.live a) : live3 a := by
  have base := live2_grow a alive
  unfold live3 weightGetterLive
  repeat first | exact base | apply Or.inl

theorem identity_budget {NR FR live framed before after old old' source target}
    (h : Parametric.StateR (S:=LSt) NR FR identity live framed before after old old' source target)
    (small : source.next+32 ≤ 2^64) : target.next+32 ≤ 2^64 := by
  have counter := h.heap.fresh 0
  change source.next = target.next+0 at counter
  rw [Nat.add_zero] at counter
  rw [← counter]
  exact small

theorem native_frame : P.RestStream.micro0.micro4.s84.ffi = P.RestStream.micro0.micro4.s9.ffi := by host_kernel_rfl

theorem weight_note (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree) :
    (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller).privates.owners 329207 =
      some ⟨4852,chars!"handle",.handle 1365⟩ := by
  change (PrivateSeed.notes.mapRoles (Value.subst LoopVariables.oracleVariables)).owners 329207 = _
  simp only [PrivateNotes.mapRoles,ConvolutionWeightSeed.initial_note,Option.map_some]
  rfl

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (weightRankNotes notes caller).publicFields = notes.publicFields := rfl

theorem offsets (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree)
    (owner : Nat) (selected : owner ∈ CacheEntry.cacheOwners) :
    (weightRankNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
      control fnRole thisRole saved caller) caller).publicFields.fields owner chars!"offset" =
      some (.literal (CacheEntry.offsetMeaning LoopVariables.cacheIndex owner)) :=
  InitializedCache.entry_offset_selected ic is owner selected

/-- The original boot execution reaches the first convolution-weight rank
query. Every getter handle comes from the initialized owned-array inventory;
the intermediate constructor and cleanup states are reached conclusions. -/
theorem initialized_weight_rank (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742339 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' InitializedCacheConcat.roles NativeSeed.boundary
          InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
        identity live4 (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro4.s84 result ∧
      RetainedInventory (weightRankNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity live4 P.RestStream.micro0.micro4.s84 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes
        InitializedCacheConcat.roles InitializedCacheConcat.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes P.RestStream.micro0.micro4.s84.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) (numberServer (P.RestStream.micro0.micro4.S84.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s409,run409,h409,inventory409,policy,support,inst409⟩ :=
    InitializedCacheWrapper.initialized_wrapper ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic {live : Nat → Prop} (grow : ∀ a, InitialRetained.live a → live a) (a : Nat) (small : a < 100) : live a :=
    grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  obtain ⟨s422,run13,h422,inventory422,inst422⟩ := wrapper_to_cleanup notes caller (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity _
    live0 (fun _ => False) [] [] input.trace input.trace s409 inst409 h409 inventory409
    (identity_budget h409 (by decide +kernel))
    (intrinsic live0_grow _ (by decide +kernel)) rfl (intrinsic live0_grow _ (by decide +kernel)) rfl
    (intrinsic live0_grow _ (by decide +kernel)) rfl (intrinsic live0_grow _ (by decide +kernel)) rfl
    (fun impossible => impossible)
  obtain ⟨s445,run23,h445,inventory445,inst445⟩ := cleanup_to_guard notes caller (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity _
    live1 (fun _ => False) [] [] input.trace input.trace s422 inst422 h422 inventory422
    (identity_budget h422 (by decide +kernel))
    (intrinsic live1_grow _ (by decide +kernel)) rfl (intrinsic live1_grow _ (by decide +kernel)) rfl
    (intrinsic live1_grow _ (by decide +kernel)) rfl (intrinsic live1_grow _ (by decide +kernel)) rfl
  obtain ⟨s466,run21,h466,inventory466,inst466⟩ := guard_to_getter notes caller (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity _
    live2 (fun _ => False) [] [] input.trace input.trace s445 inst445 h445 inventory445
    (identity_budget h445 (by decide +kernel))
    (intrinsic live2_grow _ (by decide +kernel)) rfl (intrinsic live2_grow _ (by decide +kernel)) rfl
    (intrinsic live2_grow _ (by decide +kernel)) rfl (intrinsic live2_grow _ (by decide +kernel)) rfl
  obtain ⟨result,run18,h484,inventory484,inst484⟩ := getter_to_rank notes caller (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity _
    live3 (fun _ => False) [] [] input.trace input.trace s466 inst466 h466 inventory466
    (identity_budget h466 (by decide +kernel))
    (intrinsic live3_grow _ (by decide +kernel)) rfl (intrinsic live3_grow _ (by decide +kernel)) rfl
    (intrinsic live3_grow _ (by decide +kernel)) rfl (intrinsic live3_grow _ (by decide +kernel)) rfl
    (weight_note ic is control fnRole thisRole saved caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,h484,inventory484,policy,?_,inst484⟩
  · have run75 := runC_join P.F (m:=57) (n:=18)
      (runC_join P.F (m:=36) (n:=21) (runC_join P.F (m:=13) (n:=23) run13 run23) run21) run18
    cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run409; cases run409
    | some start =>
      simp only [boot,Option.bind_some] at run409 ⊢
      exact runC_join P.F (m:=32742264) (n:=75) run409 run75
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheWeightRank
