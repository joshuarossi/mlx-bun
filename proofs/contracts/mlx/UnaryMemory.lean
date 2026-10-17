import contracts.mlx.BinaryMemory

namespace Inference.Contracts.Mlx.UnaryMemory
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := ArrayStorage.BF

variable {n : Nat} {values : Fin n → BF}

def kernel (source : ArrayStorage.BFBuffer values) (operation : BF → BF) (base : Nat) : ElementwiseMemory.Kernel n 1 :=
  ElementwiseMemory.contiguous (fun _ => source.base/2) base (fun words => ArrayStorage.bits (operation (Model.ofBits (words 0))))

theorem independent (source : ArrayStorage.BFBuffer values) (operation : BF → BF) (base : Nat)
    (safe : source.base/2=base ∨ MemoryRegions.Disjoint source.base (2*n) (2*base) (2*n)) :
    ElementwiseMemory.Independent (kernel source operation base) := by
  apply ElementwiseMemory.contiguous_independent
  intro _
  simpa only [show 2*(source.base/2)=source.base by have := source.aligned; omega] using safe

structure Execution (source : ArrayStorage.BFBuffer values) (operation : BF → BF) where
  base : Nat
  bounded : 2*base+2*n ≤ 2^64
  trace : ElementwiseMemory.Trace (kernel source operation base)
  shared : trace.before=source.bytes
  independent : ElementwiseMemory.Independent (kernel source operation base)

variable {source : ArrayStorage.BFBuffer values} {operation : BF → BF}

def canonical (source : ArrayStorage.BFBuffer values) (operation : BF → BF) (base : Nat)
    (bounded : 2*base+2*n ≤ 2^64)
    (safe : source.base/2=base ∨ MemoryRegions.Disjoint source.base (2*n) (2*base) (2*n)) : Execution source operation :=
  ⟨base, bounded, ElementwiseMemory.Trace.canonical _ source.bytes, rfl, independent source operation base safe⟩

theorem Execution.value (execution : Execution source operation) (i : Fin n) :
    ElementwiseMemory.result (kernel source operation execution.base) execution.trace.before i=ArrayStorage.bits (operation (values i)) := by
  change ArrayStorage.bits (operation (Model.ofBits (HalfMemory.load execution.trace.before (2*(source.base/2+i.val)))))=_
  rw [execution.shared, BinaryMemory.buffer_read]
  rfl

def Execution.buffer (execution : Execution source operation) : ArrayStorage.BFBuffer (fun i => operation (values i)) where
  bytes := execution.trace.memory
  base := 2*execution.base
  aligned := by omega
  bounded := execution.bounded
  attached := by
    intro i
    have read := execution.trace.read_correct execution.independent (ElementwiseMemory.contiguous_distinct _ _ _) i
    change HalfMemory.load execution.trace.memory (2*(execution.base+i.val))=_ at read
    rw [Nat.mul_add, execution.value] at read
    exact read

theorem Execution.other_region (execution : Execution source operation) {base size : Nat}
    (separate : MemoryRegions.Disjoint (2*execution.base) (2*n) base size) (offset : Nat) (bound : offset<size) :
    execution.buffer.bytes (base+offset)=source.bytes (base+offset) :=
  (execution.trace.other_region execution.independent
    (by intro i; dsimp only [kernel, ElementwiseMemory.contiguous]; have := i.isLt; omega)
    separate offset bound).trans (congrFun execution.shared _)

end Inference.Contracts.Mlx.UnaryMemory
