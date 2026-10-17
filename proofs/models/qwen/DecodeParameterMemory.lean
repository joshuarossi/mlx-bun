import models.qwen.DecodeMemoryChain
import models.qwen.DeltaNormalizedConstruction
import models.qwen.AttentionNormalizedConstruction
import models.qwen.ResidualDeltaConstruction

namespace Inference.Models.Qwen.DecodeParameterMemory
open Contracts.Mlx Layers DecodeStage
set_option maxRecDepth 10000

-- Every parameter in a layer is attached once, on the same original heap.
-- Reframing changes the heap view while preserving the physical addresses.
structure DeltaStorage (layer : ResidualDelta.Layer) (memory : ByteMemory.Bytes) where
  norm : ArrayStorage.BFBuffer layer.inputNorm.weight
  normShared : norm.bytes=memory
  projections : DeltaAffineConstruction.Weights layer.mixer memory
  mixer : DeltaParameterMemory.Storage layer.mixer memory
  suffix : ResidualDeltaConstruction.MlpWeights layer.suffix memory

structure AttentionStorage (layer : ResidualAttention.Layer) (memory : ByteMemory.Bytes) where
  norm : ArrayStorage.BFBuffer layer.inputNorm.weight
  normShared : norm.bytes=memory
  projections : AttentionAffineConstruction.Weights layer.mixer.projections memory
  mixer : AttentionParameterMemory.Storage layer.mixer memory
  suffix : ResidualDeltaConstruction.MlpWeights layer.suffix memory

def deltaProjections (w : DeltaAffineConstruction.Weights layer memory) (after : ByteMemory.Bytes)
    (same : DeltaNormalizedConstruction.Protected w
      (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset))) :
    DeltaAffineConstruction.Weights layer after where
  qkv := AffineMemoryFrames.reframe layer.qkv w.qkv after (AffineMemoryFrames.stable _ _ _ _ w.qkvShared same.1)
  z := AffineMemoryFrames.reframe layer.z w.z after (AffineMemoryFrames.stable _ _ _ _ w.zShared same.2.1)
  a := AffineMemoryFrames.reframe layer.a w.a after (AffineMemoryFrames.stable _ _ _ _ w.aShared same.2.2.1)
  b := AffineMemoryFrames.reframe layer.b w.b after (AffineMemoryFrames.stable _ _ _ _ w.bShared same.2.2.2)
  qkvShared := AffineMemoryFrames.reframe_shared _ _ _ _
  zShared := AffineMemoryFrames.reframe_shared _ _ _ _
  aShared := AffineMemoryFrames.reframe_shared _ _ _ _
  bShared := AffineMemoryFrames.reframe_shared _ _ _ _

def attentionProjections (w : AttentionAffineConstruction.Weights layer memory) (after : ByteMemory.Bytes)
    (same : AttentionNormalizedConstruction.Protected w
      (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset))) :
    AttentionAffineConstruction.Weights layer after where
  q := AffineMemoryFrames.reframe layer.q w.q after (AffineMemoryFrames.stable _ _ _ _ w.qShared same.1)
  k := AffineMemoryFrames.reframe layer.k w.k after (AffineMemoryFrames.stable _ _ _ _ w.kShared same.2.1)
  v := AffineMemoryFrames.reframe layer.v w.v after (AffineMemoryFrames.stable _ _ _ _ w.vShared same.2.2)
  qShared := AffineMemoryFrames.reframe_shared _ _ _ _
  kShared := AffineMemoryFrames.reframe_shared _ _ _ _
  vShared := AffineMemoryFrames.reframe_shared _ _ _ _

def DeltaStorage.Protected (s : DeltaStorage layer memory) (property : Nat → Nat → Prop) : Prop :=
  property s.norm.base 10240 ∧ DeltaNormalizedConstruction.Protected s.projections property ∧
    DeltaParameterMemory.Protected s.mixer property ∧ s.suffix.Protected property

def AttentionStorage.Protected (s : AttentionStorage layer memory) (property : Nat → Nat → Prop) : Prop :=
  property s.norm.base 10240 ∧ AttentionNormalizedConstruction.Protected s.projections property ∧
    AttentionParameterMemory.Protected s.mixer property ∧ s.suffix.Protected property

theorem suffix_mono (s : ResidualDeltaConstruction.MlpWeights block memory)
    {first second : Nat → Nat → Prop} (implies : ∀ base size, first base size → second base size)
    (safe : s.Protected first) : s.Protected second :=
  ⟨implies _ _ safe.1,s.trellis.protected_mono implies safe.2⟩

theorem DeltaStorage.protected_mono (s : DeltaStorage layer memory)
    {first second : Nat → Nat → Prop} (implies : ∀ base size, first base size → second base size)
    (safe : s.Protected first) : s.Protected second :=
  ⟨implies _ _ safe.1,
    ⟨AffineMemoryFrames.protected_mono _ _ implies safe.2.1.1,
      AffineMemoryFrames.protected_mono _ _ implies safe.2.1.2.1,
      AffineMemoryFrames.protected_mono _ _ implies safe.2.1.2.2.1,
      AffineMemoryFrames.protected_mono _ _ implies safe.2.1.2.2.2⟩,
    DeltaParameterMemory.protected_mono _ implies safe.2.2.1,
    suffix_mono _ implies safe.2.2.2⟩

theorem AttentionStorage.protected_mono (s : AttentionStorage layer memory)
    {first second : Nat → Nat → Prop} (implies : ∀ base size, first base size → second base size)
    (safe : s.Protected first) : s.Protected second :=
  ⟨implies _ _ safe.1,
    ⟨AffineMemoryFrames.protected_mono _ _ implies safe.2.1.1,
      AffineMemoryFrames.protected_mono _ _ implies safe.2.1.2.1,
      AffineMemoryFrames.protected_mono _ _ implies safe.2.1.2.2⟩,
    AttentionParameterMemory.protected_mono _ implies safe.2.2.1,
    suffix_mono _ implies safe.2.2.2⟩

def DeltaStorage.reframe (s : DeltaStorage layer memory) (after : ByteMemory.Bytes)
    (same : s.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset))) :
    DeltaStorage layer after where
  norm := ArrayFrame.bf s.norm after (fun offset bound => (same.1 offset bound).trans (congrFun s.normShared _).symm)
  normShared := rfl
  projections := deltaProjections s.projections after same.2.1
  mixer := DeltaParameterMemory.reframe s.mixer after same.2.2.1
  suffix := s.suffix.reframe after same.2.2.2

def AttentionStorage.reframe (s : AttentionStorage layer memory) (after : ByteMemory.Bytes)
    (same : s.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset))) :
    AttentionStorage layer after where
  norm := ArrayFrame.bf s.norm after (fun offset bound => (same.1 offset bound).trans (congrFun s.normShared _).symm)
  normShared := rfl
  projections := attentionProjections s.projections after same.2.1
  mixer := AttentionParameterMemory.reframe s.mixer after same.2.2.1
  suffix := s.suffix.reframe after same.2.2.2

theorem delta_projections_regions (w : DeltaAffineConstruction.Weights layer memory) (after : ByteMemory.Bytes)
    (same : DeltaNormalizedConstruction.Protected w (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset)))
    (property : Nat → Nat → Prop) :
    DeltaNormalizedConstruction.Protected (deltaProjections w after same) property ↔
      DeltaNormalizedConstruction.Protected w property := by
  unfold DeltaNormalizedConstruction.Protected deltaProjections
  simp only [AffineMemoryFrames.reframe_protected]

theorem attention_projections_regions (w : AttentionAffineConstruction.Weights layer memory) (after : ByteMemory.Bytes)
    (same : AttentionNormalizedConstruction.Protected w (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset)))
    (property : Nat → Nat → Prop) :
    AttentionNormalizedConstruction.Protected (attentionProjections w after same) property ↔
      AttentionNormalizedConstruction.Protected w property := by
  unfold AttentionNormalizedConstruction.Protected attentionProjections
  simp only [AffineMemoryFrames.reframe_protected]

theorem delta_mixer_regions (w : DeltaParameterMemory.Storage layer memory) (after : ByteMemory.Bytes)
    (same : DeltaParameterMemory.Protected w (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset)))
    (property : Nat → Nat → Prop) :
    DeltaParameterMemory.Protected (DeltaParameterMemory.reframe w after same) property ↔
      DeltaParameterMemory.Protected w property := by
  unfold DeltaParameterMemory.Protected DeltaParameterMemory.reframe
  simp only [ArrayFrame.bf,AffineMemoryFrames.reframe_protected]

theorem suffix_regions (w : ResidualDeltaConstruction.MlpWeights block memory) (after : ByteMemory.Bytes)
    (same : w.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset)))
    (property : Nat → Nat → Prop) : (w.reframe after same).Protected property ↔ w.Protected property := Iff.rfl

theorem DeltaStorage.reframe_protected (s : DeltaStorage layer memory) (after : ByteMemory.Bytes)
    (same : s.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset)))
    (property : Nat → Nat → Prop) : (s.reframe after same).Protected property ↔ s.Protected property := by
  change (property s.norm.base 10240 ∧ _ ∧ _ ∧ _) ↔ _
  exact and_congr Iff.rfl (and_congr (delta_projections_regions s.projections after same.2.1 property)
    (and_congr (delta_mixer_regions s.mixer after same.2.2.1 property)
      (suffix_regions s.suffix after same.2.2.2 property)))

theorem AttentionStorage.reframe_protected (s : AttentionStorage layer memory) (after : ByteMemory.Bytes)
    (same : s.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset)))
    (property : Nat → Nat → Prop) : (s.reframe after same).Protected property ↔ s.Protected property := by
  change (property s.norm.base 10240 ∧ _ ∧ _ ∧ _) ↔ _
  exact and_congr Iff.rfl (and_congr (attention_projections_regions s.projections after same.2.1 property)
    (and_congr (AttentionParameterMemory.reframe_protected s.mixer after same.2.2.1 property)
      (suffix_regions s.suffix after same.2.2.2 property)))

def StageStorage : Stage → ByteMemory.Bytes → Type
  | .delta layer, memory => DeltaStorage layer memory
  | .attention layer, memory => AttentionStorage layer memory

def StageProtected (stage : Stage) (s : StageStorage stage memory) (property : Nat → Nat → Prop) : Prop :=
  match stage with
  | .delta _ => s.Protected property
  | .attention _ => s.Protected property

theorem stage_mono (stage : Stage) (s : StageStorage stage memory)
    {first second : Nat → Nat → Prop} (implies : ∀ base size, first base size → second base size)
    (safe : StageProtected stage s first) : StageProtected stage s second := by
  cases stage with
  | delta _ => exact s.protected_mono implies safe
  | attention _ => exact s.protected_mono implies safe

def stageReframe (stage : Stage) (s : StageStorage stage memory) (after : ByteMemory.Bytes)
    (same : StageProtected stage s (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset))) :
    StageStorage stage after :=
  match stage with
  | .delta _ => s.reframe after same
  | .attention _ => s.reframe after same

theorem stage_regions (stage : Stage) (s : StageStorage stage memory) (after : ByteMemory.Bytes)
    (same : StageProtected stage s (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset)))
    (property : Nat → Nat → Prop) : StageProtected stage (stageReframe stage s after same) property ↔ StageProtected stage s property := by
  cases stage with
  | delta _ => exact s.reframe_protected after same property
  | attention _ => exact s.reframe_protected after same property

def Storage : List Stage → ByteMemory.Bytes → Type
  | [], _ => PUnit
  | stage::rest, memory => StageStorage stage memory × Storage rest memory

def Protected : (stages : List Stage) → Storage stages memory → (Nat → Nat → Prop) → Prop
  | [], _, _ => True
  | stage::rest, s, property => StageProtected stage s.1 property ∧ Protected rest s.2 property

theorem protected_mono : (stages : List Stage) → (s : Storage stages memory) →
    {first second : Nat → Nat → Prop} → (∀ base size, first base size → second base size) →
    Protected stages s first → Protected stages s second
  | [], _, _, _, _, _ => True.intro
  | stage::rest, s, _, _, implies, safe =>
    ⟨stage_mono stage s.1 implies safe.1,protected_mono rest s.2 implies safe.2⟩

def reframe : (stages : List Stage) → (s : Storage stages memory) → (after : ByteMemory.Bytes) →
    Protected stages s (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset)) → Storage stages after
  | [], _, _, _ => ⟨⟩
  | stage::rest, s, after, same => ⟨stageReframe stage s.1 after same.1,reframe rest s.2 after same.2⟩

theorem reframe_protected : (stages : List Stage) → (s : Storage stages memory) → (after : ByteMemory.Bytes) →
    (same : Protected stages s (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset))) →
    (property : Nat → Nat → Prop) → Protected stages (reframe stages s after same) property ↔ Protected stages s property
  | [], _, _, _, _ => Iff.rfl
  | stage::rest, s, after, same, property =>
    and_congr (stage_regions stage s.1 after same.1 property) (reframe_protected rest s.2 after same.2 property)

-- A chain supplies the byte-equality proof; callers supply only the region
-- separation contracts. The returned bundle keeps all original attachments.
def afterChain (stages : List Stage) (cache : DecodeChain.Caches stages n) (input : Row BF)
    (angle : Kernels.Attention.RopeAngles.Inputs) (source : ArrayStorage.BFBuffer input)
    (caches : DecodeFrame.Storage stages cache source.bytes)
    (trace : DecodeMemoryChain.Trace stages cache input angle source caches)
    (parameters : Storage parameterStages source.bytes)
    (safe : Protected parameterStages parameters (DecodeMemoryChain.Safe stages cache input angle source caches trace)) :
    Storage parameterStages (DecodeMemoryChain.outputBuffer stages cache input angle source caches trace).bytes :=
  reframe parameterStages parameters _ (protected_mono parameterStages parameters
    (fun base size region => DecodeMemoryChain.other_region stages cache input angle source caches trace base size region) safe)

theorem afterChain_protected (stages : List Stage) (cache : DecodeChain.Caches stages n) (input : Row BF)
    (angle : Kernels.Attention.RopeAngles.Inputs) (source : ArrayStorage.BFBuffer input)
    (caches : DecodeFrame.Storage stages cache source.bytes)
    (trace : DecodeMemoryChain.Trace stages cache input angle source caches)
    (parameters : Storage parameterStages source.bytes)
    (safe : Protected parameterStages parameters (DecodeMemoryChain.Safe stages cache input angle source caches trace))
    (property : Nat → Nat → Prop) :
    Protected parameterStages (afterChain stages cache input angle source caches trace parameters safe) property ↔
      Protected parameterStages parameters property :=
  reframe_protected parameterStages parameters _ _ property

end Inference.Models.Qwen.DecodeParameterMemory
