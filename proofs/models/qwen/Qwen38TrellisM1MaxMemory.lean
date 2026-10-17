import models.qwen.DecodeMemoryChain
import models.qwen.Qwen38TrellisM1Max
import layers.AffineMemoryFrames

namespace Inference.Models.Qwen.Qwen38TrellisM1MaxMemory
open Contracts.Mlx Qwen38TrellisM1Max DecodeStage Kernels.Attention
set_option maxRecDepth 10000
attribute [local irreducible] Graph.stages

structure Execution (graph : Graph) (cache : graph.Cache n) (input : Row BF) (angle : RopeAngles.Inputs) where
  source : ArrayStorage.BFBuffer input
  storage : DecodeFrame.Storage graph.stages cache source.bytes
  chain : DecodeMemoryChain.Trace graph.stages cache input angle source storage
  chainSafe : DecodeMemoryChain.CacheSafe graph.stages cache input angle source storage chain
  normInput : BinaryMemory.Input (graph.hidden cache input angle) graph.finalNorm.weight
  normLinked : normInput.lhs=DecodeMemoryChain.outputBuffer graph.stages cache input angle source storage chain
  normalization : NormalizationMemory.Execution graph.finalNorm normInput
  projection : Layers.AffineMemory.Execution (groups := 62080) graph.output (graph.normalized cache input angle)
  projectionLinked : projection.source=NormalizationMemory.forwardBuffer normalization

variable {graph : Graph} {cache : graph.Cache n} {input : Row BF} {angle : RopeAngles.Inputs}

def Execution.hiddenBuffer (execution : Execution graph cache input angle) :
    ArrayStorage.BFBuffer (graph.hidden cache input angle) :=
  DecodeMemoryChain.outputBuffer graph.stages cache input angle execution.source execution.storage execution.chain

theorem Execution.hidden_bytes (execution : Execution graph cache input angle) :
    execution.hiddenBuffer.bytes=
      (DecodeMemoryChain.outputBuffer graph.stages cache input angle execution.source execution.storage execution.chain).bytes := rfl

def Execution.chainCache (execution : Execution graph cache input angle) :
    DecodeFrame.Storage graph.stages (DecodeChain.run graph.stages cache input angle).2 execution.hiddenBuffer.bytes :=
  DecodeMemoryChain.after graph.stages cache input angle execution.source execution.storage execution.chain execution.chainSafe

def Execution.logits (execution : Execution graph cache input angle) : Fin 248320 → BF := execution.projection.output

def Execution.logitsBuffer (execution : Execution graph cache input angle) : ArrayStorage.BFBuffer execution.logits :=
  execution.projection.outputBuffer

theorem Execution.logits_eq (execution : Execution graph cache input angle) :
    execution.logits=graph.forward cache input angle := execution.projection.output_eq

def TailSafe (execution : Execution graph cache input angle) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint (2*execution.normalization.normalized.base) 10240 base size ∧
  MemoryRegions.Disjoint execution.projection.base 496640 base size

theorem Execution.tail_frame (execution : Execution graph cache input angle) {base size : Nat}
    (safe : TailSafe execution base size) (offset : Nat) (bound : offset<size) :
    execution.logitsBuffer.bytes (base+offset)=execution.hiddenBuffer.bytes (base+offset) := by
  have projectionShared : execution.projection.source.bytes=execution.normalization.outputBuffer.bytes :=
    (congrArg ArrayStorage.BFBuffer.bytes execution.projectionLinked).trans
      (NormalizationMemory.forward_bytes execution.normalization)
  have normShared : execution.normInput.lhs.bytes=execution.hiddenBuffer.bytes :=
    congrArg ArrayStorage.BFBuffer.bytes execution.normLinked
  exact (execution.projection.other_region safe.2 offset bound).trans
    ((congrFun projectionShared _).trans ((execution.normalization.other_region safe.1 offset bound).trans
      (congrFun normShared _)))

def CacheSafe (execution : Execution graph cache input angle) : Prop :=
  DecodePreservation.Protected (TailSafe execution) graph.stages (DecodeChain.run graph.stages cache input angle).2
    execution.hiddenBuffer.bytes execution.chainCache

def Execution.afterCache (execution : Execution graph cache input angle) (safe : CacheSafe execution) :
    DecodeFrame.Storage graph.stages (DecodeChain.run graph.stages cache input angle).2 execution.logitsBuffer.bytes :=
  DecodePreservation.reframe (TailSafe execution) execution.hiddenBuffer.bytes execution.logitsBuffer.bytes
    (fun _ _ region => execution.tail_frame region) graph.stages (DecodeChain.run graph.stages cache input angle).2
    execution.chainCache safe

def Execution.readResult (execution : Execution graph cache input angle) (safe : CacheSafe execution) :
    (Fin 248320 → BF) × graph.Cache (n+1) :=
  ⟨execution.logitsBuffer.read, DecodeFrameRead.caches graph.stages (DecodeChain.run graph.stages cache input angle).2
    execution.logitsBuffer.bytes (execution.afterCache safe)⟩

theorem Execution.read_result_eq (execution : Execution graph cache input angle) (safe : CacheSafe execution) :
    execution.readResult safe=(graph.forward cache input angle, (DecodeChain.run graph.stages cache input angle).2) := by
  apply Prod.ext
  · exact (funext execution.logitsBuffer.read_correct).trans execution.logits_eq
  · exact DecodeFrameRead.caches_eq _ _ _ _

structure Safe (execution : Execution graph cache input angle) (base size : Nat) : Prop where
  chain : DecodeMemoryChain.Safe graph.stages cache input angle execution.source execution.storage execution.chain base size
  tail : TailSafe execution base size

theorem Execution.chain_frame (execution : Execution graph cache input angle) {base size : Nat}
    (safe : DecodeMemoryChain.Safe graph.stages cache input angle execution.source execution.storage execution.chain base size)
    (offset : Nat) (bound : offset<size) :
    execution.hiddenBuffer.bytes (base+offset)=execution.source.bytes (base+offset) :=
  (congrFun execution.hidden_bytes _).trans
    (DecodeMemoryChain.other_region graph.stages cache input angle execution.source execution.storage execution.chain
      base size safe offset bound)

attribute [local irreducible] Execution.hiddenBuffer

theorem Execution.other_region (execution : Execution graph cache input angle) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.logitsBuffer.bytes (base+offset)=execution.source.bytes (base+offset) :=
  (execution.tail_frame safe.tail offset bound).trans
    (execution.chain_frame safe.chain offset bound)

end Inference.Models.Qwen.Qwen38TrellisM1MaxMemory
