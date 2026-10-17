import models.qwen.InitialCopiedParameterConstruction
import models.qwen.EmptyKvAttachment
import models.qwen.TokenAutoregressiveMemory
namespace Inference.Models.Qwen.EmptyKvLineage
open Contracts.Mlx Layers DecodeStage DecodeChain State Kernels.Attention
set_option maxRecDepth 10000

theorem storage_eq {cache : Kv.Cache Kv.BF 0} (storage : KvRegions.Storage cache)
    (layout : storage.layout=EmptyKvAttachment.layout) (shared : storage.memory=memory) :
    storage=EmptyKvAttachment.storage cache memory := by
  cases storage
  cases layout
  cases shared
  rfl

def StageCanonical (stage : Stage) (cache : Cache stage 0) (buffer : DecodeFrame.StageBuffer stage cache memory) : Prop :=
  match stage with
  | .delta _ => True
  | .attention _ => buffer.storage=EmptyKvAttachment.storage cache memory

def Canonical : (stages : List Stage) → (cache : Caches stages 0) → (memory : ByteMemory.Bytes) →
    DecodeFrame.Storage stages cache memory → Prop
  | [],_,_,_ => True
  | stage::rest,cache,memory,storage => StageCanonical stage cache.1 storage.1 ∧ Canonical rest cache.2 memory storage.2

theorem stage_reframe (region : Nat → Nat → Prop) (before after : ByteMemory.Bytes)
    (frame : ∀ base size, region base size → ∀ offset<size, after (base+offset)=before (base+offset))
    (stage : Stage) (cache : Cache stage 0) (buffer : DecodeFrame.StageBuffer stage cache before)
    (safe : DecodePreservation.StageProtected region stage cache buffer.storage)
    (canonical : StageCanonical stage cache buffer) :
    StageCanonical stage cache (DecodePreservation.stageReframe region before after frame stage cache buffer safe) := by
  cases stage with
  | delta _ => exact True.intro
  | attention _ =>
    apply storage_eq
    · change buffer.storage.layout=EmptyKvAttachment.layout
      exact congrArg KvRegions.Storage.layout canonical
    · rfl

theorem reframe (region : Nat → Nat → Prop) (before after : ByteMemory.Bytes)
    (frame : ∀ base size, region base size → ∀ offset<size, after (base+offset)=before (base+offset)) :
    (stages : List Stage) → (cache : Caches stages 0) → (storage : DecodeFrame.Storage stages cache before) →
    (safe : DecodePreservation.Protected region stages cache before storage) → Canonical stages cache before storage →
    Canonical stages cache after (DecodePreservation.reframe region before after frame stages cache storage safe)
  | [],_,_,_,_ => True.intro
  | stage::rest,cache,storage,safe,canonical =>
    ⟨stage_reframe region before after frame stage cache.1 storage.1 safe.1 canonical.1,
      reframe region before after frame rest cache.2 storage.2 safe.2 canonical.2⟩

theorem initial_stage (stage : Stage) (plan : InitialCacheMemory.StagePlan stage) (memory : ByteMemory.Bytes)
    (ready : InitialCacheMemory.StageReady stage plan memory) :
    StageCanonical stage (InitialState.stage stage) (DecodeFrame.initialStage stage plan memory ready) := by
  cases stage with
  | delta _ => exact True.intro
  | attention _ => rfl

theorem initial : (stages : List Stage) → (plan : InitialCacheMemory.Plan stages) → (memory : ByteMemory.Bytes) →
    (ready : InitialCacheMemory.Ready stages plan memory) →
    Canonical stages (InitialState.caches stages) memory (DecodeFrame.fromInitial stages plan memory ready)
  | [],_,_,_ => True.intro
  | stage::rest,plan,memory,ready =>
    ⟨initial_stage stage plan.1 memory ready.1,initial rest plan.2 memory ready.2⟩

-- Transport changes only the heap index; canonical empty attachments survive
-- the exact embedding-source equality used by the native Step constructor.
theorem transport {stages : List Stage} {cache : Caches stages 0} {before after : ByteMemory.Bytes}
    (same : before=after) (storage : DecodeFrame.Storage stages cache before) (canonical : Canonical stages cache before storage) :
    Canonical stages cache after (TokenAutoregressiveMemory.transportCaches same storage) := by
  cases same
  exact canonical

variable {p : TokenInference.Pipeline} (before : TokenAutoregressiveMemory.State p 0)
  (embedding : QuantizedEmbeddingMemory.Execution p.embedding before.logical.token)
  (linked : embedding.tokenBuffer=before.index)
  (safe : DecodePreservation.Protected embedding.regions.Live p.graph.stages before.logical.cache before.index.bytes before.caches)

theorem embedding_caches (canonical : Canonical p.graph.stages before.logical.cache before.index.bytes before.caches) :
    Canonical p.graph.stages before.logical.cache embedding.forwardBuffer.bytes
      (TokenAutoregressiveMemory.embeddingCaches before embedding linked safe) :=
  reframe _ _ _ _ _ _ _ _ canonical

section ActualStage
variable {stage : Stage} {cache : Cache stage 0} {input : Row BF} {angle : RopeAngles.Inputs}
  {source : ArrayStorage.BFBuffer input} {storage : DecodeFrame.StageBuffer stage cache source.bytes}
  (trace : InitialCopiedDecodeStage.Trace stage cache input angle source storage)
  (rest : List Stage) (remaining : Caches rest 0)
  (buffers : DecodeFrame.Storage rest remaining source.bytes)
  (preserved : DecodePreservation.Protected trace.Safe rest remaining source.bytes buffers)

theorem retained (canonical : Canonical rest remaining source.bytes buffers) :
    Canonical rest remaining trace.buffer.bytes (trace.retained rest remaining buffers preserved) :=
  reframe _ _ _ _ _ _ _ _ canonical
end ActualStage

-- The existing initial StagePlan's equality field is now filled from actual
-- initialized/retained cache lineage, with the original parameter factory.
def attention_plan {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF 0}
    {input : Row BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.StageBuffer (.attention layer) cache source.bytes}
    {parameters : DecodeParameterMemory.AttentionStorage layer source.bytes}
    (factory : CopiedAttentionInitialFactory.Plan layer cache input angle source parameters)
    (canonical : StageCanonical (.attention layer) cache storage) :
    InitialCopiedParameterConstruction.StagePlan (.attention layer) cache input angle source storage parameters :=
  ⟨factory,⟨canonical⟩⟩
end Inference.Models.Qwen.EmptyKvLineage
