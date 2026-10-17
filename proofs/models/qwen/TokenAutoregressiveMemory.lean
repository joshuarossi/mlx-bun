import models.qwen.Qwen38TrellisM1MaxSamplingMemory
import models.qwen.TokenAutoregressive
import layers.QuantizedEmbeddingMemory

namespace Inference.Models.Qwen.TokenAutoregressiveMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- Token and every retained cache refer to one physical heap at each step.
structure State (p : Pipeline) (time : Nat) where
  logical : TokenAutoregressive.State p time
  index : Inference.State.TokenStorage.Buffer logical.token
  caches : DecodeFrame.Storage p.graph.stages logical.cache index.bytes

def transportCaches (same : first=second) (storage : DecodeFrame.Storage stages cache first) :
    DecodeFrame.Storage stages cache second := same ▸ storage

variable {p : Pipeline} {time : Nat} {sampling : LogSumExpRanges.Platform}

def embeddingCaches (before : State p time)
    (embedding : Layers.QuantizedEmbeddingMemory.Execution p.embedding before.logical.token)
    (linked : embedding.tokenBuffer=before.index)
    (safe : DecodePreservation.Protected embedding.regions.Live p.graph.stages before.logical.cache before.index.bytes before.caches) :
    DecodeFrame.Storage p.graph.stages before.logical.cache embedding.forwardBuffer.bytes :=
  DecodePreservation.reframe embedding.regions.Live before.index.bytes embedding.forwardBuffer.bytes
    (fun _ _ region offset bound => (congrFun embedding.buffers_shared.1 _).trans
      ((embedding.other_region region offset bound).trans (congrFun (congrArg Inference.State.TokenStorage.Buffer.bytes linked) _)))
    p.graph.stages before.logical.cache before.caches safe

structure Step (p : Pipeline) (sampling : LogSumExpRanges.Platform) (before : State p time) (angle : RopeAngles.Inputs) where
  embedding : Layers.QuantizedEmbeddingMemory.Execution p.embedding before.logical.token
  indexLinked : embedding.tokenBuffer=before.index
  embeddingSafe : DecodePreservation.Protected embedding.regions.Live p.graph.stages before.logical.cache before.index.bytes before.caches
  sampled : Qwen38TrellisM1MaxSamplingMemory.Execution p.graph before.logical.cache (p.embedding.forward before.logical.token) angle sampling
  inputLinked : sampled.forward.source=embedding.forwardBuffer
  cacheLinked : sampled.forward.storage=transportCaches (congrArg ArrayStorage.BFBuffer.bytes inputLinked).symm
    (embeddingCaches before embedding indexLinked embeddingSafe)

-- Transport changes the semantic token index while keeping its physical
-- bytes and address definitionally identical.
def reindexToken {first second : Fin 248320} (same : first=second) (buffer : Inference.State.TokenStorage.Buffer first) :
    Inference.State.TokenStorage.Buffer second where
  bytes := buffer.bytes
  base := buffer.base
  aligned := buffer.aligned
  bounded := buffer.bounded
  attached := by rw [← same]; exact buffer.attached

variable {before : State p time} {angle : RopeAngles.Inputs}

theorem Step.logitsBound (_step : Step p sampling before angle) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph) (angleBound : RopeAnglesRanges.InputsBound angle)
    (supported : time+1≤262144) :
    ∀ i, Model.isFinite (p.graph.forward before.logical.cache (p.embedding.forward before.logical.token) angle i)=true ∧
      |Model.toReal (p.graph.forward before.logical.cache (p.embedding.forward before.logical.token) angle i)|≤(2:ℝ)^(23:Nat) :=
  (Qwen38TrellisM1MaxSequenceRanges.checked p.graph parameters.graph primitive before.logical.cache before.logical.cacheBound
    (p.embedding.forward before.logical.token) (TokenSequenceRanges.embedding_bound p parameters before.logical.token) angle angleBound supported).output

noncomputable def advance (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (angleBound : RopeAnglesRanges.InputsBound angle)
    (supported : time+1≤262144) (aim ae : RopeAngles.Target)
    (angleError : RopeAngles.InputError angle aim ae) (base : 0≤aim.base)
    (step : Step p sampling before angle) : State p (time+1) := by
  let reference := TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.logical angle angleBound supported aim ae angleError base
  let bound := step.logitsBound parameters primitive angleBound supported
  have token : step.sampled.selected samplingPrimitive bound=reference.token := by
    apply Fin.ext
    change step.sampled.sampler.selection.token=reference.token.val
    rw [step.sampled.token_eq samplingPrimitive bound]
    rfl
  exact ⟨reference,reindexToken token (step.sampled.index samplingPrimitive bound),step.sampled.afterCache⟩

theorem advance_logical (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (angleBound : RopeAnglesRanges.InputsBound angle)
    (supported : time+1≤262144) (aim ae : RopeAngles.Target)
    (angleError : RopeAngles.InputError angle aim ae) (base : 0≤aim.base)
    (step : Step p sampling before angle) :
    (advance p parameters primitive sampling samplingPrimitive before angle angleBound supported aim ae angleError base step).logical=
      TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.logical angle angleBound supported aim ae angleError base := rfl

theorem advance_index_bytes (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (angleBound : RopeAnglesRanges.InputsBound angle)
    (supported : time+1≤262144) (aim ae : RopeAngles.Target)
    (angleError : RopeAngles.InputError angle aim ae) (base : 0≤aim.base)
    (step : Step p sampling before angle) :
    (advance p parameters primitive sampling samplingPrimitive before angle angleBound supported aim ae angleError base step).index.bytes=step.sampled.memory := rfl

def initial (p : Pipeline) (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token) (shared : index.bytes=InitialCacheMemory.execute p.graph.stages plan before) : State p 0 :=
  ⟨TokenAutoregressive.initial p token,index,transportCaches shared.symm (DecodeFrame.initial p.graph.stages plan before)⟩

abbrev Schedules (p : Pipeline) (sampling : LogSumExpRanges.Platform) (angles : TokenAutoregressive.Angles) :=
  ∀ (time : Nat) (before : State p time), Step p sampling before (angles.value time)

noncomputable def run (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token) (shared : index.bytes=InitialCacheMemory.execute p.graph.stages plan before)
    (angles : TokenAutoregressive.Angles) (schedules : Schedules p sampling angles) :
    (steps : Nat) → steps≤262144 → State p steps
  | 0,_ => initial p token plan before index shared
  | time+1,supported =>
    let before := run p parameters primitive sampling samplingPrimitive token plan before index shared angles schedules time (by omega)
    advance p parameters primitive sampling samplingPrimitive before (angles.value time) (angles.ranges time (by omega)) supported
      (angles.target time) (angles.error time) (angles.accuracy time (by omega)) (angles.base time (by omega)) (schedules time before)

theorem run_logical (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token) (shared : index.bytes=InitialCacheMemory.execute p.graph.stages plan before)
    (angles : TokenAutoregressive.Angles) (schedules : Schedules p sampling angles) (steps : Nat) (supported : steps≤262144) :
    (run p parameters primitive sampling samplingPrimitive token plan before index shared angles schedules steps supported).logical=
      TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles steps supported := by
  induction steps with
  | zero => rfl
  | succ time ih => simp only [run,advance_logical,ih,TokenAutoregressive.run]

theorem token_read (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token) (shared : index.bytes=InitialCacheMemory.execute p.graph.stages plan before)
    (angles : TokenAutoregressive.Angles) (schedules : Schedules p sampling angles) (steps : Nat) (supported : steps≤262144) :
    (run p parameters primitive sampling samplingPrimitive token plan before index shared angles schedules steps supported).index.read=
      (TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles steps supported).token.val := by
  rw [Inference.State.TokenStorage.Buffer.read_correct,run_logical]

def State.readCaches (state : State p time) : p.graph.Cache time :=
  DecodeFrameRead.caches p.graph.stages state.logical.cache state.index.bytes state.caches

theorem State.caches_eq (state : State p time) : state.readCaches=state.logical.cache := DecodeFrameRead.caches_eq _ _ _ _

theorem run_readback (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token) (shared : index.bytes=InitialCacheMemory.execute p.graph.stages plan before)
    (angles : TokenAutoregressive.Angles) (schedules : Schedules p sampling angles) (steps : Nat) (supported : steps≤262144) :
    let actual := run p parameters primitive sampling samplingPrimitive token plan before index shared angles schedules steps supported
    let reference := TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles steps supported
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) := by
  apply Prod.ext
  · exact token_read p parameters primitive sampling samplingPrimitive token plan before index shared angles schedules steps supported
  · change (run p parameters primitive sampling samplingPrimitive token plan before index shared angles schedules steps supported).readCaches=
      (TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles steps supported).cache
    rw [State.caches_eq]
    exact congrArg TokenAutoregressive.State.cache (run_logical p parameters primitive sampling samplingPrimitive token plan before index shared angles schedules steps supported)

theorem schedule_independent (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token) (shared : index.bytes=InitialCacheMemory.execute p.graph.stages plan before)
    (angles : TokenAutoregressive.Angles) (left right : Schedules p sampling angles) (steps : Nat) (supported : steps≤262144) :
    (run p parameters primitive sampling samplingPrimitive token plan before index shared angles left steps supported).logical=
      (run p parameters primitive sampling samplingPrimitive token plan before index shared angles right steps supported).logical := by
  rw [run_logical,run_logical]

end Inference.Models.Qwen.TokenAutoregressiveMemory
