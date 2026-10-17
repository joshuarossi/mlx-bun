import models.qwen.TrellisMlpParsedGateStore
namespace Inference.Models.Qwen.TrellisMlpParsedPipeline
open Contracts.Mlx Contracts.Mlx.M1Max Contracts.Mlx.Numerics Kernels.Trellis Layers WrittenLayers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open PackedArrayMaterialization
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF

-- These are original checkpoint attachments and actual native staging
-- traces, not a middle/output correctness assumption. Primitive FTZ/FMA,
-- BF16 casts, exponentials, SIMD, descriptors and native command execution
-- remain the explicit platform boundaries of the imported source semantics.
structure GateExecution (execution : TrellisMlpParsedDown.Execution mlp input) where
  tableBase : Nat
  inputBase : Nat → Nat
  packed : GateInput mlp.gate.width mlp.up.width
  parameters : TrellisMlpParsedGateProjection.Parameters mlp packed
  actual : ∀ group, GateInputSource.Execution execution.preceding.source tableBase (inputBase group)
  precise : Float32 → Float32
  absolute : BF → BF
  exponential : TrellisMlpParsedGateTail.Exponential mlp.activation precise absolute

variable {mlp : GateDown} {input : Fin 5120 → BF}

def Ready (execution : TrellisMlpParsedDown.Execution mlp input) (gate : GateExecution execution)
    (abi : DownFoldVectorMemory.VectorLoad) : Prop :=
  (∀ group, ThreadgroupWrites.Executes
    (GateInputSource.programs execution.preceding.source gate.tableBase (gate.inputBase group))
    (gate.actual group).schedule (gate.actual group).remaining) ∧
  ThreadgroupWrites.Executes
    (TrellisMlpParsedGateStore.programs gate.packed gate.actual gate.precise gate.absolute execution.preceding.kernel.middle.base)
    execution.preceding.kernel.middle.schedule execution.preceding.kernel.middle.remaining ∧
  (∀ ty, ty<160 → ThreadgroupWrites.Executes
    (DownScratchSource.programs execution.packed (TrellisMlpParsedDown.middleBuffer execution.preceding) ty mlp.downPlatform.load
      (FloatMemory.view (FloatMemory.execute (execution.down.threadgroup ty).tableSchedule
        (FloatMemory.encode (mlp.downPlatform.before ty)))) mlp.downPlatform.base)
    (execution.down.threadgroup ty).scratchSchedule (execution.down.threadgroup ty).scratchRemaining) ∧
  ThreadgroupWrites.Executes
    (DownPartialSource.programs execution.packed (TrellisMlpParsedDown.middleBuffer execution.preceding) mlp.downPlatform.load
      (fun ty => FloatMemory.encode (mlp.downPlatform.before ty)) mlp.downPlatform.base
      execution.down.partialBase execution.down.threadgroup) execution.down.schedule execution.down.remaining ∧
  ThreadgroupWrites.Executes (DownFoldOutputSource.programs abi execution.down mlp.downPlatform.reduce execution.output.base)
    execution.output.schedule execution.output.remaining

theorem ready (execution : TrellisMlpParsedDown.Execution mlp input) (gate : GateExecution execution)
    (abi : DownFoldVectorMemory.VectorLoad) : Ready execution gate abi := by
  have down:=TrellisMlpParsedDown.parsed_execution execution abi
  exact ⟨fun group => (gate.actual group).execution,
    TrellisMlpParsedGateStore.source_execution execution.preceding gate.packed gate.parameters gate.actual
      gate.precise gate.absolute gate.exponential,down.1,down.2.1,down.2.2⟩

-- This result couples every parsed producer schedule to the actual output
-- buffer's numerical budget. No replacement intermediate/output heap is used.
theorem ready_error (execution : TrellisMlpParsedDown.Execution mlp input) (gate : GateExecution execution)
    (abi : DownFoldVectorMemory.VectorLoad) (target error : Fin 5120 → ℝ)
    (hi : ∀ i, |real (GateUpExecution.widen (ArrayStorage.bfWords input i.val))-target i| ≤ error i)
    (finite : TrellisMlp.Finite mlp (ArrayStorage.bfWords input)) (column : Fin 5120) :
    Ready execution gate abi ∧
      |Model.toReal ((TrellisMlpParsedDown.outputBuffer execution abi).read column)-mlp.target target column| ≤
        TrellisMlp.budget mlp (ArrayStorage.bfWords input) target error finite column :=
  ⟨ready execution gate abi,TrellisMlpParsedDown.output_buffer_error execution abi target error hi finite column⟩

theorem ready_output_bytes (execution : TrellisMlpParsedDown.Execution mlp input) (gate : GateExecution execution)
    (abi : DownFoldVectorMemory.VectorLoad) (column : Fin 5120) (offset : Nat) (bound : offset<2) :
    Ready execution gate abi ∧
      execution.output.memory (execution.output.base+2*column.val+offset)=
        HalfMemory.byte (mlp.forward (ArrayStorage.bfWords input) column).bits offset :=
  ⟨ready execution gate abi,TrellisMlpParsedDown.current_output_bytes execution abi column offset bound⟩

end Inference.Models.Qwen.TrellisMlpParsedPipeline
