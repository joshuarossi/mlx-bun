import models.qwen.ResidualMlpConstruction

namespace Inference.Models.Qwen.ResidualMlpAllocation
open Contracts.Mlx Layers
set_option maxRecDepth 100000
set_option maxHeartbeats 800000

variable {x update : Fin 5120 → ArrayStorage.BF} {block : ResidualBlocks.Mlp}

def bytes : Nat := 731136

structure Workspace (input : BinaryMemory.Input x update) (weights : ArrayStorage.BFBuffer block.norm.weight)
    (parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes) where
  base : Nat
  aligned : base%16=0
  bounded : base+bytes≤2^64
  leftSafe : MemoryRegions.Disjoint base bytes input.lhs.base 10240
  rightSafe : MemoryRegions.Disjoint base bytes input.rhs.base 10240
  normSafe : MemoryRegions.Disjoint base bytes weights.base 10240
  parametersSafe : parameters.Protected (MemoryRegions.Disjoint base bytes)

variable {input : BinaryMemory.Input x update} {weights : ArrayStorage.BFBuffer block.norm.weight}
  {parameters : TrellisWeightsMemory.Weights block.mlp input.lhs.bytes} {other size : Nat}

theorem subregion {workspace other size offset count : Nat}
    (safe : MemoryRegions.Disjoint workspace bytes other size) (inside : offset+count≤bytes) :
    MemoryRegions.Disjoint (workspace+offset) count other size := by
  unfold MemoryRegions.Disjoint at *
  omega

theorem Workspace.residual_byte (w : Workspace input weights parameters) : 2*(w.base/2)=w.base := by
  have := w.aligned
  omega

theorem Workspace.normalized_byte (w : Workspace input weights parameters) : 2*((w.base+10240)/2)=w.base+10240 := by
  have := w.aligned
  omega

theorem Workspace.final_byte (w : Workspace input weights parameters) : 2*((w.base+720896)/2)=w.base+720896 := by
  have := w.aligned
  omega

def Workspace.normalization (w : Workspace input weights parameters) : ResidualMlpConstruction.NormalizationAllocation input weights where
  residualBase := w.base/2
  normalizedBase := (w.base+10240)/2
  residualBounded := by rw [w.residual_byte]; have := w.bounded; dsimp [bytes] at this; omega
  normalizedBounded := by rw [w.normalized_byte]; have := w.bounded; dsimp [bytes] at this; omega
  leftSeparate := MemoryRegions.disjoint_symm (by
    rw [w.residual_byte]
    simpa only [Nat.add_zero] using subregion (offset := 0) (count := 10240) w.leftSafe (by decide +kernel))
  rightSeparate := MemoryRegions.disjoint_symm (by
    rw [w.residual_byte]
    simpa only [Nat.add_zero] using subregion (offset := 0) (count := 10240) w.rightSafe (by decide +kernel))
  residualWeight := by
    rw [w.residual_byte]
    simpa only [Nat.add_zero] using subregion (offset := 0) (count := 10240) w.normSafe (by decide +kernel)
  normalizedResidual := by rw [w.residual_byte,w.normalized_byte]; exact Or.inr (by omega)
  normalizedWeight := by rw [w.normalized_byte]; exact subregion w.normSafe (by decide +kernel : 10240+10240≤bytes)

def Workspace.mlp (w : Workspace input weights parameters) : ResidualMlpConstruction.MlpAllocation where
  middle := w.base+20480
  partialBase := w.base+55296
  output := w.base+710656
  middleAligned := by have := w.aligned; omega
  partialAligned := by have := w.aligned; omega
  outputAligned := by have := w.aligned; omega
  middleBounded := by have := w.bounded; dsimp [bytes] at this; omega
  partialBounded := by have := w.bounded; dsimp [bytes] at this; omega
  outputBounded := by have := w.bounded; dsimp [bytes] at this; omega
  middleSeparate := Or.inr (by omega)
  partialSeparate := Or.inr (by omega)

theorem Workspace.six_regions (w : Workspace input weights parameters)
    (safe : MemoryRegions.Disjoint w.base bytes other size) :
    MemoryRegions.Disjoint (2*w.normalization.residualBase) 10240 other size ∧
    MemoryRegions.Disjoint (2*w.normalization.normalizedBase) 10240 other size ∧
    MemoryRegions.Disjoint w.mlp.middle 34816 other size ∧
    MemoryRegions.Disjoint w.mlp.partialBase 655360 other size ∧
    MemoryRegions.Disjoint w.mlp.output 10240 other size ∧
    MemoryRegions.Disjoint (2*((w.base+720896)/2)) 10240 other size := by
  change MemoryRegions.Disjoint (2*(w.base/2)) 10240 other size ∧
    MemoryRegions.Disjoint (2*((w.base+10240)/2)) 10240 other size ∧
    MemoryRegions.Disjoint (w.base+20480) 34816 other size ∧
    MemoryRegions.Disjoint (w.base+55296) 655360 other size ∧
    MemoryRegions.Disjoint (w.base+710656) 10240 other size ∧
    MemoryRegions.Disjoint (2*((w.base+720896)/2)) 10240 other size
  rw [w.residual_byte,w.normalized_byte,w.final_byte]
  exact ⟨by simpa only [Nat.add_zero] using subregion (offset := 0) (count := 10240) safe (by decide +kernel),
    subregion safe (by decide +kernel : 10240+10240≤bytes),
    subregion safe (by decide +kernel : 20480+34816≤bytes),
    subregion safe (by decide +kernel : 55296+655360≤bytes),
    subregion safe (by decide +kernel : 710656+10240≤bytes),
    subregion safe (by decide +kernel : 720896+10240≤bytes)⟩

def Workspace.allocation (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes) :
    ResidualMlpConstruction.Allocation input weights shared parameters where
  norm := w.normalization
  mlp := w.mlp
  sourceAligned := by change (2*((w.base+10240)/2))%16=0; rw [w.normalized_byte]; have := w.aligned; omega
  inputSeparate := by change MemoryRegions.Disjoint (w.base+20480) 34816 (2*((w.base+10240)/2)) 10240; rw [w.normalized_byte]; exact Or.inr (by omega)
  finalBase := (w.base+720896)/2
  finalBounded := by rw [w.final_byte]; have := w.bounded; dsimp [bytes] at this; omega
  finalResidual := by change MemoryRegions.Disjoint (2*(w.base/2)) 10240 (2*((w.base+720896)/2)) 10240; rw [w.residual_byte,w.final_byte]; exact Or.inl (by omega)
  finalOutput := by change MemoryRegions.Disjoint (w.base+710656) 10240 (2*((w.base+720896)/2)) 10240; rw [w.final_byte]; exact Or.inl (by omega)
  savedResidual := by
    change MemoryRegions.Disjoint (w.base+20480) 34816 (2*(w.base/2)) 10240 ∧
      MemoryRegions.Disjoint (w.base+55296) 655360 (2*(w.base/2)) 10240 ∧
      MemoryRegions.Disjoint (w.base+710656) 10240 (2*(w.base/2)) 10240
    rw [w.residual_byte]
    exact ⟨Or.inr (by omega),Or.inr (by omega),Or.inr (by omega)⟩
  parametersSafe := parameters.protected_mono (fun _ _ region => w.six_regions region) w.parametersSafe
  normSafe := (w.six_regions w.normSafe).2.2

def Workspace.execution (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes) :
    ResidualMlpMemory.Execution block input := ResidualMlpConstruction.fromStorage input weights shared parameters (w.allocation shared)

theorem Workspace.protect (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes)
    (safe : MemoryRegions.Disjoint w.base bytes other size) : ResidualMlpMemory.Safe (w.execution shared) other size :=
  ResidualMlpConstruction.fromStorage_safe input weights shared parameters (w.allocation shared) (w.six_regions safe)

theorem Workspace.other_region (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes)
    (safe : MemoryRegions.Disjoint w.base bytes other size) (offset : Nat) (bound : offset<size) :
    (w.execution shared).outputBuffer.bytes (other+offset)=input.lhs.bytes (other+offset) :=
  (w.execution shared).other_region (w.protect shared safe) offset bound

theorem Workspace.output_eq (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes) :
    (w.execution shared).output=block.forward x update := (w.execution shared).output_eq

theorem Workspace.output_base (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes) :
    (w.execution shared).outputBuffer.base=w.base+720896 := by
  change 2*((w.base+720896)/2)=w.base+720896
  exact w.final_byte

theorem Workspace.bases (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes) :
    let e := w.execution shared
    e.residual.addition.base=w.base/2 ∧ e.normalization.normalized.base=(w.base+10240)/2 ∧
    e.mlp.device.kernel.middle.base=w.base+20480 ∧ e.mlp.device.kernel.down.partialBase=w.base+55296 ∧
    e.mlp.outputBuffer.base=w.base+710656 ∧ e.addition.base=(w.base+720896)/2 :=
  ResidualMlpConstruction.fromStorage_bases input weights shared parameters (w.allocation shared)

def Workspace.parametersAfter (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes) :
    TrellisWeightsMemory.Weights block.mlp (w.execution shared).outputBuffer.bytes :=
  ResidualMlpConstruction.parametersAfter input weights shared parameters (w.allocation shared)

private theorem trellis_regions {mlp : WrittenLayers.GateDown} {memory : ByteMemory.Bytes}
    (stored : TrellisWeightsMemory.Weights mlp memory) (after : ByteMemory.Bytes)
    (same : stored.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset)))
    (property : Nat → Nat → Prop) : (stored.reframe after same).Protected property ↔ stored.Protected property := Iff.rfl

theorem Workspace.parametersAfter_regions (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes)
    (property : Nat → Nat → Prop) : (w.parametersAfter shared).Protected property ↔ parameters.Protected property :=
  trellis_regions parameters (w.execution shared).outputBuffer.bytes
    (parameters.protected_mono (fun _ _ safe => w.other_region shared safe) w.parametersSafe) property

private theorem norm_base (shared : weights.bytes=input.lhs.bytes)
    (allocation : ResidualMlpConstruction.Allocation input weights shared parameters) :
    (ResidualMlpConstruction.normAfter input weights shared parameters allocation).base=weights.base := rfl

private theorem norm_shared (shared : weights.bytes=input.lhs.bytes)
    (allocation : ResidualMlpConstruction.Allocation input weights shared parameters) :
    (ResidualMlpConstruction.normAfter input weights shared parameters allocation).bytes=
      (ResidualMlpConstruction.fromStorage input weights shared parameters allocation).outputBuffer.bytes := rfl

def Workspace.normAfter (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes) : ArrayStorage.BFBuffer block.norm.weight :=
  ResidualMlpConstruction.normAfter input weights shared parameters (w.allocation shared)

theorem Workspace.normAfter_base (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes) :
    (w.normAfter shared).base=weights.base := norm_base shared (w.allocation shared)

theorem Workspace.normAfter_shared (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes) :
    (w.normAfter shared).bytes=(w.execution shared).outputBuffer.bytes := norm_shared shared (w.allocation shared)

theorem footprint : bytes=10240+10240+34816+655360+10240+10240 := by decide +kernel

theorem Workspace.mlp_source (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes) :
    (w.execution shared).mlp.source=(w.execution shared).normalization.outputBuffer := (w.execution shared).linked

theorem Workspace.parameter_bytes (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes) :
    parameters.Protected (fun base size => ∀ offset < size,
      (w.execution shared).outputBuffer.bytes (base+offset)=input.lhs.bytes (base+offset)) :=
  parameters.protected_mono (fun _ _ safe => w.other_region shared safe) w.parametersSafe

theorem Workspace.norm_bytes (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes)
    (offset : Nat) (bound : offset<10240) :
    (w.execution shared).outputBuffer.bytes (weights.base+offset)=weights.bytes (weights.base+offset) :=
  (w.other_region shared w.normSafe offset bound).trans (congrFun shared _).symm

theorem Workspace.left_bytes (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes)
    (offset : Nat) (bound : offset<10240) :
    (w.execution shared).outputBuffer.bytes (input.lhs.base+offset)=input.lhs.bytes (input.lhs.base+offset) :=
  w.other_region shared w.leftSafe offset bound

theorem Workspace.right_bytes (w : Workspace input weights parameters) (shared : weights.bytes=input.lhs.bytes)
    (offset : Nat) (bound : offset<10240) :
    (w.execution shared).outputBuffer.bytes (input.rhs.base+offset)=input.rhs.bytes (input.rhs.base+offset) :=
  (w.other_region shared w.rightSafe offset bound).trans (congrFun input.shared _).symm

end Inference.Models.Qwen.ResidualMlpAllocation
