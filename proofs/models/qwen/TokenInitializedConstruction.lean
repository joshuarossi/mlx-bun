import models.qwen.TokenParameterConstruction
import models.qwen.TokenInitializationMemory

namespace Inference.Models.Qwen.TokenInitializedConstruction
open Contracts.Mlx Layers TokenInference Kernels.Sampling
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {token : Fin 248320} {initialHeap : ByteMemory.Bytes}
  (original : TokenParameterMemory.Storage p initialHeap)
  (initialization : TokenInitializationMemory.Plan p token initialHeap)
  (safe : original.Protected initialization.Safe)
  (parameters : TokenSequenceRanges.Parameters p)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angles : TokenAutoregressive.Angles)

abbrev Trace {time : Nat} (state : TokenAutoregressiveMemory.State p time)
    (current : TokenParameterMemory.Storage p state.index.bytes) :=
  TokenParameterConstruction.Trace p parameters primitive sampling samplingPrimitive token
    initialization.caches initialization.tokenWrite.memory initialization.index rfl
    (TokenInitializationMemory.fromStorage original initialization safe).parameters angles state current

theorem initial :
    Trace original initialization safe parameters primitive sampling samplingPrimitive angles
      (TokenInitializationMemory.fromStorage original initialization safe).state
      (TokenInitializationMemory.fromStorage original initialization safe).parameters := .initial

variable {original initialization safe parameters primitive sampling samplingPrimitive angles}
  {time : Nat} {state : TokenAutoregressiveMemory.State p time}
  {current : TokenParameterMemory.Storage p state.index.bytes}

theorem readback (trace : Trace original initialization safe parameters primitive sampling samplingPrimitive angles state current)
    (supported : time≤262144) :
    let reference := TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles time supported
    (state.index.read,state.readCaches)=(reference.token.val,reference.cache) := trace.readback supported

theorem parameters_regions (trace : Trace original initialization safe parameters primitive sampling samplingPrimitive angles state current)
    (property : Nat → Nat → Prop) : current.Protected property ↔ original.Protected property :=
  (trace.protected property).trans (initialization.parameters_regions original safe property)

theorem parameter_bytes (trace : Trace original initialization safe parameters primitive sampling samplingPrimitive angles state current)
    (region : TokenParameterConstruction.Region original base size) (offset : Nat) (bound : offset<size) :
    state.index.bytes (base+offset)=initialHeap (base+offset) := by
  have initialized : TokenParameterConstruction.Region
      (TokenInitializationMemory.fromStorage original initialization safe).parameters base size :=
    fun property retained => region property ((initialization.parameters_regions original safe property).mp retained)
  exact (trace.frame initialized offset bound).trans (initialization.other_region (region _ safe) offset bound)

theorem packed_bytes (trace : Trace original initialization safe parameters primitive sampling samplingPrimitive angles state current)
    (offset : Nat) (bound : offset<4*(248320*640)) :
    state.index.bytes (original.embedding.packedBase+offset)=initialHeap (original.embedding.packedBase+offset) :=
  parameter_bytes trace (TokenParameterConstruction.packed_region original) offset bound

theorem scales_bytes (trace : Trace original initialization safe parameters primitive sampling samplingPrimitive angles state current)
    (offset : Nat) (bound : offset<2*(248320*80)) :
    state.index.bytes (original.embedding.scales.base+offset)=initialHeap (original.embedding.scales.base+offset) :=
  parameter_bytes trace (TokenParameterConstruction.scales_region original) offset bound

theorem biases_bytes (trace : Trace original initialization safe parameters primitive sampling samplingPrimitive angles state current)
    (offset : Nat) (bound : offset<2*(248320*80)) :
    state.index.bytes (original.embedding.biases.base+offset)=initialHeap (original.embedding.biases.base+offset) :=
  parameter_bytes trace (TokenParameterConstruction.biases_region original) offset bound

theorem graph_bytes (trace : Trace original initialization safe parameters primitive sampling samplingPrimitive angles state current)
    (selected : ∀ property, original.graph.Protected property → property base size) (offset : Nat) (bound : offset<size) :
    state.index.bytes (base+offset)=initialHeap (base+offset) :=
  parameter_bytes trace (TokenParameterConstruction.graph_region original selected) offset bound

end Inference.Models.Qwen.TokenInitializedConstruction
