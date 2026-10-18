import host.ts.RenameCachePhaseInventory
import host.ts.RenameLoopNamespaceAdvance
import host.ts.renameOrdinary.RankOriginInitializedCacheWeightRank

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.CachePhases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem distinct_owners : CacheEntry.cacheOwners.Nodup := by decide +kernel

theorem selected_layer_bound (stage owner : Nat) (selected : CacheEntry.cacheOwners[stage]? = some owner) :
    stage < 64 := by
  obtain ⟨bound,_⟩ := List.getElem?_eq_some_iff.mp selected
  rwa [CacheEntry.cache_count] at bound

/-- The reached rank-origin cut is phase one, since its first SSM offset has
already advanced. It must not be used as an all-unadvanced loop template. -/
theorem phase_one_meaning (time : SymE) (owner : Nat) :
    CachePhase.meaning CacheEntry.cacheOwners 1 time owner = CacheEntry.offsetMeaning time owner := by
  simp only [CachePhase.meaning,show CacheEntry.cacheOwners.take 1 = [2672298] from rfl,
    List.mem_singleton,CacheEntry.offsetMeaning,CachePhase.advanced]

theorem reached_weight_rank_offsets (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree)
    (owner : Nat) (member : owner ∈ CacheEntry.cacheOwners) :
    (RetainedOracleConcatReturnBatch.weightRankNotes
      (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller) caller).publicFields.fields
      owner chars!"offset" = some (.literal (CachePhase.meaning CacheEntry.cacheOwners 1 LoopVariables.cacheIndex owner)) := by
  rw [phase_one_meaning]
  exact InitializedCacheWeightRank.offsets ic is control fnRole thisRole saved caller owner member

theorem selected_offset_before (stage owner : Nat) (time : SymE)
    (selected : CacheEntry.cacheOwners[stage]? = some owner) :
    CachePhase.meaning CacheEntry.cacheOwners stage time owner = time :=
  CachePhase.next_unadvanced _ _ _ _ distinct_owners selected

theorem selected_offset_after (notes : PublicNotes) (stage owner : Nat) (time : SymE)
    (selected : CacheEntry.cacheOwners[stage]? = some owner) :
    (notes.cachePhase CacheEntry.cacheOwners (stage+1) time).fields owner chars!"offset" =
      some (.literal (CachePhase.advanced time)) := by
  rw [← PublicNotes.cachePhase_write notes CacheEntry.cacheOwners stage owner time selected]
  simp only [PublicNotes.write,and_self,ite_true]

theorem all64_offsets (notes : PublicNotes) (time : SymE) (owner : Nat) (member : owner ∈ CacheEntry.cacheOwners) :
    (notes.cachePhase CacheEntry.cacheOwners 64 time).fields owner chars!"offset" =
      some (.literal (CachePhase.advanced time)) := by
  rw [←CacheEntry.cache_count,PublicNotes.cachePhase_selected _ _ _ _ _ member,
    CachePhase.complete _ _ _ member]

/-- The phase reset's arithmetic premise follows from the supported exact
binary64 counter range. Capacity may change independently of this equation. -/
theorem next_iteration_offset (oracle : Nat → F64) (prompt index limit capacity nextCapacity : Nat)
    (bound : prompt+index+2 < 2^53) :
    (CachePhase.advanced LoopVariables.cacheIndex).eval
        (LoopVariables.valuation oracle (loopValuation prompt index limit capacity)) =
      LoopVariables.cacheIndex.eval
        (LoopVariables.valuation oracle (loopValuation prompt (index+1) limit nextCapacity)) := by
  rw [CachePhase.advanced_eval _ _ (prompt+index+1)
    (LoopVariables.cache_index_eval oracle prompt index limit capacity (by omega)) (by omega),
    LoopVariables.cache_index_eval oracle prompt (index+1) limit nextCapacity (by omega)]
  rfl

theorem namespaced_counter_step (oracle : Nat → F64) (prompt index limit capacity : Nat) (growth : Bool)
    (bound : prompt+index+2 < 2^53) (capacityBound : capacity+256 < 2^53) :
    (CachePhase.advanced LoopVariables.cacheIndex).eval
        (LoopVariables.valuation oracle (loopValuation prompt index limit capacity)) =
      (LoopVariables.cacheIndex.subst (LoopVariables.advance growth)).eval
        (LoopVariables.valuation oracle (loopValuation prompt index limit capacity)) := by
  rw [SymE.eval_subst]
  change _ = LoopVariables.cacheIndex.eval (nextValuation (LoopVariables.advance growth) _)
  rw [LoopVariables.advance_valuation oracle prompt index limit capacity growth (by omega) capacityBound]
  exact next_iteration_offset oracle prompt index limit capacity _ bound

theorem phase_one_is_advanced : CachePhase.meaning CacheEntry.cacheOwners 1 (.var 0) 2672298 ≠ .var 0 := by
  rw [phase_one_meaning]
  decide +kernel

end Host.Load.Run.Full.Ordinary.RankOrigin.CachePhases
