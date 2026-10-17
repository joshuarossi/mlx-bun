import models.qwen.ResidualAttentionStorageConstruction
import kernels.attention.SdpaWorkspace
import models.qwen.AttentionTailAllocation
import models.qwen.ResidualMlpAllocation

namespace Inference.Models.Qwen.AttentionTailWorkspaceConstruction
open Contracts.Mlx Layers Kernels Kernels.Attention State
open ResidualAttentionConstruction
set_option maxRecDepth 10000
attribute [local irreducible] AttentionHeads.Projections.forward Blocks.Norm.forward AttentionHeads.Norm.forward
  RmsHeadsMemory.sourceValues RmsHeadsMemory.produced RmsScratch.Trace.factor
  Copy2DMemory.programs CopyExecution.Trace.memory RopeRowsMemory.programs MultiOutputWrites.programs
  ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

def bytes (blocks : Nat) : Nat := SdpaWorkspace.bytes blocks+34816+731136

theorem tail_bound {base blocks : Nat} (bound : base+bytes blocks≤2^64) :
    base+SdpaWorkspace.bytes blocks+34816≤2^64 := by
  exact (Nat.le_add_right (base+SdpaWorkspace.bytes blocks+34816) 731136).trans
    (by simpa only [bytes,Nat.add_assoc] using bound)

theorem suffix_bound {base blocks : Nat} (bound : base+bytes blocks≤2^64) :
    base+SdpaWorkspace.bytes blocks+34816+731136≤2^64 := by
  simpa only [bytes,Nat.add_assoc] using bound

theorem subregion {workspace other size offset count blocks : Nat}
    (safe : MemoryRegions.Disjoint workspace (bytes blocks) other size) (inside : offset+count≤bytes blocks) :
    MemoryRegions.Disjoint (workspace+offset) count other size := by
  unfold MemoryRegions.Disjoint at *
  omega

variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : ResidualAttentionStorageConstruction.Source layer cache input}
  {e : ResidualAttentionStorageConstruction.EntryPlan s}
  {c : ResidualAttentionStorageConstruction.CopyAllocation e}
  {f : ResidualAttentionStorageConstruction.PrefixAllocation c angle}
  {a : ResidualAttentionStorageConstruction.CacheAllocation f}
  {r : ReadPlan a.input}

structure Arena (r : ReadPlan a.input) where
  base : Nat
  aligned : base%16=0
  bounded : base+bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))≤2^64
  queries : ∀ head, MemoryRegions.Disjoint base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) (r.input.query head).base 512
  gates : ∀ head, MemoryRegions.Disjoint base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) (r.gates head).base 512
  residual : MemoryRegions.Disjoint base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) r.residual.base 10240
  keys : MemoryRegions.Disjoint base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) r.input.cache.layout.keyBase (KvRegions.bytes (n+1))
  values : MemoryRegions.Disjoint base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) r.input.cache.layout.valueBase (KvRegions.bytes (n+1))
  parametersBefore : f.parameters.Protected r.Safe
  parametersOutside : f.parameters.Protected (MemoryRegions.Disjoint base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))))

def Arena.sdpa (w : Arena r) : SdpaWorkspace.Workspace r.input layer.mixer.architectureSuffix where
  base := w.base
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; dsimp [bytes] at this; omega
  keysSafe := by simpa only [Nat.add_zero] using subregion (offset := 0) w.keys (by dsimp [bytes]; omega)
  valuesSafe := by simpa only [Nat.add_zero] using subregion (offset := 0) w.values (by dsimp [bytes]; omega)
  queriesSafe := fun head => by simpa only [Nat.add_zero] using subregion (offset := 0) (w.queries head) (by dsimp [bytes]; omega)

def Arena.dispatch (w : Arena r) : DispatchPlan r where
  one := fun _ => w.sdpa.one
  two := fun _ => w.sdpa.two
  gatesSafe := fun head => (SdpaSharedConstruction.canonical_safe _ _ _ _).mp
    (w.sdpa.protect layer.mixer.attention layer.mixer.mergeContracted
      (by simpa only [Arena.sdpa,Nat.add_zero] using subregion (offset := 0) (w.gates head) (by dsimp [bytes]; omega)))

theorem Arena.attention_eq (w : Arena r) : w.dispatch.attention=w.sdpa.execution layer.mixer.attention layer.mixer.mergeContracted := rfl

theorem Arena.sdpa_safe (w : Arena r) {base size : Nat}
    (safe : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) base size) :
    SdpaShared.Safe w.dispatch.attention base size := by
  rw [w.attention_eq]
  exact w.sdpa.protect _ _ (by simpa only [Arena.sdpa,Nat.add_zero] using subregion (offset := 0) safe (by dsimp [bytes]; omega))

def Arena.tailBase (w : Arena r) : Nat := w.base+SdpaWorkspace.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))
def Arena.suffixBase (w : Arena r) : Nat := w.tailBase+34816

theorem Arena.tail_safe (w : Arena r) {base size : Nat}
    (safe : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) base size) :
    MemoryRegions.Disjoint w.tailBase 34816 base size := subregion safe (by dsimp [bytes]; omega)

theorem Arena.suffix_safe (w : Arena r) {base size : Nat}
    (safe : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) base size) :
    MemoryRegions.Disjoint w.suffixBase 731136 base size := by
  simpa only [Arena.suffixBase,Arena.tailBase,Nat.add_assoc] using
    subregion (offset := SdpaWorkspace.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))+34816)
      (count := 731136) safe (by dsimp [bytes]; omega)

theorem original_projection {property : Nat → Nat → Prop}
    (safe : f.parameters.Protected property) :
    AffineMemoryFrames.Protected layer.mixer.output f.front.parameters.projection property :=
  Eq.mp (congrArg (fun stored => AffineMemoryFrames.Protected layer.mixer.output stored.projection property) f.mixer_eq)
    safe.2.2.1.2.2

def Arena.tailGeometry (w : Arena r) : ResidualAttentionStorageConstruction.TailGeometry a r w.dispatch where
  beforeSafe := original_projection w.parametersBefore
  regions := ⟨w.tailBase/2,(w.tailBase+12288)/2,w.tailBase+24576⟩

attribute [local irreducible] Arena.dispatch

def Arena.tailWorkspace (w : Arena r) : AttentionTailAllocation.Workspace w.dispatch.attention r.gates w.tailGeometry.plan.weightsBefore where
  base := w.tailBase
  aligned := by have := w.aligned; dsimp [Arena.tailBase,SdpaWorkspace.bytes]; omega
  bounded := by
    change w.base+SdpaWorkspace.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))+34816≤2^64
    exact tail_bound w.bounded
  attentionSafe := by
    rw [w.attention_eq,w.sdpa.output_base]
    exact Or.inr (by
      dsimp [Arena.sdpa,Arena.tailBase,SdpaWorkspace.bytes]
      omega)
  gatesSafe := fun head => w.tail_safe (w.gates head)
  keysSafe := w.tail_safe w.keys
  valuesSafe := w.tail_safe w.values
  weightsSafe := by
    apply (AffineMemoryFrames.reframe_protected _ _ _ _ _).mpr
    exact AffineMemoryFrames.protected_mono _ _ (fun _ _ region => ⟨w.sdpa_safe region,w.tail_safe region⟩)
      (original_projection w.parametersOutside)

theorem Arena.tailAllocation (w : Arena r) : TailAllocation w.tailGeometry.plan := w.tailWorkspace.allocation


theorem Arena.tail_eq (w : Arena r) : tail w.tailGeometry.plan w.tailAllocation=
    w.tailWorkspace.execution layer.mixer.gate (fun _ => rfl) w.dispatch.gatesSafeAfter w.tailGeometry.plan.weightsShared := rfl

theorem Arena.tail_protect (w : Arena r) {base size : Nat}
    (safe : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) base size) :
    AttentionTailMemory.Safe (tail w.tailGeometry.plan w.tailAllocation) base size := by
  rw [w.tail_eq]
  exact w.tailWorkspace.protect _ _ _ _ (w.sdpa_safe safe) (w.tail_safe safe)

theorem affine_output_base {steps groups : Nat} {p : AffineVerifyLinear.Projection steps (4*groups)}
    {values : Fin (steps*512) → ArrayStorage.BF} (e : AffineMemory.Execution p values) : e.outputBuffer.base=e.base := by
  cases p <;> rfl

theorem Arena.tail_base (w : Arena r) : (tail w.tailGeometry.plan w.tailAllocation).buffer.base=w.tailBase+24576 := by
  change (tail w.tailGeometry.plan w.tailAllocation).projected.affine.outputBuffer.base=_
  rw [affine_output_base]
  exact AttentionTailConstruction.projected_base w.dispatch.attention r.gates (fun _ => rfl) w.dispatch.gatesSafeAfter
    w.tailGeometry.plan.weightsBefore w.tailGeometry.plan.weightsShared w.tailGeometry.plan.regions w.tailAllocation

attribute [local irreducible] ResidualAttentionConstruction.tail

theorem Arena.suffixGeometry (w : Arena r) : ResidualAttentionStorageConstruction.SuffixGeometry w.tailGeometry w.tailAllocation where
  beforeSafe := w.parametersBefore.2.2.2
  tailSafe := DecodeParameterMemory.suffix_mono _ (fun _ _ region => w.tail_protect region) w.parametersOutside.2.2.2
  residualTail := w.tail_protect w.residual

section SuffixViews
variable {body : Input layer cache input angle} {read : ReadPlan body} {dispatch : DispatchPlan read}
  {t : ResidualAttentionConstruction.TailPlan read dispatch} {ta : TailAllocation t}

def suffixInput (g : SuffixPlan t ta) :=
  AttentionResidualMemory.residualInput (tail t ta) read.residual rfl g.residualTail

def suffixNorm (g : SuffixPlan t ta) :=
  AttentionTailConstruction.normAfterTail (tail t ta) g.normBeforeTail rfl g.normTail

def suffixParameters (g : SuffixPlan t ta) :=
  AttentionTailConstruction.mlpAfterTail (tail t ta) g.parametersBeforeTail g.parametersTailSafe

theorem suffixNorm_base (g : SuffixPlan t ta) : (suffixNorm g).base=g.norm.base := rfl

theorem suffixNorm_shared (g : SuffixPlan t ta) : (suffixNorm g).bytes=(suffixInput g).lhs.bytes := rfl

theorem suffixParameters_regions (g : SuffixPlan t ta) (property : Nat → Nat → Prop) :
    (suffixParameters g).Protected property ↔ g.parameters.Protected property := Iff.rfl

theorem suffixInput_left (g : SuffixPlan t ta) : (suffixInput g).lhs.base=read.residual.base := rfl

theorem suffixInput_right (g : SuffixPlan t ta) : (suffixInput g).rhs.base=(tail t ta).buffer.base := rfl
end SuffixViews

attribute [local irreducible] Arena.tailGeometry

def Arena.mlpWorkspace (w : Arena r) : ResidualMlpAllocation.Workspace
    (suffixInput w.suffixGeometry.plan) (suffixNorm w.suffixGeometry.plan) (suffixParameters w.suffixGeometry.plan) where
  base := w.suffixBase
  aligned := by have := w.aligned; dsimp [Arena.suffixBase,Arena.tailBase,SdpaWorkspace.bytes]; omega
  bounded := by
    change w.base+SdpaWorkspace.bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))+34816+731136≤2^64
    exact suffix_bound w.bounded
  leftSafe := by rw [suffixInput_left]; exact w.suffix_safe w.residual
  rightSafe := by rw [suffixInput_right,w.tail_base]; exact Or.inr (by dsimp [Arena.suffixBase,ResidualMlpAllocation.bytes]; omega)
  normSafe := by
    rw [suffixNorm_base]
    change MemoryRegions.Disjoint w.suffixBase 731136 f.parameters.suffix.norm.base 10240
    exact w.suffix_safe w.parametersOutside.2.2.2.1
  parametersSafe := by
    apply (suffixParameters_regions w.suffixGeometry.plan _).mpr
    change f.parameters.suffix.trellis.Protected (MemoryRegions.Disjoint w.suffixBase 731136)
    exact f.parameters.suffix.trellis.protected_mono (fun _ _ region => w.suffix_safe region) w.parametersOutside.2.2.2.2


def Arena.suffixAllocation (w : Arena r) : SuffixAllocation w.suffixGeometry.plan :=
  w.mlpWorkspace.allocation (suffixNorm_shared w.suffixGeometry.plan)

theorem Arena.suffix_regions (w : Arena r) {base size : Nat}
    (safe : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) base size) :
    ResidualMlpConstruction.RegionsSafe w.suffixAllocation base size := w.mlpWorkspace.six_regions (w.suffix_safe safe)

def Arena.finishPlan (w : Arena r) : ResidualAttentionStorageConstruction.FinishPlan w.tailGeometry w.tailAllocation :=
  ⟨w.suffixGeometry,w.suffixAllocation,
    w.suffix_regions (by rw [(tail w.tailGeometry.plan w.tailAllocation).cache_layout]; exact w.keys),
    w.suffix_regions (by rw [(tail w.tailGeometry.plan w.tailAllocation).cache_layout]; exact w.values)⟩

def Arena.tailPlan (w : Arena r) : ResidualAttentionStorageConstruction.TailPlan a r w.dispatch :=
  ⟨w.tailGeometry,w.tailAllocation,w.finishPlan⟩

def Arena.bodyPlan (w : Arena r) : ResidualAttentionStorageConstruction.BodyPlan f :=
  ⟨a,r,w.dispatch,w.tailPlan⟩

def Arena.fullPlan (w : Arena r) : ResidualAttentionStorageConstruction.Plan s angle :=
  ⟨e,c,f,w.bodyPlan⟩

def Arena.execution (w : Arena r) : ResidualAttentionMemory.Execution layer cache input angle :=
  ResidualAttentionStorageConstruction.fromStorage w.fullPlan

theorem Arena.output_eq (w : Arena r) : w.execution.output=layer.forward input angle cache := w.execution.output_eq

theorem Arena.source_eq (w : Arena r) : w.execution.source=s.source :=
  ResidualAttentionStorageConstruction.source_linked w.fullPlan

theorem Arena.storage_eq (w : Arena r) : w.execution.storage=s.storage :=
  ResidualAttentionStorageConstruction.cache_linked w.fullPlan

-- The suffix execution is built by the strong constructor, not supplied.
def Arena.residualExecution (w : Arena r) :=
  suffix w.suffixGeometry.plan w.suffixAllocation w.finishPlan.2.property.1 w.finishPlan.2.property.2

theorem Arena.residual_safe (w : Arena r) {base size : Nat}
    (safe : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) base size) :
    AttentionResidualMemory.Safe w.residualExecution base size :=
  ⟨w.tail_protect safe,ResidualMlpConstruction.fromStorage_safe _ _ _ _ _ (w.suffix_regions safe)⟩

theorem Arena.other_region (w : Arena r) {base size : Nat}
    (safe : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) base size)
    (offset : Nat) (bound : offset<size) :
    w.residualExecution.outputBuffer.bytes (base+offset)=r.input.cache.memory (base+offset) :=
  w.residualExecution.other_region (w.residual_safe safe) offset bound


def Arena.parametersBeforeRead (w : Arena r) : DecodeParameterMemory.AttentionStorage layer r.input.cache.memory :=
  f.parameters.reframe _ (f.parameters.protected_mono (fun _ _ region => r.other_region region) w.parametersBefore)

theorem Arena.parametersBeforeRead_regions (w : Arena r) (property : Nat → Nat → Prop) :
    w.parametersBeforeRead.Protected property ↔ f.parameters.Protected property := f.parameters.reframe_protected _ _ property

def Arena.parametersAfter (w : Arena r) : DecodeParameterMemory.AttentionStorage layer w.residualExecution.outputBuffer.bytes :=
  w.parametersBeforeRead.reframe _ (w.parametersBeforeRead.protected_mono (fun _ _ region => w.other_region region)
    ((w.parametersBeforeRead_regions _).mpr w.parametersOutside))

theorem Arena.parametersAfter_regions (w : Arena r) (property : Nat → Nat → Prop) :
    w.parametersAfter.Protected property ↔ f.parameters.Protected property :=
  (w.parametersBeforeRead.reframe_protected _ _ property).trans (w.parametersBeforeRead_regions property)

theorem Arena.original_region (w : Arena r) {base size : Nat} (before : r.Safe base size)
    (safe : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount layer.mixer.architectureSuffix (n+1))) base size)
    (offset : Nat) (bound : offset<size) :
    w.residualExecution.outputBuffer.bytes (base+offset)=f.front.entry.source.lhs.bytes (base+offset) :=
  (w.other_region safe offset bound).trans (r.other_region before offset bound)


theorem Arena.output_memory (w : Arena r) : w.execution.outputBuffer.bytes=w.residualExecution.outputBuffer.bytes := rfl

theorem Arena.output_base (w : Arena r) : w.residualExecution.outputBuffer.base=w.suffixBase+720896 :=
  w.mlpWorkspace.output_base (suffixNorm_shared w.suffixGeometry.plan)

def Arena.executionParameters (w : Arena r) : DecodeParameterMemory.AttentionStorage layer w.execution.outputBuffer.bytes :=
  w.output_memory.symm ▸ w.parametersAfter

end Inference.Models.Qwen.AttentionTailWorkspaceConstruction
