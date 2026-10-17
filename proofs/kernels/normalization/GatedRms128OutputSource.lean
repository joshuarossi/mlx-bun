import kernels.normalization.GatedRms128TailSource

namespace Inference.Kernels.Normalization.GatedRms128OutputSource
open Contracts.Mlx GatedRms128Syntax GatedRms128TailSource
open Delta.GatedInputs
set_option maxRecDepth 2000
attribute [local irreducible] parseOutput GatedRms128TailSource.inverse CopyContiguous.programs

def head (thread : Fin 1536) : Fin 48 := ⟨thread.val/32,by have := thread.isLt; omega⟩
def lane (thread : Fin 1536) : Fin 32 := ⟨thread.val%32,by omega⟩
def column (thread : Fin 1536) (i : Fin 4) : Fin 128 := Delta.Gated.laneIndex (lane thread) i
def offset (thread : Fin 1536) (i : Fin 4) : Nat := (head thread).val*128+(column thread i).val

theorem offset_index (thread : Fin 1536) (i : Fin 4) : offset thread i=(CopyContiguous.index thread i).val := by
  have := thread.isLt
  dsimp [offset,head,column,lane,Delta.Gated.laneIndex,CopyContiguous.index]
  omega

variable {x gate : GatedRmsNormDevice.Rows} {weights : Fin 128 → ArrayStorage.BF}
  {input : GatedRmsNormMemory.Input x gate weights}

def inverseValue (p : GatedRmsNorm.Platform) (input : GatedRmsNormMemory.Input x gate weights)
    (epsilon : BitVec 32) (h : Fin 48) : Float32 :=
  p.rsqrt (FlushToZero.add (p.divide
    (Delta.SiluRmsHeads.sourceSum p.reduce p.contracted
      (fun i => BFloat16.widen (input.storage.input.read (index h i)))) width) (FloatMemory.decode epsilon))

theorem inverse_value (p : GatedRmsNorm.Platform) (input : GatedRmsNormMemory.Input x gate weights)
    (epsilon : BitVec 32) (h : Fin 48) :
    GatedRms128TailSource.inverse p (GatedRms128FirstSource.current input h) epsilon=some (inverseValue p input epsilon h) :=
  inverse_eq p (GatedRms128FirstSource.current input h) epsilon

theorem scalar_value (p : GatedRmsNorm.Platform) (input : GatedRmsNormMemory.Input x gate weights)
    (epsilon : BitVec 32) (h : Fin 48) (col : Fin 128) :
    scalar p (input.storage.input.read (index h col)) (input.storage.weight.read col)
      (input.storage.gate.read (index h col)) (inverseValue p input epsilon h)=
      GatedRmsNormDevice.produced p width (FloatMemory.decode epsilon) input.storage h col := by
  rw [scalar_eq]
  unfold GatedRmsNormDevice.produced GatedRmsNorm.sourceNormalized GatedRmsNorm.input inverseValue
  rfl

-- Each lane computes its shared SIMD inverse once, then emits its four
-- stores in native loop order. All loads use the supplied current heap.
def threadProgram (p : GatedRmsNorm.Platform) (input : GatedRmsNormMemory.Input x gate weights)
    (epsilon : BitVec 32) (base : Nat) (thread : Fin 1536) : Option (List HalfMemory.Store) := do
  let inv ←GatedRms128TailSource.inverse p (GatedRms128FirstSource.current input (head thread)) epsilon
  let _ ←parseOutput outputSource
  pure ((List.finRange 4).map (fun i =>
    ⟨base/2+offset thread i,ArrayStorage.bits (scalar p
      (input.storage.input.read (index (head thread) (column thread i)))
      (input.storage.weight.read (column thread i))
      (input.storage.gate.read (index (head thread) (column thread i))) inv)⟩))

theorem source_thread (p : GatedRmsNorm.Platform) (input : GatedRmsNormMemory.Input x gate weights)
    (epsilon : BitVec 32) (base : Nat) (thread : Fin 1536) :
    threadProgram p input epsilon base thread=some (CopyContiguous.threadStores base
      (fun i => ArrayStorage.bits (flatten (GatedRmsNormDevice.produced p width (FloatMemory.decode epsilon) input.storage) i)) thread) := by
  unfold threadProgram
  rw [inverse_value,parsed_output]
  change some ((List.finRange 4).map _)=_
  unfold CopyContiguous.threadStores
  apply congrArg some
  apply List.map_congr_left
  intro i _
  rw [scalar_value]
  have index_eq : CopyContiguous.index thread i=index (head thread) (column thread i) := by
    apply Fin.ext
    exact (offset_index thread i).symm
  simp only [CopyContiguous.entry,index_eq,flatten_index,offset]
  rfl

def programs (p : GatedRmsNorm.Platform) (input : GatedRmsNormMemory.Input x gate weights)
    (epsilon : BitVec 32) (base : Nat) : Option (List (List HalfMemory.Store)) :=
  (List.finRange 1536).mapM (threadProgram p input epsilon base)

private theorem mapM_values {α β : Type} (source : α → Option β) (value : α → β)
    (same : ∀ a, source a=some (value a)) (items : List α) :
    items.mapM source=some (items.map value) := by
  induction items with
  | nil => rfl
  | cons a rest ih =>
    simp only [List.mapM_cons,List.map_cons,same,bind,Option.bind,ih]
    rfl

theorem source_programs (p : GatedRmsNorm.Platform) (input : GatedRmsNormMemory.Input x gate weights)
    (epsilon : BitVec 32) (base : Nat) :
    programs p input epsilon base=some (CopyContiguous.programs (blocks := 1536) base
      (fun i => ArrayStorage.bits (flatten (GatedRmsNormDevice.produced p width (FloatMemory.decode epsilon) input.storage) i))) := by
  rw [programs,CopyContiguous.programs]
  exact mapM_values _ _ (source_thread p input epsilon base) (List.finRange 1536)

theorem source_execution (p : GatedRmsNorm.Platform) (epsilon : BitVec 32)
    (execution : GatedRmsNormMemory.Execution input p width (FloatMemory.decode epsilon))
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 execution.base 12288 stores) :
    ∃ writes, programs p (execution.during stores inside) epsilon execution.base=some writes ∧
      ThreadgroupWrites.Executes writes execution.stores.schedule execution.stores.remaining ∧
      ThreadgroupWrites.AtBarrier execution.stores.remaining := by
  refine ⟨_,?_,execution.stores.execution,execution.stores.completed⟩
  rw [source_programs,execution.partial_produced stores inside]

theorem current_output (p : GatedRmsNorm.Platform) (epsilon : BitVec 32)
    (execution : GatedRmsNormMemory.Execution input p width (FloatMemory.decode epsilon)) (i : Fin 6144) :
    HalfMemory.load execution.stores.memory (execution.base+2*i.val)=
      ArrayStorage.bits (flatten (fun h => GatedRmsNorm.value p (x h) (gate h) weights width (FloatMemory.decode epsilon)) i) := by
  rw [execution.stores.read_correct,GatedRmsNormDevice.produced_eq]

end Inference.Kernels.Normalization.GatedRms128OutputSource
