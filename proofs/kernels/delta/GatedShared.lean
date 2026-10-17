import kernels.delta.GatedMemory

namespace Inference.Kernels.Delta.GatedShared
open Contracts.Mlx GatedDevice
set_option maxRecDepth 10000

-- The six operands are views of one heap. The two owned output allocations
-- must preserve them while independently scheduled threadgroups still load.
structure Input (initial : State) (values : GatedInputs.Values) where
  state : GatedDevice.Storage initial
  operands : GatedInputs.Storage values
  keyShared : operands.key.bytes=state.bytes
  queryShared : operands.query.bytes=state.bytes
  valueShared : operands.value.bytes=state.bytes
  decayShared : operands.decay.bytes=state.bytes
  betaShared : operands.beta.bytes=state.bytes

variable {initial : State} {values : GatedInputs.Values}

def Input.Protected (input : Input initial values) (property : Nat → Nat → Prop) : Prop :=
  property input.state.base 3145728 ∧
  property input.operands.key.base 4096 ∧
  property input.operands.query.base 4096 ∧
  property input.operands.value.base 12288 ∧
  property input.operands.decay.base 192 ∧
  property input.operands.beta.base 96

def stateFrame (source : GatedDevice.Storage initial) (after : ByteMemory.Bytes)
    (same : ∀ offset < 3145728, after (source.base+offset)=source.bytes (source.base+offset)) :
    GatedDevice.Storage initial where
  bytes := after
  base := source.base
  aligned := source.aligned
  bounded := source.bounded
  attached := by
    intro head row key
    unfold FloatMemory.load
    rw [ArrayFrame.word_congr source.bytes after source.base 3145728 _ same
      (by have := GatedStores.state_bounds head row key; omega)]
    exact source.attached head row key

def Input.reframe (input : Input initial values) (after : ByteMemory.Bytes)
    (same : input.Protected (fun base size => ∀ offset < size, after (base+offset)=input.state.bytes (base+offset))) :
    Input initial values where
  state := stateFrame input.state after same.1
  operands := {
    key := ArrayFrame.bf input.operands.key after (by
      intro offset bound
      exact (same.2.1 offset bound).trans (congrFun input.keyShared _).symm)
    query := ArrayFrame.bf input.operands.query after (by
      intro offset bound
      exact (same.2.2.1 offset bound).trans (congrFun input.queryShared _).symm)
    value := ArrayFrame.bf input.operands.value after (by
      intro offset bound
      exact (same.2.2.2.1 offset bound).trans (congrFun input.valueShared _).symm)
    decay := ArrayFrame.fp input.operands.decay after (by
      intro offset bound
      exact (same.2.2.2.2.1 offset bound).trans (congrFun input.decayShared _).symm)
    beta := ArrayFrame.bf input.operands.beta after (by
      intro offset bound
      exact (same.2.2.2.2.2 offset bound).trans (congrFun input.betaShared _).symm) }
  keyShared := rfl
  queryShared := rfl
  valueShared := rfl
  decayShared := rfl
  betaShared := rfl

structure Execution (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction)
    (initial : State) (values : GatedInputs.Values) where
  input : Input initial values
  stores : GatedMemory.Execution (producedState reduce flags input.state.read input.operands.inputs)
    (producedOutput reduce flags input.state.read input.operands.inputs)
  shared : stores.trace.stateBefore=input.state.bytes
  safe : input.Protected (fun base size =>
    MemoryRegions.Disjoint stores.trace.stateBase 3145728 base size ∧
    MemoryRegions.Disjoint stores.trace.outputBase 12288 base size)

def canonical (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction)
    (input : Input initial values) (stateBase outputBase : Nat)
    (stateAligned : stateBase%4=0) (outputAligned : outputBase%2=0)
    (stateBound : stateBase+3145728 ≤ 2^64) (outputBound : outputBase+12288 ≤ 2^64)
    (separate : MemoryRegions.Disjoint stateBase 3145728 outputBase 12288)
    (safe : input.Protected (fun base size =>
      MemoryRegions.Disjoint stateBase 3145728 base size ∧ MemoryRegions.Disjoint outputBase 12288 base size)) :
    Execution reduce flags initial values :=
  ⟨input, GatedMemory.canonical _ _ input.state.bytes stateBase outputBase
    stateAligned outputAligned stateBound outputBound separate, rfl, safe⟩

variable {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}

theorem Execution.partial_frame (execution : Execution reduce flags initial values)
    (events : List GatedBytes.Event) (subset : ∀ event ∈ events, event ∈ execution.stores.trace.schedule) :
    execution.input.Protected (fun base size => ∀ offset < size,
      MemoryProjection.execute GatedMemory.write events execution.input.state.bytes (base+offset)=
        execution.input.state.bytes (base+offset)) := by
  have frame : ∀ base size,
      MemoryRegions.Disjoint execution.stores.trace.stateBase 3145728 base size ∧
      MemoryRegions.Disjoint execution.stores.trace.outputBase 12288 base size →
      ∀ offset < size, MemoryProjection.execute GatedMemory.write events execution.input.state.bytes (base+offset)=
        execution.input.state.bytes (base+offset) := by
    intro base size safe offset bound
    have result := execution.stores.during_other events subset safe.1 safe.2 offset bound
    rw [execution.shared] at result
    exact result
  exact ⟨frame _ _ execution.safe.1, frame _ _ execution.safe.2.1,
    frame _ _ execution.safe.2.2.1, frame _ _ execution.safe.2.2.2.1,
    frame _ _ execution.safe.2.2.2.2.1, frame _ _ execution.safe.2.2.2.2.2⟩

def Execution.during (execution : Execution reduce flags initial values)
    (events : List GatedBytes.Event) (subset : ∀ event ∈ events, event ∈ execution.stores.trace.schedule) :
    Input initial values :=
  execution.input.reframe (MemoryProjection.execute GatedMemory.write events execution.input.state.bytes)
    (execution.partial_frame events subset)

-- Reads interleaved with any subset of output stores yield the original
-- operands, so the arithmetic does not rely on a fictitious immutable heap.
theorem Execution.partial_state (execution : Execution reduce flags initial values)
    (events : List GatedBytes.Event) (subset : ∀ event ∈ events, event ∈ execution.stores.trace.schedule) :
    producedState reduce flags (execution.during events subset).state.read (execution.during events subset).operands.inputs=
      producedState reduce flags execution.input.state.read execution.input.operands.inputs := by
  rw [GatedDevice.Storage.read_eq, GatedInputs.Storage.inputs_eq,
    execution.input.state.read_eq, execution.input.operands.inputs_eq]

theorem Execution.partial_output (execution : Execution reduce flags initial values)
    (events : List GatedBytes.Event) (subset : ∀ event ∈ events, event ∈ execution.stores.trace.schedule) :
    producedOutput reduce flags (execution.during events subset).state.read (execution.during events subset).operands.inputs=
      producedOutput reduce flags execution.input.state.read execution.input.operands.inputs := by
  rw [GatedDevice.Storage.read_eq, GatedInputs.Storage.inputs_eq,
    execution.input.state.read_eq, execution.input.operands.inputs_eq]

def Execution.state (execution : Execution reduce flags initial values) : State := execution.stores.stateRead
def Execution.output (execution : Execution reduce flags initial values) : Fin 48 → Fin 128 → GatedBytes.BF := execution.stores.outputRead

theorem Execution.state_eq (execution : Execution reduce flags initial values) :
    execution.state=producedState reduce flags initial values.inputs := by
  have result : execution.state=producedState reduce flags execution.input.state.read execution.input.operands.inputs :=
    funext fun head => funext fun row => funext fun key => execution.stores.state_correct head row key
  rw [execution.input.state.read_eq, execution.input.operands.inputs_eq] at result
  exact result

theorem Execution.output_eq (execution : Execution reduce flags initial values) :
    execution.output=producedOutput reduce flags initial values.inputs := by
  have result : execution.output=producedOutput reduce flags execution.input.state.read execution.input.operands.inputs :=
    funext fun head => funext fun row => execution.stores.output_correct head row
  rw [execution.input.state.read_eq, execution.input.operands.inputs_eq] at result
  exact result

def Execution.after (execution : Execution reduce flags initial values) : GatedDevice.Storage execution.state where
  bytes := execution.stores.memory
  base := execution.stores.trace.stateBase
  aligned := execution.stores.trace.stateAligned
  bounded := execution.stores.trace.stateBounded
  attached := fun _ _ _ => rfl

def Execution.buffer (execution : Execution reduce flags initial values) :
    ArrayStorage.BFBuffer (GatedInputs.flatten execution.output) where
  bytes := execution.stores.memory
  base := execution.stores.trace.outputBase
  aligned := execution.stores.trace.outputAligned
  bounded := execution.stores.trace.outputBounded
  attached := by
    intro i
    change HalfMemory.load execution.stores.memory (execution.stores.trace.outputBase+2*i.val)=
      HalfMemory.load execution.stores.memory (execution.stores.trace.outputBase+
        2*GatedStores.outputIndex ⟨i.val/128, by have := i.isLt; omega⟩ ⟨i.val%128, by omega⟩)
    dsimp only [GatedStores.outputIndex]
    congr 2
    omega

theorem Execution.state_output_shared (execution : Execution reduce flags initial values) :
    execution.after.bytes=execution.buffer.bytes := rfl

theorem Execution.other_region (execution : Execution reduce flags initial values) {base size : Nat}
    (stateSeparate : MemoryRegions.Disjoint execution.stores.trace.stateBase 3145728 base size)
    (outputSeparate : MemoryRegions.Disjoint execution.stores.trace.outputBase 12288 base size)
    (offset : Nat) (bound : offset<size) :
    execution.stores.memory (base+offset)=execution.input.state.bytes (base+offset) :=
  (execution.stores.other_region stateSeparate outputSeparate offset bound).trans (congrFun execution.shared _)

end Inference.Kernels.Delta.GatedShared
