import kernels.trellis.DownScratchSource
namespace Inference.Kernels.Trellis.DownScratchMemory
open Contracts.Mlx Contracts.Mlx.M1Max DownScratchSource
set_option maxRecDepth 10000
variable {values : Fin 17408 → ArrayStorage.BF}

-- A supplied native execution contract issues the PARSED producer programs.
-- This retains its actual read schedule, completed barriers and scratch stores.
theorem source_execution (input : PackedArrayDownMaterialization.Input k) (activation : ArrayStorage.BFBuffer values)
    (load : ThreadgroupLoad) (before : ByteMemory.Bytes) (base ty : Nat) (tyBound : ty<160)
    (trace : DownReadBarrier.Trace load before base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue values) ty) :
    ThreadgroupWrites.Executes
      (programs input activation ty load (FloatMemory.view (FloatMemory.execute trace.tableSchedule before)) base)
      trace.scratchSchedule trace.scratchRemaining := by
  rw [programs_eq input activation ty tyBound load]
  have actual:=trace.scratchExecution
  rw [trace.completed_reads] at actual
  simpa only [DownReadBarrier.computations,DownScratchSource.values] using actual

-- Raw bit stores, rather than decode/encode cancellation, prove byte identity.
-- This remains valid for the represented payload bits of all produced values.
theorem stored_bits (before : ByteMemory.Bytes) (base : Nat) (aligned : base%4=0)
    (payload : Nat → Nat → Nat → Float32) (schedule : List Memory.Store)
    (order : schedule.Perm (DownMemory.stores base payload)) (j : Nat) (bound : j<4096) :
    ByteMemory.load32 (FloatMemory.execute schedule before) (base+4*j)=
      FloatMemory.bits (DownExecution.scratchMemory payload j) := by
  rw [FloatMemory.execute,ByteMemory.execute_bytes_load32 _ _ _ (by omega),
    show (base+4*j)/4=base/4+j by omega]
  apply MemoryCells.written_value
  · intro encoded member equal
    obtain ⟨original,inSchedule,encodedEq⟩:=List.mem_map.mp member
    subst encoded
    have originalMember:=order.mem_iff.mp inSchedule
    have value:=DownMemory.correct_value base payload j original originalMember equal
    exact congrArg FloatMemory.bits value
  · obtain ⟨original,member,equal⟩:=DownMemory.covers base payload j bound
    refine ⟨FloatMemory.encodeStore original,List.mem_map.mpr ⟨original,order.mem_iff.mpr member,rfl⟩,equal⟩

theorem current_bits (input : PackedArrayDownMaterialization.Input k)
    (load : ThreadgroupLoad) (before : ByteMemory.Bytes) (base ty : Nat) (aligned : base%4=0)
    (trace : DownReadBarrier.Trace load before base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue values) ty) (j : Nat) (bound : j<4096) :
    ByteMemory.load32 (FloatMemory.execute trace.scratchSchedule (FloatMemory.execute trace.tableSchedule before)) (base+4*j)=
      FloatMemory.bits (DownExecution.scratchMemory
        (DownScratchSource.values input values ty load (FloatMemory.view (FloatMemory.execute trace.tableSchedule before)) base) j) := by
  have order:=ThreadgroupWrites.completed_schedule trace.toBytes.scratchExecution trace.scratchBarrier
  rw [DownBarrier.flatten_programs] at order
  exact stored_bits (FloatMemory.execute trace.tableSchedule before) base aligned _ trace.scratchSchedule order j bound

theorem current_bytes (input : PackedArrayDownMaterialization.Input k)
    (load : ThreadgroupLoad) (before : ByteMemory.Bytes) (base ty : Nat) (aligned : base%4=0)
    (trace : DownReadBarrier.Trace load before base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue values) ty) (j offset : Nat) (bound : j<4096) (offsetBound : offset<4) :
    (FloatMemory.execute trace.scratchSchedule (FloatMemory.execute trace.tableSchedule before)) (base+4*j+offset)=
      ByteMemory.byte (FloatMemory.bits (DownExecution.scratchMemory
        (DownScratchSource.values input values ty load (FloatMemory.view (FloatMemory.execute trace.tableSchedule before)) base) j)) offset := by
  have bits:=current_bits input load before base ty aligned trace j bound
  have bytes:=congrArg (fun word => ByteMemory.byte word offset) bits
  rw [ByteMemory.byte_load32 _ _ _ offsetBound] at bytes
  exact bytes

theorem current_read (input : PackedArrayDownMaterialization.Input k)
    (load : ThreadgroupLoad) (before : ByteMemory.Bytes) (base ty : Nat) (aligned : base%4=0)
    (trace : DownReadBarrier.Trace load before base input.matrix k (Models.Qwen.CheckpointTrellis.scale input.scales)
      (DownLaneSource.activationValue values) ty) (j : Nat) (bound : j<4096) :
    FloatMemory.load (FloatMemory.execute trace.scratchSchedule (FloatMemory.execute trace.tableSchedule before)) (base+4*j)=
      DownExecution.scratchMemory
        (DownScratchSource.values input values ty load (FloatMemory.view (FloatMemory.execute trace.tableSchedule before)) base) j := by
  unfold FloatMemory.load
  rw [current_bits input load before base ty aligned trace j bound,FloatMemory.decode_bits]
end Inference.Kernels.Trellis.DownScratchMemory
