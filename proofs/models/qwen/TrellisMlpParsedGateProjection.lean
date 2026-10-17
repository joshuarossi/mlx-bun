import kernels.trellis.GateFlushingProjectionSource
import models.qwen.TrellisMlpParsedDown
namespace Inference.Models.Qwen.TrellisMlpParsedGateProjection
open Contracts.Mlx Contracts.Mlx.M1Max Kernels.Trellis Layers WrittenLayers
open PackedArrayMaterialization
set_option maxRecDepth 10000

-- Original checkpoint parameter attachment, independently of any result.
structure Parameters (mlp : GateDown) (packed : GateInput mlp.gate.width mlp.up.width) : Prop where
  gateWords : packed.matrix false=mlp.gate.words
  upWords : packed.matrix true=mlp.up.words
  gateScales : CheckpointTrellis.scale packed.gateScales=mlp.gate.scale
  upScales : CheckpointTrellis.scale packed.upScales=mlp.up.scale

theorem raw_reference (platform : TrellisCodebookGateUp.Platform) (projection : TrellisCodebookGateUp.Projection)
    (input : Nat → BitVec 16) (row : Nat) :
    platform.reduce (fun lane => GateUpFlushToZero.referenceLane projection.words projection.width projection.scale input row lane.val)=
      TrellisCodebookGateUp.raw platform projection input row := by
  unfold TrellisCodebookGateUp.raw
  apply congrArg platform.reduce
  funext lane
  exact (GateUpFlushToZero.sourceLane_correct platform.load platform.loads
    (TrellisCodebookGateUp.table platform) platform.base platform.aligned platform.bounded
    (TrellisCodebookGateUp.table_initialized platform) projection.words projection.width projection.validWidth
    projection.scale input row lane.val lane.isLt).symm

theorem projection_eq (mlp : GateDown) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (tableBase inputBase : Nat)
    (actual : GateInputSource.Execution source tableBase inputBase)
    (packed : GateInput mlp.gate.width mlp.up.width) (parameters : Parameters mlp packed)
    (row : Nat) (bound : row<17408) :
    GateFlushingProjectionSource.projection packed actual row mlp.gatePlatform.load mlp.gatePlatform.reduce=some
      (TrellisCodebookGateUp.raw mlp.gatePlatform mlp.gate (ArrayStorage.bfWords input) row,
       TrellisCodebookGateUp.raw mlp.gatePlatform mlp.up (ArrayStorage.bfWords input) row) := by
  have result:=GateFlushingProjectionSource.projection_correct packed actual row bound
    mlp.gatePlatform.load mlp.gatePlatform.loads mlp.gatePlatform.reduce
  have gateScale : GateWeightSource.scaleValue packed false=mlp.gate.scale := by
    funext row
    exact congrFun parameters.gateScales row
  have upScale : GateWeightSource.scaleValue packed true=mlp.up.scale := by
    funext row
    exact congrFun parameters.upScales row
  simp only [GateLaneBridge.scale] at result
  rw [parameters.gateWords,parameters.upWords,gateScale,upScale] at result
  rw [raw_reference,raw_reference] at result
  exact result

end Inference.Models.Qwen.TrellisMlpParsedGateProjection
