import kernels.delta.GateDevice
import contracts.mlx.UnaryMemory
import contracts.mlx.ArrayFrame

namespace Inference.Kernels.Delta.GateMemory
open Contracts.Mlx GateDevice
set_option maxRecDepth 10000

structure Input (aLog a dtBias b : Heads) where
  storage : GateDevice.Storage aLog a dtBias b
  aShared : storage.projectionA.bytes=storage.logarithm.bytes
  biasShared : storage.bias.bytes=storage.logarithm.bytes
  bShared : storage.projectionB.bytes=storage.logarithm.bytes

variable {aLog a dtBias b : Heads}

def Input.Protected (input : Input aLog a dtBias b) (property : Nat → Prop) : Prop :=
  property input.storage.logarithm.base ∧ property input.storage.projectionA.base ∧
  property input.storage.bias.base ∧ property input.storage.projectionB.base

def Input.reframe (input : Input aLog a dtBias b) (after : ByteMemory.Bytes)
    (same : input.Protected (fun base => ∀ offset < 96, after (base+offset)=input.storage.logarithm.bytes (base+offset))) :
    Input aLog a dtBias b where
  storage := {
    logarithm := ArrayFrame.bf input.storage.logarithm after same.1
    projectionA := ArrayFrame.bf input.storage.projectionA after
      (fun offset bound => (same.2.1 offset bound).trans (congrFun input.aShared _).symm)
    bias := ArrayFrame.bf input.storage.bias after
      (fun offset bound => (same.2.2.1 offset bound).trans (congrFun input.biasShared _).symm)
    projectionB := ArrayFrame.bf input.storage.projectionB after
      (fun offset bound => (same.2.2.2 offset bound).trans (congrFun input.bShared _).symm) }
  aShared := rfl
  biasShared := rfl
  bShared := rfl

-- The fused expression's rounding is specified by producedDecay. Its
-- generated native implementation remains a separate compiler obligation.
structure DecayExecution (input : Input aLog a dtBias b) (p : Inputs.Platform) where
  base : Nat
  stores : FloatArrayWrites.Trace base (GateDevice.producedDecay p input.storage)
  shared : stores.before=input.storage.logarithm.bytes
  safe : input.Protected (fun source => MemoryRegions.Disjoint base 192 source 96)

variable {input : Input aLog a dtBias b} {p : Inputs.Platform}

def decayCanonical (input : Input aLog a dtBias b) (p : Inputs.Platform) (base : Nat)
    (aligned : base%4=0) (bounded : base+192 ≤ 2^64)
    (safe : input.Protected (fun source => MemoryRegions.Disjoint base 192 source 96)) : DecayExecution input p :=
  let programs := FloatArrayWrites.programs base (GateDevice.producedDecay p input.storage)
  ⟨base, ⟨input.storage.logarithm.bytes, aligned, bounded, programs.flatten, List.replicate programs.length [],
    ThreadgroupWrites.canonical programs, ThreadgroupWrites.canonical_barrier programs⟩, rfl, safe⟩

def DecayExecution.during (decay : DecayExecution input p) (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 decay.base 192 stores) : Input aLog a dtBias b :=
  input.reframe (ByteMemory.execute stores input.storage.logarithm.bytes)
    ⟨MemoryRegions.execute32_other stores _ inside decay.safe.1,
      MemoryRegions.execute32_other stores _ inside decay.safe.2.1,
      MemoryRegions.execute32_other stores _ inside decay.safe.2.2.1,
      MemoryRegions.execute32_other stores _ inside decay.safe.2.2.2⟩

theorem DecayExecution.partial_produced (decay : DecayExecution input p) (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 decay.base 192 stores) (head : Fin 48) :
    GateDevice.producedDecay p (decay.during stores inside).storage head=GateDevice.producedDecay p input.storage head := by
  rw [GateDevice.produced_decay, GateDevice.produced_decay]

theorem DecayExecution.other_region (decay : DecayExecution input p) {base size : Nat}
    (separate : MemoryRegions.Disjoint decay.base 192 base size) (offset : Nat) (bound : offset<size) :
    decay.stores.memory (base+offset)=input.storage.logarithm.bytes (base+offset) :=
  (MemoryRegions.execute32_other decay.stores.schedule decay.stores.before
    (ArrayFrame.float_stores_inside decay.stores) separate offset bound).trans (congrFun decay.shared _)

def DecayExecution.after (decay : DecayExecution input p) : Input aLog a dtBias b :=
  input.reframe decay.stores.memory
    ⟨decay.other_region decay.safe.1, decay.other_region decay.safe.2.1,
      decay.other_region decay.safe.2.2.1, decay.other_region decay.safe.2.2.2⟩

structure Execution (decay : DecayExecution input p) where
  beta : UnaryMemory.Execution decay.after.storage.projectionB (Trellis.GateUpSplitTail.sigmoidValue p.expAbs)
  decaySeparate : MemoryRegions.Disjoint (2*beta.base) 96 decay.base 192

variable {decay : DecayExecution input p}

def fromDecay (decay : DecayExecution input p) (base : Nat) (bounded : 2*base+96 ≤ 2^64)
    (safe : input.storage.projectionB.base/2=base ∨ MemoryRegions.Disjoint input.storage.projectionB.base 96 (2*base) 96)
    (decaySeparate : MemoryRegions.Disjoint (2*base) 96 decay.base 192) : Execution decay :=
  ⟨UnaryMemory.canonical decay.after.storage.projectionB (Trellis.GateUpSplitTail.sigmoidValue p.expAbs) base bounded safe,
    decaySeparate⟩

def Execution.decayBuffer (execution : Execution decay) : ArrayStorage.FloatBuffer (GateDevice.producedDecay p input.storage) :=
  ArrayFrame.fp decay.stores.buffer execution.beta.buffer.bytes (execution.beta.other_region execution.decaySeparate)

def Execution.betaBuffer (execution : Execution decay) :
    ArrayStorage.BFBuffer (fun head => Trellis.GateUpSplitTail.sigmoidValue p.expAbs (b head)) := execution.beta.buffer

theorem Execution.buffers_shared (execution : Execution decay) : execution.decayBuffer.bytes=execution.betaBuffer.bytes := rfl

theorem Execution.decay_eq (execution : Execution decay) (head : Fin 48) :
    execution.decayBuffer.read head=Decay.value p.decay (BFloat16.widen (aLog head)) (a head) (dtBias head) := by
  rw [ArrayStorage.FloatBuffer.read_correct, GateDevice.produced_decay]

theorem Execution.beta_eq (execution : Execution decay) (head : Fin 48) :
    execution.betaBuffer.read head=Trellis.GateUpSplitTail.sigmoidValue p.expAbs (b head) := execution.betaBuffer.read_correct head

theorem Execution.other_region (execution : Execution decay) {base size : Nat}
    (decaySeparate : MemoryRegions.Disjoint decay.base 192 base size)
    (betaSeparate : MemoryRegions.Disjoint (2*execution.beta.base) 96 base size)
    (offset : Nat) (bound : offset<size) :
    execution.betaBuffer.bytes (base+offset)=input.storage.logarithm.bytes (base+offset) :=
  (execution.beta.other_region betaSeparate offset bound).trans (decay.other_region decaySeparate offset bound)

end Inference.Kernels.Delta.GateMemory
