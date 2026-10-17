import contracts.mlx.ElementwiseMemory
import contracts.mlx.ArrayViews

namespace Inference.Contracts.Mlx.BinaryMemory
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF

structure Input (left right : Fin n → BF) where
  lhs : ArrayStorage.BFBuffer left
  rhs : ArrayStorage.BFBuffer right
  shared : rhs.bytes=lhs.bytes

variable {n : Nat} {left right : Fin n → BF}

def bases (input : Input left right) (operand : Fin 2) : Nat := if operand.val=0 then input.lhs.base/2 else input.rhs.base/2

def kernel (input : Input left right) (operation : BF → BF → BF) (base : Nat) : ElementwiseMemory.Kernel n 2 :=
  ElementwiseMemory.contiguous (bases input) base
    (fun values => ArrayStorage.bits (operation (Model.ofBits (values 0)) (Model.ofBits (values 1))))

theorem buffer_read {values : Fin n → BF} (source : ArrayStorage.BFBuffer values) (i : Fin n) :
    HalfMemory.load source.bytes (2*(source.base/2+i.val))=ArrayStorage.bits (values i) := by
  rw [show 2*(source.base/2+i.val)=source.base+2*i.val by have := source.aligned; omega]
  exact source.attached i

theorem independent (input : Input left right) (operation : BF → BF → BF) (base : Nat)
    (leftSafe : input.lhs.base/2=base ∨ MemoryRegions.Disjoint input.lhs.base (2*n) (2*base) (2*n))
    (rightSafe : input.rhs.base/2=base ∨ MemoryRegions.Disjoint input.rhs.base (2*n) (2*base) (2*n)) :
    ElementwiseMemory.Independent (kernel input operation base) := by
  apply ElementwiseMemory.contiguous_independent
  intro operand
  unfold bases
  split
  · simpa only [show 2*(input.lhs.base/2)=input.lhs.base by have := input.lhs.aligned; omega] using leftSafe
  · simpa only [show 2*(input.rhs.base/2)=input.rhs.base by have := input.rhs.aligned; omega] using rightSafe

structure Execution (input : Input left right) (operation : BF → BF → BF) where
  base : Nat
  bounded : 2*base+2*n ≤ 2^64
  trace : ElementwiseMemory.Trace (kernel input operation base)
  initial : trace.before=input.lhs.bytes
  independent : ElementwiseMemory.Independent (kernel input operation base)

variable {input : Input left right} {operation : BF → BF → BF}

def fromBuffers (input : Input left right) (operation : BF → BF → BF) (base : Nat) (bounded : 2*base+2*n ≤ 2^64)
    (leftSafe : input.lhs.base/2=base ∨ MemoryRegions.Disjoint input.lhs.base (2*n) (2*base) (2*n))
    (rightSafe : input.rhs.base/2=base ∨ MemoryRegions.Disjoint input.rhs.base (2*n) (2*base) (2*n)) : Execution input operation :=
  ⟨base, bounded, ElementwiseMemory.Trace.canonical _ input.lhs.bytes, rfl, independent input operation base leftSafe rightSafe⟩

theorem Execution.value (execution : Execution input operation) (i : Fin n) :
    ElementwiseMemory.result (kernel input operation execution.base) execution.trace.before i=
      ArrayStorage.bits (operation (left i) (right i)) := by
  change ArrayStorage.bits (operation
    (Model.ofBits (HalfMemory.load execution.trace.before (2*(input.lhs.base/2+i.val))))
    (Model.ofBits (HalfMemory.load execution.trace.before (2*(input.rhs.base/2+i.val)))))=_
  rw [execution.initial, buffer_read]
  have rhsRead := buffer_read input.rhs i
  rw [input.shared] at rhsRead
  rw [rhsRead]
  rfl

def Execution.buffer (execution : Execution input operation) : ArrayStorage.BFBuffer (fun i => operation (left i) (right i)) where
  bytes := execution.trace.memory
  base := 2*execution.base
  aligned := by omega
  bounded := execution.bounded
  attached := by
    intro i
    have read := execution.trace.read_correct execution.independent
      (ElementwiseMemory.contiguous_distinct _ _ _) i
    change HalfMemory.load execution.trace.memory (2*(execution.base+i.val))=_ at read
    rw [Nat.mul_add, execution.value] at read
    exact read

theorem Execution.other_region (execution : Execution input operation) {base size : Nat}
    (separate : MemoryRegions.Disjoint (2*execution.base) (2*n) base size) (offset : Nat) (bound : offset<size) :
    execution.trace.memory (base+offset)=input.lhs.bytes (base+offset) :=
  (execution.trace.other_region execution.independent
    (by intro i; dsimp only [kernel, ElementwiseMemory.contiguous]; have := i.isLt; omega)
    separate offset bound).trans (congrFun execution.initial (base+offset))

end Inference.Contracts.Mlx.BinaryMemory
