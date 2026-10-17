import contracts.mlx.CopyExecution

namespace Inference.Contracts.Mlx.CopyDispatchCommutation
open CopyExecution

-- Completed dispatch ordering only. These are current-heap loads and stores,
-- not a claim about extraction of command scheduling from the native runtime.
def step (operation : Operation) (memory : ByteMemory.Bytes) : ByteMemory.Bytes :=
  HalfMemory.store memory (2*operation.destination) (HalfMemory.load memory (2*operation.source))

structure Separate (left right : Operation) : Prop where
  destinations : left.destination≠right.destination
  leftSource : left.source≠right.destination
  rightSource : right.source≠left.destination

def Independent (left right : List Operation) : Prop :=
  ∀ a∈left, ∀ b∈right, Separate a b

theorem store_commute (memory : ByteMemory.Bytes) (left right : Nat) (a b : BitVec 16)
    (different : left≠right) :
    HalfMemory.store (HalfMemory.store memory (2*left) a) (2*right) b=
      HalfMemory.store (HalfMemory.store memory (2*right) b) (2*left) a := by
  funext address
  by_cases l : 2*left≤address ∧ address<2*left+2
  · have r : ¬(2*right≤address ∧ address<2*right+2) := by omega
    simp only [HalfMemory.store,l,r,ite_false]
  · simp only [HalfMemory.store,l,ite_false]

theorem step_commute (memory : ByteMemory.Bytes) (separate : Separate left right) :
    step right (step left memory)=step left (step right memory) := by
  unfold step
  rw [load_store_other _ _ _ _ separate.rightSource,load_store_other _ _ _ _ separate.leftSource]
  exact store_commute memory _ _ _ _ separate.destinations

theorem one_many (operation : Operation) (others : List Operation)
    (separate : ∀ other∈others, Separate operation other) (memory : ByteMemory.Bytes) :
    execute others (step operation memory)=step operation (execute others memory) := by
  induction others generalizing memory with
  | nil => rfl
  | cons other rest ih =>
      change execute rest (step other (step operation memory))=_
      rw [step_commute memory (separate other List.mem_cons_self)]
      rw [ih (fun op member => separate op (List.mem_cons_of_mem _ member))]
      rfl

theorem execute_commute (left right : List Operation) (separate : Independent left right)
    (memory : ByteMemory.Bytes) : execute right (execute left memory)=execute left (execute right memory) := by
  induction left generalizing memory with
  | nil => rfl
  | cons operation rest ih =>
      change execute right (execute rest (step operation memory))=_
      rw [ih (fun op member => separate op (List.mem_cons_of_mem _ member))]
      rw [one_many operation right (separate operation List.mem_cons_self)]
      rfl

theorem independent_append (a b c : List Operation) (ab : Independent a b) (ac : Independent a c) :
    Independent a (b++c) := by
  intro x hx y hy
  rcases List.mem_append.mp hy with h|h
  · exact ab x hx y h
  · exact ac x hx y h

theorem execute_append (left right : List Operation) (memory : ByteMemory.Bytes) :
    execute (left++right) memory=execute right (execute left memory) := by
  induction left generalizing memory with
  | nil => rfl
  | cons operation rest ih => exact ih _

theorem execute_frame (operations : List Operation)
    (inside : ∀ op∈operations, destination≤2*op.destination ∧ 2*op.destination+2≤destination+size)
    (separate : MemoryRegions.Disjoint destination size other otherSize)
    (memory : ByteMemory.Bytes) (offset : Nat) (bound : offset<otherSize) :
    execute operations memory (other+offset)=memory (other+offset) := by
  induction operations generalizing memory with
  | nil => rfl
  | cons op rest ih =>
      change execute rest (step op memory) (other+offset)=_
      rw [ih (fun p hp => inside p (List.mem_cons_of_mem _ hp))]
      have address := inside op List.mem_cons_self
      have outside : ¬(2*op.destination≤other+offset ∧ other+offset<2*op.destination+2) := by
        unfold MemoryRegions.Disjoint at separate
        omega
      simp only [step,HalfMemory.store,outside,ite_false]

structure Footprint (operations : List Operation) (source sourceBytes destination destinationBytes : Nat) : Prop where
  reads : ∀ op∈operations, source≤2*op.source ∧ 2*op.source+2≤source+sourceBytes
  writes : ∀ op∈operations, destination≤2*op.destination ∧ 2*op.destination+2≤destination+destinationBytes

theorem footprints_independent
    (a : Footprint left aSource aSize aDestination aBytes)
    (b : Footprint right bSource bSize bDestination bBytes)
    (writes : MemoryRegions.Disjoint aDestination aBytes bDestination bBytes)
    (aReads : MemoryRegions.Disjoint aSource aSize bDestination bBytes)
    (bReads : MemoryRegions.Disjoint bSource bSize aDestination aBytes) : Independent left right := by
  intro l hl r hr
  have la := a.reads l hl
  have lw := a.writes l hl
  have ra := b.reads r hr
  have rw := b.writes r hr
  unfold MemoryRegions.Disjoint at writes aReads bReads
  constructor <;> omega

end Inference.Contracts.Mlx.CopyDispatchCommutation
