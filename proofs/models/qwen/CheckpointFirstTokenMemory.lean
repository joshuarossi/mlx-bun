import models.qwen.TokenFirstInitializedConstruction
import models.qwen.CheckpointTokenMemory

-- The existing checkpoint dictionary certificates supply the numerical
-- Parameters witness for a constructed positive first-token heap trace.
-- Ordered encoding/bindings, loaded-byte attachment, primitive contracts and
-- a fresh workspace remain explicit. The workspace excludes checkpoint bytes;
-- no native allocator/compiler correspondence or useful final error is claimed.
namespace Inference.Models.Qwen.CheckpointFirstTokenMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages DecodeHighWaterConstruction.bytes
  TokenFirstInitializedConstruction.Request.ready TokenFirstInitializedConstruction.Request.first
  TokenFirstInitializedConstruction.Request.plan Qwen38TrellisM1MaxMemory.Execution.logitsBuffer

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  {original : TokenParameterMemory.Storage p initialHeap}

-- Includes the initialization padding and all first-token temporary arenas.
theorem workspace_bound (p : Pipeline) :
    TokenInitializationHighWater.bytes+TokenFirstPlanConstruction.bytes p≤604918000 := by
  change 153944080+(13120+DecodeHighWaterConstruction.bytes p.graph.stages 0+506880+1952)≤604918000
  exact Nat.add_le_add_left
    (Nat.add_le_add_right (Nat.add_le_add_right
      (Nat.add_le_add_left (DecodeHighWaterConstruction.first_token_footprint p.graph) 13120) 506880) 1952) 153944080

def fromWorkspace (token : Fin 248320) (frontier : ResidualDeltaHighWater.Frontier)
    (room : frontier.cursor+604918000≤2^64)
    (parameters : original.Protected (TokenBoundaryHighWater.Before frontier.cursor))
    (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages) :
    TokenFirstInitializedConstruction.Request original where
  token := token
  frontier := frontier
  room := (Nat.add_le_add_left (workspace_bound p) frontier.cursor).trans room
  parameters := parameters
  dispatch := dispatch

variable (encoded : CheckpointDictionaryBinding.Encoding)
  (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (request : TokenFirstInitializedConstruction.Request original)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angles : TokenAutoregressive.Angles)
  (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

noncomputable def after : TokenAutoregressiveMemory.State p 1 :=
  request.after (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal

def parametersAfter : TokenParameterMemory.Storage p
    (after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).index.bytes :=
  request.parametersAfter (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal

theorem trace : CheckpointTokenMemory.Trace encoded binding original request.initialization request.initial_safe
    primitive sampling samplingPrimitive angles
    (after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal)
    (parametersAfter encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal) :=
  request.trace (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal

theorem readback :
    let reference := CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive request.token angles 1 (by decide)
    let actual := after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  CheckpointTokenMemory.readback
    (trace encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal) (by decide)

theorem parameter_bytes (region : TokenParameterConstruction.Region original base size) (offset : Nat) (bound : offset<size) :
    (after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).index.bytes (base+offset)=initialHeap (base+offset) :=
  CheckpointTokenMemory.parameter_bytes
    (trace encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal) region offset bound

theorem parameter_regions (property : Nat → Nat → Prop) :
    (parametersAfter encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).Protected property ↔
      original.Protected property :=
  CheckpointTokenMemory.parameter_regions
    (trace encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal) property

theorem initial_trace :
    CheckpointTokenMemory.Trace encoded binding original request.initialization request.initial_safe
      primitive sampling samplingPrimitive angles request.ready.state request.ready.parameters := by
  rw [request.ready_eq]
  exact CheckpointTokenMemory.initial encoded binding original request.initialization request.initial_safe
    primitive sampling samplingPrimitive angles

-- These are the actual BF reads of the first projection's global logits buffer.
include encoded binding primitive samplingPrimitive in
theorem logits_bound (i : Fin 248320) :
    Model.isFinite ((request.plan sampling angles lseLocal tileLocal finishLocal).graph.forward.logitsBuffer.read i)=true ∧
    |Model.toReal ((request.plan sampling angles lseLocal tileLocal finishLocal).graph.forward.logitsBuffer.read i)|≤(2:ℝ)^(18:Nat) := by
  rw [ArrayStorage.BFBuffer.read_correct]
  exact CheckpointTokenMemory.step_logits_bound
    (initial_trace encoded binding request primitive sampling samplingPrimitive angles)
    (request.plan sampling angles lseLocal tileLocal finishLocal) (angles.ranges 0 (by decide)) (by decide) i

include encoded binding primitive samplingPrimitive in
theorem final_logits_bound (i : Fin 248320) :
    Model.isFinite ((request.plan sampling angles lseLocal tileLocal finishLocal).sampled.sampler.selection.logitsAfter.read i)=true ∧
    |Model.toReal ((request.plan sampling angles lseLocal tileLocal finishLocal).sampled.sampler.selection.logitsAfter.read i)|≤(2:ℝ)^(18:Nat) := by
  have bound := logits_bound encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal i
  rw [ArrayStorage.BFBuffer.read_correct] at bound ⊢
  exact bound

theorem final_logits_shared :
    (request.plan sampling angles lseLocal tileLocal finishLocal).sampled.sampler.selection.logitsAfter.bytes=
      (after encoded binding request primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).index.bytes := by
  unfold after TokenFirstInitializedConstruction.Request.after
  rw [TokenAutoregressiveMemory.advance_index_bytes]
  exact (request.plan sampling angles lseLocal tileLocal finishLocal).sampled.sampler.selection.shared.1

-- The existing error budget is symbolic, with no asserted small final value.
include samplingPrimitive in
theorem accuracy (i : Fin 248320) :
    |Model.toReal ((request.plan sampling angles lseLocal tileLocal finishLocal).graph.forward.logitsBuffer.read i)-
      (p.targetRun request.ready.state.logical.targetCache request.ready.state.logical.token (angles.target 0)).1 i|≤
    (TokenSampledSequenceRanges.budget p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
      primitive request.ready.state.logical.cache request.ready.state.logical.cacheBound request.ready.state.logical.targetCache
      request.ready.state.logical.errorCache request.ready.state.logical.token (angles.value 0) (angles.ranges 0 (by decide))
      (by decide) (angles.target 0) (angles.error 0)).1 i := by
  rw [ArrayStorage.BFBuffer.read_correct]
  exact CheckpointTokenMemory.step_accuracy
    (initial_trace encoded binding request primitive sampling samplingPrimitive angles)
    (request.plan sampling angles lseLocal tileLocal finishLocal) (angles.ranges 0 (by decide)) (by decide)
    (angles.target 0) (angles.error 0) (angles.accuracy 0 (by decide)) (angles.base 0 (by decide)) i

end Inference.Models.Qwen.CheckpointFirstTokenMemory
