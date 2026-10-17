import models.qwen.TokenReadyMemory
import models.qwen.CheckpointSecondTokenMemory

namespace Inference.Models.Qwen.CheckpointReadyMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  TokenFirstInitializedConstruction.Request.first TokenFirstInitializedConstruction.Request.ready

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes} {original : TokenParameterMemory.Storage p initialHeap}
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (request : TokenFirstInitializedConstruction.Request original)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angles : TokenAutoregressive.Angles) (locals : Nat → Locals)

def context : Context p where
  parameters := CheckpointDictionaryBinding.pipeline_parameters p encoded binding
  primitive := primitive
  sampling := sampling
  samplingPrimitive := samplingPrimitive
  angles := angles
  locals := locals

noncomputable def ready : Ready p 1 request.frontier.cursor where
  state := CheckpointFirstTokenMemory.after encoded binding request primitive sampling samplingPrimitive angles
    (locals 0).lse (locals 0).tile (locals 0).finish
  parameters := CheckpointFirstTokenMemory.parametersAfter encoded binding request primitive sampling samplingPrimitive angles
    (locals 0).lse (locals 0).tile (locals 0).finish
  frontier := ⟨request.first.nextCursor,request.first.next_aligned⟩
  ordered := (CheckpointSecondTokenMemory.first_cut request).trans
    ((Nat.le_add_right _ _).trans ((Nat.le_add_right _ _).trans (Nat.le_add_right _ _)))
  token := CheckpointSecondTokenMemory.first_token_bound encoded binding request primitive sampling samplingPrimitive angles
    (locals 0).lse (locals 0).tile (locals 0).finish
  parametersBound := (CheckpointFirstTokenMemory.parameter_regions encoded binding request primitive sampling samplingPrimitive angles
    (locals 0).lse (locals 0).tile (locals 0).finish _).mpr request.parameters
  cachesBound := CheckpointSecondTokenMemory.first_cache_bound encoded binding request primitive sampling samplingPrimitive angles
    (locals 0).lse (locals 0).tile (locals 0).finish
  cachesAbove := ResidualDeltaHighWater.cacheProtected_mono _ _ _
    (fun _ _ lower => (CheckpointSecondTokenMemory.first_cut request).trans lower)
    (TokenFirstCacheGeometry.checkpoint_after_geometry encoded binding request primitive sampling samplingPrimitive angles
      (locals 0).lse (locals 0).tile (locals 0).finish).1
  pairwise := (TokenFirstCacheGeometry.checkpoint_after_geometry encoded binding request primitive sampling samplingPrimitive angles
    (locals 0).lse (locals 0).tile (locals 0).finish).2

theorem trace :
    CheckpointTokenMemory.Trace encoded binding original request.initialization request.initial_safe primitive sampling samplingPrimitive angles
      (ready encoded binding request primitive sampling samplingPrimitive angles locals).state
      (ready encoded binding request primitive sampling samplingPrimitive angles locals).parameters :=
  CheckpointFirstTokenMemory.trace encoded binding request primitive sampling samplingPrimitive angles
    (locals 0).lse (locals 0).tile (locals 0).finish

theorem parameters_regions (property : Nat → Nat → Prop) :
    (ready encoded binding request primitive sampling samplingPrimitive angles locals).parameters.Protected property ↔ original.Protected property :=
  CheckpointFirstTokenMemory.parameter_regions encoded binding request primitive sampling samplingPrimitive angles
    (locals 0).lse (locals 0).tile (locals 0).finish property

theorem parameter_bytes (region : TokenParameterConstruction.Region original base size) (offset : Nat) (bound : offset<size) :
    (ready encoded binding request primitive sampling samplingPrimitive angles locals).state.index.bytes (base+offset)=initialHeap (base+offset) :=
  CheckpointFirstTokenMemory.parameter_bytes encoded binding request primitive sampling samplingPrimitive angles
    (locals 0).lse (locals 0).tile (locals 0).finish region offset bound

end Inference.Models.Qwen.CheckpointReadyMemory
