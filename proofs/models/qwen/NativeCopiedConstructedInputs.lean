import models.qwen.NativeCopiedTokenConstruction
import models.qwen.CopiedAttentionTailBuiltLineage
namespace Inference.Models.Qwen.NativeCopiedConstructedInputs
open Contracts.Mlx Layers DecodeStage DecodeChain TokenInference Kernels.Attention Kernels.Normalization Kernels.Sampling
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] AttentionGateCopyInitialRead.Read.input
  AttentionGateCopyInitialResidualStage.block AttentionGateCopyInitialResidualStage.original
  AttentionGateCopyFreshRead.Read.input
  AttentionGateCopyCapacityResidualStage.block AttentionGateCopyCapacityResidualStage.original

-- Only descriptor/local-memory and literal-zero source boundaries remain.
-- Exact gate-buffer lineage is supplied by the original-weight constructors.

namespace Initial
structure AttentionBoundary {layer : ResidualAttention.Layer} {cache : State.Kv.Cache State.Kv.BF 0}
    {input : Row BF} {angle : RopeAngles.Inputs} (plan : AttentionGateCopyInitialResidualStage.Plan layer cache input angle) where
  trellis : TrellisParsedNative.Input (AttentionGateCopyInitialResidualStage.block plan).suffix
  before : Nat → Float32
  kernel : MlxRmsHostSelection.KernelLimit
  nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads
  scratch : M1Max.WordMemory
  inverseBefore : M1Max.WordMemory
  base : Nat
  inverseBase : Nat
  sources : InitialKvSourceMemory.Sources plan.read.kv.zeros

def StageBoundary : (kind : Stage) → (cache : Cache kind 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    InitialCopiedDecodeStage.Execution kind cache input angle → Type
  | .delta _,_,_,_,execution => InitialCopiedDerivedNative.StageInput _ _ _ _ execution
  | .attention _,_,_,_,execution => AttentionBoundary execution

private theorem gateLink {layer : ResidualAttention.Layer} {cache : State.Kv.Cache State.Kv.BF 0}
    {input : Row BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.StageBuffer (.attention layer) cache source.bytes}
    {parameters : DecodeParameterMemory.AttentionStorage layer source.bytes}
    (plan : InitialCopiedParameterConstruction.StagePlan (.attention layer) cache input angle source storage parameters)
    (built : CopiedAttentionOriginalTailChains.Initial.StageBuilt (.attention layer) cache input angle source storage parameters plan) :
    (CopiedAttentionInitialFactory.stage plan.1).tail.gates=(CopiedAttentionInitialFactory.stage plan.1).read.gate :=
  CopiedAttentionTailBuiltLineage.Initial.gates source parameters plan.1.normal
    (CopiedAttentionOriginalBundle.front_input source parameters plan.1.normal plan.1.safe plan.1.regions
      plan.1.projections plan.1.queryCopy angle plan.1.native) plan.1.read plan.1.attention built

def stageInputs (kind : Stage) (cache : Cache kind 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.StageBuffer kind cache source.bytes)
    (parameters : DecodeParameterMemory.StageStorage kind source.bytes)
    (plan : InitialCopiedParameterConstruction.StagePlan kind cache input angle source storage parameters)
    (built : CopiedAttentionOriginalTailChains.Initial.StageBuilt kind cache input angle source storage parameters plan)
    (boundary : StageBoundary kind cache input angle (InitialCopiedParameterConstruction.stage kind cache input angle source storage parameters plan).execution) :
    InitialCopiedDerivedNative.StageInput kind cache input angle (InitialCopiedParameterConstruction.stage kind cache input angle source storage parameters plan).execution := by
  cases kind with
  | delta _ => exact boundary
  | attention _ => exact {
      trellis := boundary.trellis
      before := boundary.before
      kernel := boundary.kernel
      nativeThreads := boundary.nativeThreads
      scratch := boundary.scratch
      inverseBefore := boundary.inverseBefore
      base := boundary.base
      inverseBase := boundary.inverseBase
      sources := boundary.sources
      gateLink := gateLink plan built }

def BoundaryInputs : (stages : List Stage) → (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    InitialCopiedDecodeChain.Trace stages cache input angle source storage → Type
  | [],_,_,_,_,_,_ => PUnit
  | kind::rest,cache,input,angle,_,_,trace =>
    StageBoundary kind cache.1 input angle trace.1.first.execution ×
    BoundaryInputs rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2

def inputs {all : List Stage} : (stages : List Stage) →
    (position : DecodeParameterConstruction.Cursor all stages) →
    (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (parameters : DecodeParameterMemory.Storage all source.bytes) →
    (plan : InitialCopiedParameterConstruction.ChainPlan stages position cache input angle source storage parameters) →
    CopiedAttentionOriginalTailChains.Initial.Built stages position cache input angle source storage parameters plan →
    BoundaryInputs stages cache input angle source storage (InitialCopiedParameterConstruction.chain stages position cache input angle source storage parameters plan) →
    InitialCopiedDerivedNative.Inputs stages cache input angle source storage (InitialCopiedParameterConstruction.chain stages position cache input angle source storage parameters plan)
  | [],_,_,_,_,_,_,_,_,_,_ => ⟨⟩
  | kind::rest,position,cache,input,angle,source,storage,parameters,plan,built,boundary =>
    ⟨stageInputs kind cache.1 input angle source storage.1 (DecodeParameterConstruction.remainingParameters position parameters).1
      plan.1.first built.1 boundary.1,
      inputs rest (.next position) cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer
        plan.1.step.nextStorage plan.1.nextParameters plan.2 built.2 boundary.2⟩
end Initial

namespace Capacity
variable {n : Nat}
structure AttentionBoundary {layer : ResidualAttention.Layer} {n : Nat} {cache : State.Kv.Cache State.Kv.BF n}
    {input : Row BF} {angle : RopeAngles.Inputs} (plan : AttentionGateCopyCapacityResidualStage.Plan layer cache input angle) where
  trellis : TrellisParsedNative.Input (AttentionGateCopyCapacityResidualStage.block plan).suffix
  before : Nat → Float32
  kernel : MlxRmsHostSelection.KernelLimit
  nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads
  scratch : M1Max.WordMemory
  inverseBefore : M1Max.WordMemory
  base : Nat
  inverseBase : Nat
  growth : AttentionGateCopyPositiveSources.Inputs plan.preparation.preparation

def StageBoundary : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    CapacityAttentionDecodeStage.Execution kind cache input angle → Type
  | .delta _,_,_,_,execution => CapacityAttentionDerivedNative.StageInput _ _ _ _ execution
  | .attention _,_,_,_,execution => AttentionBoundary execution.val

private theorem gateLink {layer : ResidualAttention.Layer} {cache : State.Kv.Cache State.Kv.BF n}
    {input : Row BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.StageBuffer (.attention layer) cache source.bytes}
    {parameters : DecodeParameterMemory.AttentionStorage layer source.bytes}
    (plan : CapacityAttentionParameterConstruction.StagePlan (.attention layer) cache input angle source storage parameters)
    (built : CopiedAttentionOriginalTailChains.Capacity.StageBuilt (.attention layer) cache input angle source storage parameters plan) :
    (CopiedAttentionCapacityFactory.stage plan).tail.gates=(CopiedAttentionCapacityFactory.stage plan).read.gate :=
  CopiedAttentionTailBuiltLineage.Capacity.gates source parameters plan.normal
    (CopiedAttentionOriginalBundle.front_input source parameters plan.normal plan.safe plan.regions
      plan.projections plan.queryCopy angle plan.native) plan.read plan.attention built

def stageInputs (kind : Stage) (cache : Cache kind n) (input : Row BF) (angle : RopeAngles.Inputs)
    (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.StageBuffer kind cache source.bytes)
    (parameters : DecodeParameterMemory.StageStorage kind source.bytes)
    (plan : CapacityAttentionParameterConstruction.StagePlan kind cache input angle source storage parameters)
    (built : CopiedAttentionOriginalTailChains.Capacity.StageBuilt kind cache input angle source storage parameters plan)
    (boundary : StageBoundary kind cache input angle (CapacityAttentionParameterConstruction.stage kind cache input angle source storage parameters plan).execution) :
    CapacityAttentionDerivedNative.StageInput kind cache input angle (CapacityAttentionParameterConstruction.stage kind cache input angle source storage parameters plan).execution := by
  cases kind with
  | delta _ => exact boundary
  | attention _ => exact {
      trellis := boundary.trellis
      before := boundary.before
      kernel := boundary.kernel
      nativeThreads := boundary.nativeThreads
      scratch := boundary.scratch
      inverseBefore := boundary.inverseBefore
      base := boundary.base
      inverseBase := boundary.inverseBase
      growth := boundary.growth
      gateLink := gateLink plan built }

def BoundaryInputs : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    CapacityAttentionDecodeChain.Trace stages cache input angle source storage → Type
  | [],_,_,_,_,_,_ => PUnit
  | kind::rest,cache,input,angle,_,_,trace =>
    StageBoundary kind cache.1 input angle trace.1.first.execution ×
    BoundaryInputs rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2

def inputs {all : List Stage} : (stages : List Stage) →
    (position : CapacityAttentionParameterConstruction.Cursor all stages) →
    (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (parameters : DecodeParameterMemory.Storage all source.bytes) →
    (plan : CapacityAttentionParameterConstruction.ChainPlan stages position cache input angle source storage parameters) →
    CopiedAttentionOriginalTailChains.Capacity.Built stages position cache input angle source storage parameters plan →
    BoundaryInputs stages cache input angle source storage (CapacityAttentionParameterConstruction.chain stages position cache input angle source storage parameters plan) →
    CapacityAttentionDerivedNative.Inputs stages cache input angle source storage (CapacityAttentionParameterConstruction.chain stages position cache input angle source storage parameters plan)
  | [],_,_,_,_,_,_,_,_,_,_ => ⟨⟩
  | kind::rest,position,cache,input,angle,source,storage,parameters,plan,built,boundary =>
    ⟨stageInputs kind cache.1 input angle source storage.1 (CapacityAttentionParameterConstruction.remainingParameters position parameters).1
      plan.1.first built.1 boundary.1,
      inputs rest (.next position) cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer
        plan.1.step.nextStorage plan.1.nextParameters plan.2 built.2 boundary.2⟩
end Capacity

variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {cache : p.graph.Cache n} {token : Fin 248320} {angle : RopeAngles.Inputs}

def BoundaryInputs (run : NativeCopiedTokenRoute.Execution p sampling cache token angle) : Type := match run with
  | .initial run => Initial.BoundaryInputs p.graph.stages cache (p.embedding.forward token) angle
      run.forward.source run.forward.storage run.forward.chain
  | .positive run => Capacity.BoundaryInputs p.graph.stages cache (p.embedding.forward token) angle
      run.forward.source run.forward.storage run.forward.chain

variable {before : TokenAutoregressiveMemory.State p n}
  {original : TokenParameterMemory.Storage p before.index.bytes}

def inputs (plan : NativeCopiedTokenConstruction.Plan p sampling angle before original)
    (boundary : BoundaryInputs (NativeCopiedTokenConstruction.step plan).execution) :
    NativeCopiedTokenRoute.Inputs (NativeCopiedTokenConstruction.step plan).execution := by
  cases plan with
  | initial plan built =>
    exact Initial.inputs p.graph.stages .root _ _ angle plan.embedding.entry.source plan.embedding.entry.storage
      plan.embedding.afterEmbedding.graph.stages plan.graph.body.chain built boundary
  | positive plan built =>
    exact Capacity.inputs p.graph.stages .root _ _ angle plan.embedding.entry.source plan.embedding.entry.storage
      plan.embedding.afterEmbedding.graph.stages plan.graph.body.chain built boundary
end Inference.Models.Qwen.NativeCopiedConstructedInputs
