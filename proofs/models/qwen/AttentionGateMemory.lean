import kernels.attention.OutputGateMemory
import kernels.attention.SdpaTwoPassCompletion
import kernels.attention.SdpaTwoPassDonation
import kernels.attention.SdpaOnePassDonation

namespace Inference.Models.Qwen.AttentionGateMemory
open Contracts.Mlx Kernels.Attention State
set_option maxRecDepth 10000
attribute [local irreducible] SdpaOutput.programs

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  {gate : OutputGateDevice.Heads}

def gateAfterOutput (output : SdpaOutputMemory.Execution input p contracted arch)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (shared : ∀ head, (gates head).bytes=input.cache.memory)
    (separate : ∀ head, MemoryRegions.Disjoint output.kernel.output.base 12288 (gates head).base 512)
    (head : Fin 24) : ArrayStorage.BFBuffer (gate head) :=
  ArrayFrame.bf (gates head) output.kernel.output.memory (by
    intro offset bound
    have frame := MemoryRegions.execute16_other output.kernel.output.schedule output.kernel.output.before
      (SdpaOutputMemory.stores_inside output.kernel.output) (separate head) offset bound
    exact frame.trans ((congrFun output.initial ((gates head).base+offset)).trans
      (congrFun (shared head) ((gates head).base+offset)).symm))

def fromOutput (output : SdpaOutputMemory.Execution input p contracted arch)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (shared : ∀ head, (gates head).bytes=input.cache.memory)
    (separate : ∀ head, MemoryRegions.Disjoint output.kernel.output.base 12288 (gates head).base 512) :
    OutputGateMemory.Input output.loaded.output gate where
  storage := ⟨output.loaded.outputBuffer, gateAfterOutput output gates shared separate⟩
  memory := output.kernel.output.memory
  sourceShared := fun _ => rfl
  gateShared := fun _ => rfl

theorem fromOutput_source_layout (output : SdpaOutputMemory.Execution input p contracted arch)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (shared : ∀ head, (gates head).bytes=input.cache.memory)
    (separate : ∀ head, MemoryRegions.Disjoint output.kernel.output.base 12288 (gates head).base 512) (head : Fin 24) :
    ((fromOutput output gates shared separate).storage.source head).base=2*(output.kernel.output.base/2+head.val*256) := by
  change output.kernel.output.base+2*(head.val*256)=_
  have := output.kernel.output.aligned
  omega

variable {blocks : Nat}

def gateAfterFirst (first : SdpaTwoPassShared.Execution input p blocks)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (shared : ∀ head, (gates head).bytes=input.cache.memory)
    (separate : ∀ head, SdpaTwoPassShared.Separate first.first (gates head).base 512) (head : Fin 24) :
    ArrayStorage.BFBuffer (gate head) :=
  ArrayFrame.bf (gates head) first.first.memory (by
    intro offset bound
    have safe := separate head
    exact (first.first.other_region safe.1 safe.2.1 safe.2.2 offset bound).trans
      ((congrFun first.initial ((gates head).base+offset)).trans (congrFun (shared head) ((gates head).base+offset)).symm))

def fromTwoPass (first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps))
    (completed : SdpaTwoPassCompletion.Execution first contracted)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (shared : ∀ head, (gates head).bytes=input.cache.memory)
    (firstSeparate : ∀ head, SdpaTwoPassShared.Separate first.first (gates head).base 512)
    (outputSeparate : ∀ head, MemoryRegions.Disjoint completed.output.kernel.output.base 12288 (gates head).base 512) :
    OutputGateMemory.Input completed.output.loaded.output gate :=
  fromOutput completed.output (gateAfterFirst first gates shared firstSeparate) (fun _ => rfl) outputSeparate

def fromDonated (first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps))
    (output : SdpaTwoPassDonation.Execution first contracted)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (shared : ∀ head, (gates head).bytes=input.cache.memory)
    (firstSeparate : ∀ head, SdpaTwoPassShared.Separate first.first (gates head).base 512)
    (outputSeparate : ∀ head, MemoryRegions.Disjoint output.stores.base 12288 (gates head).base 512) :
    OutputGateMemory.Input output.output gate where
  storage := {
    source := output.buffer
    gate := fun head => ArrayFrame.bf (gates head) output.stores.memory (by
      intro offset bound
      have safe := firstSeparate head
      have firstFrame := first.first.other_region safe.1 safe.2.1 safe.2.2 offset bound
      exact (output.other_region (outputSeparate head) offset bound).trans
        (firstFrame.trans ((congrFun first.initial ((gates head).base+offset)).trans
          (congrFun (shared head) ((gates head).base+offset)).symm))) }
  memory := output.stores.memory
  sourceShared := fun _ => rfl
  gateShared := fun _ => rfl

theorem fromDonated_source_layout (first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps))
    (output : SdpaTwoPassDonation.Execution first contracted)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (shared : ∀ head, (gates head).bytes=input.cache.memory)
    (firstSeparate : ∀ head, SdpaTwoPassShared.Separate first.first (gates head).base 512)
    (outputSeparate : ∀ head, MemoryRegions.Disjoint output.stores.base 12288 (gates head).base 512) (head : Fin 24) :
    ((fromDonated first output gates shared firstSeparate outputSeparate).storage.source head).base=
      2*(output.stores.base/2+head.val*256) := by
  change output.stores.base+2*(head.val*256)=_
  have := output.stores.aligned
  omega

def fromOnePass (output : SdpaOnePassDonation.Execution input p arch)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (shared : ∀ head, (gates head).bytes=input.cache.memory)
    (separate : ∀ head, MemoryRegions.Disjoint output.stores.base 12288 (gates head).base 512) :
    OutputGateMemory.Input output.output gate where
  storage := {
    source := output.buffer
    gate := fun head => ArrayFrame.bf (gates head) output.stores.memory (by
      intro offset bound
      exact (output.other_region (separate head) offset bound).trans
        (congrFun (shared head) ((gates head).base+offset)).symm) }
  memory := output.stores.memory
  sourceShared := fun _ => rfl
  gateShared := fun _ => rfl

theorem fromOnePass_source_layout (output : SdpaOnePassDonation.Execution input p arch)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (shared : ∀ head, (gates head).bytes=input.cache.memory)
    (separate : ∀ head, MemoryRegions.Disjoint output.stores.base 12288 (gates head).base 512) (head : Fin 24) :
    ((fromOnePass output gates shared separate).storage.source head).base=2*(output.stores.base/2+head.val*256) := by
  change output.stores.base+2*(head.val*256)=_
  have := output.stores.aligned
  omega

-- The gate's output can alias a dead attention/activation input, while
-- retained KV allocations must remain disjoint from both write regions.
def afterGate {x : OutputGateDevice.Heads} {gateInput : OutputGateMemory.Input x gate} {platform : OutputGate.Platform}
    (execution : OutputGateMemory.Execution gateInput platform) (storage : KvRegions.Storage cache)
    (shared : storage.memory=gateInput.memory)
    (activationKeys : MemoryRegions.Disjoint (2*execution.activation.base) 12288 storage.layout.keyBase (KvRegions.bytes steps))
    (activationValues : MemoryRegions.Disjoint (2*execution.activation.base) 12288 storage.layout.valueBase (KvRegions.bytes steps))
    (outputKeys : MemoryRegions.Disjoint (2*execution.base) 12288 storage.layout.keyBase (KvRegions.bytes steps))
    (outputValues : MemoryRegions.Disjoint (2*execution.base) 12288 storage.layout.valueBase (KvRegions.bytes steps)) : KvRegions.Storage cache :=
  storage.reframe execution.trace.memory
    (by
      intro offset bound
      exact (execution.other_region activationKeys outputKeys offset bound).trans
        (congrFun shared (storage.layout.keyBase+offset)).symm)
    (by
      intro offset bound
      exact (execution.other_region activationValues outputValues offset bound).trans
        (congrFun shared (storage.layout.valueBase+offset)).symm)

theorem afterGate_shared {x : OutputGateDevice.Heads} {gateInput : OutputGateMemory.Input x gate} {platform : OutputGate.Platform}
    (execution : OutputGateMemory.Execution gateInput platform) (storage : KvRegions.Storage cache)
    (shared : storage.memory=gateInput.memory)
    (activationKeys : MemoryRegions.Disjoint (2*execution.activation.base) 12288 storage.layout.keyBase (KvRegions.bytes steps))
    (activationValues : MemoryRegions.Disjoint (2*execution.activation.base) 12288 storage.layout.valueBase (KvRegions.bytes steps))
    (outputKeys : MemoryRegions.Disjoint (2*execution.base) 12288 storage.layout.keyBase (KvRegions.bytes steps))
    (outputValues : MemoryRegions.Disjoint (2*execution.base) 12288 storage.layout.valueBase (KvRegions.bytes steps)) :
    (afterGate execution storage shared activationKeys activationValues outputKeys outputValues).memory=execution.buffer.bytes := rfl

end Inference.Models.Qwen.AttentionGateMemory
