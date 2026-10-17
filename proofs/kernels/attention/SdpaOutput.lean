import kernels.attention.SdpaTwoPassWrites
import contracts.mlx.HalfMemory

namespace Inference.Kernels.Attention.SdpaOutput
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value
abbrev Values := Fin 24 → Fin 256 → BF
abbrev Label := SdpaTwoPassWrites.Label 32

def address (head : Fin 24) (i : Fin 256) : Nat := head.val*256+i.val
def bits (value : BF) : BitVec 16 := value.bits
def entry (base : Nat) (values : Values) (label : Label) (offset : Fin 8) : HalfMemory.Store :=
  let i := SdpaLayout.coordinate label.2.1 offset
  ⟨base/2+address label.1 i, bits (values label.1 i)⟩
def thread (base : Nat) (values : Values) (label : Label) : List HalfMemory.Store :=
  if label.2.2.val=0 then List.ofFn (entry base values label) else []
def programs (base : Nat) (values : Values) : List (List HalfMemory.Store) :=
  (SdpaTwoPassWrites.labels 32).map (thread base values)

theorem member (base : Nat) (values : Values) (store : HalfMemory.Store) (inside : store ∈ (programs base values).flatten) :
    ∃ label, label.2.2.val=0 ∧ ∃ offset, store=entry base values label offset := by
  obtain ⟨stores, hm, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨label, _, rfl⟩ := List.mem_map.mp hm
  unfold thread at hs
  split at hs
  next active =>
    obtain ⟨offset, equal⟩ := List.mem_ofFn.mp hs
    exact ⟨label, active, offset, equal.symm⟩
  next inactive => simp at hs

theorem covers (base : Nat) (values : Values) (head : Fin 24) (i : Fin 256) :
    ∃ store ∈ (programs base values).flatten, store.word=base/2+address head i := by
  let label : Label := (head, ⟨i.val/8, by omega⟩, 0)
  let offset : Fin 8 := ⟨i.val%8, by omega⟩
  refine ⟨entry base values label offset, List.mem_flatten.mpr
    ⟨thread base values label, List.mem_map.mpr ⟨label, SdpaTwoPassWrites.label_member _, rfl⟩, ?_⟩, ?_⟩
  · simp only [thread, label, ↓reduceIte, Fin.val_zero]
    exact List.mem_ofFn.mpr ⟨offset, rfl⟩
  · simp only [entry, label, offset, SdpaTwoPassWrites.coordinate_inverse]

theorem stored (base : Nat) (values : Values) (before : HalfMemory.Words)
    (schedule : List HalfMemory.Store) (remaining : List (List HalfMemory.Store))
    (execution : ThreadgroupWrites.Executes (programs base values) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (head : Fin 24) (i : Fin 256) :
    MemoryCells.execute schedule before (base/2+address head i)=bits (values head i) := by
  apply MemoryCells.completed_value execution completed before _ _
  · intro store inside same
    obtain ⟨label, _, offset, rfl⟩ := member base values store inside
    have coordinateBound := (SdpaLayout.coordinate label.2.1 offset).isLt
    have headEq : label.1=head := by
      apply Fin.ext
      simp only [entry, address] at same
      have := i.isLt
      omega
    have indexEq : SdpaLayout.coordinate label.2.1 offset=i := by
      apply Fin.ext
      simp only [entry, address, headEq] at same
      omega
    simp only [entry, headEq, indexEq]
  · exact covers base values head i

private def owner (base word : Nat) : Label :=
  (⟨(word-base/2)/256%24, by omega⟩, ⟨(word-base/2)%256/8, by omega⟩, 0)

theorem separated (base : Nat) (values : Values) : WriteOwnership.Separated MemoryCells.Store.word (programs base values) := by
  apply WriteOwnership.owned _ (SdpaTwoPassWrites.labels_unique 32) _ _ (owner base)
  intro label _ store inside
  unfold thread at inside
  split at inside
  next active =>
    obtain ⟨offset, rfl⟩ := List.mem_ofFn.mp inside
    have headBound := label.1.isLt
    have groupBound := label.2.1.isLt
    have offsetBound := offset.isLt
    apply Prod.ext
    · apply Fin.ext
      simp only [owner, entry, address, SdpaLayout.coordinate]
      omega
    · apply Prod.ext
      · apply Fin.ext
        simp only [owner, entry, address, SdpaLayout.coordinate]
        omega
      · apply Fin.ext
        exact active.symm
  next inactive => simp at inside

-- Both ordinary vector routes store eight values from lane 0 of each
-- SIMD group. The consuming output-gate kernel depends on this dispatch.
structure Trace (values : Values) where
  before : HalfMemory.Bytes
  base : Nat
  aligned : base%2=0
  bounded : base+2*(24*256) ≤ 2^64
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (programs base values) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (values : Values) (before : HalfMemory.Bytes) (base : Nat)
    (aligned : base%2=0) (bounded : base+2*(24*256) ≤ 2^64) : Trace values :=
  let stores := programs base values
  ⟨before, base, aligned, bounded, stores.flatten, List.replicate stores.length [],
    ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

def Trace.memory (trace : Trace values) : HalfMemory.Bytes := HalfMemory.execute trace.schedule trace.before
def Trace.read (trace : Trace values) (head : Fin 24) (i : Fin 256) : BF :=
  Model.ofBits (HalfMemory.load trace.memory (trace.base+2*address head i))

theorem Trace.read_correct (trace : Trace values) (head : Fin 24) (i : Fin 256) : trace.read head i=values head i := by
  have raw : HalfMemory.load trace.memory (trace.base+2*address head i)=bits (values head i) := by
    unfold Trace.memory
    rw [HalfMemory.execute_load _ _ _ (by have := trace.aligned; omega),
      show (trace.base+2*address head i)/2=trace.base/2+address head i by omega]
    exact stored _ _ _ _ _ trace.execution trace.completed head i
  exact congrArg (fun bits : BitVec 16 => (Model.ofBits bits : BF)) raw

theorem Trace.read_bounds (trace : Trace values) (head : Fin 24) (i : Fin 256) :
    let offset := trace.base+2*address head i
    offset%2=0 ∧ trace.base ≤ offset ∧ offset+2 ≤ trace.base+2*(24*256) ∧ offset+2 ≤ 2^64 := by
  have := trace.aligned
  have := trace.bounded
  have := head.isLt
  have := i.isLt
  dsimp only [address]
  omega

end Inference.Kernels.Attention.SdpaOutput
