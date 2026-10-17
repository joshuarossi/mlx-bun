import kernels.trellis.DownFoldOutputSource
namespace Inference.Kernels.Trellis.DownPipelineSource
open Contracts.Mlx Contracts.Mlx.M1Max
set_option maxRecDepth 10000
variable {values : Fin 17408 → ArrayStorage.BF}

/-- The parsed scratch, device, and fold producers share the supplied
    schedules and current heaps. Native dispatch/barrier/command execution,
    vector ABI, selected BF16 cast, and SIMD reduction remain boundaries. -/
theorem execution (input : PackedArrayDownMaterialization.Input k)
    (activation : ArrayStorage.BFBuffer values) (load : ThreadgroupLoad)
    (before : Nat → ByteMemory.Bytes) (base : Nat)
    (device : DownDevice.Trace load before base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue values))
    (abi : DownFoldVectorMemory.VectorLoad) (reduce : DownExecution.SimdReduction)
    (destination : DownOutput.Trace (DownOutput.foldValues device reduce)) :
    (∀ ty, ty<160 → ThreadgroupWrites.Executes
      (DownScratchSource.programs input activation ty load
        (FloatMemory.view (FloatMemory.execute (device.threadgroup ty).tableSchedule (before ty))) base)
      (device.threadgroup ty).scratchSchedule (device.threadgroup ty).scratchRemaining) ∧
    ThreadgroupWrites.Executes
      (DownPartialSource.programs input activation load before base device.partialBase device.threadgroup)
      device.schedule device.remaining ∧
    ThreadgroupWrites.Executes (DownFoldOutputSource.programs abi device reduce destination.base)
      destination.schedule destination.remaining := by
  have producer:=DownPartialMemorySource.pipeline_execution input activation load before base device
  exact ⟨producer.1,producer.2,DownFoldOutputSource.source_execution abi device reduce destination⟩

/-- Current destination bytes produced by that parsed fold; this retains
    the original/current device heap through the final vector reads. -/
theorem output_bytes (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF}
    (load : ThreadgroupLoad) (before : Nat → ByteMemory.Bytes) (base : Nat)
    (device : DownDevice.Trace load before base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue values))
    (abi : DownFoldVectorMemory.VectorLoad) (reduce : DownExecution.SimdReduction)
    (destination : DownOutput.Trace (DownOutput.foldValues device reduce))
    (index offset : Nat) (bound : index<5120) (offsetBound : offset<2) :
    destination.memory (destination.base+2*index+offset)=
      HalfMemory.byte (BFloat16.narrow
        (reduce (fun lane => device.read lane.val index))).bits offset := by
  exact DownFoldOutputSource.current_bytes abi device reduce destination index offset bound offsetBound

end Inference.Kernels.Trellis.DownPipelineSource
