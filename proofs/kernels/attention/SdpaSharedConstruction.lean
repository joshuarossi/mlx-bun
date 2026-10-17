import kernels.attention.SdpaShared

namespace Inference.Kernels.Attention.SdpaSharedConstruction
open Contracts.Mlx State
set_option maxRecDepth 10000
attribute [local irreducible] SdpaOutput.programs SdpaTwoPassBytes.programs
  SdpaTwoPassFirstPass.raw SdpaTwoPassFirstPass.stored
  ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}

structure Output (input : SdpaMemory.Input query cache) where
  base : Nat
  aligned : base%2=0
  bounded : base+12288 ≤ 2^64
  keysSeparate : MemoryRegions.Disjoint base 12288 input.cache.layout.keyBase (KvRegions.bytes steps)
  valuesSeparate : MemoryRegions.Disjoint base 12288 input.cache.layout.valueBase (KvRegions.bytes steps)

-- Donation requires the actual 24 contiguous query buffers at the output
-- address. Fresh storage instead preserves every incoming query region.
inductive OutputMode (output : Output input) where
  | fresh (separate : ∀ head, MemoryRegions.Disjoint output.base 12288 (input.query head).base 512)
  | donated (heads : ∀ head, (input.query head).base=(SdpaQueryMemory.layout output.base).base head)

structure OneAllocation (input : SdpaMemory.Input query cache) where
  output : Output input
  mode : OutputMode output

def onePass (input : SdpaMemory.Input query cache) (p : SdpaVector.Platform) (contracted : Bool) (arch : Char)
    (selected : ¬SdpaDispatched.twoPass arch steps) (allocation : OneAllocation input) :
    SdpaShared.Execution input p contracted arch :=
  match allocation.mode with
  | .fresh separate => .onePassFresh (SdpaOutputMemory.canonical input p contracted arch allocation.output.base
      allocation.output.aligned allocation.output.bounded allocation.output.keysSeparate allocation.output.valuesSeparate separate) selected
  | .donated heads => .onePassDonated (SdpaOnePassDonation.canonical input p arch selected allocation.output.base
      allocation.output.aligned allocation.output.bounded heads allocation.output.keysSeparate allocation.output.valuesSeparate)

theorem onePass_base (selected : ¬SdpaDispatched.twoPass arch steps) (allocation : OneAllocation input) :
    (onePass input p contracted arch selected allocation).base=allocation.output.base := by
  rcases allocation with ⟨output,mode⟩
  cases mode <;> rfl

theorem onePass_safe (selected : ¬SdpaDispatched.twoPass arch steps) (allocation : OneAllocation input) (base size : Nat) :
    SdpaShared.Safe (onePass input p contracted arch selected allocation) base size ↔
      MemoryRegions.Disjoint allocation.output.base 12288 base size := by
  rcases allocation with ⟨output,mode⟩
  cases mode <;> rfl

-- This is the complete first-dispatch allocation geometry, including all
-- sums, maxima and BF16 partials, not only the final output allocation.
def TemporarySafe (layout : SdpaTwoPassMemory.Layout blocks) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint layout.sumBase (4*(24*blocks)) base size ∧
  MemoryRegions.Disjoint layout.maxBase (4*(24*blocks)) base size ∧
  MemoryRegions.Disjoint layout.outputBase (2*(24*blocks*256)) base size

structure TwoAllocation (input : SdpaMemory.Input query cache) (arch : Char) where
  layout : SdpaTwoPassMemory.Layout (SdpaDispatched.blockCount arch steps)
  output : Output input
  mode : OutputMode output
  keysSeparate : TemporarySafe layout input.cache.layout.keyBase (KvRegions.bytes steps)
  valuesSeparate : TemporarySafe layout input.cache.layout.valueBase (KvRegions.bytes steps)
  queriesSeparate : ∀ head, TemporarySafe layout (input.query head).base 512
  outputSeparate : TemporarySafe layout output.base 12288

def firstPass (input : SdpaMemory.Input query cache) (p : SdpaVector.Platform) (arch : Char)
    (allocation : TwoAllocation input arch) : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps) :=
  SdpaTwoPassShared.canonical input p allocation.layout allocation.keysSeparate allocation.valuesSeparate allocation.queriesSeparate

def twoPass (input : SdpaMemory.Input query cache) (p : SdpaVector.Platform) (contracted : Bool) (arch : Char)
    (selected : SdpaDispatched.twoPass arch steps) (allocation : TwoAllocation input arch) :
    SdpaShared.Execution input p contracted arch :=
  let first := firstPass input p arch allocation
  .twoPass first (SdpaTwoPassDonation.canonical first contracted selected allocation.output.base
    allocation.output.aligned allocation.output.bounded allocation.output.keysSeparate allocation.output.valuesSeparate allocation.outputSeparate)

theorem twoPass_base (selected : SdpaDispatched.twoPass arch steps) (allocation : TwoAllocation input arch) :
    (twoPass input p contracted arch selected allocation).base=allocation.output.base := rfl

theorem twoPass_safe (selected : SdpaDispatched.twoPass arch steps) (allocation : TwoAllocation input arch) (base size : Nat) :
    SdpaShared.Safe (twoPass input p contracted arch selected allocation) base size ↔
      TemporarySafe allocation.layout base size ∧ MemoryRegions.Disjoint allocation.output.base 12288 base size := Iff.rfl

-- The one-pass donated branch executes real captures before overwrite;
-- no completed output or scratch witness is supplied by the caller.
theorem onePass_captured (selected : ¬SdpaDispatched.twoPass arch steps) (output : Output input)
    (heads : ∀ head, (input.query head).base=(SdpaQueryMemory.layout output.base).base head) :
    (SdpaOnePassDonation.canonical input p arch selected output.base output.aligned output.bounded heads
      output.keysSeparate output.valuesSeparate).queries.capturedQuery=query :=
  (SdpaOnePassDonation.canonical input p arch selected output.base output.aligned output.bounded heads
    output.keysSeparate output.valuesSeparate).captured_query

attribute [local irreducible] firstPass

theorem second_reads_first (allocation : TwoAllocation input arch) (head : Fin 24)
    (block : Fin (SdpaDispatched.blockCount arch steps)) (i : Fin 256) :
    ((firstPass input p arch allocation).second contracted (SdpaDispatchedDevice.complete_blocks arch steps)).first.readState head block i=
      (firstPass input p arch allocation).first.readState head block i :=
  (firstPass input p arch allocation).second_reads_heap contracted (SdpaDispatchedDevice.complete_blocks arch steps) head block i

-- Only the allocation family for the selected architecture/length route
-- is demanded. The route predicate is evaluated from the actual inputs.
def canonical (input : SdpaMemory.Input query cache) (p : SdpaVector.Platform) (contracted : Bool) (arch : Char)
    (one : ¬SdpaDispatched.twoPass arch steps → OneAllocation input)
    (two : SdpaDispatched.twoPass arch steps → TwoAllocation input arch) : SdpaShared.Execution input p contracted arch :=
  if selected : SdpaDispatched.twoPass arch steps then twoPass input p contracted arch selected (two selected)
  else onePass input p contracted arch selected (one selected)

def Safe (one : ¬SdpaDispatched.twoPass arch steps → OneAllocation input)
    (two : SdpaDispatched.twoPass arch steps → TwoAllocation input arch) (base size : Nat) : Prop :=
  if selected : SdpaDispatched.twoPass arch steps then
    TemporarySafe (two selected).layout base size ∧ MemoryRegions.Disjoint (two selected).output.base 12288 base size
  else MemoryRegions.Disjoint (one selected).output.base 12288 base size

variable (one : ¬SdpaDispatched.twoPass arch steps → OneAllocation input)
  (two : SdpaDispatched.twoPass arch steps → TwoAllocation input arch)

theorem canonical_safe (base size : Nat) :
    SdpaShared.Safe (canonical input p contracted arch one two) base size ↔ Safe one two base size := by
  unfold canonical Safe
  split <;> simp only [twoPass_safe,onePass_safe]

theorem canonical_base :
    (canonical input p contracted arch one two).base=
      if selected : SdpaDispatched.twoPass arch steps then (two selected).output.base else (one selected).output.base := by
  unfold canonical
  split <;> simp only [twoPass_base,onePass_base]

theorem canonical_route (positive : 0<steps) :
    SdpaDispatch.route (SdpaDispatch.qwen steps) arch=
      if SdpaDispatched.twoPass arch steps then .twoPass else .onePass := SdpaDispatched.route arch steps positive

theorem output_eq (head : Fin 24) (i : Fin 256) :
    (canonical input p contracted arch one two).output head i=SdpaDispatched.forward p contracted arch (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)) i :=
  (canonical input p contracted arch one two).output_eq head i

theorem cache_layout : (canonical input p contracted arch one two).afterCache.layout=input.cache.layout :=
  (canonical input p contracted arch one two).cache_layout

theorem cache_output_shared :
    (canonical input p contracted arch one two).afterCache.memory=(canonical input p contracted arch one two).memory :=
  (canonical input p contracted arch one two).cache_memory

theorem buffers_shared (head : Fin 24) :
    ((canonical input p contracted arch one two).buffer head).bytes=(canonical input p contracted arch one two).memory :=
  (canonical input p contracted arch one two).buffer_bytes head

theorem other_region {base size : Nat} (safe : Safe one two base size) (offset : Nat) (bound : offset<size) :
    (canonical input p contracted arch one two).memory (base+offset)=input.cache.memory (base+offset) :=
  (canonical input p contracted arch one two).other_region ((canonical_safe one two base size).mpr safe) offset bound

def afterQueries
    (safe : ∀ head, Safe one two (input.query head).base 512) (head : Fin 24) : ArrayStorage.BFBuffer (query head) :=
  ArrayFrame.bf (input.query head) (canonical input p contracted arch one two).memory
    (fun offset bound => (other_region one two (safe head) offset bound).trans (congrFun (input.shared head) _).symm)

end Inference.Kernels.Attention.SdpaSharedConstruction
