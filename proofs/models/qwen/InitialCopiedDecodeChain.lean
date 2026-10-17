import models.qwen.InitialCopiedDecodeStage
import models.qwen.DecodeFrameRead

namespace Inference.Models.Qwen.InitialCopiedDecodeChain
open Contracts.Mlx DecodeStage DecodeChain Kernels.Attention
set_option maxRecDepth 10000

structure Step (stage : Stage) (rest : List Stage) (cache : Caches (stage::rest) 0)
    (input : Row BF) (angle : RopeAngles.Inputs) (source : ArrayStorage.BFBuffer input)
    (storage : DecodeFrame.Storage (stage::rest) cache source.bytes) where
  first : InitialCopiedDecodeStage.Trace stage cache.1 input angle source storage.1
  retainedSafe : DecodePreservation.Protected first.Safe rest cache.2 source.bytes storage.2

def Step.nextStorage (step : Step stage rest cache input angle source storage) :
    DecodeFrame.Storage rest cache.2 step.first.buffer.bytes :=
  step.first.retained rest cache.2 storage.2 step.retainedSafe

-- Each layer sees all untouched caches reframed onto its predecessor's heap.
-- Initial cache attachment and exact activation handoff are retained by type.
def Trace : (stages : List Stage) → (cache : Caches stages 0) → (input : Row BF) → RopeAngles.Inputs →
    (source : ArrayStorage.BFBuffer input) → DecodeFrame.Storage stages cache source.bytes → Type
  | [], _, _, _, _, _ => PUnit
  | stage::rest, cache, input, angle, source, storage =>
    (step : Step stage rest cache input angle source storage) ×
      Trace rest cache.2 (forward stage cache.1 input angle) angle step.first.buffer step.nextStorage

def outputBuffer : (stages : List Stage) → (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    Trace stages cache input angle source storage → ArrayStorage.BFBuffer (DecodeChain.run stages cache input angle).1
  | [], _, _, _, source, _, _ => source
  | stage::rest, cache, input, angle, _, _, trace =>
    outputBuffer rest cache.2 (forward stage cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2

def Safe : (stages : List Stage) → (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    Trace stages cache input angle source storage → Nat → Nat → Prop
  | [], _, _, _, _, _, _, _, _ => True
  | stage::rest, cache, input, angle, _, _, trace, base, size =>
    trace.1.first.Safe base size ∧
      Safe rest cache.2 (forward stage cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 base size

theorem other_region : (stages : List Stage) → (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (trace : Trace stages cache input angle source storage) → (base size : Nat) →
    Safe stages cache input angle source storage trace base size → (offset : Nat) → offset<size →
    (outputBuffer stages cache input angle source storage trace).bytes (base+offset)=source.bytes (base+offset)
  | [], _, _, _, _, _, _, _, _, _, _, _ => rfl
  | stage::rest, cache, input, angle, _, _, trace, base, size, safe, offset, bound =>
    (other_region rest cache.2 (forward stage cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage
      trace.2 base size safe.2 offset bound).trans (trace.1.first.other_region safe.1 offset bound)

-- Newly updated caches must also survive every later layer. These conditions
-- concern regions only; the cache values are derived from the executions.
def CacheSafe : (stages : List Stage) → (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    Trace stages cache input angle source storage → Prop
  | [], _, _, _, _, _, _ => True
  | stage::rest, cache, input, angle, _, _, trace =>
    DecodePreservation.StageProtected
      (Safe rest cache.2 (forward stage cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2)
      stage (cacheAfter stage cache.1 input angle) trace.1.first.cacheAfter.storage ∧
    CacheSafe rest cache.2 (forward stage cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2

def after : (stages : List Stage) → (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (trace : Trace stages cache input angle source storage) → CacheSafe stages cache input angle source storage trace →
    DecodeFrame.Storage stages (DecodeChain.run stages cache input angle).2
      (outputBuffer stages cache input angle source storage trace).bytes
  | [], _, _, _, _, _, _, _ => ⟨⟩
  | stage::rest, cache, input, angle, _, _, trace, safe =>
    ⟨DecodePreservation.stageReframe
      (Safe rest cache.2 (forward stage cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2)
      trace.1.first.buffer.bytes
      (outputBuffer rest cache.2 (forward stage cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2).bytes
      (fun base size region => other_region rest cache.2 (forward stage cache.1 input angle) angle
        trace.1.first.buffer trace.1.nextStorage trace.2 base size region)
      stage (cacheAfter stage cache.1 input angle) trace.1.first.cacheAfter safe.1,
    after rest cache.2 (forward stage cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 safe.2⟩

theorem output_read (stages : List Stage) (cache : Caches stages 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage stages cache source.bytes)
    (trace : Trace stages cache input angle source storage) (i : Fin 5120) :
    (outputBuffer stages cache input angle source storage trace).read i=(DecodeChain.run stages cache input angle).1 i :=
  ArrayStorage.BFBuffer.read_correct _ _

def readResult (stages : List Stage) (cache : Caches stages 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage stages cache source.bytes)
    (trace : Trace stages cache input angle source storage) (safe : CacheSafe stages cache input angle source storage trace) :
    Row BF × Caches stages (0+1) :=
  ⟨(outputBuffer stages cache input angle source storage trace).read,
    DecodeFrameRead.caches stages (DecodeChain.run stages cache input angle).2
      (outputBuffer stages cache input angle source storage trace).bytes
      (after stages cache input angle source storage trace safe)⟩

-- Both the final activation and every cache are read from the one final heap.
theorem read_result_eq (stages : List Stage) (cache : Caches stages 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage stages cache source.bytes)
    (trace : Trace stages cache input angle source storage) (safe : CacheSafe stages cache input angle source storage trace) :
    readResult stages cache input angle source storage trace safe=DecodeChain.run stages cache input angle :=
  Prod.ext (funext (output_read stages cache input angle source storage trace)) (DecodeFrameRead.caches_eq _ _ _ _)

def retained {tokens : Nat} (stages : List Stage) (cache : Caches stages 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage stages cache source.bytes)
    (trace : Trace stages cache input angle source storage)
    (otherStages : List Stage) (otherCaches : Caches otherStages tokens)
    (otherStorage : DecodeFrame.Storage otherStages otherCaches source.bytes)
    (safe : DecodePreservation.Protected (Safe stages cache input angle source storage trace)
      otherStages otherCaches source.bytes otherStorage) :
    DecodeFrame.Storage otherStages otherCaches (outputBuffer stages cache input angle source storage trace).bytes :=
  DecodePreservation.reframe (Safe stages cache input angle source storage trace) source.bytes
    (outputBuffer stages cache input angle source storage trace).bytes
    (fun base size region => other_region stages cache input angle source storage trace base size region)
    otherStages otherCaches otherStorage safe

end Inference.Models.Qwen.InitialCopiedDecodeChain
