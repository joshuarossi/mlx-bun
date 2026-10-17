import kernels.trellis.GateUpBytes
import kernels.trellis.DownReadBarrier
import models.qwen.TrellisMlpScheduled

namespace Inference.Models.Qwen.TrellisMlpBytes
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Trellis Layers WrittenLayers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- The down traces consume the activation computed from the staged input
-- bytes. Encoding the old initial memory introduces no restriction: its
-- floating view is proved equal, while each kernel overwrites its own cells.
structure Execution (mlp : GateDown) (input : Nat → BitVec 16) where
  gate : GateUpBytes.Trace mlp.gatePlatform.base input
  down : ∀ ty, DownReadBarrier.Trace mlp.downPlatform.load (FloatMemory.encode (mlp.downPlatform.before ty))
    mlp.downPlatform.base mlp.down.words mlp.down.width mlp.down.scale
      (TrellisMlpScheduled.intermediate mlp gate.memory gate.inputBase) ty

def Execution.canonical (mlp : GateDown) (input : Nat → BitVec 16) : Execution mlp input :=
  let gate := GateUpBytes.Trace.canonical mlp.gatePlatform.base input (fun _ => 0)
    (4*(mlp.gatePlatform.base/4+4096)) (by omega) (Or.inl (by omega))
  ⟨gate, fun ty => DownReadBarrier.Trace.canonical mlp.downPlatform.load (FloatMemory.encode (mlp.downPlatform.before ty))
    mlp.downPlatform.base mlp.down.words mlp.down.width mlp.down.scale
      (TrellisMlpScheduled.intermediate mlp gate.memory gate.inputBase) ty⟩

def Execution.toScheduled (execution : Execution mlp input) : TrellisMlpScheduled.Execution mlp input where
  memory := execution.gate.memory
  inputBase := execution.gate.inputBase
  ready := execution.gate.ready
  down := fun ty => by simpa only [FloatMemory.view_encode] using (execution.down ty).toBytes.toScheduled

def forward (mlp : GateDown) (input : Nat → BitVec 16) (execution : Execution mlp input) (column : Fin 5120) :
    BFloat16Arithmetic.Value :=
  BFloat16.narrow (DownBytes.output mlp.downPlatform.load (fun ty => FloatMemory.encode (mlp.downPlatform.before ty))
    mlp.downPlatform.base mlp.down.words mlp.down.width mlp.down.scale
      (TrellisMlpScheduled.intermediate mlp execution.gate.memory execution.gate.inputBase)
        (fun ty => (execution.down ty).toBytes) mlp.downPlatform.reduce id column.val)

theorem forward_eq (mlp : GateDown) (input : Nat → BitVec 16) (execution : Execution mlp input) (column : Fin 5120) :
    forward mlp input execution column=mlp.forward input column := by
  unfold forward
  rw [DownBytes.output_correct mlp.downPlatform.load mlp.downPlatform.loads _ mlp.downPlatform.base
    mlp.downPlatform.aligned mlp.downPlatform.bounded mlp.down.words mlp.down.width mlp.down.validWidth mlp.down.scale
      (TrellisMlpScheduled.intermediate mlp execution.gate.memory execution.gate.inputBase) (fun ty => (execution.down ty).toBytes)
        mlp.downPlatform.reduce id column.val column.isLt]
  rw [TrellisMlpScheduled.intermediate_eq mlp input execution.gate.memory execution.gate.inputBase execution.gate.ready]
  rfl

theorem forward_scheduled_eq (mlp : GateDown) (input : Nat → BitVec 16) (execution : Execution mlp input) (column : Fin 5120) :
    forward mlp input execution column=TrellisMlpScheduled.forward mlp input execution.toScheduled column := by
  rw [forward_eq, TrellisMlpScheduled.forward_eq]

theorem forward_error (mlp : GateDown) (input : Nat → BitVec 16) (execution : Execution mlp input)
    (target error : Fin 5120 → ℝ) (hi : ∀ i, |real (GateUpExecution.widen (input i.val))-target i| ≤ error i)
    (hf : TrellisMlp.Finite mlp input) (column : Fin 5120) :
    |Model.toReal (forward mlp input execution column)-mlp.target target column| ≤
      TrellisMlp.budget mlp input target error hf column := by
  rw [forward_eq]
  exact TrellisMlp.forward_error mlp input target error hi hf column

end Inference.Models.Qwen.TrellisMlpBytes
