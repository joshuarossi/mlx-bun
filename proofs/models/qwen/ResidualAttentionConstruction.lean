import models.qwen.ResidualAttentionMemory
import models.qwen.AttentionTailConstruction
import kernels.attention.SdpaSharedConstruction

namespace Inference.Models.Qwen.ResidualAttentionConstruction
open Contracts.Mlx Kernels Kernels.Attention State Layers
set_option maxRecDepth 10000
attribute [local irreducible] SdpaOutput.programs SdpaTwoPassBytes.programs Copy2DMemory.programs
  RmsHeadsMemory.sourceValues RmsHeadsMemory.produced RmsScratch.Trace.factor
  ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

structure Input (layer : ResidualAttention.Layer) {n : Nat} (cache : Kv.Cache Kv.BF n)
    (original : Fin 5120 → ArrayStorage.BF) (angle : RopeAngles.Inputs) where
  front : ResidualAttentionMemory.Prefix layer original angle
  storage : KvRegions.Storage cache
  shared : storage.memory=front.entry.source.lhs.bytes
  keys : front.Safe storage.layout.keyBase (KvRegions.bytes n)
  values : front.Safe storage.layout.valueBase (KvRegions.bytes n)
  residual : front.Safe front.entry.source.lhs.base 10240

variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {original : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}

def Input.oldAfter (s : Input layer cache original angle) : KvRegions.Storage cache :=
  s.front.oldCache s.storage s.shared s.keys s.values

def Input.savedResidual (s : Input layer cache original angle) : ArrayStorage.BFBuffer original := s.front.residual s.residual

structure AppendPlan (s : Input layer cache original angle) where
  preparation : AttentionBlockMemory.Preparation s.oldAfter
  keyPrepared : preparation.Safe s.front.keySource.base (KvAppendMemory.sourceBytes s.front.keySource)
  valuePrepared : preparation.Safe s.front.valueSource.base (KvAppendMemory.sourceBytes s.front.valueSource)
  keySeparate : MemoryRegions.Disjoint preparation.storage.layout.keyBase (KvRegions.bytes (n+1)) s.front.keySource.base (KvAppendMemory.sourceBytes s.front.keySource)
  valueSeparate : MemoryRegions.Disjoint preparation.storage.layout.valueBase (KvRegions.bytes (n+1)) s.front.valueSource.base (KvAppendMemory.sourceBytes s.front.valueSource)
  valueKeySeparate : MemoryRegions.Disjoint preparation.storage.layout.keyBase (KvRegions.bytes (n+1)) s.front.valueSource.base (KvAppendMemory.sourceBytes s.front.valueSource)

def AppendPlan.append {s : Input layer cache original angle} (a : AppendPlan s) :
    AttentionBlockMemory.Append (layer.mixer.heads (layer.inputNorm.forward original) angle) s.oldAfter :=
  ⟨a.preparation,s.front.keySource,s.front.valueSource,rfl,rfl,a.keyPrepared,a.valuePrepared,
    a.keySeparate,a.valueSeparate,a.valueKeySeparate⟩

structure ReadPlan (s : Input layer cache original angle) where
  allocation : AppendPlan s
  queriesSafe : ∀ head, allocation.append.Safe (s.front.query head).base 512
  gatesSafe : ∀ head, allocation.append.Safe (s.front.gate head).base 512
  residualSafe : allocation.append.Safe s.savedResidual.base 10240

variable {s : Input layer cache original angle}

def ReadPlan.input (r : ReadPlan s) : SdpaMemory.Input
    (layer.mixer.heads (layer.inputNorm.forward original) angle).query
    (layer.mixer.cacheAfter (layer.inputNorm.forward original) angle cache) :=
  r.allocation.append.input s.front.query s.front.shared.1 r.queriesSafe

def ReadPlan.gates (r : ReadPlan s) (head : Fin 24) :
    ArrayStorage.BFBuffer ((layer.mixer.heads (layer.inputNorm.forward original) angle).gate head) :=
  r.allocation.append.buffer (s.front.gate head) (s.front.shared.2.2.1 head) (r.gatesSafe head)

def ReadPlan.residual (r : ReadPlan s) : ArrayStorage.BFBuffer original :=
  r.allocation.append.buffer s.savedResidual rfl r.residualSafe

def ReadPlan.Safe (r : ReadPlan s) (base size : Nat) : Prop :=
  s.front.Safe base size ∧ r.allocation.append.Safe base size

theorem ReadPlan.other_region (r : ReadPlan s) {base size : Nat} (safe : r.Safe base size) (offset : Nat) (bound : offset<size) :
    r.input.cache.memory (base+offset)=s.front.entry.source.lhs.bytes (base+offset) :=
  (r.allocation.append.other_region safe.2 offset bound).trans (s.front.other_region safe.1 offset bound)

structure DispatchPlan (r : ReadPlan s) where
  one : ¬SdpaDispatched.twoPass layer.mixer.architectureSuffix (n+1) → SdpaSharedConstruction.OneAllocation r.input
  two : SdpaDispatched.twoPass layer.mixer.architectureSuffix (n+1) → SdpaSharedConstruction.TwoAllocation r.input layer.mixer.architectureSuffix
  gatesSafe : ∀ head, SdpaSharedConstruction.Safe one two (r.gates head).base 512

def DispatchPlan.attention {r : ReadPlan s} (d : DispatchPlan r) :
    SdpaShared.Execution r.input layer.mixer.attention layer.mixer.mergeContracted layer.mixer.architectureSuffix :=
  SdpaSharedConstruction.canonical r.input layer.mixer.attention layer.mixer.mergeContracted layer.mixer.architectureSuffix d.one d.two

theorem DispatchPlan.gatesSafeAfter {r : ReadPlan s} (d : DispatchPlan r) (head : Fin 24) :
    SdpaShared.Safe d.attention (r.gates head).base 512 := (SdpaSharedConstruction.canonical_safe d.one d.two _ _).mpr (d.gatesSafe head)

structure TailPlan (r : ReadPlan s) (d : DispatchPlan r) where
  weights : AffineDevice.Storage layer.mixer.output
  shared : AffineMemory.Shared layer.mixer.output weights s.front.entry.source.lhs.bytes
  projectionLinked : weights=s.front.parameters.projection
  beforeSafe : AffineMemoryFrames.Protected layer.mixer.output weights r.Safe
  regions : AttentionTailConstruction.Regions

variable {r : ReadPlan s} {d : DispatchPlan r}

def TailPlan.weightsBefore (t : TailPlan r d) : AffineDevice.Storage layer.mixer.output :=
  AffineMemoryFrames.reframe layer.mixer.output t.weights r.input.cache.memory
    (AffineMemoryFrames.stable layer.mixer.output t.weights _ _ t.shared
      (AffineMemoryFrames.protected_mono _ _ (fun _ _ h => r.other_region h) t.beforeSafe))

theorem TailPlan.weightsShared (t : TailPlan r d) : AffineMemory.Shared layer.mixer.output t.weightsBefore r.input.cache.memory :=
  AffineMemoryFrames.reframe_shared _ _ _ _

abbrev TailAllocation (t : TailPlan r d) := AttentionTailConstruction.Allocation d.attention r.gates t.weightsBefore t.regions

def tail (t : TailPlan r d) (allocation : TailAllocation t) :
    AttentionTailMemory.Execution d.attention (layer.mixer.heads (layer.inputNorm.forward original) angle).gate layer.mixer.gate layer.mixer.output :=
  AttentionTailConstruction.fromStorage d.attention r.gates (fun _ => rfl) d.gatesSafeAfter t.weightsBefore t.weightsShared t.regions allocation

structure SuffixPlan (t : TailPlan r d) (a : TailAllocation t) where
  norm : ArrayStorage.BFBuffer layer.suffix.norm.weight
  normShared : norm.bytes=s.front.entry.source.lhs.bytes
  normBefore : r.Safe norm.base 10240
  parameters : TrellisWeightsMemory.Weights layer.suffix.mlp s.front.entry.source.lhs.bytes
  parametersBefore : parameters.Protected r.Safe
  normTail : AttentionTailMemory.Safe (tail t a) norm.base 10240
  parametersTail : parameters.Protected (AttentionTailMemory.Safe (tail t a))
  residualTail : AttentionTailMemory.Safe (tail t a) r.residual.base 10240

variable {t : TailPlan r d} {a : TailAllocation t}

def SuffixPlan.normBeforeTail (f : SuffixPlan t a) : ArrayStorage.BFBuffer layer.suffix.norm.weight :=
  ArrayFrame.bf f.norm r.input.cache.memory
    (fun offset bound => (r.other_region f.normBefore offset bound).trans (congrFun f.normShared _).symm)

def SuffixPlan.parametersBeforeTail (f : SuffixPlan t a) : TrellisWeightsMemory.Weights layer.suffix.mlp r.input.cache.memory :=
  f.parameters.reframe _ (f.parameters.protected_mono (fun _ _ h => r.other_region h) f.parametersBefore)

theorem SuffixPlan.parametersTailSafe (f : SuffixPlan t a) :
    f.parametersBeforeTail.Protected (AttentionTailMemory.Safe (tail t a)) := by
  exact f.parametersTail

abbrev SuffixAllocation (f : SuffixPlan t a) :=
  AttentionTailConstruction.SuffixAllocation (tail t a) r.residual rfl f.residualTail
    f.normBeforeTail rfl f.normTail f.parametersBeforeTail f.parametersTailSafe

def suffix (f : SuffixPlan t a) (allocation : SuffixAllocation f)
    (keys : ResidualMlpConstruction.RegionsSafe allocation (tail t a).afterCache.layout.keyBase (KvRegions.bytes (n+1)))
    (values : ResidualMlpConstruction.RegionsSafe allocation (tail t a).afterCache.layout.valueBase (KvRegions.bytes (n+1))) :=
  AttentionTailConstruction.residualFromStorage (tail t a) r.residual rfl f.residualTail
    f.normBeforeTail rfl f.normTail f.parametersBeforeTail f.parametersTailSafe allocation keys values

def fromPrefix (s : Input layer cache original angle) (r : ReadPlan s) (d : DispatchPlan r)
    (t : TailPlan r d) (a : TailAllocation t) (f : SuffixPlan t a) (allocation : SuffixAllocation f)
    (keys : ResidualMlpConstruction.RegionsSafe allocation (tail t a).afterCache.layout.keyBase (KvRegions.bytes (n+1)))
    (values : ResidualMlpConstruction.RegionsSafe allocation (tail t a).afterCache.layout.valueBase (KvRegions.bytes (n+1))) :
    ResidualAttentionMemory.Execution layer cache original angle where
  front := s.front
  storage := s.storage
  shared := s.shared
  storageKeys := s.keys
  storageValues := s.values
  residualSafe := s.residual
  block := {
    append := r.allocation.append
    queries := s.front.query
    queriesShared := s.front.shared.1
    queriesSafe := r.queriesSafe
    gates := s.front.gate
    gatesShared := s.front.shared.2.2.1
    gatesSafe := r.gatesSafe
    residual := s.savedResidual
    residualShared := rfl
    residualSafe := r.residualSafe
    attention := d.attention
    tail := tail t a
    tailGates := rfl
    suffix := suffix f allocation keys values
    suffixSource := rfl }
  queriesLinked := rfl
  gatesLinked := rfl
  keyLinked := rfl
  valueLinked := rfl
  residualLinked := rfl

structure EntryStorage (layer : ResidualAttention.Layer) (original : Fin 5120 → ArrayStorage.BF) where
  source : ArrayStorage.BFBuffer original
  normWeights : ArrayStorage.BFBuffer layer.inputNorm.weight
  shared : normWeights.bytes=source.bytes
  base : Nat
  bounded : 2*base+10240 ≤ 2^64
  residualSeparate : MemoryRegions.Disjoint (2*base) 10240 source.base 10240
  weightsSeparate : MemoryRegions.Disjoint (2*base) 10240 normWeights.base 10240
  weights : AttentionAffineConstruction.Weights layer.mixer.projections source.bytes
  weightsSafe : AttentionNormalizedConstruction.Protected weights (MemoryRegions.Disjoint (2*base) 10240)
  regions : AttentionAffineConstruction.Regions
  allocation : let norm := (NormalizationMemory.fromStorage layer.inputNorm source normWeights shared base bounded
      (Or.inr (MemoryRegions.disjoint_symm residualSeparate)) weightsSeparate)
    AttentionAffineConstruction.Allocation regions (NormalizationMemory.forwardBuffer norm)
      (AttentionNormalizedConstruction.afterWeights norm weights weightsSafe)
  residualLive : regions.Live source.base 10240

def EntryStorage.entry (e : EntryStorage layer original) : AttentionNormalizedMemory.Execution layer original :=
  AttentionNormalizedConstruction.fromStorage e.source e.normWeights e.shared e.base e.bounded e.residualSeparate
    e.weightsSeparate e.weights e.weightsSafe e.regions e.allocation e.residualLive

structure CopyPlan (entry : AttentionNormalizedMemory.Execution layer original) where
  destination : Nat
  bounded : 2*destination+12288 ≤ 2^64
  separate : MemoryRegions.Disjoint (2*destination) 12288 entry.affine.queryGateBuffer.base 24576
  parameters : AttentionParameterMemory.Storage layer.mixer entry.source.lhs.bytes
  entrySafe : AttentionParameterMemory.Protected parameters (AttentionNormalizedMemory.Safe entry)
  copySafe : AttentionParameterMemory.Protected (entry.parametersAfter parameters entrySafe)
    (MemoryRegions.Disjoint (2*destination) 12288)

variable {entry : AttentionNormalizedMemory.Execution layer original}

def CopyPlan.copy (c : CopyPlan entry) : AttentionQueryMemory.Execution entry.affine :=
  AttentionQueryMemory.canonical entry.affine c.destination c.bounded c.separate

def CopyPlan.parametersAfter (c : CopyPlan entry) : AttentionParameterMemory.Storage layer.mixer c.copy.copy.memory :=
  ResidualAttentionMemory.copiedParameters entry c.copy c.parameters c.entrySafe c.copySafe

attribute [local irreducible] ResidualAttentionMemory.copiedParameters
  AttentionNormalizationMemory.queryInput AttentionNormalizationDispatchMemory.keyInput
  AttentionHeads.Projections.forward Blocks.Norm.forward AttentionHeads.Norm.forward

structure RmsQueryPlan (c : CopyPlan entry) where
  dispatch : layer.mixer.preparation.qNorm.platform.groups=2
  keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2
  allocation : RmsHeadsDispatchMemory.Allocation (AttentionNormalizationDispatchMemory.queryInput c.copy c.parametersAfter)

def RmsQueryPlan.execution {c : CopyPlan entry} (q : RmsQueryPlan c) :
    AttentionNormalizationDispatchMemory.QueryExecution c.copy c.parametersAfter :=
  AttentionNormalizationDispatchMemory.queryCanonical c.copy c.parametersAfter q.dispatch q.allocation

attribute [local irreducible] RmsQueryPlan.execution

structure RmsKeyPlan {c : CopyPlan entry} (q : RmsQueryPlan c) where
  copyKey : MemoryRegions.Disjoint (2*c.destination) 12288 entry.affine.keyBuffer.base 2048
  keySafe : MemoryRegions.Disjoint q.execution.base 12288 entry.affine.keyBuffer.base 2048
  scaleSafe : MemoryRegions.Disjoint q.execution.base 12288 c.parametersAfter.keyScale.base 512
  allocation : RmsHeadsDispatchMemory.Allocation
    (AttentionNormalizationDispatchMemory.keyInput c.copy c.parametersAfter q.execution copyKey keySafe scaleSafe)
  outputSafe : MemoryRegions.Disjoint allocation.base 2048 q.execution.base 12288

structure RmsPlan (c : CopyPlan entry) where
  query : RmsQueryPlan c
  key : RmsKeyPlan query

def RmsPlan.normal {c : CopyPlan entry} (r : RmsPlan c) : AttentionNormalizationDispatchMemory.Execution c.copy c.parametersAfter where
  query := r.query.execution
  copyKey := r.key.copyKey
  keySafe := r.key.keySafe
  scaleSafe := r.key.scaleSafe
  key := RmsHeadsDispatchMemory.canonical _ _ _ _ r.query.keyDispatch r.key.allocation
  outputSafe := by rw [RmsHeadsDispatchMemory.canonical_base]; exact r.key.outputSafe

attribute [local irreducible] RmsPlan.normal AttentionRopeNormalizedMemory.queryInput

theorem query_destination {c : CopyPlan entry} (r : RmsPlan c)
    (preparation : RopeRowsDispatchMemory.Preparation (AttentionRopeNormalizedMemory.queryInput r.normal)) :
    (AttentionRopeNormalizedMemory.queryCanonical r.normal angle preparation).destination=preparation.destination := rfl

attribute [local irreducible] AttentionRopeNormalizedMemory.queryCanonical

structure RopePlan {c : CopyPlan entry} (r : RmsPlan c) (angle : RopeAngles.Inputs) where
  queryPreparation : RopeRowsDispatchMemory.Preparation (AttentionRopeNormalizedMemory.queryInput r.normal)
  keySafe : MemoryRegions.Disjoint (AttentionRopeNormalizedMemory.queryCanonical r.normal angle queryPreparation).destination
    12288 r.normal.keyBase 2048
  keyPreparation : RopeRowsDispatchMemory.Preparation (AttentionRopeNormalizedMemory.keyInput r.normal angle
    (AttentionRopeNormalizedMemory.queryCanonical r.normal angle queryPreparation) keySafe)
  outputSafe : MemoryRegions.Disjoint keyPreparation.destination 2048
    (AttentionRopeNormalizedMemory.queryCanonical r.normal angle queryPreparation).destination 12288

def RopePlan.rope {c : CopyPlan entry} {r : RmsPlan c} (p : RopePlan r angle) : AttentionRopeNormalizedMemory.Execution r.normal angle :=
  ⟨AttentionRopeNormalizedMemory.queryCanonical r.normal angle p.queryPreparation,p.keySafe,
    RopeRowsDispatchMemory.Execution.fromPreparation layer.mixer.preparation.rotation
      (AttentionRopeNormalizedMemory.keyInput r.normal angle
        (AttentionRopeNormalizedMemory.queryCanonical r.normal angle p.queryPreparation) p.keySafe)
      (fun _ => RopeAngles.value layer.mixer.preparation.angles angle) p.keyPreparation,p.outputSafe⟩

def RopePlan.donation {c : CopyPlan entry} (r : RmsPlan c) (angle : RopeAngles.Inputs) : RopePlan r angle := by
  have safe : MemoryRegions.Disjoint
      (AttentionRopeNormalizedMemory.queryCanonical r.normal angle .donation).destination 12288 r.normal.keyBase 2048 := by
    rw [query_destination]
    exact MemoryRegions.disjoint_symm r.normal.outputSafe
  exact ⟨.donation,safe,.donation,MemoryRegions.disjoint_symm safe⟩

structure PrefixPlan (entry : AttentionNormalizedMemory.Execution layer original) (angle : RopeAngles.Inputs) where
  copied : CopyPlan entry
  rms : RmsPlan copied
  rotation : RopePlan rms angle
  gateNormal : ∀ head, AttentionNormalizationDispatchMemory.Safe rms.normal (copied.copy.gate head).base 512
  gateRope : ∀ head, AttentionRopeNormalizedMemory.Safe rotation.rope (rms.normal.gate head (gateNormal head)).base 512
  valueCopy : MemoryRegions.Disjoint (2*copied.destination) 12288 entry.affine.valueBuffer.base 2048
  valueNormal : AttentionNormalizationDispatchMemory.Safe rms.normal entry.affine.valueBuffer.base 2048
  valueRope : AttentionRopeNormalizedMemory.Safe rotation.rope (rms.normal.valueBuffer valueCopy valueNormal).base 2048

def PrefixPlan.build (p : PrefixPlan entry angle) : ResidualAttentionMemory.Prefix layer original angle where
  entry := entry
  copy := p.copied.copy
  parameters := p.copied.parameters
  entryParameters := p.copied.entrySafe
  copyParameters := p.copied.copySafe
  normal := p.rms.normal
  rope := p.rotation.rope
  gateNormal := p.gateNormal
  gateRope := p.gateRope
  valueCopy := p.valueCopy
  valueNormal := p.valueNormal
  valueRope := p.valueRope

structure CachePlan (front : ResidualAttentionMemory.Prefix layer original angle) (cache : Kv.Cache Kv.BF n) where
  storage : KvRegions.Storage cache
  shared : storage.memory=front.entry.source.lhs.bytes
  keys : front.Safe storage.layout.keyBase (KvRegions.bytes n)
  values : front.Safe storage.layout.valueBase (KvRegions.bytes n)
  residual : front.Safe front.entry.source.lhs.base 10240

def CachePlan.input {front : ResidualAttentionMemory.Prefix layer original angle} (c : CachePlan front cache) :
    Input layer cache original angle := ⟨front,c.storage,c.shared,c.keys,c.values,c.residual⟩

-- Every intermediate execution is constructed above from attached storage,
-- dispatch selection, and allocation geometry supplied in these plans.
def fromStorage (storage : EntryStorage layer original) (front : PrefixPlan storage.entry angle)
    (c : CachePlan front.build cache) (r : ReadPlan c.input) (d : DispatchPlan r)
    (t : TailPlan r d) (a : TailAllocation t) (f : SuffixPlan t a) (allocation : SuffixAllocation f)
    (keys : ResidualMlpConstruction.RegionsSafe allocation (tail t a).afterCache.layout.keyBase (KvRegions.bytes (n+1)))
    (values : ResidualMlpConstruction.RegionsSafe allocation (tail t a).afterCache.layout.valueBase (KvRegions.bytes (n+1))) :
    ResidualAttentionMemory.Execution layer cache original angle :=
  fromPrefix c.input r d t a f allocation keys values

end Inference.Models.Qwen.ResidualAttentionConstruction
