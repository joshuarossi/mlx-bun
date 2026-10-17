import kernels.trellis.GateUpOutput
import kernels.trellis.DownOutput
import contracts.mlx.ArrayFrame

namespace Inference.Kernels.Trellis.OutputRegions
open Contracts.Mlx
set_option maxRecDepth 10000
attribute [local irreducible] GateUpOutput.programs DownOutput.programs DownPartialMemory.programs

theorem gate_inside {base : Nat} {values : Nat → GateUpOutput.BF} (aligned : base%2=0)
    (stores : List HalfMemory.Store) (subset : ∀ store ∈ stores, store ∈ (GateUpOutput.programs base values).flatten) :
    MemoryRegions.Inside16 base 34816 stores := by
  intro store member
  obtain ⟨program, present, write⟩ := List.mem_flatten.mp (subset store member)
  unfold GateUpOutput.programs at present
  obtain ⟨pair, _, rfl⟩ := List.mem_map.mp present
  obtain ⟨_, iteration, _, bound, rfl⟩ := GateUpOutput.thread_member base values pair.1 pair.2 store write
  dsimp only [GateUpOutput.entry]
  omega

theorem gate_trace_inside {values : Nat → GateUpOutput.BF} (trace : GateUpOutput.Trace values) :
    MemoryRegions.Inside16 trace.base 34816 trace.schedule :=
  gate_inside trace.aligned trace.schedule (fun _ member =>
    (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp member)

theorem partial_inside {base : Nat} {values : Nat → Nat → Float32} (aligned : base%4=0)
    (stores : List Memory.Store) (subset : ∀ store ∈ stores, store ∈ (DownPartialMemory.programs base values).flatten) :
    MemoryRegions.Inside32 base 655360 (stores.map FloatMemory.encodeStore) := by
  intro store member
  obtain ⟨original, present, rfl⟩ := List.mem_map.mp member
  obtain ⟨group, thread, iteration, hg, ht, hi, rfl⟩ := DownPartialMemory.member base values original (subset original present)
  have bounds := DownPartialMemory.bounds base values group thread iteration hg ht hi
  dsimp only [FloatMemory.encodeStore]
  omega

theorem down_trace_inside (trace : DownDevice.Trace load before base words k scale input) :
    MemoryRegions.Inside32 trace.partialBase 655360 (trace.schedule.map FloatMemory.encodeStore) :=
  partial_inside (by have := trace.partialAligned; omega) trace.schedule (fun _ member =>
    (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp member)

theorem fold_inside {base : Nat} {values : Nat → DownOutput.BF} (aligned : base%2=0)
    (stores : List HalfMemory.Store) (subset : ∀ store ∈ stores, store ∈ (DownOutput.programs base values).flatten) :
    MemoryRegions.Inside16 base 10240 stores := by
  intro store member
  obtain ⟨program, present, write⟩ := List.mem_flatten.mp (subset store member)
  unfold DownOutput.programs at present
  obtain ⟨pair, inRange, rfl⟩ := List.mem_map.mp present
  obtain ⟨groupRange, threadRange⟩ := List.mem_product.mp inRange
  have groupBound := List.mem_range.mp groupRange
  have threadBound := List.mem_range.mp threadRange
  obtain ⟨_, component, componentBound, rfl⟩ := DownOutput.thread_member base values pair.1 pair.2 store write
  dsimp only [DownOutput.entry, DownOutput.column]
  omega

theorem fold_trace_inside {values : Nat → DownOutput.BF} (trace : DownOutput.Trace values) :
    MemoryRegions.Inside16 trace.base 10240 trace.schedule :=
  fold_inside trace.aligned trace.schedule (fun _ member =>
    (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp member)

theorem gate_frame {values : Nat → GateUpOutput.BF} (trace : GateUpOutput.Trace values) {base size : Nat}
    (separate : MemoryRegions.Disjoint trace.base 34816 base size) (offset : Nat) (bound : offset<size) :
    trace.memory (base+offset)=trace.before (base+offset) :=
  MemoryRegions.execute16_other trace.schedule trace.before (gate_trace_inside trace) separate offset bound

theorem down_frame (trace : DownDevice.Trace load before scratchBase words k scale input) {base size : Nat}
    (separate : MemoryRegions.Disjoint trace.partialBase 655360 base size) (offset : Nat) (bound : offset<size) :
    trace.memory (base+offset)=trace.partialBefore (base+offset) :=
  MemoryRegions.execute32_other _ trace.partialBefore (down_trace_inside trace) separate offset bound

theorem fold_frame {values : Nat → DownOutput.BF} (trace : DownOutput.Trace values) {base size : Nat}
    (separate : MemoryRegions.Disjoint trace.base 10240 base size) (offset : Nat) (bound : offset<size) :
    trace.memory (base+offset)=trace.before (base+offset) :=
  MemoryRegions.execute16_other trace.schedule trace.before (fold_trace_inside trace) separate offset bound

end Inference.Kernels.Trellis.OutputRegions
