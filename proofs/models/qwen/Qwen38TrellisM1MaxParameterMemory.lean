import models.qwen.DecodeParameterMemory
import models.qwen.Qwen38TrellisM1MaxSamplingMemory

namespace Inference.Models.Qwen.Qwen38TrellisM1MaxParameterMemory
open Contracts.Mlx Layers Qwen38TrellisM1Max
set_option maxRecDepth 10000
attribute [local irreducible] Graph.stages

-- This bundle retains every layer's original parameter allocations, together
-- with final normalization and the vocabulary projection, on one heap.
structure Storage (graph : Graph) (memory : ByteMemory.Bytes) where
  stages : DecodeParameterMemory.Storage graph.stages memory
  norm : ArrayStorage.BFBuffer graph.finalNorm.weight
  normShared : norm.bytes=memory
  output : AffineDevice.Storage graph.output
  outputShared : AffineMemory.Shared graph.output output memory

variable {graph : Graph} {memory : ByteMemory.Bytes}

def Storage.Protected (s : Storage graph memory) (property : Nat → Nat → Prop) : Prop :=
  DecodeParameterMemory.Protected graph.stages s.stages property ∧
    property s.norm.base 10240 ∧ AffineMemoryFrames.Protected graph.output s.output property

theorem Storage.protected_mono (s : Storage graph memory) {first second : Nat → Nat → Prop}
    (implies : ∀ base size, first base size → second base size) (safe : s.Protected first) : s.Protected second :=
  ⟨DecodeParameterMemory.protected_mono graph.stages s.stages implies safe.1,
    implies _ _ safe.2.1,AffineMemoryFrames.protected_mono _ _ implies safe.2.2⟩

def Storage.reframe (s : Storage graph memory) (after : ByteMemory.Bytes)
    (same : s.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset))) : Storage graph after where
  stages := DecodeParameterMemory.reframe graph.stages s.stages after same.1
  norm := ArrayFrame.bf s.norm after (fun offset bound => (same.2.1 offset bound).trans (congrFun s.normShared _).symm)
  normShared := rfl
  output := AffineMemoryFrames.reframe graph.output s.output after (AffineMemoryFrames.stable _ _ _ _ s.outputShared same.2.2)
  outputShared := AffineMemoryFrames.reframe_shared _ _ _ _

theorem Storage.reframe_protected (s : Storage graph memory) (after : ByteMemory.Bytes)
    (same : s.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset)))
    (property : Nat → Nat → Prop) : (s.reframe after same).Protected property ↔ s.Protected property :=
  and_congr (DecodeParameterMemory.reframe_protected graph.stages s.stages after same.1 property)
    (and_congr Iff.rfl (AffineMemoryFrames.reframe_protected graph.output s.output after
      (AffineMemoryFrames.stable _ _ _ _ s.outputShared same.2.2) property))

def Storage.afterGraph (execution : Qwen38TrellisM1MaxMemory.Execution graph cache input angle)
    (s : Storage graph execution.source.bytes) (safe : s.Protected (Qwen38TrellisM1MaxMemory.Safe execution)) :
    Storage graph execution.logitsBuffer.bytes :=
  s.reframe _ (s.protected_mono (fun _ _ region => execution.other_region region) safe)

theorem Storage.afterGraph_protected (execution : Qwen38TrellisM1MaxMemory.Execution graph cache input angle)
    (s : Storage graph execution.source.bytes) (safe : s.Protected (Qwen38TrellisM1MaxMemory.Safe execution))
    (property : Nat → Nat → Prop) :
    (afterGraph execution s safe).Protected property ↔ s.Protected property := s.reframe_protected _ _ property

def Storage.afterSampling (execution : Qwen38TrellisM1MaxSamplingMemory.Execution graph cache input angle sampling)
    (s : Storage graph execution.forward.source.bytes)
    (safe : s.Protected (Qwen38TrellisM1MaxSamplingMemory.Safe execution)) : Storage graph execution.memory :=
  s.reframe _ (s.protected_mono (fun _ _ region => execution.other_region region) safe)

theorem Storage.afterSampling_protected (execution : Qwen38TrellisM1MaxSamplingMemory.Execution graph cache input angle sampling)
    (s : Storage graph execution.forward.source.bytes)
    (safe : s.Protected (Qwen38TrellisM1MaxSamplingMemory.Safe execution)) (property : Nat → Nat → Prop) :
    (afterSampling execution s safe).Protected property ↔ s.Protected property := s.reframe_protected _ _ property

-- The per-region result is an equality of the actual original and final
-- byte functions. No replacement checkpoint payload is supplied here.
theorem Storage.sampled_bytes (execution : Qwen38TrellisM1MaxSamplingMemory.Execution graph cache input angle sampling)
    (s : Storage graph execution.forward.source.bytes)
    (safe : s.Protected (Qwen38TrellisM1MaxSamplingMemory.Safe execution)) :
    s.Protected (fun base size => ∀ offset < size,
      execution.memory (base+offset)=execution.forward.source.bytes (base+offset)) :=
  s.protected_mono (fun _ _ region => execution.other_region region) safe

end Inference.Models.Qwen.Qwen38TrellisM1MaxParameterMemory
