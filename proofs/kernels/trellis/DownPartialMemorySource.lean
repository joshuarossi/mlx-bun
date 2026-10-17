import kernels.trellis.DownPartialSource
namespace Inference.Kernels.Trellis.DownPartialMemorySource
open Contracts.Mlx Contracts.Mlx.M1Max
set_option maxRecDepth 10000
variable {values : Fin 17408 → ArrayStorage.BF}

theorem source_execution (input : PackedArrayDownMaterialization.Input k) (activation : ArrayStorage.BFBuffer values)
    (load : ThreadgroupLoad) (before : Nat → ByteMemory.Bytes) (base : Nat)
    (trace : DownDevice.Trace load before base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue values)) :
    ThreadgroupWrites.Executes
      (DownPartialSource.programs input activation load before base trace.partialBase trace.threadgroup) trace.schedule trace.remaining := by
  rw [DownPartialSource.programs_eq]
  exact trace.execution

-- Both producer phases retain this trace's SAME schedules/current heaps.
-- The native read barrier and cross-dispatch dependency remain explicit.
theorem pipeline_execution (input : PackedArrayDownMaterialization.Input k) (activation : ArrayStorage.BFBuffer values)
    (load : ThreadgroupLoad) (before : Nat → ByteMemory.Bytes) (base : Nat)
    (trace : DownDevice.Trace load before base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue values)) :
    (∀ ty, ty<160 → ThreadgroupWrites.Executes
      (DownScratchSource.programs input activation ty load
        (FloatMemory.view (FloatMemory.execute (trace.threadgroup ty).tableSchedule (before ty))) base)
      (trace.threadgroup ty).scratchSchedule (trace.threadgroup ty).scratchRemaining) ∧
    ThreadgroupWrites.Executes
      (DownPartialSource.programs input activation load before base trace.partialBase trace.threadgroup) trace.schedule trace.remaining := by
  refine ⟨?_,source_execution input activation load before base trace⟩
  intro ty bound
  exact DownScratchMemory.source_execution input activation load (before ty) base ty bound (trace.threadgroup ty)

theorem stored_bits (before : ByteMemory.Bytes) (base : Nat) (aligned : base%4=0)
    (payload : Nat → Nat → Float32) (schedule : List Memory.Store)
    (order : schedule.Perm (DownPartialMemory.programs base payload).flatten)
    (y column : Nat) (yBound : y<32) (columnBound : column<5120) :
    ByteMemory.load32 (FloatMemory.execute schedule before) (base+4*(y*5120+column))=
      FloatMemory.bits (payload (32*(column/1024)+y) (column%1024)) := by
  rw [FloatMemory.execute,ByteMemory.execute_bytes_load32 _ _ _ (by omega),
    show (base+4*(y*5120+column))/4=base/4+y*5120+column by omega]
  apply MemoryCells.written_value
  · intro encoded member equal
    obtain ⟨original,inSchedule,encodedEq⟩:=List.mem_map.mp member
    subst encoded
    have originalMember:=order.mem_iff.mp inSchedule
    have value:=DownPartialMemory.correct_value base payload y column yBound columnBound original originalMember equal
    exact congrArg FloatMemory.bits value
  · obtain ⟨original,member,equal⟩:=DownPartialMemory.covers base payload y column yBound columnBound
    refine ⟨FloatMemory.encodeStore original,List.mem_map.mpr ⟨original,order.mem_iff.mpr member,rfl⟩,equal⟩

theorem current_bits (input : PackedArrayDownMaterialization.Input k)
    (load : ThreadgroupLoad) (before : Nat → ByteMemory.Bytes) (base : Nat)
    (trace : DownDevice.Trace load before base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue values)) (y column : Nat) (yBound : y<32) (columnBound : column<5120) :
    ByteMemory.load32 trace.memory (trace.partialBase+4*(y*5120+column))=
      FloatMemory.bits ((trace.threadgroup (32*(column/1024)+y)).value (column%1024)) := by
  have order:=ThreadgroupWrites.completed_schedule trace.execution trace.completed
  exact stored_bits trace.partialBefore trace.partialBase (by have := trace.partialAligned; omega) _ trace.schedule order y column yBound columnBound

theorem current_bytes (input : PackedArrayDownMaterialization.Input k)
    (load : ThreadgroupLoad) (before : Nat → ByteMemory.Bytes) (base : Nat)
    (trace : DownDevice.Trace load before base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue values)) (y column offset : Nat) (yBound : y<32) (columnBound : column<5120) (offsetBound : offset<4) :
    trace.memory (trace.partialBase+4*(y*5120+column)+offset)=
      ByteMemory.byte (FloatMemory.bits ((trace.threadgroup (32*(column/1024)+y)).value (column%1024))) offset := by
  have word:=current_bits input load before base trace y column yBound columnBound
  have bytes:=congrArg (fun value => ByteMemory.byte value offset) word
  rw [ByteMemory.byte_load32 _ _ _ offsetBound] at bytes
  exact bytes
end Inference.Kernels.Trellis.DownPartialMemorySource
