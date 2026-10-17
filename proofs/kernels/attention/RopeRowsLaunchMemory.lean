import kernels.attention.RopeRowsDispatchMemory

namespace Inference.Kernels.Attention.RopeRowsLaunchMemory
open Contracts.Mlx
open RopeRowsMemory RopeRowsDynamicMemory
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

-- The native single launch uses (lane, flattened batch/head) with grid.x=32.
def singleFirst (head lane : Nat) : Nat := lane+head*256
def singleSecond (head lane : Nat) : Nat := singleFirst head lane+32

theorem single_address (head lane : Nat) : singleFirst head lane=head*256+lane ∧
    singleSecond head lane=head*256+(lane+32) := by constructor <;> simp [singleFirst,singleSecond] <;> omega

-- After partial-RoPE preparation, native general strides are
-- (tokens*256, 256, 1). This formula also covers multiple batches/tokens.
def generalFirst (heads tokens batch head token lane : Nat) : Nat :=
  token*256+(batch*heads+head)*(tokens*256)+lane

def row (heads tokens batch head token : Nat) : Nat := (batch*heads+head)*tokens+token

theorem general_address (heads tokens batch head token lane : Nat) :
    generalFirst heads tokens batch head token lane=row heads tokens batch head token*256+lane := by
  unfold generalFirst row
  ring

theorem next_head_address (heads tokens batch head token lane : Nat) :
    generalFirst heads tokens batch (head+1) token lane=
      generalFirst heads tokens batch head token lane+tokens*256 := by
  unfold generalFirst
  ring

-- n_head_up=4*ceil(n_head/4), head_idx=(pos.z*4)%n_head_up,
-- batch_idx=(pos.z*4)/n_head_up. Q24 and K4 have no masked tail heads.
theorem padded_heads (blocks : Nat) : 4*((4*blocks+4-1)/4)=4*blocks := by omega

def head (block : Fin blocks) (inner : Fin 4) : Fin (4*blocks) :=
  ⟨4*block.val+inner.val,by have := block.isLt; have := inner.isLt; omega⟩

def reader (thread : Fin blocks × Fin 32) (inner : Fin 4) : Reader (4*blocks) :=
  (head thread.1 inner,thread.2)

theorem native_head (block : Fin blocks) (inner : Fin 4) :
    (block.val*4)%(4*blocks)+inner.val=(head block inner).val ∧ (block.val*4)/(4*blocks)=0 := by
  have bound := block.isLt
  have small : block.val*4<4*blocks := by omega
  rw [Nat.mod_eq_of_lt small,Nat.div_eq_of_lt small]
  dsimp [head]
  constructor <;> omega

theorem query_grid : (24/4=6) ∧ (4*((24+4-1)/4)=24) := by decide

theorem key_grid : (4/4=1) ∧ (4*((4+4-1)/4)=4) := by decide

def threads (blocks : Nat) : List (Fin blocks × Fin 32) := (List.finRange blocks).product (List.finRange 32)
def readers (blocks : Nat) : List (Reader (4*blocks)) :=
  (threads blocks).flatMap (fun thread => (List.finRange 4).map (reader thread))
def labelPrograms (blocks : Nat) : List (List (Label (4*blocks))) :=
  (threads blocks).map (fun thread => (List.finRange 4).flatMap (fun inner => readerHistory (reader thread inner)))

theorem reader_injective : Function.Injective (fun label : (Fin blocks × Fin 32) × Fin 4 => reader label.1 label.2) := by
  intro first second same
  have h := congrArg (fun r => r.1.val) same
  have lane := congrArg (fun r => r.2) same
  have fb := first.2.isLt
  have sb := second.2.isLt
  have block : first.1.1=second.1.1 := by apply Fin.ext; dsimp [reader,head] at h; omega
  have inner : first.2=second.2 := by apply Fin.ext; dsimp [reader,head] at h; omega
  exact Prod.ext (Prod.ext block lane) inner

theorem readers_nodup (blocks : Nat) : (readers blocks).Nodup := by
  have unique := (((List.nodup_finRange blocks).product (List.nodup_finRange 32)).product (List.nodup_finRange 4))
  have mapped := unique.map reader_injective
  change (((threads blocks).product (List.finRange 4)).map (fun label => reader label.1 label.2)).Nodup at mapped
  simpa only [readers,List.product,List.map_flatMap,List.map_map,Function.comp_def] using mapped

theorem readers_cover (target : Reader (4*blocks)) : target ∈ readers blocks := by
  let block : Fin blocks := ⟨target.1.val/4,by have := target.1.isLt; omega⟩
  let inner : Fin 4 := ⟨target.1.val%4,by omega⟩
  have equal : reader (block,target.2) inner=target := by
    apply Prod.ext
    · apply Fin.ext
      dsimp [reader,head,block,inner]
      omega
    · rfl
  rw [← equal]
  exact List.mem_flatMap.mpr ⟨(block,target.2),List.mem_product.mpr ⟨List.mem_finRange _,List.mem_finRange _⟩,
    List.mem_map.mpr ⟨inner,List.mem_finRange _,rfl⟩⟩

theorem labels_flatten (blocks : Nat) : (labelPrograms blocks).flatten=(readers blocks).flatMap readerHistory := by
  simp only [labelPrograms,readers,List.flatten_eq_flatMap,List.flatMap_map,List.flatMap_assoc,id_eq]

theorem label_member (label : Label (4*blocks)) : label ∈ (labelPrograms blocks).flatten := by
  rw [labels_flatten]
  apply List.mem_flatMap.mpr
  refine ⟨label.1,readers_cover label.1,?_⟩
  have bound := label.2.isLt
  rcases (show label.2.val=0 ∨ label.2.val=1 by omega) with h|h
  · have equal : label.2=0 := Fin.ext h
    exact List.mem_cons.mpr (Or.inl (Prod.ext rfl equal))
  · have equal : label.2=1 := Fin.ext h
    exact List.mem_cons.mpr (Or.inr (List.mem_singleton.mpr (Prod.ext rfl equal)))

variable {blocks base : Nat} {x : Fin (4*blocks) → Fin 256 → BF}
  {p : Rope.Platform} {source : Input x base} {theta : Fin (4*blocks) → Fin 32 → Float32}

-- Store schedules follow exact general-kernel four-head thread ownership.
-- The dynamic relation independently checks real heap captures and write
-- order. Native captures are a subset of the allowed safe capture timings.
structure Execution (p : Rope.Platform) (source : Input x base) (theta : Fin (4*blocks) → Fin 32 → Float32) where
  events : List (Event (4*blocks))
  finish : State (4*blocks)
  dynamic : RopeRowsDynamicMemory.Executes p base theta (initial source.memory) events finish
  remaining : List (List (Label (4*blocks)))
  stores : ThreadgroupWrites.Executes (labelPrograms blocks) finish.history remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Execution.canonical (p : Rope.Platform) (source : Input x base)
    (theta : Fin (4*blocks) → Fin 32 → Float32) : Execution p source theta where
  events := (readers blocks).flatMap readerEvents
  finish := runReaders p base theta (readers blocks) (initial source.memory)
  dynamic := runReaders_execution _ (readers_nodup blocks) _ initial_valid (by intro _ _; rfl)
  remaining := List.replicate (labelPrograms blocks).length []
  stores := by
    rw [runReaders_history]
    simp only [initial,List.nil_append,← labels_flatten]
    exact ThreadgroupWrites.canonical _
  completed := ThreadgroupWrites.canonical_barrier _

theorem Execution.read (e : Execution p source theta) (h : Fin (4*blocks)) (i : Fin 64) :
    HalfMemory.load e.finish.memory (base+512*h.val+2*i.val)=rotated p x theta h i := by
  have valid := preserves e.dynamic initial_valid
  rw [valid.memory,HalfMemory.execute_load _ _ _ (by have := source.aligned; omega),
    show (base+512*h.val+2*i.val)/2=base/2+256*h.val+i.val by omega]
  apply MemoryCells.completed_value (ArrayRelocation.map_execution (fixed p base x theta) e.stores)
    (ArrayRelocation.map_barrier _ _ e.completed)
  · intro store member same
    obtain ⟨thread,threadMember,storeMember⟩ := List.mem_flatten.mp member
    obtain ⟨original,originalMember,rfl⟩ := List.mem_map.mp threadMember
    obtain ⟨label,labelMember,rfl⟩ := List.mem_map.mp storeMember
    have idx := (RopeDevice.index label.1.2 label.2).isLt
    have ib := i.isLt
    have sameHead : label.1.1=h := by apply Fin.ext; dsimp [fixed,entry] at same; omega
    have sameIndex : RopeDevice.index label.1.2 label.2=i := by apply Fin.ext; dsimp [fixed,entry] at same; rw [sameHead] at same; omega
    change rotated p x theta label.1.1 (RopeDevice.index label.1.2 label.2)=rotated p x theta h i
    rw [sameHead,sameIndex]
  · let lane : Fin 32 := ⟨i.val%32,by omega⟩
    let half : Fin 2 := ⟨i.val/32,by have := i.isLt; omega⟩
    let label : Label (4*blocks) := ((h,lane),half)
    obtain ⟨thread,present,inside⟩ := List.mem_flatten.mp (label_member label)
    refine ⟨fixed p base x theta label,List.mem_flatten.mpr ⟨thread.map (fixed p base x theta),
      List.mem_map.mpr ⟨thread,present,rfl⟩,List.mem_map.mpr ⟨label,inside,rfl⟩⟩,?_⟩
    dsimp [fixed,entry,label,RopeDevice.index,lane,half]
    omega

theorem Execution.tail_byte (e : Execution p source theta) (h : Fin (4*blocks)) (offset : Nat)
    (lower : 128≤offset) (upper : offset<512) :
    e.finish.memory (base+512*h.val+offset)=source.memory (base+512*h.val+offset) := by
  have valid := preserves e.dynamic initial_valid
  rw [valid.memory,← MemoryProjection.halves]
  apply MemoryProjection.frame
  intro store member memory
  obtain ⟨label,present,rfl⟩ := List.mem_map.mp member
  have idx := (RopeDevice.index label.1.2 label.2).isLt
  have aligned := source.aligned
  have miss : ¬(2*(fixed p base x theta label).word≤base+512*h.val+offset ∧
      base+512*h.val+offset<2*(fixed p base x theta label).word+2) := by
    dsimp [fixed,entry]
    omega
  simp only [MemoryProjection.halfWrite,HalfMemory.store,miss,ite_false]

theorem Execution.raw_read (e : Execution p source theta) (h : Fin (4*blocks)) (i : Fin 256) :
    HalfMemory.load e.finish.memory (base+512*h.val+2*i.val)=ArrayStorage.bits (Rope.head p (x h) (theta h) i) := by
  by_cases inside : i.val<64
  · exact e.read h ⟨i.val,inside⟩
  · have bound := i.isLt
    have lower : 64 ≤ i.val := by omega
    rw [Rope.unchanged p (x h) (theta h) i lower,← source.attached h i]
    simp only [HalfMemory.load]
    rw [Nat.add_assoc (base+512*h.val) (2*i.val) 1,Nat.add_assoc (base+512*h.val) (2*i.val) 0]
    rw [e.tail_byte h _ (by omega) (by omega),e.tail_byte h _ (by omega) (by omega)]

def Execution.output (e : Execution p source theta) : Input (fun h => Rope.head p (x h) (theta h)) base where
  memory := e.finish.memory
  aligned := source.aligned
  bounded := source.bounded
  attached := e.raw_read

theorem Execution.frame (e : Execution p source theta) (address : Nat)
    (outside : address<base ∨ base+512*(4*blocks)≤address) : e.finish.memory address=source.memory address := by
  have valid := preserves e.dynamic initial_valid
  rw [valid.memory]
  apply MemoryRegions.execute16_frame _ _ (base := base) (size := 512*(4*blocks)) _ outside
  intro store present
  obtain ⟨label,present,rfl⟩ := List.mem_map.mp present
  have headBound := label.1.1.isLt
  have indexBound := (RopeDevice.index label.1.2 label.2).isLt
  have aligned := source.aligned
  dsimp [fixed,entry]
  omega

-- The single-token fast path has one pair program per (head,lane).
def singleLabelPrograms (rows : Nat) : List (List (Label rows)) :=
  (allReaders rows).map readerHistory

theorem single_store_programs (p : Rope.Platform) (base : Nat) (x : Fin rows → Fin 256 → BF)
    (theta : Fin rows → Fin 32 → Float32) :
    (singleLabelPrograms rows).map (List.map (fixed p base x theta))=programs base (rotated p x theta) := by
  simp only [singleLabelPrograms,allReaders,List.product,List.map_flatMap,List.map_map,Function.comp_def,programs]
  apply congrArg (List.flatMap · (List.finRange rows))
  funext h
  apply congrArg (List.map · (List.finRange 32))
  funext lane
  simp only [readerHistory,List.map_cons,List.map_nil,List.finRange_succ,List.finRange_zero]
  rfl

theorem single_execution_legal (e : RopeRowsDynamicMemory.Execution p source theta) :
    ThreadgroupWrites.Executes ((singleLabelPrograms (4*blocks)).map (List.map (fixed p base x theta)))
      e.physical.trace.schedule e.physical.trace.remaining := by
  rw [single_store_programs]
  exact e.physical.trace.execution

theorem single_canonical_completed (p : Rope.Platform) (source : Input x base)
    (theta : Fin (4*blocks) → Fin 32 → Float32) :
    ThreadgroupWrites.Executes (singleLabelPrograms (4*blocks))
      (RopeRowsDynamicMemory.Execution.canonical p source theta).finish.history
      (List.replicate (singleLabelPrograms (4*blocks)).length []) := by
  change ThreadgroupWrites.Executes _ (runReaders p base theta (allReaders (4*blocks)) (initial source.memory)).history _
  rw [runReaders_history]
  simp only [initial,List.nil_append]
  change ThreadgroupWrites.Executes _ (singleLabelPrograms (4*blocks)).flatten _
  exact ThreadgroupWrites.canonical _

def singleSelected (rowContiguous : Bool) (tokens offsetCount : Nat) : Bool :=
  rowContiguous && decide (tokens=1) && decide (offsetCount=1)

theorem single_decode : singleSelected true 1 1=true := rfl

theorem general_multiple_tokens (contiguous : Bool) (tokens offsets : Nat) (multiple : tokens≠1) :
    singleSelected contiguous tokens offsets=false := by simp [singleSelected,multiple]

theorem general_multiple_offsets (contiguous : Bool) (tokens offsets : Nat) (multiple : offsets≠1) :
    singleSelected contiguous tokens offsets=false := by simp [singleSelected,multiple]

end Inference.Kernels.Attention.RopeRowsLaunchMemory
