import kernels.attention.RopeCopyMemory
import contracts.mlx.MemoryProjection

namespace Inference.Kernels.Attention.RopeRowsMemory
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
variable {rows base : Nat} {x : Fin rows → Fin 256 → BF} {values : Fin rows → Fin 64 → BitVec 16}

-- Contiguous head rows in one heap. For the native single-token route,
-- pos.y is the head and stride is 256; grid.x is rotary_dims/2 = 32.
structure Input (x : Fin rows → Fin 256 → BF) (base : Nat) where
  memory : ByteMemory.Bytes
  aligned : base%2=0
  bounded : base+512*rows≤2^64
  attached : ∀ head i, HalfMemory.load memory (base+512*head.val+2*i.val)=ArrayStorage.bits (x head i)

def Input.buffer (source : Input x base) (head : Fin rows) : ArrayStorage.BFBuffer (x head) where
  bytes := source.memory
  base := base+512*head.val
  aligned := by have := source.aligned; omega
  bounded := by have := source.bounded; have := head.isLt; omega
  attached := source.attached head

def entry (base : Nat) (values : Fin rows → Fin 64 → BitVec 16)
    (head : Fin rows) (lane : Fin 32) (half : Fin 2) : HalfMemory.Store :=
  ⟨base/2+256*head.val+(RopeDevice.index lane half).val, values head (RopeDevice.index lane half)⟩

def programs (base : Nat) (values : Fin rows → Fin 64 → BitVec 16) : List (List HalfMemory.Store) :=
  (List.finRange rows).flatMap (fun head =>
    (List.finRange 32).map (fun lane => (List.finRange 2).map (entry base values head lane)))

theorem member (base : Nat) (values : Fin rows → Fin 64 → BitVec 16) (store : HalfMemory.Store)
    (present : store ∈ (programs base values).flatten) :
    ∃ head lane half, store=entry base values head lane half := by
  obtain ⟨thread, threadMember, storeMember⟩ := List.mem_flatten.mp present
  obtain ⟨head, _, laneMember⟩ := List.mem_flatMap.mp threadMember
  obtain ⟨lane, _, rfl⟩ := List.mem_map.mp laneMember
  obtain ⟨half, _, rfl⟩ := List.mem_map.mp storeMember
  exact ⟨head,lane,half,rfl⟩

theorem covered (base : Nat) (values : Fin rows → Fin 64 → BitVec 16) (head : Fin rows) (i : Fin 64) :
    ∃ store ∈ (programs base values).flatten, store.word=base/2+256*head.val+i.val := by
  obtain ⟨store, present, same⟩ := RopeDevice.covers (values head) i
  obtain ⟨lane, half, rfl⟩ := RopeDevice.member (values head) store present
  refine ⟨entry base values head lane half, ?_, ?_⟩
  · exact List.mem_flatten.mpr ⟨(List.finRange 2).map (entry base values head lane),
      List.mem_flatMap.mpr ⟨head, List.mem_finRange _, List.mem_map.mpr ⟨lane,List.mem_finRange _,rfl⟩⟩,
      List.mem_map.mpr ⟨half,List.mem_finRange _,rfl⟩⟩
  · dsimp [entry]
    change (RopeDevice.index lane half).val=i.val at same
    rw [same]

structure Trace (base : Nat) (values : Fin rows → Fin 64 → BitVec 16) where
  before : ByteMemory.Bytes
  aligned : base%2=0
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (programs base values) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (base : Nat) (values : Fin rows → Fin 64 → BitVec 16)
    (memory : ByteMemory.Bytes) (aligned : base%2=0) : Trace base values :=
  ⟨memory,aligned,(programs base values).flatten,List.replicate (programs base values).length [],
   ThreadgroupWrites.canonical _,ThreadgroupWrites.canonical_barrier _⟩

def Trace.memory (trace : Trace base values) : ByteMemory.Bytes := HalfMemory.execute trace.schedule trace.before

theorem Trace.inside (trace : Trace base values) : MemoryRegions.Inside16 base (512*rows) trace.schedule := by
  intro store present
  obtain ⟨head,lane,half,rfl⟩ := member base values store
    ((ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp present)
  have headBound := head.isLt
  have indexBound := (RopeDevice.index lane half).isLt
  have aligned := trace.aligned
  dsimp [entry]
  omega

theorem Trace.read (trace : Trace base values) (head : Fin rows) (i : Fin 64) :
    HalfMemory.load trace.memory (base+512*head.val+2*i.val)=values head i := by
  unfold Trace.memory
  have aligned := trace.aligned
  rw [HalfMemory.execute_load _ _ _ (by omega),
    show (base+512*head.val+2*i.val)/2=base/2+256*head.val+i.val by omega]
  apply MemoryCells.completed_value trace.execution trace.completed
  · intro store present same
    obtain ⟨other,lane,half,rfl⟩ := member base values store present
    have idx := (RopeDevice.index lane half).isLt
    have ib := i.isLt
    have sameHead : other=head := by apply Fin.ext; dsimp [entry] at same; omega
    subst other
    have sameIndex : RopeDevice.index lane half=i := by apply Fin.ext; dsimp [entry] at same; omega
    simp only [entry,sameIndex]
  · exact covered base values head i

theorem Trace.frame (trace : Trace base values) (address : Nat)
    (outside : address<base ∨ base+512*rows≤address) : trace.memory address=trace.before address :=
  MemoryRegions.execute16_frame _ _ trace.inside outside

theorem Trace.tail_byte (trace : Trace base values) (head : Fin rows) (offset : Nat)
    (lower : 128≤offset) (upper : offset<512) :
    trace.memory (base+512*head.val+offset)=trace.before (base+512*head.val+offset) := by
  unfold Trace.memory
  rw [← MemoryProjection.halves]
  apply MemoryProjection.frame
  intro store present memory
  obtain ⟨other,lane,half,rfl⟩ := member base values store
    ((ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp present)
  have idx := (RopeDevice.index lane half).isLt
  have aligned := trace.aligned
  have miss : ¬(2*(entry base values other lane half).word≤base+512*head.val+offset ∧
      base+512*head.val+offset<2*(entry base values other lane half).word+2) := by
    dsimp [entry]
    omega
  simp only [MemoryProjection.halfWrite,HalfMemory.store,miss,ite_false]

theorem Trace.tail (trace : Trace base values) (head : Fin rows) (i : Fin 256) (lower : 64 ≤ i.val) :
    HalfMemory.load trace.memory (base+512*head.val+2*i.val)=HalfMemory.load trace.before (base+512*head.val+2*i.val) := by
  have bound := i.isLt
  simp only [HalfMemory.load]
  rw [Nat.add_assoc (base+512*head.val) (2*i.val) 1, Nat.add_assoc (base+512*head.val) (2*i.val) 0]
  rw [trace.tail_byte head _ (by omega) (by omega), trace.tail_byte head _ (by omega) (by omega)]

def rotated (p : Rope.Platform) (x : Fin rows → Fin 256 → BF) (theta : Fin rows → Fin 32 → Float32)
    (head : Fin rows) (i : Fin 64) : BitVec 16 :=
  ArrayStorage.bits (Rope.head p (x head) (theta head) ⟨i.val,by have := i.isLt; omega⟩)

structure Rotation (p : Rope.Platform) (source : Input x base) (theta : Fin rows → Fin 32 → Float32) where
  trace : Trace base (rotated p x theta)
  before : trace.before=source.memory

variable {p : Rope.Platform} {source : Input x base} {theta : Fin rows → Fin 32 → Float32}

theorem Rotation.read (rotation : Rotation p source theta) (head : Fin rows) (i : Fin 256) :
    HalfMemory.load rotation.trace.memory (base+512*head.val+2*i.val)=
      ArrayStorage.bits (Rope.head p (x head) (theta head) i) := by
  by_cases inside : i.val<64
  · exact rotation.trace.read head ⟨i.val,inside⟩
  · rw [rotation.trace.tail head i (by omega), rotation.before, source.attached,
      Rope.unchanged p (x head) (theta head) i (by omega)]

def Rotation.output (rotation : Rotation p source theta) : Input (fun head => Rope.head p (x head) (theta head)) base where
  memory := rotation.trace.memory
  aligned := source.aligned
  bounded := source.bounded
  attached := rotation.read

def Rotation.canonical (p : Rope.Platform) (source : Input x base) (theta : Fin rows → Fin 32 → Float32) : Rotation p source theta :=
  ⟨Trace.canonical base (rotated p x theta) source.memory source.aligned,rfl⟩

end Inference.Kernels.Attention.RopeRowsMemory
