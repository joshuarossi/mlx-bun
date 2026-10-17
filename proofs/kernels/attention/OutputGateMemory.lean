import kernels.attention.OutputGateDevice
import contracts.mlx.ElementwiseMemory

namespace Inference.Kernels.Attention.OutputGateMemory
open Contracts.Mlx OutputGateDevice
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

def wordAddress {values : Fin n → BF} (buffer : ArrayStorage.BFBuffer values) (i : Fin n) : Nat := buffer.base/2+i.val

theorem buffer_load {values : Fin n → BF} (buffer : ArrayStorage.BFBuffer values)
    (memory : ByteMemory.Bytes) (shared : buffer.bytes=memory) (i : Fin n) :
    HalfMemory.load memory (2*wordAddress buffer i)=ArrayStorage.bits (values i) := by
  rw [show 2*wordAddress buffer i=buffer.base+2*i.val by unfold wordAddress; have := buffer.aligned; omega, ← shared]
  exact buffer.attached i

theorem word_bounds {values : Fin n → BF} (buffer : ArrayStorage.BFBuffer values) (i : Fin n) :
    buffer.base ≤ 2*wordAddress buffer i ∧ 2*wordAddress buffer i+2 ≤ buffer.base+2*n := by
  have := buffer.aligned
  have := i.isLt
  unfold wordAddress
  omega

structure Input (x gate : Heads) where
  storage : OutputGateDevice.Storage x gate
  memory : ByteMemory.Bytes
  sourceShared : ∀ head, (storage.source head).bytes=memory
  gateShared : ∀ head, (storage.gate head).bytes=memory

variable {x gate : Heads}

def Input.sourceAddress (input : Input x gate) (i : Fin 6144) : Nat := wordAddress (input.storage.source (headOf i)) (coordinate i)
def Input.gateAddress (input : Input x gate) (i : Fin 6144) : Nat := wordAddress (input.storage.gate (headOf i)) (coordinate i)

theorem Input.source_load (input : Input x gate) (i : Fin 6144) :
    HalfMemory.load input.memory (2*input.sourceAddress i)=ArrayStorage.bits (x (headOf i) (coordinate i)) :=
  buffer_load _ input.memory (input.sourceShared _) _

theorem Input.gate_load (input : Input x gate) (i : Fin 6144) :
    HalfMemory.load input.memory (2*input.gateAddress i)=ArrayStorage.bits (gate (headOf i) (coordinate i)) :=
  buffer_load _ input.memory (input.gateShared _) _

def sigmoidKernel (input : Input x gate) (p : OutputGate.Platform) (base : Nat) : ElementwiseMemory.Kernel 6144 1 where
  source i _ := input.gateAddress i
  destination i := base+i.val
  evaluate values := ArrayStorage.bits (OutputGate.sigmoid p (Model.ofBits (values 0)))

theorem sigmoid_separate (input : Input x gate) (p : OutputGate.Platform) (base : Nat)
    (separate : ∀ head, MemoryRegions.Disjoint (2*base) 12288 (input.storage.gate head).base 512) :
    ElementwiseMemory.Independent (sigmoidKernel input p base) := by
  intro reader writer _ operand same
  have bounds := word_bounds (input.storage.gate (headOf reader)) (coordinate reader)
  have hw := writer.isLt
  change wordAddress (input.storage.gate (headOf reader)) (coordinate reader)=base+writer.val at same
  rcases separate (headOf reader) with left|right <;> omega

theorem head_address {heads : Heads} (buffers : ∀ head, ArrayStorage.BFBuffer (heads head)) (base : Nat)
    (layout : ∀ head, (buffers head).base=2*(base+head.val*256)) (i : Fin 6144) :
    wordAddress (buffers (headOf i)) (coordinate i)=base+i.val := by
  unfold wordAddress
  rw [layout]
  dsimp only [headOf, coordinate]
  omega

theorem sigmoid_donated (input : Input x gate) (p : OutputGate.Platform) (base : Nat)
    (layout : ∀ head, (input.storage.gate head).base=2*(base+head.val*256)) :
    ElementwiseMemory.Independent (sigmoidKernel input p base) := by
  intro reader writer different operand same
  change wordAddress (input.storage.gate (headOf reader)) (coordinate reader)=base+writer.val at same
  rw [head_address input.storage.gate base layout reader] at same
  exact different (Fin.ext (Nat.add_left_cancel same))

structure Activation (input : Input x gate) (p : OutputGate.Platform) where
  base : Nat
  bounded : 2*base+12288 ≤ 2^64
  trace : ElementwiseMemory.Trace (sigmoidKernel input p base)
  initial : trace.before=input.memory
  independent : ElementwiseMemory.Independent (sigmoidKernel input p base)
  sourceSeparate : ∀ head, MemoryRegions.Disjoint (2*base) 12288 (input.storage.source head).base 512

variable {input : Input x gate} {p : OutputGate.Platform}

def Activation.canonical (input : Input x gate) (p : OutputGate.Platform) (base : Nat) (bounded : 2*base+12288 ≤ 2^64)
    (independent : ElementwiseMemory.Independent (sigmoidKernel input p base))
    (sourceSeparate : ∀ head, MemoryRegions.Disjoint (2*base) 12288 (input.storage.source head).base 512) : Activation input p :=
  ⟨base, bounded, ElementwiseMemory.Trace.canonical _ input.memory, rfl, independent, sourceSeparate⟩

theorem Activation.value (activation : Activation input p) (i : Fin 6144) :
    ElementwiseMemory.result (sigmoidKernel input p activation.base) activation.trace.before i=
      ArrayStorage.bits (OutputGate.sigmoid p (gate (headOf i) (coordinate i))) := by
  change ArrayStorage.bits (OutputGate.sigmoid p (Model.ofBits (HalfMemory.load activation.trace.before (2*input.gateAddress i))))=_
  rw [activation.initial, input.gate_load]
  rfl

def Activation.buffer (activation : Activation input p) :
    ArrayStorage.BFBuffer (fun i => OutputGate.sigmoid p (gate (headOf i) (coordinate i))) where
  bytes := activation.trace.memory
  base := 2*activation.base
  aligned := by omega
  bounded := activation.bounded
  attached := by
    intro i
    have read := activation.trace.read_correct activation.independent (fun _ _ same => Fin.ext (Nat.add_left_cancel same)) i
    change HalfMemory.load activation.trace.memory (2*(activation.base+i.val))=_ at read
    rw [Nat.mul_add, activation.value] at read
    exact read

theorem Activation.other_region (activation : Activation input p) {base size : Nat}
    (separate : MemoryRegions.Disjoint (2*activation.base) 12288 base size) (offset : Nat) (bound : offset<size) :
    activation.trace.memory (base+offset)=input.memory (base+offset) :=
  (activation.trace.other_region activation.independent
    (by intro i; dsimp only [sigmoidKernel]; have := i.isLt; omega)
    separate offset bound).trans (congrFun activation.initial (base+offset))

def Activation.source (activation : Activation input p) (head : Fin 24) : ArrayStorage.BFBuffer (x head) :=
  ArrayFrame.bf (input.storage.source head) activation.trace.memory (by
    intro offset bound
    exact (activation.other_region (activation.sourceSeparate head) offset bound).trans
      (congrFun (input.sourceShared head) ((input.storage.source head).base+offset)).symm)

theorem Activation.source_load (activation : Activation input p) (i : Fin 6144) :
    HalfMemory.load activation.trace.memory (2*input.sourceAddress i)=ArrayStorage.bits (x (headOf i) (coordinate i)) :=
  buffer_load (activation.source (headOf i)) activation.trace.memory rfl (coordinate i)

def multiplyKernel (activation : Activation input p) (base : Nat) : ElementwiseMemory.Kernel 6144 2 where
  source i operand := if operand.val=0 then input.sourceAddress i else activation.base+i.val
  destination i := base+i.val
  evaluate values := ArrayStorage.bits (BFloat16Arithmetic.mul (Model.ofBits (values 0)) (Model.ofBits (values 1)))

theorem multiply_independent (activation : Activation input p) (sourceBase base : Nat)
    (layout : ∀ head, (input.storage.source head).base=2*(sourceBase+head.val*256))
    (sourceSafe : sourceBase=base ∨ MemoryRegions.Disjoint (2*sourceBase) 12288 (2*base) 12288)
    (activationSafe : activation.base=base ∨ MemoryRegions.Disjoint (2*activation.base) 12288 (2*base) 12288) :
    ElementwiseMemory.Independent (multiplyKernel activation base) := by
  let sources : Fin 2 → Nat := fun operand => if operand.val=0 then sourceBase else activation.base
  have independent := ElementwiseMemory.contiguous_independent (n := 6144) sources base (multiplyKernel activation base).evaluate (by
    intro operand
    dsimp only [sources]
    split
    · exact sourceSafe
    · exact activationSafe)
  intro reader writer different operand
  have safe := independent reader writer different operand
  have source : input.sourceAddress reader=sourceBase+reader.val := head_address input.storage.source sourceBase layout reader
  by_cases zero : operand.val=0
  · simpa only [ElementwiseMemory.contiguous, sources, multiplyKernel, zero, ite_true, source] using safe
  · simpa only [ElementwiseMemory.contiguous, sources, multiplyKernel, zero, ite_false] using safe

def values (p : OutputGate.Platform) (x gate : Heads) (i : Fin 6144) : BF :=
  OutputGate.forward p (x (headOf i) (coordinate i)) (gate (headOf i) (coordinate i))

structure Execution (input : Input x gate) (p : OutputGate.Platform) where
  activation : Activation input p
  base : Nat
  bounded : 2*base+12288 ≤ 2^64
  trace : ElementwiseMemory.Trace (multiplyKernel activation base)
  initial : trace.before=activation.trace.memory
  independent : ElementwiseMemory.Independent (multiplyKernel activation base)

def fromActivation (activation : Activation input p) (base : Nat) (bounded : 2*base+12288 ≤ 2^64)
    (independent : ElementwiseMemory.Independent (multiplyKernel activation base)) : Execution input p :=
  ⟨activation, base, bounded, ElementwiseMemory.Trace.canonical _ activation.trace.memory, rfl, independent⟩

def fromBuffers (input : Input x gate) (p : OutputGate.Platform) (sourceBase activationBase outputBase : Nat)
    (sourceLayout : ∀ head, (input.storage.source head).base=2*(sourceBase+head.val*256))
    (activationBound : 2*activationBase+12288 ≤ 2^64) (outputBound : 2*outputBase+12288 ≤ 2^64)
    (gateSeparate : ∀ head, MemoryRegions.Disjoint (2*activationBase) 12288 (input.storage.gate head).base 512)
    (sourceSeparate : ∀ head, MemoryRegions.Disjoint (2*activationBase) 12288 (input.storage.source head).base 512)
    (outputSource : sourceBase=outputBase ∨ MemoryRegions.Disjoint (2*sourceBase) 12288 (2*outputBase) 12288)
    (outputActivation : activationBase=outputBase ∨ MemoryRegions.Disjoint (2*activationBase) 12288 (2*outputBase) 12288) : Execution input p :=
  let activation := Activation.canonical input p activationBase activationBound (sigmoid_separate input p activationBase gateSeparate) sourceSeparate
  fromActivation activation outputBase outputBound (multiply_independent activation sourceBase outputBase sourceLayout outputSource outputActivation)

theorem Execution.value (execution : Execution input p) (i : Fin 6144) :
    ElementwiseMemory.result (multiplyKernel execution.activation execution.base) execution.trace.before i=ArrayStorage.bits (values p x gate i) := by
  change ArrayStorage.bits (BFloat16Arithmetic.mul
    (Model.ofBits (HalfMemory.load execution.trace.before (2*input.sourceAddress i)))
    (Model.ofBits (HalfMemory.load execution.trace.before (2*(execution.activation.base+i.val)))))=_
  rw [execution.initial, execution.activation.source_load, Nat.mul_add]
  have activationRead := execution.activation.buffer.attached i
  change HalfMemory.load execution.activation.trace.memory (2*execution.activation.base+2*i.val)=_ at activationRead
  rw [activationRead]
  rfl

def Execution.buffer (execution : Execution input p) : ArrayStorage.BFBuffer (values p x gate) where
  bytes := execution.trace.memory
  base := 2*execution.base
  aligned := by omega
  bounded := execution.bounded
  attached := by
    intro i
    have read := execution.trace.read_correct execution.independent (fun _ _ same => Fin.ext (Nat.add_left_cancel same)) i
    change HalfMemory.load execution.trace.memory (2*(execution.base+i.val))=_ at read
    rw [Nat.mul_add, execution.value] at read
    exact read

theorem Execution.output_eq (execution : Execution input p) (i : Fin 6144) :
    execution.buffer.read i=OutputGate.forward p (x (headOf i) (coordinate i)) (gate (headOf i) (coordinate i)) :=
  execution.buffer.read_correct i

theorem Execution.other_region (execution : Execution input p) {base size : Nat}
    (activationSeparate : MemoryRegions.Disjoint (2*execution.activation.base) 12288 base size)
    (outputSeparate : MemoryRegions.Disjoint (2*execution.base) 12288 base size) (offset : Nat) (bound : offset<size) :
    execution.trace.memory (base+offset)=input.memory (base+offset) := by
  have output := execution.trace.other_region execution.independent
    (by intro i; dsimp only [multiplyKernel]; have := i.isLt; omega) outputSeparate offset bound
  exact output.trans ((congrFun execution.initial (base+offset)).trans
    (execution.activation.other_region activationSeparate offset bound))

end Inference.Kernels.Attention.OutputGateMemory
