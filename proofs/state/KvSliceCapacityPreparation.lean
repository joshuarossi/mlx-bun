import state.KvPreparedMemory
import contracts.mlx.CopyContiguous
namespace Inference.State.KvSliceCapacityPreparation
open Contracts.Mlx
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs

def words (capacity : Nat) : Nat := 4*(capacity*256)
def bytes (capacity : Nat) : Nat := 2*words capacity

theorem region_bytes : bytes (KvAllocation.capacity time)=KvRegions.bytes time := by
  unfold bytes words KvRegions.bytes
  omega

theorem stores_inside (trace : CopyContiguous.Trace (blocks:=capacity*256) base values) :
    MemoryRegions.Inside16 base (bytes capacity) trace.schedule := by
  intro write member
  have original := (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp member
  obtain ⟨thread,offset,rfl⟩ := CopyContiguous.member _ _ write original
  have bound := (CopyContiguous.index thread offset).isLt
  have aligned := trace.aligned
  dsimp only [CopyContiguous.entry]
  unfold bytes words
  omega

theorem trace_frame (trace : CopyContiguous.Trace (blocks:=capacity*256) base values)
    (separate : MemoryRegions.Disjoint base (bytes capacity) other size) (offset : Nat) (bound : offset<size) :
    trace.memory (other+offset)=trace.before (other+offset) :=
  MemoryRegions.execute16_other trace.schedule trace.before (stores_inside trace) separate offset bound

structure Copy (capacity : Nat) (before : ByteMemory.Bytes) (source : Nat) where
  destination : Nat
  aligned : destination%2=0
  bounded : destination+bytes capacity≤2^64
  separate : MemoryRegions.Disjoint destination (bytes capacity) source (bytes capacity)
  trace : CopyContiguous.Trace (blocks:=capacity*256) destination (CopyContiguous.vectorValues before source)
  initial : trace.before=before

variable {capacity : Nat} {before : ByteMemory.Bytes} {source : Nat}
def Copy.canonical (capacity : Nat) (before : ByteMemory.Bytes) (source destination : Nat) (aligned : destination%2=0)
    (bounded : destination+bytes capacity≤2^64)
    (separate : MemoryRegions.Disjoint destination (bytes capacity) source (bytes capacity)) : Copy capacity before source :=
  ⟨destination,aligned,bounded,separate,CopyContiguous.Trace.canonical destination _ before aligned,rfl⟩
def Copy.memory (copy : Copy capacity before source) : ByteMemory.Bytes := copy.trace.memory

theorem Copy.read (copy : Copy capacity before source) (i : Fin (words capacity)) :
    HalfMemory.load copy.memory (copy.destination+2*i.val)=HalfMemory.load before (source+2*i.val) :=
  copy.trace.read_correct i

theorem Copy.frame (copy : Copy capacity before source)
    (separate : MemoryRegions.Disjoint copy.destination (bytes capacity) other size) (offset : Nat) (bound : offset<size) :
    copy.memory (other+offset)=before (other+offset) :=
  (trace_frame copy.trace separate offset bound).trans (congrFun copy.initial _)

-- Native ownership selects this route; no donation is inferred from disposal.
inductive Choice (capacity source : Nat) where
  | donated (aligned : source%2=0) (bounded : source+bytes capacity≤2^64)
  | copied (destination : Nat) (aligned : destination%2=0) (bounded : destination+bytes capacity≤2^64)
      (separate : MemoryRegions.Disjoint destination (bytes capacity) source (bytes capacity))
def Choice.destination : Choice capacity source → Nat
  | .donated _ _ => source
  | .copied destination _ _ _ => destination
theorem Choice.aligned (choice : Choice capacity source) : choice.destination%2=0 := by cases choice <;> assumption
theorem Choice.bounded (choice : Choice capacity source) : choice.destination+bytes capacity≤2^64 := by cases choice <;> assumption

inductive Preparation (capacity : Nat) (before : ByteMemory.Bytes) (source : Nat) where
  | donated : Preparation capacity before source
  | copied : Copy capacity before source → Preparation capacity before source

def Preparation.destination : Preparation capacity before source → Nat
  | .donated => source
  | .copied copy => copy.destination

def Preparation.memory : Preparation capacity before source → ByteMemory.Bytes
  | .donated => before
  | .copied copy => copy.memory

def Choice.prepare (choice : Choice capacity source) (before : ByteMemory.Bytes) : Preparation capacity before source :=
  match choice with
  | .donated _ _ => .donated
  | .copied destination aligned bounded separate => .copied (Copy.canonical capacity before source destination aligned bounded separate)

theorem Choice.destination_prepare (choice : Choice capacity source) (before : ByteMemory.Bytes) :
    (choice.prepare before).destination=choice.destination := by cases choice <;> rfl

theorem Preparation.read (preparation : Preparation capacity before source) (i : Fin (words capacity)) :
    HalfMemory.load preparation.memory (preparation.destination+2*i.val)=HalfMemory.load before (source+2*i.val) := by
  cases preparation with
  | donated => rfl
  | copied copy => exact copy.read i

theorem Preparation.frame (preparation : Preparation capacity before source)
    (separate : MemoryRegions.Disjoint preparation.destination (bytes capacity) other size) (offset : Nat) (bound : offset<size) :
    preparation.memory (other+offset)=before (other+offset) := by
  cases preparation with
  | donated => rfl
  | copied copy => exact copy.frame separate offset bound
end Inference.State.KvSliceCapacityPreparation
