import kernels.delta.MlxDepthwiseConvSource
import kernels.delta.MlxDepthwiseConvHostSource
import kernels.delta.ConvolutionMemory
namespace Inference.Kernels.Delta.MlxDepthwiseConvMemory
open Contracts.Mlx
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

variable {values : Fin 40960→ArrayStorage.BF} {weights : Fin 40960→ArrayStorage.BF}

def view (source : ArrayStorage.BFBuffer values) (weight : ArrayStorage.BFBuffer weights) (base : Nat) : MlxDepthwiseConvSource.Memory :=
  ⟨source.bytes,source.base,weight.bytes,weight.base,base⟩

theorem view_value (contracted : Bool) (source : ArrayStorage.BFBuffer values)
    (weight : ArrayStorage.BFBuffer weights) (base : Nat) (channel : Fin 10240) :
    Convolution.value contracted (MlxDepthwiseConvSource.inputValue (view source weight base) channel)
      (MlxDepthwiseConvSource.weightValue (view source weight base) channel)=
      ConvolutionDevice.produced contracted source weight channel := by
  unfold ConvolutionDevice.produced
  have inputs : MlxDepthwiseConvSource.inputValue (view source weight base) channel=
      fun tap=>source.read (Inference.State.ConvolutionStorage.index tap channel) := by
    funext tap
    change (Model.ofBits (HalfMemory.load source.bytes (source.base+2*(channel.val+tap.val*10240))) : ArrayStorage.BF)=
      (Model.ofBits (HalfMemory.load source.bytes (source.base+2*(tap.val*10240+channel.val))) : ArrayStorage.BF)
    rw [Nat.add_comm channel.val]
  have weights : MlxDepthwiseConvSource.weightValue (view source weight base) channel=
      fun tap=>weight.read (ConvolutionDevice.weightIndex channel tap) := by
    rfl
  rw [inputs,weights]

def programs (contracted : Bool) (memory : MlxDepthwiseConvSource.Memory) : Option (List (List HalfMemory.Store)) :=
  (List.finRange 10240).mapM (MlxDepthwiseConvSource.execute contracted memory)

private theorem mapM_some {α β : Type} (items : List α) (f : α→Option β) (g : α→β)
    (same : ∀ item∈items,f item=some (g item)) : items.mapM f=some (items.map g) := by
  induction items with
  | nil => rfl
  | cons item rest ih =>
    simp only [List.mapM_cons,same item (by simp),List.map_cons]
    rw [ih (fun value member=>same value (by simp [member]))]
    rfl

attribute [local irreducible] programs MlxDepthwiseConvSource.execute

theorem source_programs (contracted : Bool) (source : ArrayStorage.BFBuffer values)
    (weight : ArrayStorage.BFBuffer weights) (base : Nat) (aligned : base%2=0) :
    programs contracted (view source weight base)=some (HalfArrayWrites.programs base
      (fun channel=>ArrayStorage.bits (ConvolutionDevice.produced contracted source weight channel))) := by
  unfold programs HalfArrayWrites.programs
  apply mapM_some
  intro channel _
  have run := MlxDepthwiseConvSource.execution contracted (view source weight base) source.bounded aligned channel
  simpa only [view_value,show (view source weight base).outputBase=base from rfl] using run

variable {history : Inference.State.ConvolutionStorage.History} {next : Fin 10240→ArrayStorage.BF}
    {weight : Fin 10240→Fin 4→ArrayStorage.BF} {input : ConvolutionMemory.Input history next weight}
    {contracted : Bool} (execution : ConvolutionMemory.Execution input contracted)

theorem current_programs (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.base 20480 stores) :
    programs contracted (view (execution.duringSource stores inside) (execution.duringWeights stores inside) execution.base)=
      some (HalfArrayWrites.programs execution.base (fun channel=>ArrayStorage.bits
        (ConvolutionDevice.produced contracted input.window.window input.weightsAfter channel))) := by
  rw [source_programs _ _ _ _ execution.stores.aligned]
  congr 2
  funext channel
  rw [execution.partial_produced stores inside channel]

theorem current_read_bounds (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 execution.base 20480 stores) (channel : Fin 10240) (tap : Fin 4) :
    (input.window.window.base+2*(channel.val+tap.val*10240))%2=0 ∧
    input.window.window.base+2*(channel.val+tap.val*10240)+2≤2^64 ∧
    (input.weight.base+2*(channel.val*4+tap.val))%2=0 ∧
    input.weight.base+2*(channel.val*4+tap.val)+2≤2^64 :=
  MlxDepthwiseConvSource.read_bounds (view (execution.duringSource stores inside) (execution.duringWeights stores inside) execution.base)
    (execution.duringSource stores inside).aligned (execution.duringWeights stores inside).aligned
    (execution.duringSource stores inside).bounded (execution.duringWeights stores inside).bounded channel tap

theorem current_shared (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 execution.base 20480 stores) :
    (view (execution.duringSource stores inside) (execution.duringWeights stores inside) execution.base).input=HalfMemory.execute stores input.window.tail.memory ∧
    (view (execution.duringSource stores inside) (execution.duringWeights stores inside) execution.base).weight=HalfMemory.execute stores input.window.tail.memory := ⟨rfl,rfl⟩

structure Certificate : Prop where
  signedCounter : ∀ index : Fin 5,(BitVec.ofNat 32 index.val).toInt=(index.val:Int)
  signedIncrement : ∀ index : Fin 4,BitVec.ofNat 32 index.val+BitVec.ofNat 32 1=BitVec.ofNat 32 (index.val+1)
  host : MlxDepthwiseConvHostSource.depthwise MlxDepthwiseConvHostSource.selected=true ∧
    MlxDepthwiseConvHostSource.large MlxDepthwiseConvHostSource.selected=false ∧
    MlxDepthwiseConvHostSource.grid MlxDepthwiseConvHostSource.selected=(10240,1,1) ∧
    MlxDepthwiseConvHostSource.selected.kernel=4 ∧ MlxDepthwiseConvHostSource.strides=(40960,10240,1)
  sourcePrograms : ∀ stores,∀ inside : MemoryRegions.Inside16 execution.base 20480 stores,
    programs contracted (view (execution.duringSource stores inside) (execution.duringWeights stores inside) execution.base)=
      some (HalfArrayWrites.programs execution.base (fun channel=>ArrayStorage.bits
        (ConvolutionDevice.produced contracted input.window.window input.weightsAfter channel)))
  sourceExecution : ∃ writes,programs contracted (view (execution.duringSource [] (by intro store member;cases member))
      (execution.duringWeights [] (by intro store member;cases member)) execution.base)=some writes ∧
      ThreadgroupWrites.Executes writes execution.stores.schedule execution.stores.remaining
  completed : ThreadgroupWrites.AtBarrier execution.stores.remaining
  readback : ∀ channel,HalfMemory.load execution.stores.memory (execution.base+2*channel.val)=
    ArrayStorage.bits (Convolution.value contracted (fun tap=>Convolution.streamWindow history next tap channel) (weight channel))

theorem checked : Certificate execution := by
  have noStores : MemoryRegions.Inside16 execution.base 20480 [] := by intro store member;cases member
  refine ⟨MlxDepthwiseConvSource.signed_counter,MlxDepthwiseConvSource.signed_increment,
    MlxDepthwiseConvHostSource.selected_dispatch,current_programs execution,
    ⟨_,current_programs execution [] noStores,execution.stores.execution⟩,execution.stores.completed,?_⟩
  intro channel
  rw [execution.stores.read_correct]
  apply congrArg ArrayStorage.bits
  exact input.window.convolution_value contracted weight input.weightsAfter channel

theorem readback (channel : Fin 10240) : execution.outputBuffer.read channel=
    Convolution.value contracted (fun tap=>Convolution.streamWindow history next tap channel) (weight channel) := by
  rw [ArrayStorage.BFBuffer.read_correct]
  exact execution.output_eq channel

theorem outside (separate : MemoryRegions.Disjoint execution.base 20480 base size) (offset : Nat) (bound : offset<size) :
    execution.stores.memory (base+offset)=input.window.tail.memory (base+offset) :=
  (MemoryRegions.execute16_other execution.stores.schedule execution.stores.before
    (ArrayFrame.half_stores_inside execution.stores) separate offset bound).trans (congrFun execution.shared _)
end Inference.Kernels.Delta.MlxDepthwiseConvMemory
