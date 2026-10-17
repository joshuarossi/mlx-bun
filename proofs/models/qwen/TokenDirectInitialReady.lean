import models.qwen.TokenDirectInitialConstruction
import models.qwen.DecodeInitialGeometry
import models.qwen.TokenReadyMemory

namespace Inference.Models.Qwen.TokenDirectInitialReady
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open TokenDirectInitialConstruction TokenReadyMemory
open TokenBoundaryHighWater (Before)
open DecodeHighWaterGeometry (After)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  GreedySampling.sample
  Request.chain Request.finalStorage Request.finalWorkspace Request.logitsBuffer Request.sampler Request.afterCaches

section LogicalProjections
variable {p : Pipeline} (before : TokenAutoregressive.State p 0) (context : Context p)
private theorem logical_token :
    (TokenAutoregressive.advance p context.parameters context.primitive context.sampling context.samplingPrimitive
      before (context.angles.value 0) (context.angles.ranges 0 (by decide)) (by decide)
      (context.angles.target 0) (context.angles.error 0) (context.angles.accuracy 0 (by decide)) (context.angles.base 0 (by decide))).token.val=
    GreedySampling.sample context.sampling (p.graph.forward before.cache (p.embedding.forward before.token) (context.angles.value 0)) := rfl
private theorem logical_cache :
    (TokenAutoregressive.advance p context.parameters context.primitive context.sampling context.samplingPrimitive
      before (context.angles.value 0) (context.angles.ranges 0 (by decide)) (by decide)
      (context.angles.target 0) (context.angles.error 0) (context.angles.accuracy 0 (by decide)) (context.angles.base 0 (by decide))).cache=
    (DecodeChain.run p.graph.stages before.cache (p.embedding.forward before.token) (context.angles.value 0)).2 := rfl
end LogicalProjections

-- Keep the physical attachment generic before specializing to a concrete
-- sampler. Reducing logical cache indices never unfolds its kernel schedule.
private noncomputable def attachAdvance {p : Pipeline} (before : TokenAutoregressive.State p 0)
    (context : Context p) (memory : ByteMemory.Bytes) (destination : Nat)
    (aligned : destination%4=0) (bounded : destination+4≤2^64)
    (selected : (ByteMemory.load32 memory destination).toNat=
      GreedySampling.sample context.sampling (p.graph.forward before.cache (p.embedding.forward before.token) (context.angles.value 0)))
    (caches : DecodeFrame.Storage p.graph.stages
      (DecodeChain.run p.graph.stages before.cache (p.embedding.forward before.token) (context.angles.value 0)).2 memory) :
    TokenAutoregressiveMemory.State p 1 := by
  let reference : TokenAutoregressive.State p 1 := TokenAutoregressive.advance p context.parameters context.primitive context.sampling context.samplingPrimitive
    before (context.angles.value 0) (context.angles.ranges 0 (by decide)) (by decide)
    (context.angles.target 0) (context.angles.error 0) (context.angles.accuracy 0 (by decide)) (context.angles.base 0 (by decide))
  have tokenRead : (ByteMemory.load32 memory destination).toNat=reference.token.val :=
    selected.trans (logical_token before context).symm
  let index := Inference.State.TokenStorage.Buffer.fromRead reference.token memory destination aligned bounded tokenRead
  have cacheStorage : DecodeFrame.Storage p.graph.stages reference.cache index.bytes :=
    (logical_cache before context).symm ▸ caches
  exact { logical := reference, index := index, caches := cacheStorage }

section AttachmentProjections
variable {p : Pipeline} (before : TokenAutoregressive.State p 0) (context : Context p)
  (memory : ByteMemory.Bytes) (destination : Nat) (aligned : destination%4=0) (bounded : destination+4≤2^64)
  (selected : (ByteMemory.load32 memory destination).toNat=
    GreedySampling.sample context.sampling (p.graph.forward before.cache (p.embedding.forward before.token) (context.angles.value 0)))
  (caches : DecodeFrame.Storage p.graph.stages
    (DecodeChain.run p.graph.stages before.cache (p.embedding.forward before.token) (context.angles.value 0)).2 memory)
private theorem attachAdvance_logical : (attachAdvance before context memory destination aligned bounded selected caches).logical=
    TokenAutoregressive.advance p context.parameters context.primitive context.sampling context.samplingPrimitive
      before (context.angles.value 0) (context.angles.ranges 0 (by decide)) (by decide)
      (context.angles.target 0) (context.angles.error 0) (context.angles.accuracy 0 (by decide)) (context.angles.base 0 (by decide)) := rfl
private theorem attachAdvance_bytes : (attachAdvance before context memory destination aligned bounded selected caches).index.bytes=memory := rfl
private theorem attachAdvance_base : (attachAdvance before context memory destination aligned bounded selected caches).index.base=destination := rfl
end AttachmentProjections

variable {p : Pipeline} {state : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p state.index.bytes}
  (request : Request original)

theorem chain_geometry (angle : RopeAngles.Inputs) : DecodeInitialGeometry.Geometry (request.chain angle) := by
  unfold Request.chain
  apply DecodeInitialGeometry.build_geometry

theorem after_regions (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    DecodeCacheGeometry.regions p.graph.stages
      (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2 _
      (request.afterCaches angle sampling lseLocal tileLocal finishLocal)=
    DecodeCacheGeometry.regions p.graph.stages
      (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2 _
      (request.chain angle).after := by
  unfold Request.afterCaches Request.sampler Request.samplerPlan Request.logitCaches
    TokenBoundaryHighWater.samplerCachesAfter TokenBoundaryHighWater.retainCaches
  exact (DecodeCacheGeometry.reframe_regions _ _ _ _ _ _ _ _).trans
    (DecodeCacheGeometry.reframe_regions _ _ _ _ _ _ _ _)

theorem after_geometry (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (cut : Nat) (ordered : cut≤request.frontier.cursor) :
    DecodePreservation.Protected (After cut) p.graph.stages
      (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2 _
      (request.afterCaches angle sampling lseLocal tileLocal finishLocal) ∧
    DecodeCacheGeometry.Pairwise p.graph.stages
      (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2 _
      (request.afterCaches angle sampling lseLocal tileLocal finishLocal) :=
  TokenFirstCacheGeometry.geometry_transport (after_regions request angle sampling lseLocal tileLocal finishLocal)
    ((chain_geometry request angle).after_cut cut ordered)

variable (context : Context p)

theorem logits_bound : ∀ i,
    Model.isFinite (p.graph.forward state.logical.cache (p.embedding.forward state.logical.token) (context.angles.value 0) i)=true ∧
      |Model.toReal (p.graph.forward state.logical.cache (p.embedding.forward state.logical.token) (context.angles.value 0) i)|≤(2:ℝ)^(23:Nat) :=
  (Qwen38TrellisM1MaxSequenceRanges.checked p.graph context.parameters.graph context.primitive state.logical.cache state.logical.cacheBound
    (p.embedding.forward state.logical.token) (TokenSequenceRanges.embedding_bound p context.parameters state.logical.token)
    (context.angles.value 0) (context.angles.ranges 0 (by decide)) (by decide)).output

theorem sampled_token :
    (request.sampler (context.angles.value 0) context.sampling (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish).selection.token=
      GreedySampling.sample context.sampling
        (p.graph.forward state.logical.cache (p.embedding.forward state.logical.token) (context.angles.value 0)) := by
  have actual : ∀ i, Model.isFinite (request.logits (context.angles.value 0) i)=true ∧
      |Model.toReal (request.logits (context.angles.value 0) i)|≤(2:ℝ)^(23:Nat) := by
    rw [request.logits_eq]
    exact logits_bound context
  rw [(request.sampler (context.angles.value 0) context.sampling (context.locals 0).lse (context.locals 0).tile
    (context.locals 0).finish).token_eq context.samplingPrimitive actual,request.logits_eq]

noncomputable def advance : TokenAutoregressiveMemory.State p 1 :=
  attachAdvance state.logical context
    (request.sampler (context.angles.value 0) context.sampling (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish).memory
    (request.sampler (context.angles.value 0) context.sampling (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish).selection.destination
    (request.sampler (context.angles.value 0) context.sampling (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish).selection.output.aligned
    (request.sampler (context.angles.value 0) context.sampling (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish).selection.output.bounded
    (sampled_token request context)
    (request.afterCaches (context.angles.value 0) context.sampling (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish)

theorem advance_logical : (advance request context).logical=
    TokenAutoregressive.advance p context.parameters context.primitive context.sampling context.samplingPrimitive
      state.logical (context.angles.value 0) (context.angles.ranges 0 (by decide)) (by decide)
      (context.angles.target 0) (context.angles.error 0) (context.angles.accuracy 0 (by decide)) (context.angles.base 0 (by decide)) :=
  attachAdvance_logical _ _ _ _ _ _ _ _

theorem advance_bytes : (advance request context).index.bytes=
    (request.sampler (context.angles.value 0) context.sampling (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish).memory :=
  attachAdvance_bytes _ _ _ _ _ _ _ _

theorem advance_base : (advance request context).index.base=
    (request.sampler (context.angles.value 0) context.sampling (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish).selection.destination :=
  attachAdvance_base _ _ _ _ _ _ _ _

def parameters : TokenParameterMemory.Storage p (advance request context).index.bytes :=
  request.afterParameters (context.angles.value 0) context.sampling (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish

theorem parameters_regions (property : Nat → Nat → Prop) :
    (parameters request context).Protected property ↔ original.Protected property :=
  request.after_parameter_regions (context.angles.value 0) context.sampling
    (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish property

noncomputable def ready (cut : Nat) (ordered : cut≤request.cursor)
    (parameterBound : original.Protected (Before cut)) : Ready p 1 cut where
  state := advance request context
  parameters := parameters request context
  frontier := ⟨request.nextCursor,request.next_aligned⟩
  ordered := (ordered.trans (Nat.le_add_right request.cursor (bytes p))).trans (Nat.le_of_eq request.next_cursor.symm)
  token := request.token_bound (context.angles.value 0) context.sampling
    (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish
  parametersBound := (parameters_regions request context _).mpr parameterBound
  cachesBound := request.after_caches_bound (context.angles.value 0) context.sampling
    (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish
  cachesAbove := (after_geometry request (context.angles.value 0) context.sampling
    (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish cut
    (ordered.trans (Nat.le_add_right _ 13120))).1
  pairwise := (after_geometry request (context.angles.value 0) context.sampling
    (context.locals 0).lse (context.locals 0).tile (context.locals 0).finish cut
    (ordered.trans (Nat.le_add_right _ 13120))).2

theorem ready_cursor (cut : Nat) (ordered : cut≤request.cursor) (parameterBound : original.Protected (Before cut)) :
    (ready request context cut ordered parameterBound).frontier.cursor=request.cursor+bytes p := request.next_cursor

theorem ready_parameters (cut : Nat) (ordered : cut≤request.cursor) (parameterBound : original.Protected (Before cut))
    (property : Nat → Nat → Prop) :
    (ready request context cut ordered parameterBound).parameters.Protected property ↔ original.Protected property :=
  parameters_regions request context property

theorem ready_frame (cut : Nat) (ordered : cut≤request.cursor) (parameterBound : original.Protected (Before cut))
    (region : TokenParameterConstruction.Region original base size) (offset : Nat) (bound : offset<size) :
    (ready request context cut ordered parameterBound).state.index.bytes (base+offset)=state.index.bytes (base+offset) :=
  request.other_region (context.angles.value 0) context.sampling (context.locals 0).lse (context.locals 0).tile
    (context.locals 0).finish (region _ request.parameters) offset bound

theorem ready_logical (cut : Nat) (ordered : cut≤request.cursor) (parameterBound : original.Protected (Before cut))
    (token : Fin 248320) (initial : state.logical=TokenAutoregressive.initial p token) :
    (ready request context cut ordered parameterBound).state.logical=
      TokenAutoregressive.run p context.parameters context.primitive context.sampling context.samplingPrimitive token context.angles 1 (by decide) := by
  rw [show (ready request context cut ordered parameterBound).state.logical=(advance request context).logical from rfl,advance_logical]
  exact congrArg (fun logical => TokenAutoregressive.advance p context.parameters context.primitive context.sampling context.samplingPrimitive
    logical (context.angles.value 0) (context.angles.ranges 0 (by decide)) (by decide)
    (context.angles.target 0) (context.angles.error 0) (context.angles.accuracy 0 (by decide)) (context.angles.base 0 (by decide))) initial

end Inference.Models.Qwen.TokenDirectInitialReady
