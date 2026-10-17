import state.KvPreparedMemory
import contracts.mlx.CopyContiguous

namespace Inference.State.KvSlicePreparationMemory
open Contracts.Mlx
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs

-- BF16[1,4,256,256], the first updateAndFetch slabs.
def words : Nat := 4*65536
def bytes : Nat := 524288

theorem stores_inside (trace : CopyContiguous.Trace (blocks:=65536) base values) :
    MemoryRegions.Inside16 base bytes trace.schedule := by
  intro write member
  have original := (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp member
  obtain ⟨thread,offset,rfl⟩ := CopyContiguous.member _ _ write original
  have bound := (CopyContiguous.index thread offset).isLt
  have aligned := trace.aligned
  dsimp only [CopyContiguous.entry]
  unfold bytes
  omega

theorem trace_frame (trace : CopyContiguous.Trace (blocks:=65536) base values)
    (separate : MemoryRegions.Disjoint base bytes other size) (offset : Nat) (bound : offset<size) :
    trace.memory (other+offset)=trace.before (other+offset) :=
  MemoryRegions.execute16_other trace.schedule trace.before (stores_inside trace) separate offset bound

structure Copy (before : ByteMemory.Bytes) (source : Nat) where
  destination : Nat
  aligned : destination%2=0
  bounded : destination+bytes≤2^64
  separate : MemoryRegions.Disjoint destination bytes source bytes
  trace : CopyContiguous.Trace (blocks:=65536) destination (CopyContiguous.vectorValues before source)
  initial : trace.before=before

variable {before : ByteMemory.Bytes} {source : Nat}

def Copy.canonical (before : ByteMemory.Bytes) (source destination : Nat) (aligned : destination%2=0)
    (bounded : destination+bytes≤2^64) (separate : MemoryRegions.Disjoint destination bytes source bytes) : Copy before source :=
  ⟨destination,aligned,bounded,separate,CopyContiguous.Trace.canonical destination _ before aligned,rfl⟩

def Copy.memory (copy : Copy before source) : ByteMemory.Bytes := copy.trace.memory

theorem Copy.read (copy : Copy before source) (i : Fin words) :
    HalfMemory.load copy.memory (copy.destination+2*i.val)=HalfMemory.load before (source+2*i.val) :=
  copy.trace.read_correct i

theorem Copy.frame (copy : Copy before source) (separate : MemoryRegions.Disjoint copy.destination bytes other size)
    (offset : Nat) (bound : offset<size) : copy.memory (other+offset)=before (other+offset) :=
  (trace_frame copy.trace separate offset bound).trans (congrFun copy.initial _)

-- Donation is an explicit ownership route, never inferred from dispose().
inductive Choice (source : Nat) where
  | donated (aligned : source%2=0) (bounded : source+bytes≤2^64)
  | copied (destination : Nat) (aligned : destination%2=0) (bounded : destination+bytes≤2^64)
      (separate : MemoryRegions.Disjoint destination bytes source bytes)

def Choice.destination : Choice source → Nat
  | .donated _ _ => source
  | .copied destination _ _ _ => destination

theorem Choice.aligned (choice : Choice source) : choice.destination%2=0 := by cases choice <;> assumption
theorem Choice.bounded (choice : Choice source) : choice.destination+bytes≤2^64 := by cases choice <;> assumption

inductive Preparation (before : ByteMemory.Bytes) (source : Nat) where
  | donated : Preparation before source
  | copied : Copy before source → Preparation before source

def Preparation.destination : Preparation before source → Nat
  | .donated => source
  | .copied copy => copy.destination

def Preparation.memory : Preparation before source → ByteMemory.Bytes
  | .donated => before
  | .copied copy => copy.memory

def Choice.prepare (choice : Choice source) (before : ByteMemory.Bytes) : Preparation before source :=
  match choice with
  | .donated _ _ => .donated
  | .copied destination aligned bounded separate => .copied (Copy.canonical before source destination aligned bounded separate)

theorem Choice.destination_prepare (choice : Choice source) (before : ByteMemory.Bytes) :
    (choice.prepare before).destination=choice.destination := by cases choice <;> rfl

theorem Preparation.read (preparation : Preparation before source) (i : Fin words) :
    HalfMemory.load preparation.memory (preparation.destination+2*i.val)=HalfMemory.load before (source+2*i.val) := by
  cases preparation with
  | donated => rfl
  | copied copy => exact copy.read i

theorem Preparation.frame (preparation : Preparation before source)
    (separate : MemoryRegions.Disjoint preparation.destination bytes other size) (offset : Nat) (bound : offset<size) :
    preparation.memory (other+offset)=before (other+offset) := by
  cases preparation with
  | donated => rfl
  | copied copy => exact copy.frame separate offset bound
end Inference.State.KvSlicePreparationMemory
