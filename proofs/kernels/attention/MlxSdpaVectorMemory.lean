import kernels.attention.MlxSdpaVectorSyntax
import kernels.attention.SdpaAddresses
import kernels.attention.SdpaQueryMemory

namespace Inference.Kernels.Attention.MlxSdpaVectorMemory
open Contracts.Mlx State MlxSdpaVectorSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

def environment (capacity : Nat) (transposed : Bool) (head : Fin 24) (group lane : Fin 32) : String → Nat
  | "q_offset" => SdpaAddresses.queryOffset transposed head
  | "o_offset" => head.val
  | "kv_head_idx" => head.val/6
  | "D" | "V" => 256
  | "qk_per_thread" | "v_per_thread" => 8
  | "k_head_stride" | "v_head_stride" => capacity*256
  | "k_seq_stride" | "v_seq_stride" => 256
  | "simd_lid" => lane.val
  | "simd_gid" => group.val
  | _ => 0

def queryAddress (transposed : Bool) (head : Fin 24) (lane : Fin 32) (item : Fin 8) : Nat :=
  eval (environment 0 transposed head 0 lane) queryPointer.offset+item.val

def keyAddress (capacity : Nat) (head : Fin 24) (group lane : Fin 32) (iteration : Nat) (item : Fin 8) : Nat :=
  eval (environment capacity false head group lane) keyPointer.offset+iteration*(32*256)+item.val

def valueAddress (capacity : Nat) (head : Fin 24) (group lane : Fin 32) (iteration : Nat) (item : Fin 8) : Nat :=
  eval (environment capacity false head group lane) valuePointer.offset+iteration*(32*256)+item.val

def outputAddress (head : Fin 24) (group : Fin 32) (item : Fin 8) : Nat :=
  eval (environment 0 false head group 0) outputPointer.offset+item.val

theorem query_address (transposed : Bool) (head : Fin 24) (lane : Fin 32) (item : Fin 8) :
    queryAddress transposed head lane item=SdpaAddresses.queryAddress transposed head lane item := rfl

theorem key_address (capacity : Nat) (head : Fin 24) (group lane : Fin 32) (iteration : Nat) (item : Fin 8) :
    keyAddress capacity head group lane iteration item=SdpaAddresses.kvAddress capacity head group lane iteration item := rfl

theorem value_address (capacity : Nat) (head : Fin 24) (group lane : Fin 32) (iteration : Nat) (item : Fin 8) :
    valueAddress capacity head group lane iteration item=SdpaAddresses.kvAddress capacity head group lane iteration item := rfl

theorem output_address (head : Fin 24) (group : Fin 32) (item : Fin 8) :
    outputAddress head group item=SdpaAddresses.outputAddress head group item := by
  simp [outputAddress,outputPointer,environment,eval,SdpaAddresses.outputAddress]

-- BF16 widening happens before Float32 scale multiplication, and scaling
-- happens before each multiply in the lane's ordered dot-product fold.
def queryCell : Cell → ByteMemory.Bytes → Nat → Nat → Float32 → Option Float32
  | .query "i",memory,base,index,scale =>
      some (FlushToZero.mul scale (BFloat16.widen (Model.ofBits (HalfMemory.load memory (base+2*index)))))
  | _,_,_,_,_ => none

def keyCell : Cell → ByteMemory.Bytes → Nat → Nat → Option Float32
  | .key "j",memory,base,index => some (BFloat16.widen (Model.ofBits (HalfMemory.load memory (base+2*index))))
  | _,_,_,_ => none

def querySource (memory : ByteMemory.Bytes) (base : Nat) (transposed : Bool)
    (head : Fin 24) (lane : Fin 32) (item : Fin 8) (scale : Float32) : Option Float32 := do
  let pointers ←parsePointers sourcePointers
  if pointers=[queryPointer,keyPointer,valuePointer,outputPointer] then
    queryCell (←parseQuery sourceQuery) memory base (queryAddress transposed head lane item) scale
  else none

def keySource (memory : ByteMemory.Bytes) (base capacity : Nat) (head : Fin 24)
    (group lane : Fin 32) (iteration : Nat) (item : Fin 8) : Option Float32 := do
  let pointers ←parsePointers sourcePointers
  if pointers=[queryPointer,keyPointer,valuePointer,outputPointer] then
    keyCell (←parseKey sourceKey) memory base (keyAddress capacity head group lane iteration item)
  else none

theorem query_current (memory : ByteMemory.Bytes) (base : Nat) (transposed : Bool)
    (head : Fin 24) (thread : Fin 1024) (item : Fin 8) :
    querySource memory base transposed head (SdpaQueryMemory.lane thread) item SdpaScore.scale=
      some (FlushToZero.mul SdpaScore.scale (BFloat16.widen (Model.ofBits (SdpaQueryMemory.read base memory head thread item)))) := by
  unfold querySource
  rw [parsed_pointers]
  change queryCell (.query "i") memory base (queryAddress transposed head (SdpaQueryMemory.lane thread) item) SdpaScore.scale=_
  have same : base+2*queryAddress transposed head (SdpaQueryMemory.lane thread) item=(SdpaQueryMemory.layout base).base head+2*(SdpaLayout.coordinate (SdpaQueryMemory.lane thread) item).val := by
    rw [query_address,SdpaAddresses.query_address,SdpaQueryMemory.native_address]
    simp [SdpaScore.index,SdpaQueryMemory.lane,Nat.add_assoc]
  simp only [queryCell,same,SdpaQueryMemory.read]

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}

theorem key_current (input : SdpaMemory.Input query cache) (head : Fin 24) (group lane : Fin 32)
    (iteration : Fin (SdpaLayout.count steps group)) (item : Fin 8) :
    keySource input.cache.memory input.cache.layout.keyBase (KvAllocation.capacity steps) head group lane iteration.val item=
      some (BFloat16.widen (cache.keys (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item))) := by
  unfold keySource
  rw [parsed_pointers]
  change keyCell (.key "j") input.cache.memory input.cache.layout.keyBase (keyAddress (KvAllocation.capacity steps) head group lane iteration.val item)=_
  simp only [keyCell]
  rw [key_address,SdpaAddresses.kv_address]
  have attached := input.cache.keys (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item)
  exact congrArg (fun word : BitVec 16 => some (BFloat16.widen (Model.ofBits word))) attached

theorem key_storage (storage : KvRegions.Storage cache) (head : Fin 24) (group lane : Fin 32)
    (iteration : Fin (SdpaLayout.count steps group)) (item : Fin 8) :
    keySource storage.memory storage.layout.keyBase (KvAllocation.capacity steps) head group lane iteration.val item=
      some (BFloat16.widen (cache.keys (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item))) := by
  unfold keySource
  rw [parsed_pointers]
  change keyCell (.key "j") storage.memory storage.layout.keyBase (keyAddress (KvAllocation.capacity steps) head group lane iteration.val item)=_
  simp only [keyCell]
  rw [key_address,SdpaAddresses.kv_address]
  exact congrArg (fun word : BitVec 16 => some (BFloat16.widen (Model.ofBits word)))
    (storage.keys (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item))

-- This consumes the actual ReadBeforeOverwrite ownership invariant. Another
-- head may already have stored into the donated query allocation.
theorem captured_query (trace : SdpaQueryMemory.Trace base) (input : SdpaMemory.Input query cache)
    (initial : trace.before=input.cache.memory)
    (heads : ∀ head, (input.query head).base=(SdpaQueryMemory.layout base).base head)
    (head : Fin 24) (thread : Fin 1024) (registers : SdpaQueryMemory.Registers)
    (captured : trace.after.registers head thread=some registers) (item : Fin 8) :
    FlushToZero.mul SdpaScore.scale (BFloat16.widen (Model.ofBits (registers item)))=
      FlushToZero.mul SdpaScore.scale (BFloat16.widen (query head (SdpaLayout.coordinate (SdpaQueryMemory.lane thread) item))) := by
  rw [trace.captured head thread registers captured,initial,SdpaQueryMemory.input_read input base heads]
  rfl

end Inference.Kernels.Attention.MlxSdpaVectorMemory
