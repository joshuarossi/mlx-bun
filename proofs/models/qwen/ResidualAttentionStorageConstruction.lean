import models.qwen.DecodeParameterMemory
import models.qwen.ResidualAttentionConstruction

namespace Inference.Models.Qwen.ResidualAttentionStorageConstruction
open Contracts.Mlx Kernels Kernels.Attention State Layers
open ResidualAttentionConstruction
set_option maxRecDepth 10000

structure Source (layer : ResidualAttention.Layer) {n : Nat} (cache : Kv.Cache Kv.BF n)
    (original : Fin 5120 → ArrayStorage.BF) where
  source : ArrayStorage.BFBuffer original
  storage : KvRegions.Storage cache
  shared : storage.memory=source.bytes
  parameters : DecodeParameterMemory.AttentionStorage layer source.bytes

variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {original : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}

structure EntryPlan (s : Source layer cache original) where
  base : Nat
  bounded : 2*base+10240 ≤ 2^64
  residualSeparate : MemoryRegions.Disjoint (2*base) 10240 s.source.base 10240
  weightsSeparate : MemoryRegions.Disjoint (2*base) 10240 s.parameters.norm.base 10240
  weightsSafe : AttentionNormalizedConstruction.Protected s.parameters.projections (MemoryRegions.Disjoint (2*base) 10240)
  regions : AttentionAffineConstruction.Regions
  allocation : let norm := (NormalizationMemory.fromStorage layer.inputNorm s.source s.parameters.norm s.parameters.normShared base bounded (Or.inr (MemoryRegions.disjoint_symm residualSeparate)) weightsSeparate)
    AttentionAffineConstruction.Allocation regions (NormalizationMemory.forwardBuffer norm)
      (AttentionNormalizedConstruction.afterWeights norm s.parameters.projections weightsSafe)
  residualLive : regions.Live s.source.base 10240

def EntryPlan.data {s : Source layer cache original} (p : EntryPlan s) : EntryStorage layer original where
  source := s.source
  normWeights := s.parameters.norm
  shared := s.parameters.normShared
  base := p.base
  bounded := p.bounded
  residualSeparate := p.residualSeparate
  weightsSeparate := p.weightsSeparate
  weights := s.parameters.projections
  weightsSafe := p.weightsSafe
  regions := p.regions
  allocation := p.allocation
  residualLive := p.residualLive

def EntryPlan.entry {s : Source layer cache original} (p : EntryPlan s) := p.data.entry

theorem EntryPlan.source_eq {s : Source layer cache original} (p : EntryPlan s) : p.entry.source.lhs=s.source := rfl

def EntryPlan.parameters {s : Source layer cache original} (p : EntryPlan s) : DecodeParameterMemory.AttentionStorage layer p.entry.source.lhs.bytes := s.parameters

theorem EntryPlan.parameters_original {s : Source layer cache original} (p : EntryPlan s) :
    HEq p.parameters s.parameters := HEq.rfl

attribute [local irreducible] EntryPlan.entry EntryPlan.parameters

-- The only parameters used by the query-copy stage are the original mixer bundle.
structure CopyAllocation {s : Source layer cache original} (p : EntryPlan s) where
  destination : Nat
  bounded : 2*destination+12288 ≤ 2^64
  separate : MemoryRegions.Disjoint (2*destination) 12288 p.entry.affine.queryGateBuffer.base 24576
  entrySafe : AttentionParameterMemory.Protected p.parameters.mixer (AttentionNormalizedMemory.Safe p.entry)
  copySafe : AttentionParameterMemory.Protected
    (p.entry.parametersAfter p.parameters.mixer entrySafe)
    (MemoryRegions.Disjoint (2*destination) 12288)

def CopyAllocation.plan {s : Source layer cache original} {p : EntryPlan s} (c : CopyAllocation p) : CopyPlan p.entry :=
  ⟨c.destination,c.bounded,c.separate,p.parameters.mixer,c.entrySafe,c.copySafe⟩

structure PrefixAllocation {s : Source layer cache original} {p : EntryPlan s} (c : CopyAllocation p) (angle : RopeAngles.Inputs) where
  rms : RmsPlan c.plan
  rotation : RopePlan rms angle
  gateNormal : ∀ head, AttentionNormalizationDispatchMemory.Safe rms.normal (c.plan.copy.gate head).base 512
  gateRope : ∀ head, AttentionRopeNormalizedMemory.Safe rotation.rope (rms.normal.gate head (gateNormal head)).base 512
  valueCopy : MemoryRegions.Disjoint (2*c.destination) 12288 p.entry.affine.valueBuffer.base 2048
  valueNormal : AttentionNormalizationDispatchMemory.Safe rms.normal p.entry.affine.valueBuffer.base 2048
  valueRope : AttentionRopeNormalizedMemory.Safe rotation.rope (rms.normal.valueBuffer valueCopy valueNormal).base 2048

def PrefixAllocation.plan {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    (f : PrefixAllocation c angle) : PrefixPlan p.entry angle :=
  ⟨c.plan,f.rms,f.rotation,f.gateNormal,f.gateRope,f.valueCopy,f.valueNormal,f.valueRope⟩

def PrefixAllocation.front {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    (f : PrefixAllocation c angle) := f.plan.build

theorem PrefixAllocation.entry_eq {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    (f : PrefixAllocation c angle) : f.front.entry=p.entry := rfl

theorem PrefixAllocation.parameters_eq {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    (f : PrefixAllocation c angle) : f.front.parameters=p.parameters.mixer := rfl

attribute [local irreducible] PrefixAllocation.front

structure CacheAllocation {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    (f : PrefixAllocation c angle) where
  keys : f.front.Safe s.storage.layout.keyBase (KvRegions.bytes n)
  values : f.front.Safe s.storage.layout.valueBase (KvRegions.bytes n)
  residual : f.front.Safe s.source.base 10240

def CacheAllocation.input {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    {f : PrefixAllocation c angle} (a : CacheAllocation f) : Input layer cache original angle where
  front := f.front
  storage := s.storage
  shared := by rw [f.entry_eq,p.source_eq]; exact s.shared
  keys := a.keys
  values := a.values
  residual := by rw [f.entry_eq,p.source_eq]; exact a.residual

-- Subsequent geometry refers to these derived views; no replacement parameter
-- attachment is accepted after the entry or the cache append.
def PrefixAllocation.parameters {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    (f : PrefixAllocation c angle) : DecodeParameterMemory.AttentionStorage layer f.front.entry.source.lhs.bytes := by
  rw [f.entry_eq]
  exact p.parameters

theorem PrefixAllocation.mixer_eq {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    (f : PrefixAllocation c angle) : f.parameters.mixer=f.front.parameters := by
  unfold PrefixAllocation.parameters PrefixAllocation.front
  rfl

attribute [local irreducible] PrefixAllocation.parameters

structure TailGeometry {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    {f : PrefixAllocation c angle} (a : CacheAllocation f) (r : ReadPlan a.input) (d : DispatchPlan r) where
  beforeSafe : AffineMemoryFrames.Protected layer.mixer.output f.front.parameters.projection r.Safe
  regions : AttentionTailConstruction.Regions

def TailGeometry.plan {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    {f : PrefixAllocation c angle} {a : CacheAllocation f} {r : ReadPlan a.input} {d : DispatchPlan r}
    (t : TailGeometry a r d) : TailPlan r d where
  weights := f.front.parameters.projection
  shared := f.front.parameters.projectionShared
  projectionLinked := rfl
  beforeSafe := t.beforeSafe
  regions := t.regions

structure SuffixGeometry {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    {f : PrefixAllocation c angle} {a : CacheAllocation f} {r : ReadPlan a.input} {d : DispatchPlan r}
    (t : TailGeometry a r d) (allocation : TailAllocation t.plan) where
  beforeSafe : f.parameters.suffix.Protected r.Safe
  tailSafe : f.parameters.suffix.Protected (AttentionTailMemory.Safe (tail t.plan allocation))
  residualTail : AttentionTailMemory.Safe (tail t.plan allocation) r.residual.base 10240

def SuffixGeometry.plan {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    {f : PrefixAllocation c angle} {a : CacheAllocation f} {r : ReadPlan a.input} {d : DispatchPlan r}
    {t : TailGeometry a r d} {allocation : TailAllocation t.plan} (g : SuffixGeometry t allocation) : SuffixPlan t.plan allocation where
  norm := f.parameters.suffix.norm
  normShared := f.parameters.suffix.normShared
  normBefore := g.beforeSafe.1
  parameters := f.parameters.suffix.trellis
  parametersBefore := g.beforeSafe.2
  normTail := g.tailSafe.1
  parametersTail := g.tailSafe.2
  residualTail := g.residualTail

theorem CacheAllocation.front_eq {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    {f : PrefixAllocation c angle} (a : CacheAllocation f) : a.input.front=f.front := rfl

theorem CacheAllocation.storage_eq {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    {f : PrefixAllocation c angle} (a : CacheAllocation f) : a.input.storage=s.storage := rfl

attribute [local irreducible] CopyAllocation.plan PrefixAllocation.plan CacheAllocation.input
  TailGeometry.plan SuffixGeometry.plan
  ResidualAttentionConstruction.tail ResidualAttentionConstruction.DispatchPlan.attention
  AttentionHeads.Projections.forward Blocks.Norm.forward AttentionHeads.Norm.forward
  ResidualMlpConstruction.RegionsSafe

-- Each stage is parametrized by the preceding constructed stage, keeping the
-- dependent heap links small while exposing only geometry to the caller.
def FinishPlan {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    {f : PrefixAllocation c angle} {a : CacheAllocation f} {r : ReadPlan a.input} {d : DispatchPlan r}
    (t : TailGeometry a r d) (ta : TailAllocation t.plan) :=
  Σ' geometry : SuffixGeometry t ta, {allocation : SuffixAllocation geometry.plan //
    ResidualMlpConstruction.RegionsSafe allocation (tail t.plan ta).afterCache.layout.keyBase (KvRegions.bytes (n+1)) ∧
    ResidualMlpConstruction.RegionsSafe allocation (tail t.plan ta).afterCache.layout.valueBase (KvRegions.bytes (n+1))}

structure TailPlan {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    {f : PrefixAllocation c angle} (a : CacheAllocation f) (r : ReadPlan a.input) (d : DispatchPlan r) where
  geometry : TailGeometry a r d
  allocation : TailAllocation geometry.plan
  finish : FinishPlan geometry allocation

structure BodyPlan {s : Source layer cache original} {p : EntryPlan s} {c : CopyAllocation p}
    (f : PrefixAllocation c angle) where
  cacheAllocation : CacheAllocation f
  read : ReadPlan cacheAllocation.input
  dispatch : DispatchPlan read
  tailPlan : TailPlan cacheAllocation read dispatch

structure Plan (s : Source layer cache original) (angle : RopeAngles.Inputs) where
  entry : EntryPlan s
  copied : CopyAllocation entry
  frontPlan : PrefixAllocation copied angle
  body : BodyPlan frontPlan

def canonical {s : Source layer cache original} (plan : Plan s angle) :
    ResidualAttentionMemory.Execution layer cache original angle :=
  fromPrefix plan.body.cacheAllocation.input plan.body.read plan.body.dispatch
    plan.body.tailPlan.geometry.plan plan.body.tailPlan.allocation
    plan.body.tailPlan.finish.1.plan plan.body.tailPlan.finish.2.val
    plan.body.tailPlan.finish.2.property.1 plan.body.tailPlan.finish.2.property.2

theorem source_eq {s : Source layer cache original} (plan : Plan s angle) : (canonical plan).source=s.source := by
  change plan.body.cacheAllocation.input.front.entry.source.lhs=s.source
  rw [plan.body.cacheAllocation.front_eq,plan.frontPlan.entry_eq,plan.entry.source_eq]

theorem storage_eq {s : Source layer cache original} (plan : Plan s angle) :
    (canonical plan).storage=s.storage := plan.body.cacheAllocation.storage_eq

theorem output_eq {s : Source layer cache original} (plan : Plan s angle) :
    (canonical plan).output=layer.forward original angle cache := (canonical plan).output_eq

def fromStorage {s : Source layer cache original} (plan : Plan s angle) := canonical plan

theorem source_linked {s : Source layer cache original} (plan : Plan s angle) :
    (fromStorage plan).source=s.source := source_eq plan

theorem cache_linked {s : Source layer cache original} (plan : Plan s angle) :
    (fromStorage plan).storage=s.storage := storage_eq plan

end Inference.Models.Qwen.ResidualAttentionStorageConstruction
