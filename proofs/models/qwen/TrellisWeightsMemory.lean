import models.qwen.CheckpointTrellisStorage
import models.qwen.TrellisMlpMemory

namespace Inference.Models.Qwen.TrellisWeightsMemory
open Contracts.Mlx Kernels.Trellis Layers WrittenLayers
set_option maxRecDepth 10000

-- Six finite payloads are attached to the same heap as the activations.
-- Bindings identify the exact mathematical weights used by the MLP proof.
structure Weights (mlp : GateDown) (memory : ByteMemory.Bytes) where
  gateCodes : CheckpointTrellis.Codes mlp.gate.width
  upCodes : CheckpointTrellis.Codes mlp.up.width
  downCodes : CheckpointTrellis.Codes mlp.down.width
  gateScales : CheckpointTrellis.Scales
  upScales : CheckpointTrellis.Scales
  downScales : CheckpointTrellis.Scales
  gate : CheckpointTrellisStorage.Storage gateCodes gateScales
  up : CheckpointTrellisStorage.Storage upCodes upScales
  down : CheckpointTrellisStorage.Storage downCodes downScales
  gateShared : gate.code.bytes=memory
  upShared : up.code.bytes=memory
  downShared : down.code.bytes=memory
  gateBinding : CheckpointTrellis.gateUp mlp.gate.width mlp.gate.validWidth gateCodes gateScales=mlp.gate
  upBinding : CheckpointTrellis.gateUp mlp.up.width mlp.up.validWidth upCodes upScales=mlp.up
  downBinding : CheckpointTrellis.down mlp.down.width mlp.down.validWidth downCodes downScales=mlp.down

variable {mlp : GateDown} {memory : ByteMemory.Bytes}

def Weights.Protected (weights : Weights mlp memory) (property : Nat → Nat → Prop) : Prop :=
  property weights.gate.code.base (4*(17408*20*(8*mlp.gate.width))) ∧
  property weights.gate.scale.base 34816 ∧
  property weights.up.code.base (4*(17408*20*(8*mlp.up.width))) ∧
  property weights.up.scale.base 34816 ∧
  property weights.down.code.base (4*(17408*20*(8*mlp.down.width))) ∧
  property weights.down.scale.base 34816

theorem Weights.protected_mono (weights : Weights mlp memory) {first second : Nat → Nat → Prop}
    (implies : ∀ base size, first base size → second base size) (safe : weights.Protected first) : weights.Protected second :=
  ⟨implies _ _ safe.1, implies _ _ safe.2.1, implies _ _ safe.2.2.1,
    implies _ _ safe.2.2.2.1, implies _ _ safe.2.2.2.2.1, implies _ _ safe.2.2.2.2.2⟩

def Weights.reframe (weights : Weights mlp memory) (after : ByteMemory.Bytes)
    (same : weights.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset))) :
    Weights mlp after where
  gateCodes := weights.gateCodes
  upCodes := weights.upCodes
  downCodes := weights.downCodes
  gateScales := weights.gateScales
  upScales := weights.upScales
  downScales := weights.downScales
  gate := weights.gate.reframe after
    (fun offset bound => (same.1 offset bound).trans (congrFun weights.gateShared _).symm)
    (fun offset bound => (same.2.1 offset bound).trans (congrFun weights.gateShared _).symm)
  up := weights.up.reframe after
    (fun offset bound => (same.2.2.1 offset bound).trans (congrFun weights.upShared _).symm)
    (fun offset bound => (same.2.2.2.1 offset bound).trans (congrFun weights.upShared _).symm)
  down := weights.down.reframe after
    (fun offset bound => (same.2.2.2.2.1 offset bound).trans (congrFun weights.downShared _).symm)
    (fun offset bound => (same.2.2.2.2.2 offset bound).trans (congrFun weights.downShared _).symm)
  gateShared := rfl
  upShared := rfl
  downShared := rfl
  gateBinding := weights.gateBinding
  upBinding := weights.upBinding
  downBinding := weights.downBinding

def Weights.after16 (weights : Weights mlp memory) {base size : Nat} (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 base size stores) (safe : weights.Protected (MemoryRegions.Disjoint base size)) :
    Weights mlp (HalfMemory.execute stores memory) :=
  weights.reframe _ (weights.protected_mono (fun _ _ separate => MemoryRegions.execute16_other stores memory inside separate) safe)

def Weights.after32 (weights : Weights mlp memory) {base size : Nat} (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 base size stores) (safe : weights.Protected (MemoryRegions.Disjoint base size)) :
    Weights mlp (ByteMemory.execute stores memory) :=
  weights.reframe _ (weights.protected_mono (fun _ _ separate => MemoryRegions.execute32_other stores memory inside separate) safe)

theorem Weights.gate_projection (weights : Weights mlp memory) : weights.gate.gateProjection mlp.gate.validWidth=mlp.gate :=
  (weights.gate.gate_eq mlp.gate.validWidth).trans weights.gateBinding

theorem Weights.up_projection (weights : Weights mlp memory) : weights.up.gateProjection mlp.up.validWidth=mlp.up :=
  (weights.up.gate_eq mlp.up.validWidth).trans weights.upBinding

theorem Weights.down_projection (weights : Weights mlp memory) : weights.down.downProjection mlp.down.validWidth=mlp.down :=
  (weights.down.down_eq mlp.down.validWidth).trans weights.downBinding

def Weights.readMlp (weights : Weights mlp memory) : GateDown where
  activation := mlp.activation
  gatePlatform := mlp.gatePlatform
  gate := weights.gate.gateProjection mlp.gate.validWidth
  up := weights.up.gateProjection mlp.up.validWidth
  downPlatform := mlp.downPlatform
  down := weights.down.downProjection mlp.down.validWidth

theorem Weights.readMlp_eq (weights : Weights mlp memory) : weights.readMlp=mlp := by
  unfold Weights.readMlp
  rw [weights.gate_projection, weights.up_projection, weights.down_projection]

theorem Weights.forward_eq (weights : Weights mlp memory) (input : Nat → BitVec 16) :
    weights.readMlp.forward input=mlp.forward input := by rw [weights.readMlp_eq]

-- These are the actual main/wrap and interleaved global loads, not a
-- separately encoded copy of the packed matrix.
theorem Weights.gate_word (weights : Weights mlp memory) (row run index : Nat)
    (hr : row<17408) (hRun : run<160) (hi : index ≤ mlp.gate.width) :
    ByteMemory.load32 memory (weights.gate.code.base+4*CheckpointTrellisMemory.gateIndex row run mlp.gate.width index)=
      GateUpCodebook.runWords (mlp.gate.words row (run/8)) run mlp.gate.width index := by
  have words := congrArg TrellisCodebookGateUp.Projection.words weights.gateBinding
  change CheckpointTrellis.gateWords mlp.gate.width mlp.gate.validWidth weights.gateCodes=mlp.gate.words at words
  have result := weights.gate.gate_run_word mlp.gate.validWidth row run index hr hRun hi
  rw [words] at result
  exact (congrArg (fun bytes => ByteMemory.load32 bytes
    (weights.gate.code.base+4*CheckpointTrellisMemory.gateIndex row run mlp.gate.width index)) weights.gateShared.symm).trans result

theorem Weights.up_word (weights : Weights mlp memory) (row run index : Nat)
    (hr : row<17408) (hRun : run<160) (hi : index ≤ mlp.up.width) :
    ByteMemory.load32 memory (weights.up.code.base+4*CheckpointTrellisMemory.gateIndex row run mlp.up.width index)=
      GateUpCodebook.runWords (mlp.up.words row (run/8)) run mlp.up.width index := by
  have words := congrArg TrellisCodebookGateUp.Projection.words weights.upBinding
  change CheckpointTrellis.gateWords mlp.up.width mlp.up.validWidth weights.upCodes=mlp.up.words at words
  have result := weights.up.gate_run_word mlp.up.validWidth row run index hr hRun hi
  rw [words] at result
  exact (congrArg (fun bytes => ByteMemory.load32 bytes
    (weights.up.code.base+4*CheckpointTrellisMemory.gateIndex row run mlp.up.width index)) weights.upShared.symm).trans result

theorem Weights.down_word (weights : Weights mlp memory) (row block word : Nat)
    (hr : row<17408) (hb : block<20) (hw : word<8*mlp.down.width) :
    ByteMemory.load32 memory (weights.down.code.base+4*CheckpointTrellisMemory.downIndex row block word mlp.down.width)=
      mlp.down.words row block word := by
  have words := congrArg TrellisCodebookDown.Projection.words weights.downBinding
  change CheckpointTrellis.downWords mlp.down.width mlp.down.validWidth weights.downCodes=mlp.down.words at words
  have result := weights.down.down_source_word mlp.down.validWidth row block word hr hb hw
  rw [words] at result
  exact (congrArg (fun bytes => ByteMemory.load32 bytes
    (weights.down.code.base+4*CheckpointTrellisMemory.downIndex row block word mlp.down.width)) weights.downShared.symm).trans result

end Inference.Models.Qwen.TrellisWeightsMemory
