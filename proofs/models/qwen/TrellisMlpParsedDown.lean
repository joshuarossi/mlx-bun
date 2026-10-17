import kernels.trellis.DownBuiltinSource
import models.qwen.TrellisMlpSource
namespace Inference.Models.Qwen.TrellisMlpParsedDown
open Contracts.Mlx Contracts.Mlx.M1Max Contracts.Mlx.Numerics Kernels.Trellis Layers WrittenLayers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF

def middleValues (preceding : TrellisMlpSource.Execution mlp input) : Fin 17408 → BF :=
  fun row => TrellisMlpDevice.activation mlp (ArrayStorage.bfWords input) preceding.kernel.gate row.val

/-- Attach the preceding producer's actual bytes, without constructing a
    fresh canonical activation memory or supplying an activation-value premise. -/
def middleBuffer (preceding : TrellisMlpSource.Execution mlp input) :
    ArrayStorage.BFBuffer (middleValues preceding) where
  bytes := preceding.kernel.middle.memory
  base := preceding.kernel.middle.base
  aligned := preceding.kernel.middle.aligned
  bounded := preceding.kernel.middle.bounded
  attached := by
    intro row
    unfold GateUpOutput.Trace.memory
    rw [HalfMemory.execute_load _ _ _ (by have := preceding.kernel.middle.aligned; omega),
      show (preceding.kernel.middle.base+2*row.val)/2=preceding.kernel.middle.base/2+row.val by
        have := preceding.kernel.middle.aligned; omega]
    exact GateUpOutput.stored _ _ _ _ _ preceding.kernel.middle.execution preceding.kernel.middle.completed row.val row.isLt

/-- The checkpoint equalities attach packed bytes/scales to the model's
    parameter functions. They do not assume any kernel output or error bound. -/
structure Execution (mlp : GateDown) (input : Fin 5120 → BF) where
  preceding : TrellisMlpSource.Execution mlp input
  packed : PackedArrayDownMaterialization.Input mlp.down.width
  words : packed.matrix=mlp.down.words
  scales : CheckpointTrellis.scale packed.scales=mlp.down.scale
  down : DownDevice.Trace mlp.downPlatform.load (fun ty => FloatMemory.encode (mlp.downPlatform.before ty))
    mlp.downPlatform.base packed.matrix mlp.down.width (CheckpointTrellis.scale packed.scales)
      (DownLaneSource.activationValue (middleValues preceding))
  output : DownOutput.Trace (DownOutput.foldValues down mlp.downPlatform.reduce)

variable {mlp : GateDown} {input : Fin 5120 → BF}

theorem middle_value (execution : Execution mlp input) (row : Nat) (bound : row<17408) :
    DownLaneSource.activationValue (middleValues execution.preceding) row=
      mlp.intermediate (ArrayStorage.bfWords input) row := by
  rw [←DownLaneSource.activation_value (middleValues execution.preceding) row bound]
  exact TrellisMlpDevice.activation_widen mlp (ArrayStorage.bfWords input) execution.preceding.kernel.gate row

/-- All three parsed down phases consume the preceding current activation
    and preserve the native schedules already represented in this execution. -/
theorem parsed_execution (execution : Execution mlp input) (abi : DownFoldVectorMemory.VectorLoad) :
    (∀ ty, ty<160 → ThreadgroupWrites.Executes
      (DownScratchSource.programs execution.packed (middleBuffer execution.preceding) ty mlp.downPlatform.load
        (FloatMemory.view (FloatMemory.execute (execution.down.threadgroup ty).tableSchedule
          (FloatMemory.encode (mlp.downPlatform.before ty)))) mlp.downPlatform.base)
      (execution.down.threadgroup ty).scratchSchedule (execution.down.threadgroup ty).scratchRemaining) ∧
    ThreadgroupWrites.Executes
      (DownPartialSource.programs execution.packed (middleBuffer execution.preceding) mlp.downPlatform.load
        (fun ty => FloatMemory.encode (mlp.downPlatform.before ty)) mlp.downPlatform.base
        execution.down.partialBase execution.down.threadgroup)
      execution.down.schedule execution.down.remaining ∧
    ThreadgroupWrites.Executes
      (DownFoldOutputSource.programs abi execution.down mlp.downPlatform.reduce execution.output.base)
      execution.output.schedule execution.output.remaining :=
  DownPipelineSource.execution execution.packed (middleBuffer execution.preceding) mlp.downPlatform.load
    (fun ty => FloatMemory.encode (mlp.downPlatform.before ty)) mlp.downPlatform.base execution.down abi
    mlp.downPlatform.reduce execution.output

def output (execution : Execution mlp input) (column : Fin 5120) : BF := execution.output.read column.val

theorem output_eq (execution : Execution mlp input) (column : Fin 5120) :
    output execution column=mlp.forward (ArrayStorage.bfWords input) column := by
  rw [output,execution.output.read_correct column.val column.isLt]
  unfold DownOutput.foldValues
  rw [DownInputCongruence.output_eq execution.down mlp.downPlatform.loads mlp.downPlatform.aligned mlp.downPlatform.bounded
    execution.packed.valid (mlp.intermediate (ArrayStorage.bfWords input)) (middle_value execution)
    mlp.downPlatform.reduce id column.val column.isLt]
  rw [execution.words,execution.scales]
  rfl

theorem output_error (execution : Execution mlp input) (target error : Fin 5120 → ℝ)
    (hi : ∀ i, |real (GateUpExecution.widen (ArrayStorage.bfWords input i.val))-target i| ≤ error i)
    (finite : TrellisMlp.Finite mlp (ArrayStorage.bfWords input)) (column : Fin 5120) :
    |Model.toReal (output execution column)-mlp.target target column| ≤
      TrellisMlp.budget mlp (ArrayStorage.bfWords input) target error finite column := by
  rw [output_eq]
  exact TrellisMlp.forward_error mlp (ArrayStorage.bfWords input) target error hi finite column

theorem current_output_bits (execution : Execution mlp input) (abi : DownFoldVectorMemory.VectorLoad)
    (column : Fin 5120) :
    HalfMemory.load execution.output.memory (execution.output.base+2*column.val)=
      (mlp.forward (ArrayStorage.bfWords input) column).bits := by
  rw [DownFoldOutputSource.current_bits abi execution.down mlp.downPlatform.reduce execution.output column.val column.isLt]
  have actual : DownOutput.foldValues execution.down mlp.downPlatform.reduce column.val=
      mlp.forward (ArrayStorage.bfWords input) column :=
    (execution.output.read_correct column.val column.isLt).symm.trans (output_eq execution column)
  exact congrArg (fun value : BF => value.bits) actual

theorem current_output_bytes (execution : Execution mlp input) (abi : DownFoldVectorMemory.VectorLoad)
    (column : Fin 5120) (offset : Nat) (bound : offset<2) :
    execution.output.memory (execution.output.base+2*column.val+offset)=
      HalfMemory.byte (mlp.forward (ArrayStorage.bfWords input) column).bits offset := by
  have bits:=congrArg (fun bits => HalfMemory.byte bits offset) (current_output_bits execution abi column)
  rw [HalfMemory.byte_load _ _ _ bound] at bits
  exact bits

/-- The model output buffer is the actual completed destination heap. -/
def outputBuffer (execution : Execution mlp input) (abi : DownFoldVectorMemory.VectorLoad) :
    ArrayStorage.BFBuffer (mlp.forward (ArrayStorage.bfWords input)) where
  bytes := execution.output.memory
  base := execution.output.base
  aligned := execution.output.aligned
  bounded := execution.output.bounded
  attached := current_output_bits execution abi

theorem output_buffer_error (execution : Execution mlp input) (abi : DownFoldVectorMemory.VectorLoad)
    (target error : Fin 5120 → ℝ)
    (hi : ∀ i, |real (GateUpExecution.widen (ArrayStorage.bfWords input i.val))-target i| ≤ error i)
    (finite : TrellisMlp.Finite mlp (ArrayStorage.bfWords input)) (column : Fin 5120) :
    |Model.toReal ((outputBuffer execution abi).read column)-mlp.target target column| ≤
      TrellisMlp.budget mlp (ArrayStorage.bfWords input) target error finite column := by
  rw [ArrayStorage.BFBuffer.read_correct]
  exact TrellisMlp.forward_error mlp (ArrayStorage.bfWords input) target error hi finite column

end Inference.Models.Qwen.TrellisMlpParsedDown
