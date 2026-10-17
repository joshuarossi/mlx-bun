import kernels.attention.SdpaDispatchedDevice
import contracts.mlx.ArrayStorage

namespace Inference.Kernels.Attention.SdpaLoads
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := ArrayStorage.BF
abbrev History (steps : Nat) := Fin 4 → Fin steps → Fin 256 → BF
set_option maxRecDepth 10000

def address (capacity : Nat) (head : Fin 4) (time : Nat) (i : Fin 256) : Nat :=
  (head.val*capacity+time)*256+i.val

structure HistoryBuffer (values : History steps) where
  bytes : HalfMemory.Bytes
  capacity : Nat
  room : steps ≤ capacity
  attached : ∀ head time i, HalfMemory.load bytes (2*address capacity head time.val i)=ArrayStorage.bits (values head time i)

variable {steps : Nat} {values : History steps}

def HistoryBuffer.read (buffer : HistoryBuffer values) (head : Fin 4) (time : Fin steps) (i : Fin 256) : BF :=
  Model.ofBits (HalfMemory.load buffer.bytes (2*address buffer.capacity head time.val i))

theorem HistoryBuffer.read_eq (buffer : HistoryBuffer values) : buffer.read=values := by
  funext head time i
  exact congrArg (fun word : BitVec 16 => (Model.ofBits word : BF)) (buffer.attached head time i)

theorem HistoryBuffer.bounds (buffer : HistoryBuffer values) (supported : buffer.capacity ≤ 262144)
    (head : Fin 4) (time : Fin steps) (i : Fin 256) :
    address buffer.capacity head time.val i<2^31 ∧ 2*address buffer.capacity head time.val i+2 ≤ 2^64 := by
  have hhead := head.isLt
  have htime := time.isLt.trans_le buffer.room
  have hi := i.isLt
  have hmul : head.val*buffer.capacity ≤ 3*buffer.capacity := Nat.mul_le_mul_right _ (by omega)
  unfold address
  omega

structure Storage (query : Fin 24 → Fin 256 → BF) (keys values : History steps) where
  query : ∀ head, ArrayStorage.BFBuffer (query head)
  keys : HistoryBuffer keys
  values : HistoryBuffer values

variable {query : Fin 24 → Fin 256 → BF} {keys : History steps}

def Storage.queryValues (storage : Storage query keys values) (head : Fin 24) : Fin 256 → BF := (storage.query head).read

theorem Storage.query_eq (storage : Storage query keys values) : storage.queryValues=query :=
  funext fun _head => funext (ArrayStorage.BFBuffer.read_correct _)

structure Execution (p : SdpaVector.Platform) (contracted : Bool) (arch : Char)
    (query : Fin 24 → Fin 256 → BF) (keys values : History steps) where
  storage : Storage query keys values
  kernel : SdpaDispatchedDevice.Execution p contracted arch storage.queryValues storage.keys.read storage.values.read

def Execution.fromStorage (p : SdpaVector.Platform) (contracted : Bool) (arch : Char)
    (query : Fin 24 → Fin 256 → BF) (keys values : History steps) (storage : Storage query keys values) :
    Execution p contracted arch query keys values :=
  ⟨storage, SdpaDispatchedDevice.Execution.canonical _ _ _ _ _ _⟩

variable {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}

def Execution.output (execution : Execution p contracted arch query keys values) : Fin 24 → Fin 256 → BF :=
  SdpaDispatchedDevice.forward execution.kernel

theorem Execution.output_eq (execution : Execution p contracted arch query keys values) (head : Fin 24) (i : Fin 256) :
    execution.output head i=SdpaDispatched.forward p contracted arch (query head)
      (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)) i := by
  unfold Execution.output
  rw [SdpaDispatchedDevice.forward_eq, execution.storage.query_eq, execution.storage.keys.read_eq, execution.storage.values.read_eq]

def Execution.outputBuffer (execution : Execution p contracted arch query keys values) (head : Fin 24) :
    ArrayStorage.BFBuffer (execution.output head) where
  bytes := execution.kernel.output.memory
  base := execution.kernel.output.base+2*(head.val*256)
  aligned := by have := execution.kernel.output.aligned; omega
  bounded := by have := execution.kernel.output.bounded; have := head.isLt; omega
  attached := by
    intro i
    change HalfMemory.load execution.kernel.output.memory ((execution.kernel.output.base+2*(head.val*256))+2*i.val)=
      HalfMemory.load execution.kernel.output.memory (execution.kernel.output.base+2*SdpaOutput.address head i)
    congr 1
    dsimp [SdpaOutput.address]
    omega

theorem Execution.output_bytes (execution : Execution p contracted arch query keys values) (head : Fin 24) :
    (execution.outputBuffer head).bytes=execution.kernel.output.memory := rfl

end Inference.Kernels.Attention.SdpaLoads
