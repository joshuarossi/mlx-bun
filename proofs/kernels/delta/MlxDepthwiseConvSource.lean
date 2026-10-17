import kernels.delta.MlxDepthwiseConvSyntax
import kernels.delta.ConvolutionDevice
import kernels.quantization.AffineDot4Source
namespace Inference.Kernels.Delta.MlxDepthwiseConvSource
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib.Floats.Formats.BinaryInterchange
open MlxDepthwiseConvSyntax
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] parseProduct parseHeader parseInitial parseAdvance parseStore parsePointers

structure Memory where
  input : HalfMemory.Bytes
  inputBase : Nat
  weight : HalfMemory.Bytes
  weightBase : Nat
  outputBase : Nat

-- Native pointer-width representation is explicit. All four dereferenced
-- positions are bounded below; the final, unused pointer increment may wrap.
def pointer (base channel tap : Nat) : BitVec 64 := BitVec.ofNat 64 (base+2*(channel+tap*10240))
def inputValue (memory : Memory) (channel : Fin 10240) (tap : Fin 4) : ArrayStorage.BF :=
  Model.ofBits (HalfMemory.load memory.input (memory.inputBase+2*(channel.val+tap.val*10240)))
def weightValue (memory : Memory) (channel : Fin 10240) (tap : Fin 4) : ArrayStorage.BF :=
  Model.ofBits (HalfMemory.load memory.weight (memory.weightBase+2*(channel.val*4+tap.val)))

theorem signed_counter : ∀ index : Fin 5,(BitVec.ofNat 32 index.val).toInt=(index.val:Int) := by decide +kernel
theorem signed_increment : ∀ index : Fin 4,BitVec.ofNat 32 index.val+BitVec.ofNat 32 1=BitVec.ofNat 32 (index.val+1) := by decide +kernel

structure State where
  inputPointer : BitVec 64
  accumulator : Float32

def step (contracted : Bool) (memory : Memory) (channel : Fin 10240) (iteration : Nat) (state : State) : Option State := do
  let product ←parseProduct productSource
  let component ←parseAdvance advanceSource
  if product.weightCounter≠"i" ∨ component≠1 then none else
    let x := BFloat16.widen (Model.ofBits (HalfMemory.load memory.input (state.inputPointer.toNat+2*product.inputOffset)))
    let w := BFloat16.widen (Model.ofBits (HalfMemory.load memory.weight (memory.weightBase+2*(channel.val*4+iteration))))
    pure ⟨state.inputPointer+BitVec.ofNat 64 (2*10240),Gated.maddFloat contracted x w state.accumulator⟩

def loop {α : Type} (body : Nat→α→Option α) : Nat→Nat→α→Option α
  | 0,index,state => if index<4 then none else some state
  | fuel+1,index,state => if index<4 then do
      loop body fuel (index+1) (←body index state) else some state

def run (fuel : Nat) (contracted : Bool) (memory : Memory) (channel : Fin 10240)
    (index : Nat) (state : State) : Option State := loop (step contracted memory channel) fuel index state

theorem pointer_value (memory : Memory) (bounded : memory.inputBase+81920≤2^64)
    (channel : Fin 10240) (tap : Fin 4) :
    (pointer memory.inputBase channel.val tap.val).toNat=memory.inputBase+2*(channel.val+tap.val*10240) := by
  have := channel.isLt;have := tap.isLt
  simp only [pointer,BitVec.toNat_ofNat]
  exact Nat.mod_eq_of_lt (by omega)

theorem pointer_advance (base channel tap : Nat) :
    pointer base channel tap+BitVec.ofNat 64 (2*10240)=pointer base channel (tap+1) := by
  apply BitVec.eq_of_toNat_eq
  simp only [pointer,BitVec.toNat_add,BitVec.toNat_ofNat]
  omega

theorem step_value (contracted : Bool) (memory : Memory) (bounded : memory.inputBase+81920≤2^64)
    (channel : Fin 10240) (tap : Fin 4) (acc : Float32) :
    step contracted memory channel tap.val ⟨pointer memory.inputBase channel.val tap.val,acc⟩=
      some ⟨pointer memory.inputBase channel.val (tap.val+1),Gated.maddFloat contracted
        (BFloat16.widen (inputValue memory channel tap)) (BFloat16.widen (weightValue memory channel tap)) acc⟩ := by
  simp only [step,parsed_product,parsed_advance,product,ne_eq,not_true_eq_false,or_self,ite_false,bind,Option.bind]
  rw [pointer_value memory bounded channel tap,pointer_advance]
  rfl

attribute [local irreducible] loop run step inputValue weightValue Gated.maddFloat

def accumulator (contracted : Bool) (memory : Memory) (channel : Fin 10240) : Float32 :=
  Convolution.accumulate contracted (fun tap=>BFloat16.widen (inputValue memory channel tap))
    (fun tap=>BFloat16.widen (weightValue memory channel tap))

theorem run_four {α : Type} (body : Nat→α→Option α) (s0 s1 s2 s3 s4 : α)
    (h0 : body 0 s0=some s1) (h1 : body 1 s1=some s2)
    (h2 : body 2 s2=some s3) (h3 : body 3 s3=some s4) :
    loop body 4 0 s0=some s4 := by
  rw [loop,if_pos (show (0:Nat)<4 by decide),h0]
  change loop body 3 1 s1=_
  rw [loop,if_pos (show (1:Nat)<4 by decide),h1]
  change loop body 2 2 s2=_
  rw [loop,if_pos (show (2:Nat)<4 by decide),h2]
  change loop body 1 3 s3=_
  rw [loop,if_pos (show (3:Nat)<4 by decide),h3]
  change loop body 0 4 s4=_
  rw [loop,if_neg (show ¬(4:Nat)<4 by decide)]

private theorem fold_four {α : Type} (f : Fin 4→α→α) (zero : α) :
    (List.finRange 4).foldl (fun acc i=>f i acc) zero=f 3 (f 2 (f 1 (f 0 zero))) := rfl

theorem run_correct (contracted : Bool) (memory : Memory) (bounded : memory.inputBase+81920≤2^64)
    (channel : Fin 10240) :
    run 4 contracted memory channel 0 ⟨pointer memory.inputBase channel.val 0,0⟩=
      some ⟨pointer memory.inputBase channel.val 4,accumulator contracted memory channel⟩ := by
  let update := fun (tap : Fin 4) (acc : Float32)=>Gated.maddFloat contracted
    (BFloat16.widen (inputValue memory channel tap)) (BFloat16.widen (weightValue memory channel tap)) acc
  have four : accumulator contracted memory channel=update 3 (update 2 (update 1 (update 0 0))) :=
    fold_four update 0
  rw [four]
  unfold run
  apply run_four (step contracted memory channel)
    ⟨pointer memory.inputBase channel.val 0,0⟩
    ⟨pointer memory.inputBase channel.val 1,update 0 0⟩
    ⟨pointer memory.inputBase channel.val 2,update 1 (update 0 0)⟩
    ⟨pointer memory.inputBase channel.val 3,update 2 (update 1 (update 0 0))⟩
    ⟨pointer memory.inputBase channel.val 4,update 3 (update 2 (update 1 (update 0 0)))⟩
  · exact step_value contracted memory bounded channel (0:Fin 4) 0
  · exact step_value contracted memory bounded channel (1:Fin 4) (update 0 0)
  · exact step_value contracted memory bounded channel (2:Fin 4) (update 1 (update 0 0))
  · exact step_value contracted memory bounded channel (3:Fin 4) (update 2 (update 1 (update 0 0)))

def execute (contracted : Bool) (memory : Memory) (channel : Fin 10240) : Option (List HalfMemory.Store) := do
  let _ ←parsePointers pointersSource
  let initial ←parseInitial initialSource
  let first ←parseHeader headerSource
  let final ←run 4 contracted memory channel first ⟨pointer memory.inputBase channel.val 0,Float32.ofInt initial⟩
  let _ ←parseStore storeSource
  pure [⟨(memory.outputBase+2*channel.val)/2,ArrayStorage.bits (BFloat16.narrow final.accumulator)⟩]

theorem execution (contracted : Bool) (memory : Memory) (bounded : memory.inputBase+81920≤2^64)
    (aligned : memory.outputBase%2=0) (channel : Fin 10240) :
    execute contracted memory channel=some [HalfArrayWrites.entry memory.outputBase
      (fun channel=>ArrayStorage.bits (Convolution.value contracted (inputValue memory channel) (weightValue memory channel))) channel] := by
  simp only [execute,parsed_pointers,parsed_initial,parsed_header,parsed_store,bind,Option.bind]
  change (run 4 contracted memory channel 0 ⟨pointer memory.inputBase channel.val 0,0⟩).bind _=_
  rw [run_correct contracted memory bounded channel]
  have address : (memory.outputBase+2*channel.val)/2=memory.outputBase/2+channel.val := by omega
  simp only [Option.bind_some,address,HalfArrayWrites.entry,accumulator,Convolution.value]
  rfl

-- Source reads refer to actual current byte images, including the distinct
-- history/input window layout and contiguous channel-major weight layout.
theorem input_current {values : Fin (4*10240)→ArrayStorage.BF}
    (source : ArrayStorage.BFBuffer values) (memory : Memory)
    (bytes : memory.input=source.bytes) (base : memory.inputBase=source.base)
    (channel : Fin 10240) (tap : Fin 4) :
    inputValue memory channel tap=values (Inference.State.ConvolutionStorage.index tap channel) := by
  unfold inputValue
  rw [bytes,base]
  rw [Nat.add_comm channel.val (tap.val*10240)]
  exact source.read_correct (Inference.State.ConvolutionStorage.index tap channel)

theorem weight_current {values : Fin 40960→ArrayStorage.BF}
    (source : ArrayStorage.BFBuffer values) (memory : Memory)
    (bytes : memory.weight=source.bytes) (base : memory.weightBase=source.base)
    (channel : Fin 10240) (tap : Fin 4) :
    weightValue memory channel tap=values (ConvolutionDevice.weightIndex channel tap) := by
  unfold weightValue
  rw [bytes,base]
  exact source.read_correct (ConvolutionDevice.weightIndex channel tap)

theorem read_bounds (memory : Memory) (inputAligned : memory.inputBase%2=0)
    (weightAligned : memory.weightBase%2=0) (inputBounded : memory.inputBase+81920≤2^64)
    (weightBounded : memory.weightBase+81920≤2^64) (channel : Fin 10240) (tap : Fin 4) :
    (memory.inputBase+2*(channel.val+tap.val*10240))%2=0 ∧
    memory.inputBase+2*(channel.val+tap.val*10240)+2≤2^64 ∧
    (memory.weightBase+2*(channel.val*4+tap.val))%2=0 ∧
    memory.weightBase+2*(channel.val*4+tap.val)+2≤2^64 := by
  have := channel.isLt;have := tap.isLt
  omega
end Inference.Kernels.Delta.MlxDepthwiseConvSource
