import kernels.attention.MlxSdpaTwoPassSyntax
import kernels.attention.SdpaTwoPassShared

namespace Inference.Kernels.Attention.MlxSdpaTwoPassMemory
open Contracts.Mlx State MlxSdpaTwoPassSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

def head (kv : Fin 4) (query : Fin 6) : Fin 24 := ⟨6*kv.val+query.val,by have := kv.isLt; have := query.isLt; omega⟩
theorem kv_head (kv : Fin 4) (query : Fin 6) : SdpaScore.kvHead (head kv query)=kv := by
  apply Fin.ext
  dsimp [head,SdpaScore.kvHead]
  have := query.isLt
  omega

def environment (capacity blocks : Nat) (head : Fin 24) (block : Fin blocks) (lane : Fin 32) : String → Nat
  | "q_offset" | "o_offset" => head.val
  | "kv_batch_head_idx" => head.val/6
  | "D" | "V" => 256
  | "qk_per_thread" | "v_per_thread" => 8
  | "k_head_stride" | "v_head_stride" => capacity*256
  | "k_seq_stride" | "v_seq_stride" => 256
  | "simd_lid" => lane.val
  | "block_idx" => block.val
  | "blocks" => blocks
  | _ => 0

def keyAddress (capacity blocks : Nat) (head : Fin 24) (block : Fin blocks) (lane : Fin 32) (iteration : Nat) (item : Fin 8) : Nat :=
  MlxSdpaVectorSyntax.eval (environment capacity blocks head block lane) keyPointer.offset+iteration*(blocks*256)+item.val

def valueAddress (capacity blocks : Nat) (head : Fin 24) (block : Fin blocks) (lane : Fin 32) (iteration : Nat) (item : Fin 8) : Nat :=
  MlxSdpaVectorSyntax.eval (environment capacity blocks head block lane) valuePointer.offset+iteration*(blocks*256)+item.val

def outputAddress (blocks : Nat) (head : Fin 24) (block : Fin blocks) (lane : Fin 32) (item : Fin 8) : Nat :=
  MlxSdpaVectorSyntax.eval (environment 0 blocks head block lane) outputPointer.offset+item.val

theorem key_address (capacity blocks : Nat) (head : Fin 24) (block : Fin blocks) (lane : Fin 32) (iteration : Nat) (item : Fin 8) :
    keyAddress capacity blocks head block lane iteration item=
      Kv.address capacity (SdpaScore.kvHead head) (block.val+blocks*iteration) (SdpaScore.index lane item) := by
  simp only [keyAddress,environment,keyPointer,MlxSdpaVectorSyntax.eval,Kv.address,SdpaScore.kvHead,SdpaScore.index]
  ring

theorem value_address (capacity blocks : Nat) (head : Fin 24) (block : Fin blocks) (lane : Fin 32) (iteration : Nat) (item : Fin 8) :
    valueAddress capacity blocks head block lane iteration item=
      Kv.address capacity (SdpaScore.kvHead head) (block.val+blocks*iteration) (SdpaScore.index lane item) := by
  simp only [valueAddress,environment,valuePointer,MlxSdpaVectorSyntax.eval,Kv.address,SdpaScore.kvHead,SdpaScore.index]
  ring

theorem output_address (blocks : Nat) (head : Fin 24) (block : Fin blocks) (lane : Fin 32) (item : Fin 8) :
    outputAddress blocks head block lane item=SdpaTwoPassLayout.partialAddress blocks head block (SdpaScore.index lane item) := by
  simp only [outputAddress,environment,outputPointer,MlxSdpaVectorSyntax.eval,SdpaTwoPassLayout.partialAddress,SdpaTwoPassLayout.summaryAddress,SdpaScore.index]
  ring

theorem summary_address (blocks : Nat) (head : Fin 24) (block : Fin blocks) (lane : Fin 32) :
    MlxSdpaVectorSyntax.eval (environment 0 blocks head block lane) sumPointer.offset=
      SdpaTwoPassLayout.summaryAddress blocks head block := rfl

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}

def queryRegisters (input : SdpaMemory.Input query cache) (head : Fin 24) (lane : Fin 32) : SdpaQueryMemory.Registers :=
  fun item => HalfMemory.load input.cache.memory ((input.query head).base+2*(SdpaScore.index lane item).val)

theorem query_registers (input : SdpaMemory.Input query cache) (head : Fin 24) (lane : Fin 32) (item : Fin 8) :
    queryRegisters input head lane item=ArrayStorage.bits (query head (SdpaScore.index lane item)) := by
  unfold queryRegisters
  rw [←input.shared head]
  exact (input.query head).attached _

def keyValue (memory : ByteMemory.Bytes) (base capacity blocks : Nat) (head : Fin 24)
    (block : Fin blocks) (lane : Fin 32) (iteration : Nat) (item : Fin 8) : Float32 :=
  BFloat16.widen (Model.ofBits (HalfMemory.load memory (base+2*keyAddress capacity blocks head block lane iteration item)))

def value (memory : ByteMemory.Bytes) (base capacity blocks : Nat) (head : Fin 24)
    (block : Fin blocks) (lane : Fin 32) (iteration : Nat) (item : Fin 8) : Float32 :=
  BFloat16.widen (Model.ofBits (HalfMemory.load memory (base+2*valueAddress capacity blocks head block lane iteration item)))

theorem key_value (input : SdpaMemory.Input query cache) (head : Fin 24) (block : Fin blocks) (lane : Fin 32)
    (iteration : Fin (SdpaTwoPassLayout.count steps blocks block)) (item : Fin 8) :
    keyValue input.cache.memory input.cache.layout.keyBase (KvAllocation.capacity steps) blocks head block lane iteration.val item=
      BFloat16.widen (cache.keys (SdpaScore.kvHead head) (SdpaTwoPassLayout.key steps blocks block iteration) (SdpaScore.index lane item)) := by
  unfold keyValue
  rw [key_address]
  exact congrArg (fun word : BitVec 16 => BFloat16.widen (Model.ofBits word))
    (input.cache.keys (SdpaScore.kvHead head) (SdpaTwoPassLayout.key steps blocks block iteration) (SdpaScore.index lane item))

theorem value_current (input : SdpaMemory.Input query cache) (head : Fin 24) (block : Fin blocks) (lane : Fin 32)
    (iteration : Fin (SdpaTwoPassLayout.count steps blocks block)) (item : Fin 8) :
    value input.cache.memory input.cache.layout.valueBase (KvAllocation.capacity steps) blocks head block lane iteration.val item=
      BFloat16.widen (cache.values (SdpaScore.kvHead head) (SdpaTwoPassLayout.key steps blocks block iteration) (SdpaScore.index lane item)) := by
  unfold value
  rw [value_address]
  exact congrArg (fun word : BitVec 16 => BFloat16.widen (Model.ofBits word))
    (input.cache.values (SdpaScore.kvHead head) (SdpaTwoPassLayout.key steps blocks block iteration) (SdpaScore.index lane item))

theorem key_device_address (input : SdpaMemory.Input query cache) (head : Fin 24) (block : Fin blocks) (lane : Fin 32)
    (iteration : Fin (SdpaTwoPassLayout.count steps blocks block)) (item : Fin 8) :
    input.cache.layout.keyBase+2*keyAddress (KvAllocation.capacity steps) blocks head block lane iteration.val item+2≤2^64 := by
  rw [key_address]
  have inside := KvRegions.active_bounds (SdpaScore.kvHead head)
    (SdpaTwoPassLayout.key steps blocks block iteration) (SdpaScore.index lane item)
  simp only [SdpaTwoPassLayout.key] at inside
  have bounded := input.cache.layout.keyBound
  omega

theorem partial_signed_address (blocks : Nat) (bound : blocks≤1024) (head : Fin 24) (block : Fin blocks)
    (lane : Fin 32) (item : Fin 8) : outputAddress blocks head block lane item<2^31 := by
  rw [output_address]
  have inside := SdpaTwoPassLayout.partial_bounds blocks head block (SdpaScore.index lane item)
  omega

def scoreSource (p : SdpaVector.Platform) (input : SdpaMemory.Input query cache)
    (head : Fin 24) (block : Fin blocks) (iteration : Nat) : Option Float32 := do
  let ps ←parsePointers sourcePointers
  if ps=pointers then
    let dot ←parseDot sourceDot
    pure (p.merge.reduce (fun lane => MlxSdpaScoreSource.laneValue dot p.scoreContracted (queryRegisters input head lane)
      (keyValue input.cache.memory input.cache.layout.keyBase (KvAllocation.capacity steps) blocks head block lane iteration)))
  else none

theorem current_score (p : SdpaVector.Platform) (input : SdpaMemory.Input query cache) (head : Fin 24) (block : Fin blocks)
    (iteration : Fin (SdpaTwoPassLayout.count steps blocks block)) :
    scoreSource p input head block iteration.val=
      some (SdpaVector.scores p (query head) (cache.keys (SdpaScore.kvHead head)) (SdpaTwoPassLayout.key steps blocks block iteration)) := by
  unfold scoreSource
  rw [parsed_pointers]
  change (do let dot ←parseDot sourceDot; pure (p.merge.reduce (fun lane => MlxSdpaScoreSource.laneValue dot p.scoreContracted
    (queryRegisters input head lane) (keyValue input.cache.memory input.cache.layout.keyBase (KvAllocation.capacity steps) blocks head block lane iteration.val))))=_
  rw [parsed_dot]
  change some (p.merge.reduce (fun lane => MlxSdpaScoreSource.laneValue ⟨0,0⟩ p.scoreContracted
    (queryRegisters input head lane) (keyValue input.cache.memory input.cache.layout.keyBase (KvAllocation.capacity steps) blocks head block lane iteration.val)))=_
  unfold SdpaVector.scores SdpaScore.source
  apply congrArg some
  apply congrArg p.merge.reduce
  funext lane
  unfold MlxSdpaScoreSource.laneValue
  simp only [List.drop_zero,↓reduceIte]
  have same : (fun acc item => ArithmeticFold.maddFloat p.scoreContracted
      (FlushToZero.mul SdpaScore.scale (BFloat16.widen (Model.ofBits (queryRegisters input head lane item))))
      (keyValue input.cache.memory input.cache.layout.keyBase (KvAllocation.capacity steps) blocks head block lane iteration.val item) acc)=
      (fun acc item => ArithmeticFold.maddFloat p.scoreContracted
        (FlushToZero.mul SdpaScore.scale (BFloat16.widen (query head (SdpaScore.index lane item))))
        (BFloat16.widen (cache.keys (SdpaScore.kvHead head) (SdpaTwoPassLayout.key steps blocks block iteration) (SdpaScore.index lane item))) acc) := by
    funext acc item
    rw [query_registers,key_value input head block lane iteration item]
    rfl
  rw [same]

end Inference.Kernels.Attention.MlxSdpaTwoPassMemory
