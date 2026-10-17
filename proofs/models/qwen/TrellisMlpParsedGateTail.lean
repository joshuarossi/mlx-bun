import models.qwen.TrellisMlpParsedGateProjection
namespace Inference.Models.Qwen.TrellisMlpParsedGateTail
open Contracts.Mlx Contracts.Mlx.M1Max Kernels.Trellis Layers WrittenLayers PackedArrayMaterialization
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF

-- This is a primitive exponential attachment, not a tail/output agreement.
def Exponential (activation : Activation) (precise : Float32 → Float32) (absolute : BF → BF) : Prop :=
  match activation with
  | .float expNeg => ∀ x, precise (-x)=expNeg x
  | .split expAbs => absolute=expAbs

def code (activation : Activation) : Nat := match activation with | .float _ => 0 | .split _ => 1

def value (activation : Activation) (gate up : Float32) : BF := match activation with
  | .split expAbs => GateUpSplitTail.tail expAbs (BFloat16.narrow gate) (BFloat16.narrow up)
  | .float expNeg =>
    let gateT:=BFloat16.cast gate
    let upT:=BFloat16.cast up
    BFloat16.narrow (FlushToZero.mul
      (GateUpTailFlushToZero.roundedMul gateT (GateUpTailFlushToZero.roundedSigmoid expNeg gateT)) upT)

theorem run_value (activation : Activation) (precise : Float32 → Float32) (absolute : BF → BF)
    (exponential : Exponential activation precise absolute) (gate up : Float32) :
    GateTailSource.run GateTailSource.flushing precise absolute (code activation) gate up=some (value activation gate up) := by
  cases activation with
  | split expAbs =>
    change absolute=expAbs at exponential
    rw [exponential]
    exact GateTailSource.split_tail GateTailSource.flushing precise expAbs gate up
  | float expNeg =>
    change ∀ x, precise (-x)=expNeg x at exponential
    rw [show code (.float expNeg)=0 from rfl,GateStoreSource.run_float]
    unfold GateStoreSource.floatTail
    simp only [GateTailSource.flushing]
    rw [exponential]
    rfl

def output (mlp : GateDown) (input : Fin 5120 → BF) (source : ArrayStorage.BFBuffer input)
    (actual : GateInputSource.Execution source tableBase inputBase)
    (packed : GateInput mlp.gate.width mlp.up.width) (precise : Float32 → Float32) (absolute : BF → BF)
    (row : Nat) : Option BF :=
  (GateFlushingProjectionSource.projection packed actual row mlp.gatePlatform.load mlp.gatePlatform.reduce).bind
    (fun pair => GateTailSource.run GateTailSource.flushing precise absolute (code mlp.activation) pair.1 pair.2)

theorem output_eq (mlp : GateDown) (input : Fin 5120 → BF) (source : ArrayStorage.BFBuffer input)
    (actual : GateInputSource.Execution source tableBase inputBase)
    (packed : GateInput mlp.gate.width mlp.up.width) (parameters : TrellisMlpParsedGateProjection.Parameters mlp packed)
    (precise : Float32 → Float32) (absolute : BF → BF) (exponential : Exponential mlp.activation precise absolute)
    (row : Nat) (bound : row<17408) :
    output mlp input source actual packed precise absolute row=some
      (value mlp.activation (TrellisCodebookGateUp.raw mlp.gatePlatform mlp.gate (ArrayStorage.bfWords input) row)
        (TrellisCodebookGateUp.raw mlp.gatePlatform mlp.up (ArrayStorage.bfWords input) row)) := by
  rw [output,TrellisMlpParsedGateProjection.projection_eq mlp input source _ _ actual packed parameters row bound,Option.bind_some]
  exact run_value mlp.activation precise absolute exponential _ _

/-- The existing scheduled gate traces provide the same logical activation;
    their readiness discharges staged input/table reads, not an output premise. -/
theorem value_eq_activation (mlp : GateDown) (input : Nat → BitVec 16)
    (groups : Nat → GateUpBytes.Trace mlp.gatePlatform.base input) (row : Nat) :
    value mlp.activation (TrellisCodebookGateUp.raw mlp.gatePlatform mlp.gate input row)
      (TrellisCodebookGateUp.raw mlp.gatePlatform mlp.up input row)=
      TrellisMlpDevice.activation mlp input groups row := by
  unfold TrellisMlpDevice.activation
  dsimp only
  rw [TrellisScheduled.gateUpRaw_eq mlp.gatePlatform (groups (row%5120/32)).memory
    (groups (row%5120/32)).inputBase mlp.gate input (groups (row%5120/32)).ready row,
    TrellisScheduled.gateUpRaw_eq mlp.gatePlatform (groups (row%5120/32)).memory
    (groups (row%5120/32)).inputBase mlp.up input (groups (row%5120/32)).ready row]
  cases mlp.activation <;> rfl

end Inference.Models.Qwen.TrellisMlpParsedGateTail
