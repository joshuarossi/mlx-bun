import models.qwen.TrellisWeightsMemory

namespace Inference.Models.Qwen.TrellisParameterExecution
open Contracts.Mlx Kernels.Trellis WrittenLayers
set_option maxRecDepth 10000

structure Execution (mlp : GateDown) (input : Fin 5120 → ArrayStorage.BF) where
  kernel : TrellisMlpMemory.Execution mlp input
  weights : TrellisWeightsMemory.Weights mlp kernel.source.bytes
  safe : weights.Protected (TrellisMlpMemory.Safe kernel)

variable {mlp : GateDown} {input : Fin 5120 → ArrayStorage.BF}

-- Every partial producer schedule preserves all six parameter regions.
def Execution.duringGate (execution : Execution mlp input) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.kernel.device.kernel.middle.base 34816 stores) :
    TrellisWeightsMemory.Weights mlp (HalfMemory.execute stores execution.kernel.source.bytes) :=
  execution.weights.after16 stores inside
    (execution.weights.protected_mono (fun _ _ separate => separate.1) execution.safe)

theorem Execution.gate_parameters (execution : Execution mlp input) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.kernel.device.kernel.middle.base 34816 stores) :
    (execution.duringGate stores inside).readMlp=mlp :=
  (execution.duringGate stores inside).readMlp_eq

def Execution.afterMiddle (execution : Execution mlp input) :
    TrellisWeightsMemory.Weights mlp execution.kernel.device.kernel.middle.memory :=
  execution.weights.reframe _ (execution.weights.protected_mono (by
    intro base size safe offset bound
    exact (OutputRegions.gate_frame execution.kernel.device.kernel.middle safe.1 offset bound).trans
      (congrFun execution.kernel.middleInitial _)) execution.safe)

def Execution.duringDown (execution : Execution mlp input) (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 execution.kernel.device.kernel.down.partialBase 655360 stores) :
    TrellisWeightsMemory.Weights mlp (ByteMemory.execute stores execution.kernel.device.kernel.middle.memory) :=
  execution.afterMiddle.after32 stores inside (by
    change execution.weights.Protected (MemoryRegions.Disjoint execution.kernel.device.kernel.down.partialBase 655360)
    exact execution.weights.protected_mono (fun _ _ separate => separate.2.1) execution.safe)

theorem Execution.down_parameters (execution : Execution mlp input) (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 execution.kernel.device.kernel.down.partialBase 655360 stores) :
    (execution.duringDown stores inside).readMlp=mlp :=
  (execution.duringDown stores inside).readMlp_eq

-- Returned parameter views share the completed output heap and retain
-- their exact payload attachments for subsequent layers and tokens.
def Execution.after (execution : Execution mlp input) :
    TrellisWeightsMemory.Weights mlp execution.kernel.outputBuffer.bytes :=
  execution.weights.reframe _ (execution.weights.protected_mono (fun _ _ safe => execution.kernel.other_region safe) execution.safe)

theorem Execution.output_eq (execution : Execution mlp input) :
    execution.kernel.output=execution.weights.readMlp.forward (Blocks.packed input) :=
  execution.kernel.output_eq.trans (execution.weights.forward_eq (Blocks.packed input)).symm

theorem Execution.after_parameters (execution : Execution mlp input) : execution.after.readMlp=mlp := execution.after.readMlp_eq

theorem Execution.gate_load (execution : Execution mlp input) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.kernel.device.kernel.middle.base 34816 stores)
    (row run index : Nat) (hr : row<17408) (hRun : run<160) (hi : index ≤ mlp.gate.width) :
    ByteMemory.load32 (HalfMemory.execute stores execution.kernel.source.bytes)
      (execution.weights.gate.code.base+4*CheckpointTrellisMemory.gateIndex row run mlp.gate.width index)=
      GateUpCodebook.runWords (mlp.gate.words row (run/8)) run mlp.gate.width index :=
  (execution.duringGate stores inside).gate_word row run index hr hRun hi

theorem Execution.up_load (execution : Execution mlp input) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.kernel.device.kernel.middle.base 34816 stores)
    (row run index : Nat) (hr : row<17408) (hRun : run<160) (hi : index ≤ mlp.up.width) :
    ByteMemory.load32 (HalfMemory.execute stores execution.kernel.source.bytes)
      (execution.weights.up.code.base+4*CheckpointTrellisMemory.gateIndex row run mlp.up.width index)=
      GateUpCodebook.runWords (mlp.up.words row (run/8)) run mlp.up.width index :=
  (execution.duringGate stores inside).up_word row run index hr hRun hi

theorem Execution.down_load (execution : Execution mlp input) (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 execution.kernel.device.kernel.down.partialBase 655360 stores)
    (row block word : Nat) (hr : row<17408) (hb : block<20) (hw : word<8*mlp.down.width) :
    ByteMemory.load32 (ByteMemory.execute stores execution.kernel.device.kernel.middle.memory)
      (execution.weights.down.code.base+4*CheckpointTrellisMemory.downIndex row block word mlp.down.width)=
      mlp.down.words row block word :=
  (execution.duringDown stores inside).down_word row block word hr hb hw

end Inference.Models.Qwen.TrellisParameterExecution
