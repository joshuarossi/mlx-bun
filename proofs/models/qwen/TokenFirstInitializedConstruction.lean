import models.qwen.TokenFirstPlanConstruction
import models.qwen.TokenInitializationHighWater
import models.qwen.TokenInitializedConstruction

-- Positive first-token execution from a loaded parameter heap and one fresh
-- arena. Primitive contracts and loaded attachment remain explicit.
namespace Inference.Models.Qwen.TokenFirstInitializedConstruction
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open TokenBoundaryHighWater (Before)
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages DecodeHighWaterConstruction.bytes

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  {original : TokenParameterMemory.Storage p initialHeap}

private theorem prefix_room (cursor first rest limit : Nat) (room : cursor+(first+rest)≤limit) : cursor+first≤limit :=
  (Nat.le_add_right _ rest).trans (by simpa only [Nat.add_assoc] using room)

private theorem suffix_room (cursor first rest limit : Nat) (room : cursor+(first+rest)≤limit) : cursor+first+rest≤limit := by simpa only [Nat.add_assoc] using room

structure Request (original : TokenParameterMemory.Storage p initialHeap) where
  token : Fin 248320
  frontier : ResidualDeltaHighWater.Frontier
  room : frontier.cursor+(TokenInitializationHighWater.bytes+TokenFirstPlanConstruction.bytes p)≤2^64
  parameters : original.Protected (Before frontier.cursor)
  dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages

variable (request : Request original)

theorem Request.initial_room : (TokenInitializationHighWater.next request.frontier).cursor≤2^64 :=
  prefix_room _ _ _ _ request.room

def Request.ready : TokenInitializationMemory.Initialized p :=
  TokenInitializationHighWater.initialized original request.token request.frontier request.initial_room request.parameters

def Request.first : TokenFirstPlanConstruction.Request (state:=request.ready.state) request.ready.parameters where
  cursor := (TokenInitializationHighWater.next request.frontier).cursor
  aligned := (TokenInitializationHighWater.next request.frontier).aligned
  room := suffix_room _ _ _ _ request.room
  token := TokenInitializationHighWater.token_bound original request.token request.frontier request.initial_room request.parameters
  parameters := TokenInitializationHighWater.parameters_bound original request.token request.frontier request.initial_room request.parameters
  caches := TokenInitializationHighWater.cache_bound original request.token request.frontier request.initial_room request.parameters
  dispatch := request.dispatch

def Request.initialization : TokenInitializationMemory.Plan p request.token initialHeap :=
  (TokenInitializationHighWater.workspace (p:=p) request.frontier request.initial_room).plan

theorem Request.initial_safe : original.Protected request.initialization.Safe :=
  original.protected_mono (fun _ _ bound =>
    (TokenInitializationHighWater.workspace (p:=p) request.frontier request.initial_room).protect
      (TokenBoundaryHighWater.fresh bound)) request.parameters

theorem Request.ready_eq : request.ready = TokenInitializationMemory.fromStorage original request.initialization request.initial_safe := rfl

attribute [local irreducible] Request.ready Request.first

variable (parameters : TokenSequenceRanges.Parameters p)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angles : TokenAutoregressive.Angles)
  (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

def Request.plan : TokenParameterConstruction.Plan (before:=request.ready.state) request.ready.parameters (angles.value 0) sampling :=
  request.first.plan (angles.value 0) sampling lseLocal tileLocal finishLocal

attribute [local irreducible] Request.plan

theorem Request.plan_safe : request.ready.parameters.Protected (TokenParameterMemory.StepSafe
    (request.plan sampling angles lseLocal tileLocal finishLocal).step) :=
  by
  unfold Request.plan
  exact request.first.parameters_safe (angles.value 0) sampling lseLocal tileLocal finishLocal

noncomputable def Request.after : TokenAutoregressiveMemory.State p 1 :=
  TokenAutoregressiveMemory.advance p parameters primitive sampling samplingPrimitive request.ready.state
    (angles.value 0) (angles.ranges 0 (by decide)) (by decide) (angles.target 0) (angles.error 0)
    (angles.accuracy 0 (by decide)) (angles.base 0 (by decide))
    (request.plan sampling angles lseLocal tileLocal finishLocal).step

def Request.parametersAfter : TokenParameterMemory.Storage p
    (request.after parameters primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).index.bytes :=
  (request.plan sampling angles lseLocal tileLocal finishLocal).nextParameters
    (parameters:=parameters) (primitive:=primitive) (samplingPrimitive:=samplingPrimitive)
    (angles.ranges 0 (by decide)) (by decide) (angles.target 0) (angles.error 0)
    (angles.accuracy 0 (by decide)) (angles.base 0 (by decide))
    (request.plan_safe sampling angles lseLocal tileLocal finishLocal)

theorem Request.trace :
    TokenInitializedConstruction.Trace original request.initialization request.initial_safe
      parameters primitive sampling samplingPrimitive angles
      (request.after parameters primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal)
      (request.parametersAfter parameters primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal) := by
  have start : TokenInitializedConstruction.Trace original request.initialization request.initial_safe
      parameters primitive sampling samplingPrimitive angles request.ready.state request.ready.parameters := by
    rw [request.ready_eq]
    exact TokenInitializedConstruction.initial original request.initialization request.initial_safe
      parameters primitive sampling samplingPrimitive angles
  exact TokenParameterConstruction.Trace.step (before:=request.ready.state) (current:=request.ready.parameters)
    start (by decide)
    (request.plan sampling angles lseLocal tileLocal finishLocal)
    (request.plan_safe sampling angles lseLocal tileLocal finishLocal)

theorem Request.readback :
    let reference := TokenAutoregressive.run p parameters primitive sampling samplingPrimitive request.token angles 1 (by decide)
    let actual := request.after parameters primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  TokenInitializedConstruction.readback (request.trace parameters primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal) (by decide)

theorem Request.parameter_bytes
    (region : TokenParameterConstruction.Region original base size) (offset : Nat) (bound : offset<size) :
    (request.after parameters primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).index.bytes (base+offset)=initialHeap (base+offset) :=
  TokenInitializedConstruction.parameter_bytes
    (request.trace parameters primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal) region offset bound

theorem Request.parameters_regions (property : Nat → Nat → Prop) :
    (request.parametersAfter parameters primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal).Protected property ↔
      original.Protected property :=
  TokenInitializedConstruction.parameters_regions
    (request.trace parameters primitive sampling samplingPrimitive angles lseLocal tileLocal finishLocal) property

end Inference.Models.Qwen.TokenFirstInitializedConstruction
