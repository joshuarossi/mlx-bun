import models.qwen.Qwen38CapacityAttentionExecution
namespace Inference.Models.Qwen.Qwen38CapacityAttentionCache
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Qwen38TrellisM1Max
set_option maxRecDepth 10000
attribute [local irreducible] Graph.stages
variable {n : Nat} {graph : Graph} {cache : graph.Cache n} {input : Row BF} {angle : RopeAngles.Inputs}
  (execution : Qwen38CapacityAttentionExecution.Execution graph cache input angle)

def hiddenBuffer := CapacityAttentionDecodeChain.outputBuffer graph.stages cache input angle execution.source execution.storage execution.chain
def hiddenCache := CapacityAttentionDecodeChain.after graph.stages cache input angle execution.source execution.storage execution.chain execution.safe

def TailSafe (base size : Nat) : Prop :=
  MemoryRegions.Disjoint (2*execution.allocation.normBase) 10240 base size ∧
  MemoryRegions.Disjoint execution.allocation.outputBase 496640 base size

theorem tail_frame {base size : Nat} (safe : TailSafe execution base size) (offset : Nat) (bound : offset<size) :
    (Qwen38CapacityAttentionExecution.logitsBuffer execution).bytes (base+offset)=(hiddenBuffer execution).bytes (base+offset) := by
  rw [Qwen38CapacityAttentionExecution.logitsBuffer,Qwen38CapacityAttentionExecution.projection,hiddenBuffer]
  exact (FinalProjectionConstruction.other_region execution.finalParameters execution.allocation safe.1 safe.2 offset bound).trans
    (congrArg (fun buffer => buffer.bytes (base+offset)) execution.linked)

def Safe : Prop := DecodePreservation.Protected (TailSafe execution) graph.stages
  (DecodeChain.run graph.stages cache input angle).2 (hiddenBuffer execution).bytes (hiddenCache execution)

def after (safe : Safe execution) : DecodeFrame.Storage graph.stages (DecodeChain.run graph.stages cache input angle).2
    (Qwen38CapacityAttentionExecution.logitsBuffer execution).bytes :=
  DecodePreservation.reframe (TailSafe execution) (hiddenBuffer execution).bytes
    (Qwen38CapacityAttentionExecution.logitsBuffer execution).bytes (fun _ _ region => tail_frame execution region)
    graph.stages (DecodeChain.run graph.stages cache input angle).2 (hiddenCache execution) safe

def readResult (safe : Safe execution) : (Fin 248320 → BF) × graph.Cache (n+1) :=
  ⟨(Qwen38CapacityAttentionExecution.logitsBuffer execution).read,
    DecodeFrameRead.caches graph.stages (DecodeChain.run graph.stages cache input angle).2
      (Qwen38CapacityAttentionExecution.logitsBuffer execution).bytes (after execution safe)⟩

theorem read_result_eq (safe : Safe execution) : readResult execution safe=
    (graph.forward cache input angle,(DecodeChain.run graph.stages cache input angle).2) :=
  Prod.ext (funext (Qwen38CapacityAttentionExecution.read_eq execution)) (DecodeFrameRead.caches_eq _ _ _ _)

theorem parsed_result (safe : Safe execution)
    (native : CapacityAttentionChainParsed.Native graph.stages cache input angle execution.source execution.storage execution.chain) :
    CapacityAttentionChainParsed.Parsed graph.stages cache input angle execution.source execution.storage execution.chain native ∧
    readResult execution safe=(graph.forward cache input angle,(DecodeChain.run graph.stages cache input angle).2) :=
  ⟨CapacityAttentionChainParsed.checked graph.stages cache input angle execution.source execution.storage execution.chain native,
    read_result_eq execution safe⟩
end Inference.Models.Qwen.Qwen38CapacityAttentionCache
