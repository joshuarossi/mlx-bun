import kernels.sampling.ArgmaxReductionDevice
import contracts.mlx.ArrayFrame
import contracts.mlx.MemoryProjection

namespace Inference.Kernels.Sampling.ArgmaxPairMemory
open Contracts.Mlx ArgmaxPairs
set_option maxRecDepth 10000

structure Layout (count : Nat) where
  scores : Nat
  ids : Nat
  scoreAligned : scores%4=0
  idAligned : ids%4=0
  scoreBounded : scores+4*count≤2^64
  idBounded : ids+4*count≤2^64
  separate : MemoryRegions.Disjoint scores (4*count) ids (4*count)

def scoreStore (layout : Layout n) (values : Fin n → Candidate) (i : Fin n) : ByteMemory.Store :=
  ⟨layout.scores/4+i.val,FloatMemory.bits (ArgmaxStorage.score (values i))⟩
def idStore (layout : Layout n) (values : Fin n → Candidate) (i : Fin n) : ByteMemory.Store :=
  ⟨layout.ids/4+i.val,BitVec.ofNat 32 (values i).index⟩
def programs (layout : Layout n) (values : Fin n → Candidate) : List (List ByteMemory.Store) :=
  (List.finRange n).map (fun i => [scoreStore layout values i,idStore layout values i])

theorem member (layout : Layout n) (values : Fin n → Candidate) (store : ByteMemory.Store)
    (present : store ∈ (programs layout values).flatten) :
    ∃ i, store=scoreStore layout values i ∨ store=idStore layout values i := by
  obtain ⟨thread,present,inside⟩ := List.mem_flatten.mp present
  obtain ⟨i,_,rfl⟩ := List.mem_map.mp present
  exact ⟨i,by simpa only [List.mem_cons,List.mem_singleton,List.not_mem_nil,or_false] using inside⟩

theorem covered_score (layout : Layout n) (values : Fin n → Candidate) (i : Fin n) :
    scoreStore layout values i ∈ (programs layout values).flatten :=
  List.mem_flatten.mpr ⟨_,List.mem_map.mpr ⟨i,List.mem_finRange _,rfl⟩,List.mem_cons_self⟩
theorem covered_id (layout : Layout n) (values : Fin n → Candidate) (i : Fin n) :
    idStore layout values i ∈ (programs layout values).flatten :=
  List.mem_flatten.mpr ⟨_,List.mem_map.mpr ⟨i,List.mem_finRange _,rfl⟩,by simp⟩

structure Trace (layout : Layout n) (values : Fin n → Candidate) where
  before : ByteMemory.Bytes
  schedule : List ByteMemory.Store
  remaining : List (List ByteMemory.Store)
  execution : ThreadgroupWrites.Executes (programs layout values) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (layout : Layout n) (values : Fin n → Candidate) (before : ByteMemory.Bytes) : Trace layout values :=
  ⟨before,(programs layout values).flatten,List.replicate (programs layout values).length [],
    ThreadgroupWrites.canonical _,ThreadgroupWrites.canonical_barrier _⟩

variable {n : Nat} {layout : Layout n} {values : Fin n → Candidate}

def Trace.memory (trace : Trace layout values) : ByteMemory.Bytes := ByteMemory.execute trace.schedule trace.before

theorem Trace.score_read (trace : Trace layout values) (i : Fin n) :
    FloatMemory.load trace.memory (layout.scores+4*i.val)=ArgmaxStorage.score (values i) := by
  unfold FloatMemory.load Trace.memory
  rw [ByteMemory.execute_bytes_load32 _ _ _ (by have := layout.scoreAligned; omega),
    show (layout.scores+4*i.val)/4=layout.scores/4+i.val by omega]
  rw [show MemoryCells.execute trace.schedule (ByteMemory.view trace.before) (layout.scores/4+i.val)=
    FloatMemory.bits (ArgmaxStorage.score (values i)) from by
      apply MemoryCells.completed_value trace.execution trace.completed
      · intro store present same
        obtain ⟨j,h|h⟩ := member layout values store present
        · subst store
          have equal : j=i := Fin.ext (by dsimp [scoreStore] at same; omega)
          subst j
          rfl
        · subst store
          have ib := i.isLt
          have jb := j.isLt
          have sa := layout.scoreAligned
          have ia := layout.idAligned
          dsimp [idStore] at same
          rcases layout.separate with h|h <;> omega
      · exact ⟨scoreStore layout values i,covered_score layout values i,rfl⟩]
  exact FloatMemory.decode_bits _

theorem Trace.id_read (trace : Trace layout values) (i : Fin n) :
    ByteMemory.load32 trace.memory (layout.ids+4*i.val)=BitVec.ofNat 32 (values i).index := by
  unfold Trace.memory
  rw [ByteMemory.execute_bytes_load32 _ _ _ (by have := layout.idAligned; omega),
    show (layout.ids+4*i.val)/4=layout.ids/4+i.val by omega]
  apply MemoryCells.completed_value trace.execution trace.completed
  · intro store present same
    obtain ⟨j,h|h⟩ := member layout values store present
    · subst store
      have ib := i.isLt
      have jb := j.isLt
      have sa := layout.scoreAligned
      have ia := layout.idAligned
      dsimp [scoreStore] at same
      rcases layout.separate with h|h <;> omega
    · subst store
      have equal : j=i := Fin.ext (by dsimp [idStore] at same; omega)
      subst j
      rfl
  · exact ⟨idStore layout values i,covered_id layout values i,rfl⟩

def readAt (layout : Layout n) (memory : ByteMemory.Bytes) (i : Fin n) : Candidate :=
  ⟨ArgmaxStorage.decodedScore (FloatMemory.load memory (layout.scores+4*i.val)),
   (ByteMemory.load32 memory (layout.ids+4*i.val)).toNat⟩

theorem readAt_congr (layout : Layout n) (before after : ByteMemory.Bytes)
    (scores : ∀ offset < 4*n, after (layout.scores+offset)=before (layout.scores+offset))
    (ids : ∀ offset < 4*n, after (layout.ids+offset)=before (layout.ids+offset)) (i : Fin n) :
    readAt layout after i=readAt layout before i := by
  unfold readAt FloatMemory.load
  rw [ArrayFrame.word_congr before after layout.scores (4*n) _ scores (by have := i.isLt; omega),
    ArrayFrame.word_congr before after layout.ids (4*n) _ ids (by have := i.isLt; omega)]

def Trace.read (trace : Trace layout values) (i : Fin n) : Candidate :=
  ⟨ArgmaxStorage.decodedScore (FloatMemory.load trace.memory (layout.scores+4*i.val)),
   (ByteMemory.load32 trace.memory (layout.ids+4*i.val)).toNat⟩

theorem Trace.read_correct (trace : Trace layout values) (valid : ∀ i, ArgmaxStorage.Valid (values i)) (i : Fin n) :
    trace.read i=values i := by
  unfold Trace.read
  rw [trace.score_read,trace.id_read,ArgmaxStorage.decoded_score _ (valid i).1]
  simp only [BitVec.toNat_ofNat,Nat.mod_eq_of_lt (valid i).2]

def Safe (layout : Layout n) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint layout.scores (4*n) base size ∧ MemoryRegions.Disjoint layout.ids (4*n) base size

theorem Trace.during_other (trace : Trace layout values) (stores : List ByteMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ trace.schedule) (safe : Safe layout base size) (offset : Nat) (bound : offset<size) :
    ByteMemory.execute stores trace.before (base+offset)=trace.before (base+offset) := by
  rw [← MemoryProjection.words]
  apply MemoryProjection.frame
  intro store present memory
  obtain ⟨i,h|h⟩ := member layout values store
    ((ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp (subset store present))
  · subst store
    apply MemoryProjection.word_misses _ _ safe.1 offset bound memory
    have aligned := layout.scoreAligned
    have bounded := i.isLt
    dsimp [scoreStore]
    omega
  · subst store
    apply MemoryProjection.word_misses _ _ safe.2 offset bound memory
    have aligned := layout.idAligned
    have bounded := i.isLt
    dsimp [idStore]
    omega

theorem Trace.other_region (trace : Trace layout values) (safe : Safe layout base size) (offset : Nat) (bound : offset<size) :
    trace.memory (base+offset)=trace.before (base+offset) := trace.during_other _ (fun _ h => h) safe offset bound

-- Native scores[4] and ids[4] inhabit one local threadgroup allocation.
-- Distinct tiles have separate local address spaces, supplied independently.
def localLayout : Layout 4 := ⟨0,16,by decide,by decide,by decide,by decide,Or.inl (by decide)⟩

structure Reduction (input : Fin 128 → Candidate) where
  scratch : Trace localLayout (ArgmaxReductionDevice.simd input)

def Reduction.canonical (input : Fin 128 → Candidate) (localBefore : ByteMemory.Bytes) : Reduction input :=
  ⟨Trace.canonical localLayout (ArgmaxReductionDevice.simd input) localBefore⟩

def Reduction.output (reduction : Reduction input) : Candidate := ArgmaxPairs.tree reduction.scratch.read NormalizedArgmaxLayout.mergeTree

theorem Reduction.output_eq (reduction : Reduction input) (valid : ∀ i, ArgmaxStorage.Valid (input i)) :
    reduction.output=ArgmaxPairs.tree input NormalizedArgmaxLayout.threadgroupTree := by
  have read : reduction.scratch.read=ArgmaxReductionDevice.simd input :=
    funext (reduction.scratch.read_correct (ArgmaxReductionDevice.group_valid input valid))
  unfold Reduction.output
  rw [read]
  unfold NormalizedArgmaxLayout.threadgroupTree
  rw [ArgmaxReductionDevice.tree_substitute]
  rw [show ArgmaxReductionDevice.simd input=(fun group => ArgmaxPairs.tree input (NormalizedArgmaxLayout.groupTree group))
    from funext (ArgmaxReductionDevice.group_eq input)]

theorem Reduction.output_valid (reduction : Reduction input) (valid : ∀ i, ArgmaxStorage.Valid (input i)) : ArgmaxStorage.Valid reduction.output := by
  rw [reduction.output_eq valid]
  exact ArgmaxStorage.tree_valid _ _ valid

end Inference.Kernels.Sampling.ArgmaxPairMemory
