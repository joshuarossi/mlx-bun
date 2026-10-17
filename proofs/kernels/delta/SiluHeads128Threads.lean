import kernels.delta.SiluHeads128Geometry

namespace Inference.Kernels.Delta.SiluHeads128Threads
open Contracts.Mlx SiluHeads128Geometry SiluHeads128Output GatedInputs
set_option maxRecDepth 2000
attribute [local irreducible] SiluHeads128Output.normalized SiluHeads128Output.value CopyContiguous.programs

abbrev Initial := Fin 32 → Fin 4 → ArrayStorage.BF

def normalizedValues (p : SiluRmsHeads.Platform) (data : Fin 16 → Nat → ArrayStorage.BF)
    (scale : Fin 128 → ArrayStorage.BF) (h : Fin 16) (col : Fin 128) : ArrayStorage.BF :=
  SiluRmsHeads.sourceNormalized p (fun j : Fin 128 => data h j.val) scale width epsilon col

def normalizedThread (p : SiluRmsHeads.Platform) (data : Fin 16 → Nat → ArrayStorage.BF)
    (scale : Fin 128 → ArrayStorage.BF) (base : Nat) (thread : Fin 512) (initial : Initial) : Option (List HalfMemory.Store) := do
  let result ←SiluHeads128Output.normalized p (data (head (heads := 16) thread)) scale (lane (heads := 16) thread) initial
  pure ((List.finRange 4).map (fun i =>
    ⟨base/2+(head (heads := 16) thread).val*128+(Gated.laneIndex (lane (heads := 16) thread) i).val,ArrayStorage.bits (result i)⟩))

theorem normalized_thread (p : SiluRmsHeads.Platform) (data : Fin 16 → Nat → ArrayStorage.BF)
    (scale : Fin 128 → ArrayStorage.BF) (base : Nat) (thread : Fin 512) (initial : Initial) :
    normalizedThread p data scale base thread initial=some (CopyContiguous.threadStores base
      (fun i => ArrayStorage.bits (flatten (normalizedValues p data scale) i)) thread) := by
  unfold normalizedThread
  rw [normalized_eq]
  change some ((List.finRange 4).map _)=_
  unfold CopyContiguous.threadStores
  apply congrArg some
  apply List.map_congr_left
  intro i _
  have same : CopyContiguous.index thread i=index (head (heads := 16) thread) (Gated.laneIndex (lane (heads := 16) thread) i) := by
    apply Fin.ext
    exact (thread_index (heads := 16) thread i).symm
  dsimp only [CopyContiguous.entry]
  rw [same,flatten_index]
  simp only [normalizedValues,index,Nat.add_assoc]

def valueValues (p : SiluRmsHeads.Platform) (data : Fin 48 → Nat → ArrayStorage.BF)
    (h : Fin 48) (col : Fin 128) : ArrayStorage.BF := SiluRmsHeads.activate p (data h col.val)

def valueThread (p : SiluRmsHeads.Platform) (data : Fin 48 → Nat → ArrayStorage.BF)
    (base : Nat) (thread : Fin 1536) (initial : Initial) : Option (List HalfMemory.Store) := do
  let result ←SiluHeads128Output.value p (data (head (heads := 48) thread)) (lane (heads := 48) thread) initial
  pure ((List.finRange 4).map (fun i =>
    ⟨base/2+(head (heads := 48) thread).val*128+(Gated.laneIndex (lane (heads := 48) thread) i).val,ArrayStorage.bits (result i)⟩))

theorem value_thread (p : SiluRmsHeads.Platform) (data : Fin 48 → Nat → ArrayStorage.BF)
    (base : Nat) (thread : Fin 1536) (initial : Initial) :
    valueThread p data base thread initial=some (CopyContiguous.threadStores base
      (fun i => ArrayStorage.bits (flatten (valueValues p data) i)) thread) := by
  unfold valueThread
  rw [value_eq]
  change some ((List.finRange 4).map _)=_
  unfold CopyContiguous.threadStores
  apply congrArg some
  apply List.map_congr_left
  intro i _
  have same : CopyContiguous.index thread i=index (head (heads := 48) thread) (Gated.laneIndex (lane (heads := 48) thread) i) := by
    apply Fin.ext
    exact (thread_index (heads := 48) thread i).symm
  dsimp only [CopyContiguous.entry]
  rw [same,flatten_index]
  simp only [valueValues,index,Nat.add_assoc]

private theorem mapM_values {α β : Type} (source : α → Option β) (value : α → β)
    (same : ∀ a, source a=some (value a)) (items : List α) :
    items.mapM source=some (items.map value) := by
  induction items with
  | nil => rfl
  | cons a rest ih =>
    simp only [List.mapM_cons,List.map_cons,same,bind,Option.bind,ih]
    rfl

def normalizedPrograms (p : SiluRmsHeads.Platform) (data : Fin 16 → Nat → ArrayStorage.BF)
    (scale : Fin 128 → ArrayStorage.BF) (base : Nat) (initial : Initial) : Option (List (List HalfMemory.Store)) :=
  (List.finRange 512).mapM (fun thread => normalizedThread p data scale base thread initial)

theorem normalized_programs (p : SiluRmsHeads.Platform) (data : Fin 16 → Nat → ArrayStorage.BF)
    (scale : Fin 128 → ArrayStorage.BF) (base : Nat) (initial : Initial) :
    normalizedPrograms p data scale base initial=some (CopyContiguous.programs (blocks := 512) base
      (fun i => ArrayStorage.bits (flatten (normalizedValues p data scale) i))) := by
  rw [normalizedPrograms,CopyContiguous.programs]
  exact mapM_values _ _ (fun thread => normalized_thread p data scale base thread initial) _

def valuePrograms (p : SiluRmsHeads.Platform) (data : Fin 48 → Nat → ArrayStorage.BF)
    (base : Nat) (initial : Initial) : Option (List (List HalfMemory.Store)) :=
  (List.finRange 1536).mapM (fun thread => valueThread p data base thread initial)

theorem value_programs (p : SiluRmsHeads.Platform) (data : Fin 48 → Nat → ArrayStorage.BF)
    (base : Nat) (initial : Initial) :
    valuePrograms p data base initial=some (CopyContiguous.programs (blocks := 1536) base
      (fun i => ArrayStorage.bits (flatten (valueValues p data) i))) := by
  rw [valuePrograms,CopyContiguous.programs]
  exact mapM_values _ _ (fun thread => value_thread p data base thread initial) _

end Inference.Kernels.Delta.SiluHeads128Threads
