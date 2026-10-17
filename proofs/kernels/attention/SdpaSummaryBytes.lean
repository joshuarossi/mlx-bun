import contracts.mlx.FloatMemory
import contracts.mlx.WriteOwnership

namespace Inference.Kernels.Attention.SdpaSummaryBytes
open Contracts.Mlx
abbrev Label := Fin 32 × Fin 32
def labels : List Label := (List.finRange 32).product (List.finRange 32)
def Separate (maxBase sumBase : Nat) : Prop := maxBase/4+32 ≤ sumBase/4 ∨ sumBase/4+32 ≤ maxBase/4
def selected (maximum : Bool) (a b : α) : α := if maximum then a else b

def entry (maxBase sumBase : Nat) (maxima sums : Fin 32 → Float32) (label : Label) (maximum : Bool) : Memory.Store :=
  ⟨selected maximum maxBase sumBase/4+label.1.val, selected maximum maxima sums label.1⟩
def thread (maxBase sumBase : Nat) (maxima sums : Fin 32 → Float32) (label : Label) : List Memory.Store :=
  if label.2.val=0 then [entry maxBase sumBase maxima sums label true, entry maxBase sumBase maxima sums label false] else []
def programs (maxBase sumBase : Nat) (maxima sums : Fin 32 → Float32) : List (List Memory.Store) :=
  labels.map (thread maxBase sumBase maxima sums)

theorem member (maxBase sumBase : Nat) (maxima sums : Fin 32 → Float32) (store : Memory.Store)
    (inside : store ∈ (programs maxBase sumBase maxima sums).flatten) :
    ∃ label, label.2.val=0 ∧ ∃ maximum, store=entry maxBase sumBase maxima sums label maximum := by
  obtain ⟨stores, hm, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨label, _, rfl⟩ := List.mem_map.mp hm
  unfold thread at hs
  split at hs
  next active =>
    rcases List.mem_cons.mp hs with same | same
    · exact ⟨label, active, true, same⟩
    · exact ⟨label, active, false, List.mem_singleton.mp same⟩
  next inactive => simp at hs

theorem covers (maxBase sumBase : Nat) (maxima sums : Fin 32 → Float32) (group : Fin 32) (maximum : Bool) :
    entry maxBase sumBase maxima sums (group, 0) maximum ∈ (programs maxBase sumBase maxima sums).flatten := by
  apply List.mem_flatten.mpr
  refine ⟨thread maxBase sumBase maxima sums (group, 0), List.mem_map.mpr
    ⟨(group, 0), List.mem_product.mpr ⟨List.mem_finRange _, List.mem_finRange _⟩, rfl⟩, ?_⟩
  cases maximum <;> simp [thread]

theorem correct_value (maxBase sumBase : Nat) (maxima sums : Fin 32 → Float32) (separate : Separate maxBase sumBase)
    (group : Fin 32) (maximum : Bool) (store : Memory.Store)
    (inside : store ∈ (programs maxBase sumBase maxima sums).flatten)
    (same : store.word=selected maximum maxBase sumBase/4+group.val) : store.value=selected maximum maxima sums group := by
  obtain ⟨label, _, kind, rfl⟩ := member maxBase sumBase maxima sums store inside
  have groupBound := group.isLt
  have writerBound := label.1.isLt
  unfold Separate at separate
  cases maximum <;> cases kind <;> simp only [entry, selected, Bool.false_eq_true, ↓reduceIte] at same ⊢
  · rw [show label.1=group from Fin.ext (by omega)]
  · omega
  · omega
  · rw [show label.1=group from Fin.ext (by omega)]

theorem stored (maxBase sumBase : Nat) (maxima sums : Fin 32 → Float32) (separate : Separate maxBase sumBase)
    (before : M1Max.WordMemory) (schedule : List Memory.Store) (remaining : List (List Memory.Store))
    (execution : ThreadgroupWrites.Executes (programs maxBase sumBase maxima sums) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (group : Fin 32) (maximum : Bool) :
    Memory.execute schedule before (selected maximum maxBase sumBase/4+group.val)=selected maximum maxima sums group :=
  ThreadgroupWrites.completed_value execution completed before _ _
    (fun store inside same => correct_value maxBase sumBase maxima sums separate group maximum store inside same)
    ⟨entry maxBase sumBase maxima sums (group, 0) maximum, covers maxBase sumBase maxima sums group maximum, rfl⟩

private def owner (maxBase sumBase word : Nat) : Label :=
  (⟨(if maxBase/4 ≤ word ∧ word<maxBase/4+32 then word-maxBase/4 else word-sumBase/4)%32, by omega⟩, 0)

theorem owner_entry (maxBase sumBase : Nat) (maxima sums : Fin 32 → Float32) (separate : Separate maxBase sumBase)
    (label : Label) (active : label.2.val=0) (maximum : Bool) :
    owner maxBase sumBase (entry maxBase sumBase maxima sums label maximum).word=label := by
  have := label.1.isLt
  unfold Separate at separate
  apply Prod.ext
  · apply Fin.ext
    cases maximum <;> simp only [owner, entry, selected, Bool.false_eq_true, ↓reduceIte] <;> split <;> omega
  · apply Fin.ext
    exact active.symm

theorem separated (maxBase sumBase : Nat) (maxima sums : Fin 32 → Float32) (separate : Separate maxBase sumBase) :
    WriteOwnership.Separated Memory.Store.word (programs maxBase sumBase maxima sums) := by
  apply WriteOwnership.owned labels ((List.nodup_finRange 32).product (List.nodup_finRange 32)) _ _ (owner maxBase sumBase)
  intro label _ store inside
  unfold thread at inside
  split at inside
  next active =>
    rcases List.mem_cons.mp inside with same | same
    · subst store
      exact owner_entry maxBase sumBase maxima sums separate label active true
    · have equal := List.mem_singleton.mp same
      subst store
      exact owner_entry maxBase sumBase maxima sums separate label active false
  next inactive => simp at inside

-- The maximum and sum arrays share a threadgroup allocation but occupy
-- disjoint ranges. Only lane 0 publishes each group's two summaries.
structure Trace (maxima sums : Fin 32 → Float32) where
  before : ByteMemory.Bytes
  maxBase : Nat
  sumBase : Nat
  maxAligned : maxBase%4=0
  sumAligned : sumBase%4=0
  maxBounded : maxBase+128 ≤ 2^64
  sumBounded : sumBase+128 ≤ 2^64
  separate : Separate maxBase sumBase
  schedule : List Memory.Store
  remaining : List (List Memory.Store)
  execution : ThreadgroupWrites.Executes (programs maxBase sumBase maxima sums) schedule remaining
  barrier : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (maxima sums : Fin 32 → Float32) : Trace maxima sums :=
  let stores := programs 0 128 maxima sums
  ⟨fun _ => 0, 0, 128, by decide, by decide, by decide, by decide, Or.inl (by decide), stores.flatten,
    List.replicate stores.length [], ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

variable {maxima sums : Fin 32 → Float32}

def Trace.memory (trace : Trace maxima sums) : ByteMemory.Bytes := FloatMemory.execute trace.schedule trace.before
def Trace.read (trace : Trace maxima sums) (maximum : Bool) (group : Fin 32) : Float32 :=
  FloatMemory.load trace.memory (selected maximum trace.maxBase trace.sumBase+4*group.val)

theorem Trace.read_correct (trace : Trace maxima sums) (maximum : Bool) (group : Fin 32) :
    trace.read maximum group=selected maximum maxima sums group := by
  have aligned : selected maximum trace.maxBase trace.sumBase%4=0 := by
    cases maximum
    · exact trace.sumAligned
    · exact trace.maxAligned
  unfold Trace.read Trace.memory
  rw [FloatMemory.execute_load _ _ _ (by omega),
    show (selected maximum trace.maxBase trace.sumBase+4*group.val)/4=selected maximum trace.maxBase trace.sumBase/4+group.val by omega]
  exact stored _ _ _ _ trace.separate _ _ _ trace.execution trace.barrier group maximum

theorem Trace.read_bounds (trace : Trace maxima sums) (maximum : Bool) (group : Fin 32) :
    let base := selected maximum trace.maxBase trace.sumBase
    (base+4*group.val)%4=0 ∧ base ≤ base+4*group.val ∧ base+4*group.val+4 ≤ base+128 ∧ base+4*group.val+4 ≤ 2^64 := by
  have := trace.maxAligned
  have := trace.sumAligned
  have := trace.maxBounded
  have := trace.sumBounded
  have := group.isLt
  cases maximum <;> simp only [selected, Bool.false_eq_true, ↓reduceIte] <;> omega

end Inference.Kernels.Attention.SdpaSummaryBytes
