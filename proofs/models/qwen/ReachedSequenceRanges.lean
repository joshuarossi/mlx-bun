import models.qwen.ReachedStageRanges
import models.qwen.TokenSampledSequenceRanges

namespace Inference.Models.Qwen.ReachedSequenceRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Attention Kernels.Delta
abbrev BF := BFloat16Arithmetic.Value
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

namespace DeltaAccuracy
open ResidualDelta ResidualDeltaDecodeRanges
theorem accuracy (b : Layer) (parameters : Parameters b) (primitive : ReachedStageRanges.DeltaResidual.Primitives b)
    (stage : Nat) (hs : stage < 64) (cache : DeltaNet.Cache) (x : Nat → Fin 5120 → BF)
    (hx : ∀ t, ResidualMlpRanges.InputBound stage (x t))
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (stateFinite : ∀ h v i, (cache.recurrent h v i).isFinite = true)
    (stateBound : ∀ h v, RecurrenceStability.magnitude (fun i => real (cache.recurrent h v i)) ≤ RecurrenceEnvelope.bound time)
    (supported : time+1 ≤ 262144)
    (targetCache errorCache : DeltaNet.ReferenceCache) (hc : DeltaNet.CacheError cache targetCache errorCache)
    (target error : Nat → Fin 5120 → ℝ) (hi : ∀ t i, |Model.toReal (x t i)-target t i| ≤ error t i) :
    (∀ i, |Model.toReal (b.forward cache x 0 i)-b.target targetCache target 0 i| ≤
      b.budget cache targetCache errorCache x target error 0
        (ReachedStageRanges.DeltaResidual.checked b parameters primitive stage hs cache x hx history stateFinite stateBound supported).finite i) ∧
    DeltaNet.CacheError (b.cacheAfter cache x 1) (b.targetCacheAfter targetCache target 1)
      (b.cacheBudget cache targetCache errorCache x target error 1) := by
  let h := ReachedStageRanges.DeltaResidual.checked b parameters primitive stage hs cache x hx history stateFinite stateBound supported
  refine ⟨fun i => ?_, b.cache_error cache targetCache errorCache hc x target error hi 0 h.finite⟩
  exact b.suffix.forward_error_of_bounds (x 0) (b.mixed cache x 0) (target 0) (b.mixedTarget targetCache target 0)
    (error 0) (b.mixedBudget cache targetCache errorCache x target error 0) (hi 0)
    (b.mixed_error cache targetCache errorCache hc x target error hi 0 h.finite) h.finite.suffix h.addition i

end DeltaAccuracy

namespace AttentionAccuracy
open ResidualAttention ResidualAttentionSequenceRanges
theorem accuracy (b : Layer) (parameters : Parameters b) (primitive : ReachedStageRanges.AttentionResidual.Primitives b)
    (stage : Nat) (hs : stage < 64) (x : Fin 5120 → BF) (hx : ResidualMlpRanges.InputBound stage x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (cache : Cache BF steps) (cacheBound : CacheBound cache) (supported : steps+1 ≤ 262144)
    (target error : Fin 5120 → ℝ) (hi : ∀ i, |Model.toReal (x i)-target i| ≤ error i)
    (angleTarget angleError : RopeAngles.Target) (he : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base)
    (cacheTarget cacheError : Cache ℝ steps) (hc : State.Kv.Error cache cacheTarget cacheError) :
    (∀ i, |Model.toReal (b.forward x angle cache i)-b.target target angleTarget cacheTarget i| ≤
      b.budget x target error angle angleTarget angleError cache cacheTarget cacheError
        (ReachedStageRanges.AttentionResidual.checked b parameters primitive stage hs x hx angle ha cache cacheBound supported).finite i) ∧
    State.Kv.Error (b.cacheAfter x angle cache) (b.targetCacheAfter target angleTarget cacheTarget)
      (b.cacheBudget x target error angle angleTarget angleError cacheError) := by
  let h := ReachedStageRanges.AttentionResidual.checked b parameters primitive stage hs x hx angle ha cache cacheBound supported
  refine ⟨fun i => ?_, b.cache_error x target error angle angleTarget angleError cache cacheTarget cacheError hi hc h.finite he hb⟩
  exact b.suffix.forward_error_of_bounds x (b.mixed x angle cache) target (b.mixedTarget target angleTarget cacheTarget) error
    (b.mixedBudget x target error angle angleTarget angleError cache cacheTarget cacheError) hi
    (b.mixed_error x target error angle angleTarget angleError cache cacheTarget cacheError hi hc
      (CacheBound.finite cache cacheBound) h.finite he hb) h.finite.suffix h.addition i

end AttentionAccuracy

namespace Stage
open DecodeStage DecodeStageSequenceRanges
def Primitives : Stage → Type
  | .delta b => ReachedStageRanges.DeltaResidual.Primitives b
  | .attention b => ReachedStageRanges.AttentionResidual.Primitives b

theorem cache_finite (s : Stage) (cache : Cache s time) (hc : CacheBound s cache) : DecodeStage.CacheFinite s cache := by
  cases s with
  | delta _ => exact ⟨fun i c => (hc.history i c).1, hc.finite⟩
  | attention _ => exact ResidualAttentionSequenceRanges.CacheBound.finite cache hc

theorem initial (s : Stage) : CacheBound s (InitialState.stage s) := by
  cases s with
  | delta _ =>
    change DeltaBound InitialState.delta 0
    refine ⟨?_, InitialState.delta_finite.recurrent, ?_⟩
    · intro i c
      exact ⟨InitialState.delta_finite.history i c, by simp [InitialState.delta]⟩
    · intro h v
      simp [InitialState.delta, RecurrenceStability.magnitude, RecurrenceStability.energy,
        FlushedIdentities.zero_real, RecurrenceEnvelope.zero]
  | attention _ =>
    constructor <;> intro _ t <;> exact Fin.elim0 t

noncomputable def checked (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (cache : Cache s time) (hc : CacheBound s cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    DecodeStage.Finite s cache x angle := by
  cases s with
  | delta b =>
    exact (ReachedStageRanges.DeltaResidual.checked b parameters primitive index hs cache (fun _ => x)
      (fun _ => hx) hc.history hc.finite hc.size supported).finite
  | attention b =>
    exact (ReachedStageRanges.AttentionResidual.checked b parameters primitive index hs x hx angle ha cache hc supported).finite

theorem next_input (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (cache : Cache s time) (hc : CacheBound s cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    ResidualMlpRanges.InputBound (index+1) (DecodeStage.forward s cache x angle) := by
  cases s with
  | delta b =>
    exact ReachedStageRanges.DeltaResidual.next_input b parameters primitive index hs cache (fun _ => x)
      (fun _ => hx) hc.history hc.finite hc.size supported
  | attention b =>
    exact ReachedStageRanges.AttentionResidual.next_input b parameters primitive index hs x hx angle ha cache hc supported

theorem output_bounded (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (cache : Cache s time) (hc : CacheBound s cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    ∀ i, |Model.toReal (DecodeStage.forward s cache x angle i)| ≤ (2 : ℝ)^(56 : Nat) := by
  have cap : (index+1 : Nat)*(2 : ℝ)^(50 : Nat) ≤ (2 : ℝ)^(56 : Nat) := by
    have h : ((index+1 : Nat) : ℝ) ≤ 64 := by exact_mod_cast (show index+1 ≤ 64 by omega)
    push_cast at h
    norm_num
    linarith
  cases s with
  | delta b =>
    intro i
    exact ((ReachedStageRanges.DeltaResidual.checked b parameters primitive index hs cache (fun _ => x)
      (fun _ => hx) hc.history hc.finite hc.size supported).output i).trans cap
  | attention b =>
    intro i
    exact ((ReachedStageRanges.AttentionResidual.checked b parameters primitive index hs x hx angle ha cache hc supported).output i).trans cap

theorem next_cache (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (cache : Cache s time) (hc : CacheBound s cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    CacheBound s (DecodeStage.cacheAfter s cache x angle) := by
  cases s with
  | delta b =>
    let h := ReachedStageRanges.DeltaResidual.checked b parameters primitive index hs cache (fun _ => x)
      (fun _ => hx) hc.history hc.finite hc.size supported
    exact ⟨h.history, fun head v => (h.recurrent head v).1, fun head v => (h.recurrent head v).2⟩
  | attention b =>
    exact (ReachedStageRanges.AttentionResidual.checked b parameters primitive index hs x hx angle ha cache hc supported).cacheBound

theorem accuracy (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (cache : Cache s time) (cacheBound : CacheBound s cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144)
    (ct ce : ReferenceCache s time) (hc : CacheError s cache ct ce)
    (t e : Row ℝ) (hi : ∀ i, |Model.toReal (x i)-t i| ≤ e i)
    (aim ae : RopeAngles.Target) (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal (DecodeStage.forward s cache x angle i)-DecodeStage.target s ct t aim i| ≤
      DecodeStage.budget s cache ct ce x t e angle aim ae
        (checked s parameters primitive index hs cache cacheBound x hx angle ha supported) i) ∧
    CacheError s (DecodeStage.cacheAfter s cache x angle) (DecodeStage.targetCacheAfter s ct t aim)
      (DecodeStage.cacheBudget s cache ct ce x t e angle aim ae) := by
  cases s with
  | delta b =>
    exact DeltaAccuracy.accuracy b parameters primitive index hs cache (fun _ => x)
      (fun _ => hx) cacheBound.history cacheBound.finite cacheBound.size supported ct ce hc
      (fun _ => t) (fun _ => e) (fun _ => hi)
  | attention b =>
    exact AttentionAccuracy.accuracy b parameters primitive index hs x hx angle ha cache cacheBound supported
      t e hi aim ae he hb ct ce hc

end Stage

namespace Chain
open DecodeStage DecodeChainSequenceRanges
def Primitives : List Stage → Type
  | [] => PUnit
  | s::rest => Stage.Primitives s × Primitives rest
theorem initial (stages : List Stage) : CachesBound stages (InitialState.caches stages) := by
  induction stages with
  | nil => trivial
  | cons s rest ih => exact ⟨Stage.initial s, ih⟩

theorem caches_finite (stages : List Stage) (cache : DecodeChain.Caches stages time) (hc : CachesBound stages cache) :
    DecodeChain.CachesFinite stages cache := by
  induction stages with
  | nil => trivial
  | cons s rest ih => exact ⟨Stage.cache_finite s cache.1 hc.1, ih cache.2 hc.2⟩

noncomputable def ranges : (stages : List Stage) → Parameters stages → Primitives stages →
    (index : Nat) → index+stages.length ≤ 64 →
    (cache : DecodeChain.Caches stages time) → CachesBound stages cache →
    (x : Row BF) → ResidualMlpRanges.InputBound index x →
    (angle : RopeAngles.Inputs) → RopeAnglesRanges.InputsBound angle → time+1 ≤ 262144 →
    DecodeChain.Ranges stages cache x angle
  | [], _, _, _, _, _, _, _, _, _, _, _ => ⟨⟩
  | s::rest, parameters, primitive, index, size, cache, hc, x, hx, angle, ha, supported =>
    let hs : index < 64 := by simp only [List.length_cons] at size; omega
    let ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    ⟨Stage.checked s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported,
      ranges rest parameters.2 primitive.2 (index+1) ht cache.2 hc.2 (DecodeStage.forward s cache.1 x angle)
        (Stage.next_input s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported)
        angle ha supported⟩

theorem next_input (stages : List Stage) (parameters : Parameters stages) (primitive : Primitives stages)
    (index : Nat) (size : index+stages.length ≤ 64) (cache : DecodeChain.Caches stages time) (hc : CachesBound stages cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    ResidualMlpRanges.InputBound (index+stages.length) (DecodeChain.run stages cache x angle).1 := by
  induction stages generalizing index x with
  | nil => exact hx
  | cons s rest ih =>
    have hs : index < 64 := by simp only [List.length_cons] at size; omega
    have ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    have hn := Stage.next_input s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported
    have h := ih parameters.2 primitive.2 (index+1) ht cache.2 hc.2 (DecodeStage.forward s cache.1 x angle) hn
    simpa only [DecodeChain.run, List.length_cons, show index+1+rest.length = index+(rest.length+1) from by omega] using h

theorem output_bounded (stages : List Stage) (parameters : Parameters stages) (primitive : Primitives stages)
    (index : Nat) (size : index+stages.length ≤ 64) (nonempty : stages ≠ [])
    (cache : DecodeChain.Caches stages time) (hc : CachesBound stages cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    ∀ i, |Model.toReal ((DecodeChain.run stages cache x angle).1 i)| ≤ (2 : ℝ)^(56 : Nat) := by
  induction stages generalizing index x with
  | nil => exact False.elim (nonempty rfl)
  | cons s rest ih =>
    have hs : index < 64 := by simp only [List.length_cons] at size; omega
    have ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    by_cases empty : rest = []
    · subst rest
      exact Stage.output_bounded s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported
    · exact ih parameters.2 primitive.2 (index+1) ht empty cache.2 hc.2 (DecodeStage.forward s cache.1 x angle)
        (Stage.next_input s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported)

theorem next_cache (stages : List Stage) (parameters : Parameters stages) (primitive : Primitives stages)
    (index : Nat) (size : index+stages.length ≤ 64) (cache : DecodeChain.Caches stages time) (hc : CachesBound stages cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    CachesBound stages (DecodeChain.run stages cache x angle).2 := by
  induction stages generalizing index x with
  | nil => trivial
  | cons s rest ih =>
    have hs : index < 64 := by simp only [List.length_cons] at size; omega
    have ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    refine ⟨Stage.next_cache s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported, ?_⟩
    exact ih parameters.2 primitive.2 (index+1) ht cache.2 hc.2 (DecodeStage.forward s cache.1 x angle)
      (Stage.next_input s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported)

theorem run_correct (stages : List Stage) (parameters : Parameters stages) (primitive : Primitives stages)
    (index : Nat) (size : index+stages.length ≤ 64) (cache : DecodeChain.Caches stages time) (cacheBound : CachesBound stages cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144)
    (ct ce : DecodeChain.ReferenceCaches stages time) (hc : DecodeChain.CacheErrors stages cache ct ce)
    (t e : Row ℝ) (hi : ∀ i, |Model.toReal (x i)-t i| ≤ e i)
    (aim ae : RopeAngles.Target) (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal ((DecodeChain.run stages cache x angle).1 i)-(DecodeChain.targetRun stages ct t aim).1 i| ≤
      (DecodeChain.budgetRun stages cache ct ce x t e angle aim ae
        (ranges stages parameters primitive index size cache cacheBound x hx angle ha supported)).1 i) ∧
    DecodeChain.CacheErrors stages (DecodeChain.run stages cache x angle).2 (DecodeChain.targetRun stages ct t aim).2
      (DecodeChain.budgetRun stages cache ct ce x t e angle aim ae
        (ranges stages parameters primitive index size cache cacheBound x hx angle ha supported)).2 ∧
    (∀ i, Model.isFinite ((DecodeChain.run stages cache x angle).1 i) = true) ∧
    DecodeChain.CachesFinite stages (DecodeChain.run stages cache x angle).2 := by
  induction stages generalizing index x t e with
  | nil => exact ⟨hi, trivial, fun i => (hx i).1, trivial⟩
  | cons s rest ih =>
    have hs : index < 64 := by simp only [List.length_cons] at size; omega
    have ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    let hf := Stage.checked s parameters.1 primitive.1 index hs cache.1 cacheBound.1 x hx angle ha supported
    have hn := Stage.next_input s parameters.1 primitive.1 index hs cache.1 cacheBound.1 x hx angle ha supported
    have layer := Stage.accuracy s parameters.1 primitive.1 index hs cache.1 cacheBound.1 x hx angle ha supported
      ct.1 ce.1 hc.1 t e hi aim ae he hb
    have tail := ih parameters.2 primitive.2 (index+1) ht cache.2 cacheBound.2 (DecodeStage.forward s cache.1 x angle) hn
      ct.2 ce.2 hc.2 (DecodeStage.target s ct.1 t aim) (DecodeStage.budget s cache.1 ct.1 ce.1 x t e angle aim ae hf) layer.1
    exact ⟨tail.1, ⟨layer.2, tail.2.1⟩, tail.2.2.1,
      ⟨DecodeStage.cache_finite s cache.1 x angle (Stage.cache_finite s cache.1 cacheBound.1) hf, tail.2.2.2⟩⟩

end Chain

namespace Graph
open DecodeStage Qwen38TrellisM1Max
open Qwen38TrellisM1MaxSequenceRanges (Parameters Result chainParameters)
structure Primitives (g : Graph) where
  delta : ∀ i, ReachedStageRanges.DeltaResidual.Primitives (g.delta i)
  attention : ∀ i, ReachedStageRanges.AttentionResidual.Primitives (g.attention i)
  normalization : DivisionDirectedBounds.Contract g.finalNorm.platform.divide
  root : RsqrtEpsilonBounds.Envelope g.finalNorm.platform.rsqrt Blocks.eps 2
  output : NormalizedAffineProjection.DivisionContract g.output

def chainPrimitives (g : Graph) (primitive : Primitives g) : Chain.Primitives g.stages := by
  simp only [Qwen38TrellisM1Max.Graph.stages, Chain.Primitives, Stage.Primitives]
  repeat' apply Prod.mk
  all_goals first | exact primitive.delta _ | exact primitive.attention _ | exact PUnit.unit

noncomputable def checked (g : Graph) (parameters : Parameters g) (primitive : Primitives g)
    (cache : g.Cache time) (hc : DecodeChainSequenceRanges.CachesBound g.stages cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound 0 x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    Result g cache x angle := by
  let cp := chainParameters g parameters
  let pp := chainPrimitives g primitive
  have size : 0+g.stages.length ≤ 64 := by rw [g.layer_count]
  have nonempty : g.stages ≠ [] := by intro h; have hn := g.layer_count; rw [h] at hn; contradiction
  have finite := Chain.ranges g.stages cp pp 0 size cache hc x hx angle ha supported
  have next := Chain.next_input g.stages cp pp 0 size cache hc x hx angle ha supported
  have bound := Chain.output_bounded g.stages cp pp 0 size nonempty cache hc x hx angle ha supported
  have output := ReachedStageRanges.Affine.ranges g.finalNorm g.output parameters.output primitive.normalization
    primitive.root primitive.output parameters.normalization (g.hidden cache x angle) (fun i => ⟨(next i).1, bound i⟩)
  exact ⟨⟨finite, fun i => (parameters.normalization i).1, output.1, output.2.1⟩, output.2.2,
    Chain.next_cache g.stages cp pp 0 size cache hc x hx angle ha supported⟩

theorem run_correct (g : Graph) (parameters : Parameters g) (primitive : Primitives g)
    (cache : g.Cache time) (cacheBound : DecodeChainSequenceRanges.CachesBound g.stages cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound 0 x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144)
    (ct ce : g.ReferenceCache time) (hc : DecodeChain.CacheErrors g.stages cache ct ce)
    (t e : Row ℝ) (hi : ∀ i, |Model.toReal (x i)-t i| ≤ e i)
    (aim ae : RopeAngles.Target) (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal (g.forward cache x angle i)-g.target ct t aim i| ≤
      g.budget cache ct ce x t e angle aim ae
        (checked g parameters primitive cache cacheBound x hx angle ha supported).finite i) ∧
    DecodeChain.CacheErrors g.stages (DecodeChain.run g.stages cache x angle).2 (DecodeChain.targetRun g.stages ct t aim).2
      (DecodeChain.budgetRun g.stages cache ct ce x t e angle aim ae
        (checked g parameters primitive cache cacheBound x hx angle ha supported).finite.chain).2 ∧
    (∀ i, Model.isFinite (g.forward cache x angle i) = true) ∧
    DecodeChain.CachesFinite g.stages (DecodeChain.run g.stages cache x angle).2 := by
  let h := checked g parameters primitive cache cacheBound x hx angle ha supported
  have chain := Chain.run_correct g.stages (chainParameters g parameters) (chainPrimitives g primitive)
    0 (by rw [g.layer_count]) cache cacheBound x hx angle ha supported ct ce hc t e hi aim ae he hb
  refine ⟨fun i => ?_, chain.2.1, fun i => (h.output i).1, chain.2.2.2⟩
  apply g.output.forward_error _ _ _ _ h.finite.output i
  intro j
  exact g.finalNorm.forward_error (g.hidden cache x angle) (g.targetHidden ct t aim)
    (g.hiddenBudget cache ct ce x t e angle aim ae h.finite)
    chain.1 chain.2.2.1 h.finite.finalWeight h.finite.finalNorm j

end Graph

namespace Token
open DecodeStage TokenInference TokenSequenceRanges
noncomputable def checked (p : Pipeline) (parameters : Parameters p)
    (primitive : Graph.Primitives p.graph)
    (cache : p.graph.Cache time) (hc : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) : p.Ranges cache token angle :=
  ⟨EmbeddingRanges.embedding_finite p.embedding parameters.embedding token,
    (Graph.checked p.graph parameters.graph primitive cache hc (p.embedding.forward token)
      (embedding_bound p parameters token) angle ha supported).finite⟩

theorem next_cache (p : Pipeline) (parameters : Parameters p)
    (primitive : Graph.Primitives p.graph)
    (cache : p.graph.Cache time) (hc : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) : DecodeChainSequenceRanges.CachesBound p.graph.stages (p.run cache token angle).2 :=
  (Graph.checked p.graph parameters.graph primitive cache hc (p.embedding.forward token)
    (embedding_bound p parameters token) angle ha supported).cacheBound

-- Every call consumes the preceding cache contract and produces its
-- successor. Numerical errors in that cache are propagated independently.
theorem run_correct (p : Pipeline) (parameters : Parameters p)
    (primitive : Graph.Primitives p.graph)
    (cache : p.graph.Cache time) (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (ct ce : p.graph.ReferenceCache time) (hc : DecodeChain.CacheErrors p.graph.stages cache ct ce)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal ((p.run cache token angle).1 i)-(p.targetRun ct token aim).1 i| ≤
      (p.budgetRun cache ct ce token angle aim ae (checked p parameters primitive cache cacheBound token angle ha supported)).1 i) ∧
    DecodeChain.CacheErrors p.graph.stages (p.run cache token angle).2 (p.targetRun ct token aim).2
      (p.budgetRun cache ct ce token angle aim ae (checked p parameters primitive cache cacheBound token angle ha supported)).2 ∧
    (∀ i, Model.isFinite ((p.run cache token angle).1 i) = true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2 : ℝ)^(23 : Nat)) ∧
    DecodeChainSequenceRanges.CachesBound p.graph.stages (p.run cache token angle).2 := by
  have hf := EmbeddingRanges.embedding_finite p.embedding parameters.embedding token
  have h := Graph.run_correct p.graph parameters.graph primitive cache cacheBound
    (p.embedding.forward token) (embedding_bound p parameters token) angle ha supported ct ce hc
    (p.embedding.target token) (p.embedding.budget token) (p.embedding.forward_error token hf) aim ae he hb
  have ranges := Graph.checked p.graph parameters.graph primitive cache cacheBound
    (p.embedding.forward token) (embedding_bound p parameters token) angle ha supported
  exact ⟨h.1, h.2.1, ranges.output, ranges.cacheBound⟩

end Token

namespace Sample
open TokenInference Kernels.Sampling TokenSampledSequenceRanges
noncomputable def budget (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Graph.Primitives p.graph)
    (cache : p.graph.Cache time) (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (ct ce : p.graph.ReferenceCache time) (token : Fin 248320)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144)
    (aim ae : RopeAngles.Target) : (Fin 248320 → ℝ) × p.graph.ReferenceCache (time+1) :=
  p.budgetRun cache ct ce token angle aim ae (Token.checked p parameters primitive cache cacheBound token angle ha supported)

theorem run_correct (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Graph.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (cache : p.graph.Cache time) (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (ct ce : p.graph.ReferenceCache time) (hc : DecodeChain.CacheErrors p.graph.stages cache ct ce)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal (logits p cache token angle i)-(p.targetRun ct token aim).1 i| ≤
      (budget p parameters primitive cache cacheBound ct ce token angle ha supported aim ae).1 i) ∧
    DecodeChain.CacheErrors p.graph.stages (run p sampling cache token angle).2 (p.targetRun ct token aim).2
      (budget p parameters primitive cache cacheBound ct ce token angle ha supported aim ae).2 ∧
    DecodeChainSequenceRanges.CachesBound p.graph.stages (run p sampling cache token angle).2 ∧
    LogSumExpRanges.Trace sampling (fun i => BFloat16.widen (logits p cache token angle i)) ∧
    (∀ i, (NormalizedScores.value (logits p cache token angle i)
      (LogSumExpRanges.value sampling (logits p cache token angle))).isFinite = true) ∧
    ∃ selected : Fin 248320, (run p sampling cache token angle).1 = selected.val ∧
      (∀ i, GreedySampling.score sampling (logits p cache token angle) i ≤ GreedySampling.score sampling (logits p cache token angle) selected) ∧
      (∀ i, GreedySampling.score sampling (logits p cache token angle) selected = GreedySampling.score sampling (logits p cache token angle) i →
        selected.val ≤ i.val) := by
  have numeric := Token.run_correct p parameters primitive cache cacheBound ct ce hc token angle ha supported aim ae he hb
  have selection := GreedySampling.correct sampling samplingPrimitive (logits p cache token angle) numeric.2.2.1
  exact ⟨numeric.1, numeric.2.1, numeric.2.2.2, selection.1, selection.2⟩

theorem target_winner (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Graph.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (cache : p.graph.Cache time) (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (ct ce : p.graph.ReferenceCache time) (hc : DecodeChain.CacheErrors p.graph.stages cache ct ce)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) (winner : Fin 248320)
    (margin : ∀ i, i ≠ winner →
      (p.targetRun ct token aim).1 i + GreedySampling.error sampling (logits p cache token angle)
        (budget p parameters primitive cache cacheBound ct ce token angle ha supported aim ae).1 i <
      (p.targetRun ct token aim).1 winner - GreedySampling.error sampling (logits p cache token angle)
        (budget p parameters primitive cache cacheBound ct ce token angle ha supported aim ae).1 winner) :
    (run p sampling cache token angle).1 = winner.val := by
  have numeric := Token.run_correct p parameters primitive cache cacheBound ct ce hc token angle ha supported aim ae he hb
  exact GreedySampling.target_winner sampling samplingPrimitive (logits p cache token angle) numeric.2.2.1 _ _ numeric.1 winner margin

end Sample

end Inference.Models.Qwen.ReachedSequenceRanges
