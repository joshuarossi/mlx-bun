import kernels.trellis.GateUpOutput
import kernels.trellis.GateUpBytes
import kernels.trellis.DownInputCongruence
import kernels.trellis.DownOutput
import models.qwen.TrellisMlpScheduled
import models.qwen.MlpExecution

namespace Inference.Models.Qwen.TrellisMlpDevice
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Trellis Layers WrittenLayers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- Each output row uses its actual producer threadgroup's staged memory.
-- This value is the BF16 stored by the last operation of either tail.
@[irreducible] def activation (mlp : GateDown) (input : Nat → BitVec 16)
    (groups : Nat → GateUpBytes.Trace mlp.gatePlatform.base input) (row : Nat) : BFloat16Arithmetic.Value :=
  let group := groups (row%5120/32)
  let gate := TrellisScheduled.gateUpRaw mlp.gatePlatform group.memory group.inputBase mlp.gate row
  let up := TrellisScheduled.gateUpRaw mlp.gatePlatform group.memory group.inputBase mlp.up row
  match mlp.activation with
  | .split expAbs => GateUpSplitTail.tail expAbs (BFloat16.narrow gate) (BFloat16.narrow up)
  | .float expNeg =>
    let gateT := BFloat16.cast gate
    let upT := BFloat16.cast up
    BFloat16.narrow (FlushToZero.mul
      (GateUpTailFlushToZero.roundedMul gateT (GateUpTailFlushToZero.roundedSigmoid expNeg gateT)) upT)

theorem activation_widen (mlp : GateDown) (input : Nat → BitVec 16)
    (groups : Nat → GateUpBytes.Trace mlp.gatePlatform.base input) (row : Nat) :
    BFloat16.widen (activation mlp input groups row)=mlp.intermediate input row := by
  let group := groups (row%5120/32)
  have stored : BFloat16.widen (activation mlp input groups row)=
      TrellisMlpScheduled.intermediate mlp group.memory group.inputBase row := by
    unfold activation TrellisMlpScheduled.intermediate
    cases kind : mlp.activation with
    | float expNeg => rfl
    | split expAbs => rfl
  exact stored.trans (congrFun (TrellisMlpScheduled.intermediate_eq mlp input group.memory group.inputBase group.ready) row)

-- Gate/up dispatch -> BF16 activation buffer -> down read/computation and
-- scratch phases -> global partial buffer -> fold -> BF16 output buffer.
-- All intermediate inputs
-- below are the values read from the preceding completed storage trace.
structure Execution (mlp : GateDown) (input : Nat → BitVec 16) where
  gate : Nat → GateUpBytes.Trace mlp.gatePlatform.base input
  middle : GateUpOutput.Trace (activation mlp input gate)
  down : DownDevice.Trace mlp.downPlatform.load (fun ty => FloatMemory.encode (mlp.downPlatform.before ty))
    mlp.downPlatform.base mlp.down.words mlp.down.width mlp.down.scale middle.read
  output : DownOutput.Trace (DownOutput.foldValues down mlp.downPlatform.reduce)

def Execution.canonical (mlp : GateDown) (input : Nat → BitVec 16) : Execution mlp input :=
  let gate := fun _ : Nat => GateUpBytes.Trace.canonical mlp.gatePlatform.base input (fun _ => 0)
    (16*(mlp.gatePlatform.base/16+1025)) (by omega) (Or.inl (by omega))
  let middle := GateUpOutput.Trace.canonical (activation mlp input gate) (fun _ => 0) 0 (by decide) (by decide)
  let down := DownDevice.Trace.canonical mlp.downPlatform.load (fun ty => FloatMemory.encode (mlp.downPlatform.before ty))
    mlp.downPlatform.base mlp.down.words mlp.down.width mlp.down.scale middle.read (fun _ => 0) 0 (by decide) (by decide)
  ⟨gate, middle, down, DownOutput.Trace.canonical (DownOutput.foldValues down mlp.downPlatform.reduce)
    (fun _ => 0) 0 (by decide) (by decide)⟩

theorem Execution.input_eq (execution : Execution mlp input) (row : Nat) (bound : row<17408) :
    execution.middle.read row=mlp.intermediate input row := by
  rw [execution.middle.read_correct row bound]
  exact activation_widen mlp input execution.gate row

def forward (mlp : GateDown) (input : Nat → BitVec 16) (execution : Execution mlp input) (column : Fin 5120) :
    BFloat16Arithmetic.Value :=
  execution.output.read column.val

theorem forward_eq (mlp : GateDown) (input : Nat → BitVec 16) (execution : Execution mlp input) (column : Fin 5120) :
    forward mlp input execution column=mlp.forward input column := by
  unfold forward
  rw [execution.output.read_correct column.val column.isLt]
  unfold DownOutput.foldValues
  rw [DownInputCongruence.output_eq execution.down mlp.downPlatform.loads mlp.downPlatform.aligned mlp.downPlatform.bounded
    mlp.down.validWidth (mlp.intermediate input) (fun row bound => execution.input_eq row bound)
      mlp.downPlatform.reduce id column.val column.isLt]
  rfl

theorem forward_error (mlp : GateDown) (input : Nat → BitVec 16) (execution : Execution mlp input)
    (target error : Fin 5120 → ℝ) (hi : ∀ i, |real (GateUpExecution.widen (input i.val))-target i| ≤ error i)
    (hf : TrellisMlp.Finite mlp input) (column : Fin 5120) :
    |Model.toReal (forward mlp input execution column)-mlp.target target column| ≤ TrellisMlp.budget mlp input target error hf column := by
  rw [forward_eq]
  exact TrellisMlp.forward_error mlp input target error hi hf column

theorem forward_finite (mlp : GateDown) (input : Nat → BitVec 16) (execution : Execution mlp input)
    (hf : TrellisMlp.Finite mlp input) (column : Fin 5120) : Model.isFinite (forward mlp input execution column)=true := by
  rw [forward_eq]
  exact TrellisMlp.forward_finite mlp input hf column

def implementation : MlpExecution.Implementation where
  Trace := Execution
  forward := forward
  refines := fun mlp input execution => funext (forward_eq mlp input execution)
  canonical := Execution.canonical

end Inference.Models.Qwen.TrellisMlpDevice
