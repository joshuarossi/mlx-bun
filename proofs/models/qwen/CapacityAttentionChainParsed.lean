import models.qwen.CapacityAttentionDecodeChain
import models.qwen.CapacityAttentionStageParsed
namespace Inference.Models.Qwen.CapacityAttentionChainParsed
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
set_option maxRecDepth 10000
variable {n : Nat}

def Native : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    CapacityAttentionDecodeChain.Trace stages cache input angle source storage → Type
  | [], _, _, _, _, _, _ => PUnit
  | kind::rest, cache, input, angle, _, _, trace =>
    CapacityAttentionStageParsed.Native kind cache.1 input angle trace.1.first.execution ×
    Native rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2

def Parsed : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (trace : CapacityAttentionDecodeChain.Trace stages cache input angle source storage) →
    Native stages cache input angle source storage trace → Prop
  | [], _, _, _, _, _, _, _ => True
  | kind::rest, cache, input, angle, _, _, trace, native =>
    CapacityAttentionStageParsed.Parsed kind cache.1 input angle trace.1.first.execution native.1 ∧
    Parsed rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 native.2

theorem checked : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (trace : CapacityAttentionDecodeChain.Trace stages cache input angle source storage) →
    (native : Native stages cache input angle source storage trace) → Parsed stages cache input angle source storage trace native
  | [], _, _, _, _, _, _, _ => True.intro
  | kind::rest, cache, input, angle, _, _, trace, native =>
    ⟨CapacityAttentionStageParsed.checked kind cache.1 input angle trace.1.first.execution native.1,
      checked rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 native.2⟩
end Inference.Models.Qwen.CapacityAttentionChainParsed
