import models.qwen.DeltaBlockMemory
import models.qwen.DeltaConvolutionParsedSource
import models.qwen.DeltaParsedHeads
import models.qwen.DeltaParsedOutputProjection
import kernels.delta.ComputeGHostMemory
import kernels.delta.DeltaBetaMemory

namespace Inference.Models.Qwen.DeltaParsedPipeline
open Contracts.Mlx Kernels Kernels.Delta Kernels.Normalization Layers
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 2000

variable {history : State.ConvolutionStorage.History} {next : Fin 10240 → ArrayStorage.BF}
  {convWeights : Fin 10240 → Fin 4 → ArrayStorage.BF}
  {convInput : ConvolutionMemory.Input history next convWeights} {contracted : Bool}
  {convolution : ConvolutionMemory.Execution convInput contracted}
  {qScale kScale : Fin 128 → ArrayStorage.BF} {headPlatform : SiluRmsHeads.Platform} {width eps : Float32}
  {aLog a dtBias b : GateDevice.Heads} {gatePlatform : Inputs.Platform}
  {preparation : DeltaConvolutionMemory.Execution convolution qScale kScale headPlatform width eps aLog a dtBias b gatePlatform}
  {initial : GatedDevice.State} {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}
  {gate : GatedRmsNormDevice.Rows} {normWeights : Fin 128 → ArrayStorage.BF}
  {normalization : GatedRmsNorm.Platform} {projection : AffineVerifyLinear.Projection 12 5120}
  {block : ResidualBlocks.Mlp} {x : Fin 5120 → ArrayStorage.BF}
  (run : DeltaBlockMemory.Execution preparation initial reduce flags gate normWeights normalization projection block x)

def decayInput : GateMemory.Input aLog a dtBias b :=
  DeltaPreparedMemory.gatesAfterHeads preparation.heads preparation.prepared.source
    preparation.prepared.shared preparation.prepared.headSafe

def epsilon : BitVec 32 := 0x358637bd

-- Every field uses the original execution's trace and memory. In particular,
-- source values are not accepted as separately supplied intermediate arrays.
-- The fused computeG relation is a typed host graph; JIT realization remains
-- a compiler contract, unlike the separately parsed beta kernel schedule.
structure Certificate (before : Nat → Float32) : Prop where
  convolution : MlxDepthwiseConvMemory.Certificate convolution
  heads : ∀ initial stores,∀ subset : ∀ store ∈ stores,store ∈ preparation.heads.trace.schedule,
    ∃ writes,SiluHeads128Memory.programs headPlatform (preparation.heads.during stores subset)
      preparation.heads.geometry.base initial=some writes ∧
      ThreadgroupWrites.Executes writes preparation.heads.trace.schedule preparation.heads.trace.remaining ∧
      ThreadgroupWrites.AtBarrier preparation.heads.trace.remaining
  decay : ∀ head,ComputeGHostMemory.source (p := gatePlatform) (decayInput (preparation := preparation)) head=
    some (.fp (preparation.prepared.gates.decayBuffer.read head))
  beta : DeltaBetaSource.execute gatePlatform (preparation.prepared.decay.after.storage.projectionB.base/2)
    preparation.prepared.gates.beta.base preparation.prepared.gates.beta.trace.schedule
    preparation.prepared.decay.after.storage.projectionB.bytes=some preparation.prepared.gates.beta.buffer.bytes
  recurrence : ∀ events,∀ inside : ∀ event ∈ events,event ∈ run.recurrence.stores.trace.schedule,
    ∃ writes,GatedOutputSource.programs (run.recurrence.during events inside)
      run.recurrence.stores.trace.stateBase run.recurrence.stores.trace.outputBase reduce flags=some writes ∧
      ThreadgroupWrites.Executes writes run.recurrence.stores.trace.schedule run.recurrence.stores.trace.remaining ∧
      ThreadgroupWrites.AtBarrier run.recurrence.stores.trace.remaining
  normalization : ∀ stores,∀ inside : MemoryRegions.Inside16 run.tail.normalization.base 12288 stores,
    ∃ writes,GatedRms128OutputSource.programs normalization (run.tail.normalization.during stores inside)
      epsilon run.tail.normalization.base=some writes ∧
      ThreadgroupWrites.Executes writes run.tail.normalization.stores.schedule run.tail.normalization.stores.remaining ∧
      ThreadgroupWrites.AtBarrier run.tail.normalization.stores.remaining
  projection : AffineParsedSource.Certificate (steps := 12) (blocks := 80) run.tail.affine before

theorem checked (before : Nat → Float32)
    (widthSame : width=SiluHeads128Output.width) (epsSame : eps=SiluHeads128Output.epsilon)
    (decayFinite : ∀ head,Decay.Finite gatePlatform.decay (BFloat16.widen (aLog head)) (a head) (dtBias head))
    (projectionFinite : projection.Finite (GatedInputs.flatten run.tail.normalization.output)) :
    Certificate run before := by
  refine ⟨MlxDepthwiseConvMemory.checked convolution,?_,?_,DeltaBetaMemory.source_execution preparation.prepared.gates,
    DeltaParsedRecurrence.source_execution run.recurrence,?_,DeltaParsedOutputProjection.source run.tail before projectionFinite⟩
  · exact DeltaParsedHeads.source_execution preparation.heads widthSame epsSame
  · intro head
    exact ComputeGHostMemory.gates_readback preparation.prepared.decay preparation.prepared.gates head (decayFinite head)
  · exact DeltaParsedGatedNormalization.source_execution run.tail epsilon widthSame epsSame

theorem convolution_heads_heap : preparation.scales.headInput.storage.input.bytes=convolution.stores.memory := rfl

theorem heads_decay_heap :
    (decayInput (preparation := preparation)).storage.logarithm.bytes=preparation.heads.trace.memory := rfl

theorem decay_beta_heap :
    preparation.prepared.decay.after.storage.projectionB.bytes=preparation.prepared.decay.stores.memory := rfl

theorem gates_recurrence_heap : run.recurrence.input.state.bytes=preparation.prepared.gates.betaBuffer.bytes :=
  run.input_memory

theorem recurrence_normalization_heap : run.tailInput.normalization.storage.input.bytes=run.recurrence.stores.memory := rfl

theorem normalization_projection_heap : run.tail.affine.source.bytes=run.tail.normalization.stores.memory :=
  DeltaParsedGatedNormalization.affine_input_heap run.tail

-- The recurrence operands are the preserved head arrays and both actual gate
-- outputs; their attachment follows from the block's physical input link.
theorem recurrence_operands : run.recurrence.input.operands=preparation.prepared.operands := by
  rw [run.linked]
  rfl

theorem recurrence_decay (before : Nat → Float32) (source : Certificate run before) (head : Fin 48) :
    ComputeGHostMemory.source (p := gatePlatform) (decayInput (preparation := preparation)) head=
      some (.fp (run.recurrence.input.operands.decay.read head)) := by
  rw [recurrence_operands run]
  exact source.decay head

theorem recurrence_beta (head : Fin 48) :
    Attention.MlxOutputGateSource.parsedSigmoid (DeltaBetaSource.platform gatePlatform)
      (preparation.prepared.decay.after.storage.projectionB.read head)=
      some (run.recurrence.input.operands.beta.read head) := by
  rw [recurrence_operands run]
  exact DeltaBetaMemory.cell_execution preparation.prepared.gates head

theorem projection_readback (before : Nat → Float32) (source : Certificate run before) (row : Fin 5120) :
    AffineParsedSource.value (steps := 12) (blocks := 80) run.tail.affine row=run.tail.buffer.read row :=
  AffineParsedSource.same_buffer (steps := 12) (blocks := 80) (p := projection)
    run.tail.affine before source.projection row

theorem projection_error (before : Nat → Float32) (source : Certificate run before)
    (finite : projection.Finite (GatedInputs.flatten run.tail.normalization.output))
    (target error : Fin 6144 → ℝ)
    (inputBound : ∀ i, |Model.toReal (GatedInputs.flatten run.tail.normalization.output i)-target i| ≤ error i)
    (row : Fin 5120) :
    |Model.toReal (run.tail.buffer.read row)-projection.target target row| ≤
      projection.budget (GatedInputs.flatten run.tail.normalization.output) target error row := by
  rw [←projection_readback run before source row]
  exact AffineParsedSource.readback_error (steps := 12) (blocks := 80) (p := projection)
    run.tail.affine before source.projection target error inputBound finite row

theorem retained_cache : run.afterCache.memory=run.outputBuffer.bytes ∧
    run.afterCache.buffers.recurrent.read=GatedDevice.producedState reduce flags initial preparation.prepared.values.inputs :=
  ⟨run.cache_output_shared,run.state_eq⟩

end Inference.Models.Qwen.DeltaParsedPipeline
