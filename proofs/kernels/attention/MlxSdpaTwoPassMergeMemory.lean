import kernels.attention.MlxSdpaTwoPassMergeSyntax

namespace Inference.Kernels.Attention.MlxSdpaTwoPassMergeMemory
open Contracts.Mlx State MlxSdpaTwoPassMergeSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

def environment (blocks : Nat) (head : Fin 24) (group lane : Fin 32) : String → Nat
  | "q_offset" => head.val
  | "D" => 256
  | "elem_per_thread" => 8
  | "simd_gid" => group.val
  | "simd_lid" => lane.val
  | "blocks" => blocks
  | _ => 0

def summaryAddress (blocks : Nat) (head : Fin 24) (lane : Fin 32) (iteration : Nat) : Nat :=
  MlxSdpaVectorSyntax.eval (environment blocks head 0 lane) sumPointer.offset+lane.val+32*iteration

def partialAddress (blocks : Nat) (head : Fin 24) (group lane : Fin 32) (iteration : Nat) (item : Fin 8) : Nat :=
  MlxSdpaVectorSyntax.eval (environment blocks head group lane) partialPointer.offset+iteration*(32*256)+item.val

def outputAddress (blocks : Nat) (head : Fin 24) (group : Fin 32) (item : Fin 8) : Nat :=
  MlxSdpaVectorSyntax.eval (environment blocks head group 0) outputPointer.offset+item.val

theorem summary_address (complete : blocks%32=0) (head : Fin 24) (lane : Fin 32) (iteration : Fin (blocks/32)) :
    summaryAddress blocks head lane iteration.val=
      SdpaTwoPassLayout.summaryAddress blocks head (SdpaTwoPassExecution.blockIndex complete lane iteration) := by
  simp only [summaryAddress,sumPointer,environment,MlxSdpaVectorSyntax.eval]
  exact SdpaTwoPassExecution.summary_address complete head lane iteration

theorem partial_address (complete : blocks%32=0) (head : Fin 24) (group lane : Fin 32) (iteration : Fin (blocks/32)) (item : Fin 8) :
    partialAddress blocks head group lane iteration.val item=
      SdpaTwoPassLayout.partialAddress blocks head (SdpaTwoPassExecution.blockIndex complete group iteration) (SdpaLayout.coordinate lane item) := by
  simp only [partialAddress,partialPointer,environment,MlxSdpaVectorSyntax.eval]
  exact SdpaTwoPassExecution.partial_address complete head group lane iteration item

theorem output_address (blocks : Nat) (head : Fin 24) (group : Fin 32) (item : Fin 8) :
    outputAddress blocks head group item=SdpaAddresses.outputAddress head group item := by
  simp [outputAddress,outputPointer,environment,MlxSdpaVectorSyntax.eval,SdpaAddresses.outputAddress]

theorem map_chunks (complete : blocks%32=0) (lane : Fin 32) :
    (List.finRange (blocks/32)).map (SdpaTwoPassExecution.blockIndex complete lane)=SdpaTwoPassExecution.sourceKeys complete lane := by
  change (List.ofFn id).map _=_
  rw [List.map_ofFn]
  rfl

theorem fold_chunks (complete : blocks%32=0) (lane : Fin 32) (f : α → Fin blocks → α) (initial : α) :
    (List.finRange (blocks/32)).foldl (fun acc iteration => f acc (SdpaTwoPassExecution.blockIndex complete lane iteration)) initial=
      (SdpaTwoPassExecution.sourceKeys complete lane).foldl f initial := by
  rw [←map_chunks complete lane,List.foldl_map]

variable {steps blocks : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF}
  {cache : Kv.Cache Kv.BF steps} {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform}

def maxValue (execution : SdpaTwoPassShared.Execution input p blocks) (head : Fin 24) (lane : Fin 32) (iteration : Nat) : Float32 :=
  FloatMemory.load execution.first.memory (execution.first.trace.maxBase+4*summaryAddress blocks head lane iteration)

def sumValue (execution : SdpaTwoPassShared.Execution input p blocks) (head : Fin 24) (lane : Fin 32) (iteration : Nat) : Float32 :=
  FloatMemory.load execution.first.memory (execution.first.trace.sumBase+4*summaryAddress blocks head lane iteration)

def partialValue (execution : SdpaTwoPassShared.Execution input p blocks) (head : Fin 24) (group lane : Fin 32)
    (iteration : Nat) (item : Fin 8) : Float32 :=
  BFloat16.widen (Model.ofBits (HalfMemory.load execution.first.memory
    (execution.first.trace.outputBase+2*partialAddress blocks head group lane iteration item)))

theorem max_current (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (head : Fin 24) (lane : Fin 32) (iteration : Fin (blocks/32)) :
    maxValue execution head lane iteration.val=
      (execution.first.readState head (SdpaTwoPassExecution.blockIndex complete lane iteration) 0).shift := by
  unfold maxValue
  rw [summary_address complete]
  rfl

theorem sum_current (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (head : Fin 24) (lane : Fin 32) (iteration : Fin (blocks/32)) :
    sumValue execution head lane iteration.val=
      (execution.first.readState head (SdpaTwoPassExecution.blockIndex complete lane iteration) 0).denominator := by
  unfold sumValue
  rw [summary_address complete]
  rfl

theorem partial_current (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (head : Fin 24) (group lane : Fin 32) (iteration : Fin (blocks/32)) (item : Fin 8) :
    partialValue execution head group lane iteration.val item=
      (execution.first.readState head (SdpaTwoPassExecution.blockIndex complete group iteration) (SdpaLayout.coordinate lane item)).numerator := by
  unfold partialValue
  rw [partial_address complete]
  rfl

-- The floor-divided source counter covers exactly these block IDs only with
-- the host's multiple-of-32 contract; no incomplete tail is silently admitted.
theorem chunk_counter (blocks : Nat) (bound : blocks≤1024) : blocks/32<2^31 := by omega

end Inference.Kernels.Attention.MlxSdpaTwoPassMergeMemory
