import state.KvConcatMemory
import state.KvAppendMemory

namespace Inference.State.KvGrowthAppendMemory
open Contracts.Mlx KvBytes
set_option maxRecDepth 10000
attribute [local irreducible] KvConcatMemory.programs CopyContiguous.programs Copy2DMemory.programs

-- At a full capacity boundary, initialize the extension, concatenate it
-- with the old cache, then append the new row into the same shared heap.
structure Execution (old : History capacity) (next : Row) where
  layout : KvConcatMemory.Layout capacity
  growth : KvConcatMemory.Initialized layout
  source : KvCopy.Source next
  shared : source.bytes=growth.zeros.before
  zeroSeparate : MemoryRegions.Disjoint (2*layout.zeroBase) 524288 source.base (KvAppendMemory.sourceBytes source)
  copySeparate : MemoryRegions.Disjoint (2*layout.destination) (2*(4*(capacity+256)*256)) source.base (KvAppendMemory.sourceBytes source)
  attached : ∀ head time i,
    HalfMemory.load growth.zeros.before (2*(layout.oldBase+Kv.address capacity head time.val i))=bits (old head time i)

variable {capacity : Nat} {old : History capacity} {next : Row}

theorem Execution.source_preserved (execution : Execution old next) (offset : Nat) (bound : offset<KvAppendMemory.sourceBytes execution.source) :
    execution.growth.concatenation.memory (execution.source.base+offset)=execution.source.bytes (execution.source.base+offset) := by
  have copied := KvConcatMemory.other_region execution.layout execution.growth.concatenation execution.copySeparate offset bound
  rw [execution.growth.initial] at copied
  have filled := MemoryRegions.execute16_other execution.growth.zeros.schedule execution.growth.zeros.before
    (KvConcatMemory.zero_stores_inside _ execution.growth.zeros) execution.zeroSeparate offset bound
  exact copied.trans (filled.trans (congrFun execution.shared (execution.source.base+offset)).symm)

def Execution.appendSource (execution : Execution old next) : KvCopy.Source next :=
  KvAppendMemory.reframe execution.source execution.growth.concatenation.memory execution.source_preserved

def Execution.appended (execution : Execution old next) : KvAppendMemory.Execution old next :=
  KvAppendMemory.Execution.canonical old next execution.appendSource
    (2*execution.layout.destination) (capacity+256) (by omega) (by omega) execution.copySeparate (by
      intro head time i
      have copied := execution.growth.preserves head time i
      have original := execution.attached head time i
      simpa only [Nat.mul_add, Execution.appendSource, KvAppendMemory.reframe] using copied.trans original)

def Execution.memory (execution : Execution old next) : ByteMemory.Bytes := execution.appended.copy.memory

theorem Execution.load_correct (execution : Execution old next) (head : Fin 4) (time : Fin (capacity+1)) (i : Fin 256) :
    HalfMemory.load execution.memory (2*(execution.layout.destination+Kv.address (capacity+256) head time.val i))=
      bits (Kv.appendRows (fun t => old head t i) (next head i) time) := by
  simpa only [Execution.memory, Execution.appended, KvAppendMemory.Execution.canonical, Nat.mul_add] using
    execution.appended.load_correct head time i

theorem Execution.append_reads_grown_heap (execution : Execution old next) :
    execution.appended.copy.before=execution.growth.concatenation.memory := rfl

theorem Execution.retains_source_layout (execution : Execution old next) :
    execution.appendSource.base=execution.source.base ∧
      execution.appendSource.rowStride=execution.source.rowStride ∧
      execution.appendSource.columnStride=execution.source.columnStride := ⟨rfl, rfl, rfl⟩

end Inference.State.KvGrowthAppendMemory
