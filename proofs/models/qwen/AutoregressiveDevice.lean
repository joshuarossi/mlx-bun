import models.qwen.TokenDevice
import models.qwen.AutoregressiveActivation

namespace Inference.Models.Qwen.AutoregressiveDevice
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
set_option maxRecDepth 10000
attribute [local irreducible] GreedySampling.sample

abbrev State := AutoregressiveActivation.State
abbrev initial := AutoregressiveActivation.initial

abbrev Schedules (p : Pipeline) (sampling : LogSumExpRanges.Platform) (angles : TokenAutoregressive.Angles) :=
  ∀ (time : Nat) (cache : p.graph.Cache time) (token : Fin 248320) (storage : DecodeStorage.Storage p.graph.stages cache),
    TokenDevice.Execution p sampling cache token (angles.value time) storage

def Schedules.fromStorage (p : Pipeline) (sampling : LogSumExpRanges.Platform) (angles : TokenAutoregressive.Angles)
    (weights : Layers.QuantizedEmbeddingDevice.Storage p.embedding) : Schedules p sampling angles :=
  fun _ cache token storage => TokenDevice.Execution.fromStorage p sampling cache token _ storage weights

theorem execution_eq (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : TokenDevice.Execution p sampling before.logical.cache before.logical.token angle before.storage) :
    execution.run=TokenSampledSequenceRanges.run p sampling before.logical.cache before.logical.token angle := by
  have ranges := TokenSequenceRanges.run_correct p parameters primitive before.logical.cache before.logical.cacheBound
    before.logical.targetCache before.logical.errorCache before.logical.cacheError before.logical.token angle ha supported aim ae he hb
  exact execution.run_eq samplingPrimitive ranges.2.2.1

-- The next token is decoded from the final uint32 store. Its range and all
-- cache invariants are derived from the kernel refinements and reachable
-- numerical contracts, rather than assumed for this step's output.
private def reindexStorage {p : Pipeline} {time : Nat} {a b : p.graph.Cache time} (equal : a=b)
    (storage : DecodeStorage.Storage p.graph.stages a) : DecodeStorage.Storage p.graph.stages b := by
  cases equal
  exact storage

private theorem reindexStorage_heq {p : Pipeline} {time : Nat} {a b : p.graph.Cache time} (equal : a=b)
    (storage : DecodeStorage.Storage p.graph.stages a) : HEq (reindexStorage equal storage) storage := by
  cases equal
  rfl

private theorem reference_result (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    let reference := TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.logical angle ha supported aim ae he hb
    (reference.token.val, reference.cache)=TokenSampledSequenceRanges.run p sampling before.logical.cache before.logical.token angle := rfl

attribute [local irreducible] TokenAutoregressive.advance

noncomputable def advance (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : TokenDevice.Execution p sampling before.logical.cache before.logical.token angle before.storage) : State p (time+1) := by
  let reference := TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.logical angle ha supported aim ae he hb
  have resultEq : execution.run=(reference.token.val, reference.cache) :=
    (execution_eq p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb execution).trans
      (reference_result p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb).symm
  have cacheEq : execution.run.2=reference.cache := congrArg Prod.snd resultEq
  exact ⟨reference, reindexStorage (p := p) cacheEq execution.after⟩

theorem advance_logical (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : TokenDevice.Execution p sampling before.logical.cache before.logical.token angle before.storage) :
    (advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb execution).logical=
      TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.logical angle ha supported aim ae he hb := rfl

theorem advance_token_read (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : TokenDevice.Execution p sampling before.logical.cache before.logical.token angle before.storage) :
    (advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb execution).logical.token.val=
      (ByteMemory.load32 execution.selection.selection.output.memory 0).toNat := by
  have resultEq := (execution_eq p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb execution).trans
    (reference_result p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb).symm
  exact (congrArg Prod.fst resultEq).symm.trans execution.token_read

theorem advance_storage (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : TokenDevice.Execution p sampling before.logical.cache before.logical.token angle before.storage) :
    HEq (advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb execution).storage execution.after :=
  reindexStorage_heq _ _

noncomputable def run (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (schedules : Schedules p sampling angles) :
    (steps : Nat) → steps ≤ 262144 → State p steps
  | 0, _ => initial p token
  | time+1, supported =>
    let before := run p parameters primitive sampling samplingPrimitive token angles schedules time (by omega)
    advance p parameters primitive sampling samplingPrimitive before (angles.value time) (angles.ranges time (by omega))
      supported (angles.target time) (angles.error time) (angles.accuracy time (by omega)) (angles.base time (by omega))
      (schedules time before.logical.cache before.logical.token before.storage)

theorem run_logical (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (schedules : Schedules p sampling angles) (steps : Nat) (supported : steps ≤ 262144) :
    (run p parameters primitive sampling samplingPrimitive token angles schedules steps supported).logical=
      TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles steps supported := by
  induction steps with
  | zero => rfl
  | succ time ih => simp only [run, advance_logical, ih, TokenAutoregressive.run]

theorem schedule_independent (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (a b : Schedules p sampling angles) (steps : Nat) (supported : steps ≤ 262144) :
    (run p parameters primitive sampling samplingPrimitive token angles a steps supported).logical=
      (run p parameters primitive sampling samplingPrimitive token angles b steps supported).logical := by
  rw [run_logical, run_logical]

theorem checkpoint_logical (p : Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (schedules : Schedules p sampling RopeInputConstruction.angles) (steps : Nat) (supported : steps ≤ 262144) :
    (run p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding) primitive sampling samplingPrimitive
      token RopeInputConstruction.angles schedules steps supported).logical=
      Qwen38TrellisM1MaxInference.run p encoded binding primitive sampling samplingPrimitive token steps supported :=
  run_logical p _ primitive sampling samplingPrimitive token RopeInputConstruction.angles schedules steps supported

end Inference.Models.Qwen.AutoregressiveDevice
