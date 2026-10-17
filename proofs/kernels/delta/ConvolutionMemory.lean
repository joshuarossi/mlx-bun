import state.ConvolutionMemory
import contracts.mlx.ArrayViews

namespace Inference.Kernels.Delta.ConvolutionMemory
open Contracts.Mlx State.ConvolutionStorage
set_option maxRecDepth 10000

variable {history : History} {next : Fin 10240 → BF} {weights : Fin 10240 → Fin 4 → BF}

-- Construct the actual four-row window and retained tail first, preserving
-- the convolution weights through both copy dispatches.
structure Input (history : History) (next : Fin 10240 → BF) (weights : Fin 10240 → Fin 4 → BF) where
  window : State.ConvolutionMemory.Execution history next
  weight : ArrayStorage.BFBuffer (ConvolutionDevice.weightWords weights)
  shared : weight.bytes=window.joined.old.bytes
  joinWeight : MemoryRegions.Disjoint (2*window.joined.destination) 81920 weight.base 81920
  tailWeight : MemoryRegions.Disjoint (2*window.destination) 61440 weight.base 81920

def Input.weightsAfter (input : Input history next weights) : ArrayStorage.BFBuffer (ConvolutionDevice.weightWords weights) :=
  ArrayFrame.bf input.weight input.window.tail.memory (by
    intro offset bound
    have joined := ConcatMemory.other_region _ input.window.joined.copy input.joinWeight offset bound
    have tail := ConcatMemory.other_region _ input.window.tail input.tailWeight offset bound
    rw [input.window.initial] at tail
    rw [input.window.joined.initial] at joined
    exact tail.trans (joined.trans (congrFun input.shared _).symm))

structure Execution (input : Input history next weights) (contracted : Bool) where
  base : Nat
  stores : HalfArrayWrites.Trace base (fun channel => ArrayStorage.bits
    (ConvolutionDevice.produced contracted input.window.window input.weightsAfter channel))
  shared : stores.before=input.window.tail.memory
  sourceSeparate : MemoryRegions.Disjoint base 20480 input.window.window.base 81920
  weightsSeparate : MemoryRegions.Disjoint base 20480 input.weight.base 81920
  historySeparate : MemoryRegions.Disjoint base 20480 input.window.after.base 61440

variable {input : Input history next weights} {contracted : Bool}

def canonical (input : Input history next weights) (contracted : Bool) (base : Nat)
    (aligned : base%2=0) (bounded : base+20480 ≤ 2^64)
    (sourceSeparate : MemoryRegions.Disjoint base 20480 input.window.window.base 81920)
    (weightsSeparate : MemoryRegions.Disjoint base 20480 input.weight.base 81920)
    (historySeparate : MemoryRegions.Disjoint base 20480 input.window.after.base 61440) : Execution input contracted :=
  let programs := HalfArrayWrites.programs base (fun channel => ArrayStorage.bits
    (ConvolutionDevice.produced contracted input.window.window input.weightsAfter channel))
  ⟨base, ⟨input.window.tail.memory, aligned, bounded, programs.flatten, List.replicate programs.length [],
    ThreadgroupWrites.canonical programs, ThreadgroupWrites.canonical_barrier programs⟩,
    rfl, sourceSeparate, weightsSeparate, historySeparate⟩

def Execution.duringSource (execution : Execution input contracted) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.base 20480 stores) :
    ArrayStorage.BFBuffer (flatten (Convolution.streamWindow history next)) :=
  ArrayFrame.bf input.window.window (HalfMemory.execute stores input.window.tail.memory)
    (MemoryRegions.execute16_other stores _ inside execution.sourceSeparate)

def Execution.duringWeights (execution : Execution input contracted) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.base 20480 stores) : ArrayStorage.BFBuffer (ConvolutionDevice.weightWords weights) :=
  ArrayFrame.bf input.weightsAfter (HalfMemory.execute stores input.window.tail.memory)
    (MemoryRegions.execute16_other stores _ inside execution.weightsSeparate)

theorem Execution.partial_produced (execution : Execution input contracted) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.base 20480 stores) (channel : Fin 10240) :
    ConvolutionDevice.produced contracted (execution.duringSource stores inside) (execution.duringWeights stores inside) channel=
      ConvolutionDevice.produced contracted input.window.window input.weightsAfter channel := by
  unfold ConvolutionDevice.produced
  simp only [ArrayStorage.BFBuffer.read_correct]

def Execution.output (execution : Execution input contracted) : Fin 10240 → BF := execution.stores.buffer.read

def Execution.outputBuffer (execution : Execution input contracted) : ArrayStorage.BFBuffer execution.output :=
  ArrayViews.readback execution.stores.buffer

theorem Execution.output_eq (execution : Execution input contracted) (channel : Fin 10240) :
    execution.output channel=Convolution.value contracted
      (fun tap => Convolution.streamWindow history next tap channel) (weights channel) := by
  unfold Execution.output
  rw [ArrayStorage.BFBuffer.read_correct]
  exact input.window.convolution_value contracted weights input.weightsAfter channel

def Execution.afterHistory (execution : Execution input contracted) : Storage (Convolution.tail history (fun _ => next) 1) :=
  ArrayFrame.bf input.window.after execution.stores.memory (by
    intro offset bound
    have result := MemoryRegions.execute16_other execution.stores.schedule execution.stores.before
      (ArrayFrame.half_stores_inside execution.stores) execution.historySeparate offset bound
    exact result.trans (congrFun execution.shared _))

theorem Execution.history_output_shared (execution : Execution input contracted) :
    execution.afterHistory.bytes=execution.outputBuffer.bytes := rfl

def Safe (execution : Execution input contracted) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint (2*input.window.joined.destination) 81920 base size ∧
  MemoryRegions.Disjoint (2*input.window.destination) 61440 base size ∧
  MemoryRegions.Disjoint execution.base 20480 base size

theorem Execution.other_region (execution : Execution input contracted) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=input.window.joined.old.bytes (base+offset) := by
  have joined := ConcatMemory.other_region _ input.window.joined.copy safe.1 offset bound
  have tail := ConcatMemory.other_region _ input.window.tail safe.2.1 offset bound
  have output := MemoryRegions.execute16_other execution.stores.schedule execution.stores.before
    (ArrayFrame.half_stores_inside execution.stores) safe.2.2 offset bound
  rw [input.window.joined.initial] at joined
  rw [input.window.initial] at tail
  exact output.trans ((congrFun execution.shared _).trans (tail.trans joined))

end Inference.Kernels.Delta.ConvolutionMemory
