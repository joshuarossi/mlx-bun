import models.qwen.TokenAutoregressiveMemoryConstruction
import models.qwen.Qwen38TrellisM1MaxParameterMemory

namespace Inference.Models.Qwen.TokenParameterMemory
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

structure Storage (p : Pipeline) (memory : ByteMemory.Bytes) where
  embedding : QuantizedEmbeddingDevice.Storage p.embedding
  packedShared : embedding.packed=memory
  scalesShared : embedding.scales.bytes=memory
  biasesShared : embedding.biases.bytes=memory
  graph : Qwen38TrellisM1MaxParameterMemory.Storage p.graph memory

variable {p : Pipeline} {memory : ByteMemory.Bytes}

def Storage.Protected (s : Storage p memory) (property : Nat → Nat → Prop) : Prop :=
  property s.embedding.packedBase (4*(248320*640)) ∧
  property s.embedding.scales.base (2*(248320*80)) ∧
  property s.embedding.biases.base (2*(248320*80)) ∧ s.graph.Protected property

theorem Storage.protected_mono (s : Storage p memory) {first second : Nat → Nat → Prop}
    (implies : ∀ base size, first base size → second base size) (safe : s.Protected first) : s.Protected second :=
  ⟨implies _ _ safe.1,implies _ _ safe.2.1,implies _ _ safe.2.2.1,s.graph.protected_mono implies safe.2.2.2⟩

def Storage.reframe (s : Storage p memory) (after : ByteMemory.Bytes)
    (same : s.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset))) : Storage p after where
  embedding := {
    packed := after
    packedBase := s.embedding.packedBase
    aligned := s.embedding.aligned
    bounded := s.embedding.bounded
    attached := by
      intro token i
      rw [ArrayFrame.word_congr memory after s.embedding.packedBase (4*(248320*640)) _ same.1
        (by have := token.isLt; have := i.isLt; omega)]
      exact ((congrArg (fun bytes => ByteMemory.load32 bytes (s.embedding.packedBase+4*(token.val*640+i.val))) s.packedShared).symm).trans
        (s.embedding.attached token i)
    scales := ArrayFrame.bf s.embedding.scales after (fun offset bound =>
      (same.2.1 offset bound).trans (congrFun s.scalesShared _).symm)
    biases := ArrayFrame.bf s.embedding.biases after (fun offset bound =>
      (same.2.2.1 offset bound).trans (congrFun s.biasesShared _).symm) }
  packedShared := rfl
  scalesShared := rfl
  biasesShared := rfl
  graph := s.graph.reframe after same.2.2.2

theorem Storage.reframe_protected (s : Storage p memory) (after : ByteMemory.Bytes)
    (same : s.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset)))
    (property : Nat → Nat → Prop) : (s.reframe after same).Protected property ↔ s.Protected property :=
  and_congr Iff.rfl (and_congr Iff.rfl (and_congr Iff.rfl (s.graph.reframe_protected after same.2.2.2 property)))

variable {time : Nat} {before : TokenAutoregressiveMemory.State p time}
  {angle : RopeAngles.Inputs} {sampling : LogSumExpRanges.Platform}

def StepSafe (step : TokenAutoregressiveMemory.Step p sampling before angle) (base size : Nat) : Prop :=
  step.embedding.regions.Live base size ∧ Qwen38TrellisM1MaxSamplingMemory.Safe step.sampled base size

theorem step_frame (step : TokenAutoregressiveMemory.Step p sampling before angle)
    (safe : StepSafe step base size) (offset : Nat) (bound : offset<size) :
    step.sampled.memory (base+offset)=before.index.bytes (base+offset) := by
  have sampled := step.sampled.other_region safe.2 offset bound
  rw [step.inputLinked] at sampled
  exact sampled.trans ((congrFun step.embedding.buffers_shared.1 _).trans
    ((step.embedding.other_region safe.1 offset bound).trans
      (congrFun (congrArg Inference.State.TokenStorage.Buffer.bytes step.indexLinked) _)))

variable {parameters : TokenSequenceRanges.Parameters p}
  {primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph}
  {samplingPrimitive : LogSumExpRanges.Primitives sampling}

def Storage.afterStep (s : Storage p before.index.bytes)
    (step : TokenAutoregressiveMemory.Step p sampling before angle) (safe : s.Protected (StepSafe step)) :
    Storage p step.sampled.memory :=
  s.reframe _ (s.protected_mono (fun _ _ region => step_frame step region) safe)

def Storage.afterAdvance (s : Storage p before.index.bytes)
    (angleBound : RopeAnglesRanges.InputsBound angle) (supported : time+1≤262144)
    (aim ae : RopeAngles.Target) (angleError : RopeAngles.InputError angle aim ae) (base : 0≤aim.base)
    (step : TokenAutoregressiveMemory.Step p sampling before angle) (safe : s.Protected (StepSafe step)) :
    Storage p (TokenAutoregressiveMemory.advance p parameters primitive sampling samplingPrimitive before angle angleBound supported aim ae angleError base step).index.bytes :=
  s.afterStep step safe

theorem Storage.afterAdvance_protected (s : Storage p before.index.bytes)
    (angleBound : RopeAnglesRanges.InputsBound angle) (supported : time+1≤262144)
    (aim ae : RopeAngles.Target) (angleError : RopeAngles.InputError angle aim ae) (base : 0≤aim.base)
    (step : TokenAutoregressiveMemory.Step p sampling before angle) (safe : s.Protected (StepSafe step))
    (property : Nat → Nat → Prop) :
    (s.afterAdvance (parameters:=parameters) (primitive:=primitive) (samplingPrimitive:=samplingPrimitive)
      angleBound supported aim ae angleError base step safe).Protected property ↔ s.Protected property :=
  s.reframe_protected step.sampled.memory (s.protected_mono (fun _ _ region => step_frame step region) safe) property

open TokenAutoregressiveMemoryConstruction

-- Geometry is required only at each state that this finite trace reaches.
inductive FramedTrace (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (initialPlan : InitialCacheMemory.Plan p.graph.stages) (initialMemory : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token)
    (shared : index.bytes=InitialCacheMemory.execute p.graph.stages initialPlan initialMemory)
    (angles : TokenAutoregressive.Angles) (property : Nat → Nat → Prop) :
    {time : Nat} → TokenAutoregressiveMemory.State p time → Prop where
  | initial : FramedTrace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles property
      (TokenAutoregressiveMemory.initial p token initialPlan initialMemory index shared)
  | step {time : Nat} {before : TokenAutoregressiveMemory.State p time}
      (previous : FramedTrace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles property before)
      (supported : time+1≤262144) (plan : Plan before (angles.value time) sampling)
      (safe : ∀ base size, property base size → StepSafe plan.step base size) :
      FramedTrace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles property
        (TokenAutoregressiveMemory.advance p parameters primitive sampling samplingPrimitive before
          (angles.value time) (angles.ranges time (by omega)) supported (angles.target time) (angles.error time)
          (angles.accuracy time (by omega)) (angles.base time (by omega)) plan.step)

variable {token : Fin 248320} {initialPlan : InitialCacheMemory.Plan p.graph.stages} {initialMemory : ByteMemory.Bytes}
  {index : Inference.State.TokenStorage.Buffer token}
  {shared : index.bytes=InitialCacheMemory.execute p.graph.stages initialPlan initialMemory}
  {angles : TokenAutoregressive.Angles} {property : Nat → Nat → Prop}

theorem FramedTrace.execution (trace : FramedTrace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles property before) :
    Trace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles before := by
  induction trace with
  | initial => exact .initial
  | step previous supported plan safe ih => exact .step ih supported plan

theorem FramedTrace.frame (trace : FramedTrace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles property before)
    (safe : property base size) (offset : Nat) (bound : offset<size) :
    before.index.bytes (base+offset)=index.bytes (base+offset) := by
  induction trace with
  | initial => rfl
  | step previous supported plan geometry ih =>
    exact (step_frame plan.step (geometry _ _ safe) offset bound).trans ih

def FramedTrace.retained (trace : FramedTrace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles property before)
    (original : Storage p index.bytes) (safe : original.Protected property) : Storage p before.index.bytes :=
  original.reframe _ (original.protected_mono (fun _ _ region => trace.frame region) safe)

theorem FramedTrace.retained_protected (trace : FramedTrace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles property before)
    (original : Storage p index.bytes) (safe : original.Protected property) (next : Nat → Nat → Prop) :
    (trace.retained original safe).Protected next ↔ original.Protected next := original.reframe_protected _ _ next

theorem Storage.reframe_embedding_bases (s : Storage p memory) (after : ByteMemory.Bytes)
    (same : s.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset))) :
    (s.reframe after same).embedding.packedBase=s.embedding.packedBase ∧
    (s.reframe after same).embedding.scales.base=s.embedding.scales.base ∧
    (s.reframe after same).embedding.biases.base=s.embedding.biases.base := ⟨rfl,rfl,rfl⟩

theorem FramedTrace.original_bytes (trace : FramedTrace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles property before)
    (original : Storage p index.bytes) (safe : original.Protected property) :
    original.Protected (fun base size => ∀ offset < size, before.index.bytes (base+offset)=index.bytes (base+offset)) :=
  original.protected_mono (fun _ _ region => trace.frame region) safe

theorem FramedTrace.readback (trace : FramedTrace p parameters primitive sampling samplingPrimitive token initialPlan initialMemory index shared angles property before)
    (supported : time≤262144) :
    let reference := TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles time supported
    (before.index.read,before.readCaches)=(reference.token.val,reference.cache) := trace.execution.readback supported

end Inference.Models.Qwen.TokenParameterMemory
