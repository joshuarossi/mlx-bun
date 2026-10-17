import layers.TrellisScheduled
import models.qwen.TrellisMlp

namespace Inference.Models.Qwen.TrellisMlpScheduled
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Trellis Layers WrittenLayers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

@[irreducible] def intermediate (mlp : GateDown) (memory : GateUpBarrier.RawMemory) (inputBase : Nat) (row : Nat) : Float32 :=
  match mlp.activation with
  | .float expNeg => TrellisScheduled.gateUpFloatOutput mlp.gatePlatform memory inputBase mlp.gate mlp.up row expNeg
  | .split expAbs => TrellisScheduled.gateUpSplitOutput mlp.gatePlatform memory inputBase mlp.gate mlp.up row expAbs

theorem intermediate_eq (mlp : GateDown) (input : Nat → BitVec 16) (memory : GateUpBarrier.RawMemory) (inputBase : Nat)
    (ready : GateUpBarrier.Ready memory mlp.gatePlatform.base inputBase input) :
    intermediate mlp memory inputBase=mlp.intermediate input := by
  funext row
  unfold intermediate GateDown.intermediate WrittenLayers.hidden
  cases activation : mlp.activation with
  | float expNeg => exact TrellisScheduled.gateUpFloatOutput_eq mlp.gatePlatform memory inputBase mlp.gate mlp.up input ready row expNeg
  | split expAbs => exact TrellisScheduled.gateUpSplitOutput_eq mlp.gatePlatform memory inputBase mlp.gate mlp.up input ready row expAbs

-- The down kernel consumes precisely the staged gate/up result. Its trace
-- is indexed by that result, so no separate equality of intermediate inputs
-- is requested from the caller.
structure Execution (mlp : GateDown) (input : Nat → BitVec 16) where
  memory : GateUpBarrier.RawMemory
  inputBase : Nat
  ready : GateUpBarrier.Ready memory mlp.gatePlatform.base inputBase input
  down : ∀ ty, DownScheduled.Trace mlp.downPlatform.load (mlp.downPlatform.before ty) mlp.downPlatform.base
    mlp.down.words mlp.down.width mlp.down.scale (intermediate mlp memory inputBase) ty

def Execution.canonical (mlp : GateDown) (input : Nat → BitVec 16) (before : GateUpBarrier.RawMemory)
    (inputBase : Nat) (separate : GateUpBarrier.Separate mlp.gatePlatform.base inputBase) : Execution mlp input :=
  let programs := GateUpBarrier.programs mlp.gatePlatform.base inputBase input
  let memory := MemoryCells.execute programs.flatten before
  ⟨memory, inputBase,
    GateUpBarrier.ready before mlp.gatePlatform.base inputBase input separate programs.flatten
      (List.replicate programs.length []) (ThreadgroupWrites.canonical programs) (ThreadgroupWrites.canonical_barrier programs),
    fun ty => DownScheduled.Trace.canonical mlp.downPlatform.load (mlp.downPlatform.before ty) mlp.downPlatform.base
      mlp.down.words mlp.down.width mlp.down.scale (intermediate mlp memory inputBase) ty⟩

def forward (mlp : GateDown) (input : Nat → BitVec 16) (execution : Execution mlp input) (col : Fin 5120) :
    BFloat16Arithmetic.Value :=
  BFloat16.narrow (DownScheduled.output mlp.downPlatform.load mlp.downPlatform.before mlp.downPlatform.base
    mlp.down.words mlp.down.width mlp.down.scale (intermediate mlp execution.memory execution.inputBase)
    execution.down mlp.downPlatform.reduce id col.val)

theorem forward_eq (mlp : GateDown) (input : Nat → BitVec 16) (execution : Execution mlp input) (col : Fin 5120) :
    forward mlp input execution col=mlp.forward input col := by
  unfold forward
  rw [DownScheduled.output_correct mlp.downPlatform.load mlp.downPlatform.loads mlp.downPlatform.before
    mlp.downPlatform.base mlp.downPlatform.aligned mlp.downPlatform.bounded mlp.down.words mlp.down.width mlp.down.validWidth
    mlp.down.scale (intermediate mlp execution.memory execution.inputBase) execution.down mlp.downPlatform.reduce id col.val col.isLt]
  rw [intermediate_eq mlp input execution.memory execution.inputBase execution.ready]
  rfl

theorem forward_error (mlp : GateDown) (input : Nat → BitVec 16) (execution : Execution mlp input)
    (target error : Fin 5120 → ℝ) (hi : ∀ i, |real (GateUpExecution.widen (input i.val))-target i| ≤ error i)
    (hf : TrellisMlp.Finite mlp input) (col : Fin 5120) :
    |Model.toReal (forward mlp input execution col)-mlp.target target col| ≤ TrellisMlp.budget mlp input target error hf col := by
  rw [forward_eq]
  exact TrellisMlp.forward_error mlp input target error hi hf col

theorem forward_finite (mlp : GateDown) (input : Nat → BitVec 16) (execution : Execution mlp input)
    (hf : TrellisMlp.Finite mlp input) (col : Fin 5120) : Model.isFinite (forward mlp input execution col)=true := by
  rw [forward_eq]
  exact TrellisMlp.forward_finite mlp input hf col

end Inference.Models.Qwen.TrellisMlpScheduled
