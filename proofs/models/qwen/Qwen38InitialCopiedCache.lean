import models.qwen.Qwen38InitialCopiedExecution
namespace Inference.Models.Qwen.Qwen38InitialCopiedCache
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Qwen38TrellisM1Max
set_option maxRecDepth 10000
attribute [local irreducible] Graph.stages
variable {graph : Graph} {cache : graph.Cache 0} {input : Row BF} {angle : RopeAngles.Inputs}
  (execution : Qwen38InitialCopiedExecution.Execution graph cache input angle)

def hiddenBuffer := InitialCopiedDecodeChain.outputBuffer graph.stages cache input angle execution.source execution.storage execution.chain
def hiddenCache := InitialCopiedDecodeChain.after graph.stages cache input angle execution.source execution.storage execution.chain execution.safe

def TailSafe (base size : Nat) : Prop :=
  MemoryRegions.Disjoint (2*execution.allocation.normBase) 10240 base size ∧
  MemoryRegions.Disjoint execution.allocation.outputBase 496640 base size

theorem tail_frame {base size : Nat} (safe : TailSafe execution base size) (offset : Nat) (bound : offset<size) :
    (Qwen38InitialCopiedExecution.logitsBuffer execution).bytes (base+offset)=(hiddenBuffer execution).bytes (base+offset) := by
  rw [Qwen38InitialCopiedExecution.logitsBuffer,Qwen38InitialCopiedExecution.projection,hiddenBuffer]
  exact (FinalProjectionConstruction.other_region execution.finalParameters execution.allocation safe.1 safe.2 offset bound).trans
    (congrArg (fun buffer => buffer.bytes (base+offset)) execution.linked)

def Safe : Prop := DecodePreservation.Protected (TailSafe execution) graph.stages
  (DecodeChain.run graph.stages cache input angle).2 (hiddenBuffer execution).bytes (hiddenCache execution)

def after (safe : Safe execution) : DecodeFrame.Storage graph.stages (DecodeChain.run graph.stages cache input angle).2
    (Qwen38InitialCopiedExecution.logitsBuffer execution).bytes :=
  DecodePreservation.reframe (TailSafe execution) (hiddenBuffer execution).bytes
    (Qwen38InitialCopiedExecution.logitsBuffer execution).bytes (fun _ _ region => tail_frame execution region)
    graph.stages (DecodeChain.run graph.stages cache input angle).2 (hiddenCache execution) safe

def readResult (safe : Safe execution) : (Fin 248320 → BF) × graph.Cache 1 :=
  ⟨(Qwen38InitialCopiedExecution.logitsBuffer execution).read,
    DecodeFrameRead.caches graph.stages (DecodeChain.run graph.stages cache input angle).2
      (Qwen38InitialCopiedExecution.logitsBuffer execution).bytes (after execution safe)⟩

theorem read_result_eq (safe : Safe execution) : readResult execution safe=
    (graph.forward cache input angle,(DecodeChain.run graph.stages cache input angle).2) :=
  Prod.ext (funext (Qwen38InitialCopiedExecution.read_eq execution)) (DecodeFrameRead.caches_eq _ _ _ _)

theorem parsed_result (safe : Safe execution)
    (native : InitialCopiedChainParsed.Native graph.stages cache input angle execution.source execution.storage execution.chain) :
    InitialCopiedChainParsed.Parsed graph.stages cache input angle execution.source execution.storage execution.chain native ∧
    readResult execution safe=(graph.forward cache input angle,(DecodeChain.run graph.stages cache input angle).2) :=
  ⟨InitialCopiedChainParsed.checked graph.stages cache input angle execution.source execution.storage execution.chain native,
    read_result_eq execution safe⟩
end Inference.Models.Qwen.Qwen38InitialCopiedCache
