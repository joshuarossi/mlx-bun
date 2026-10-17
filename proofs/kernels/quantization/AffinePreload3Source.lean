import kernels.quantization.AffineInput3Source
import kernels.quantization.AffinePreload4Source
namespace Inference.Kernels.Quantization.AffinePreload3Source
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open AffinePreload4Syntax
open AffinePreload4Source (sourceVisits source_visits)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] AffinePreload4Syntax.parse AffineInput3Syntax.parse AffineScratch4Source.parse

variable (p : AffineTile.Platform) {x : Fin (steps*32) → Fin 16 → AffineInput.BF}
  (buffers : ∀ chunk, ArrayStorage.BFBuffer (x chunk))

def privateCells (chunk : Fin (steps*32)) : Nat → Float32 :=
  MemoryCells.execute (AffineInput4Source.stores p.divide (buffers chunk).bytes (buffers chunk).base
    AffineInput3Syntax.body [0,8]) (fun _ => 0)
def chunkSum (chunk : Fin (steps*32)) : Float32 :=
  AffineInput4Source.sum (buffers chunk).bytes (buffers chunk).base AffineInput3Syntax.body [0,8]
def ssStore (chunk : Fin (steps*32)) : MemoryCells.Store Float32 := ⟨steps*32*16+chunk.val,chunkSum buffers chunk⟩
def xsStore (chunk : Fin (steps*32)) (column : Fin 16) : MemoryCells.Store Float32 :=
  ⟨chunk.val*16+column.val,privateCells p buffers chunk column.val⟩
def chunkProgram (chunk : Fin (steps*32)) : List (MemoryCells.Store Float32) :=
  ssStore buffers chunk::(List.finRange 16).map (xsStore p buffers chunk)

-- Parsing both the loader and its caller produces the same ordered writes:
-- ss first, followed by the sixteen private-to-threadgroup xs copies.
def sourceProgram (chunk : Fin (steps*32)) : Option (List (MemoryCells.Store Float32)) := do
  let h ←AffineScratch4Source.parse AffineScratch4Source.sourcePublish
  if h.inputWidth≠16 ∨ h.start≠0 ∨ h.bound≠16 then none else do
    let (sum,cells) ←AffineInput3Source.execute p.divide (buffers chunk).bytes (buffers chunk).base (fun _ => 0)
    pure (⟨steps*32*16+chunk.val,sum⟩::AffineScratch4Source.copies (chunk.val*h.outputWidth) cells)

theorem source_program (chunk : Fin (steps*32)) : sourceProgram p buffers chunk=some (chunkProgram p buffers chunk) := by
  simp only [sourceProgram,AffineScratch4Source.parsed_publish]
  change (do let (sum,cells) ←AffineInput3Source.execute p.divide (buffers chunk).bytes (buffers chunk).base (fun _ => 0)
             pure ((⟨steps*32*16+chunk.val,sum⟩ : MemoryCells.Store Float32)::AffineScratch4Source.copies (chunk.val*16) cells))=_
  simp only [AffineInput3Source.execute,AffineInput4Syntax.parsed_initializer,AffineInput3Syntax.parsed_branch,AffineInput3Syntax.parsed_loop,
    AffineInput4Syntax.parsed_return]
  rfl

def threadProgram (thread : Fin 512) : List (MemoryCells.Store Float32) :=
  if h : thread.val<steps*32 then chunkProgram p buffers ⟨thread.val,h⟩ else []
def programs : List (List (MemoryCells.Store Float32)) := (List.finRange 512).map (threadProgram p buffers)

def sourceThread (thread : Fin 512) : Option (List (MemoryCells.Store Float32)) := do
  let visits ←sourceVisits steps ⟨thread.val/32,by have := thread.isLt; omega⟩ ⟨thread.val%32,by omega⟩
  match visits with
  | [] => some []
  | [index] => if h : index<steps*32 then sourceProgram p buffers ⟨index,h⟩ else none
  | _ => none

theorem source_thread (hsteps : steps≤15) (thread : Fin 512) :
    sourceThread p buffers thread=some (threadProgram p buffers thread) := by
  unfold sourceThread
  rw [source_visits hsteps]
  have reconstruction : thread.val/32*32+thread.val%32=thread.val := by omega
  simp only [reconstruction]
  by_cases active : thread.val<steps*32
  · simp [active,threadProgram,source_program]
  · simp [active,threadProgram]

theorem member_origin {store : MemoryCells.Store Float32} (member : store∈(programs p buffers).flatten) :
    ∃ chunk, store=ssStore buffers chunk ∨ ∃ column, store=xsStore p buffers chunk column := by
  obtain ⟨thread,outer,inner⟩ := List.mem_flatten.mp member
  obtain ⟨owner,_,rfl⟩ := List.mem_map.mp outer
  unfold threadProgram at inner
  split at inner
  next active =>
    refine ⟨⟨owner.val,active⟩,?_⟩
    rcases List.mem_cons.mp inner with head|tail
    · exact Or.inl head
    · obtain ⟨column,_,equal⟩ := List.mem_map.mp tail
      exact Or.inr ⟨column,equal.symm⟩
  next => simp at inner

theorem chunk_member (hsteps : steps≤15) (chunk : Fin (steps*32)) : chunkProgram p buffers chunk∈programs p buffers := by
  have bounded : chunk.val<512 := by have := chunk.isLt; omega
  apply List.mem_map.mpr
  refine ⟨⟨chunk.val,bounded⟩,List.mem_finRange _,?_⟩
  simp only [threadProgram,chunk.isLt,↓reduceDIte]

theorem xs_completed (hsteps : steps≤15) {schedule after}
    (execution : ThreadgroupWrites.Executes (programs p buffers) schedule after)
    (barrier : ThreadgroupWrites.AtBarrier after) (before : Nat → Float32)
    (chunk : Fin (steps*32)) (column : Fin 16) :
    MemoryCells.execute schedule before (chunk.val*16+column.val)=privateCells p buffers chunk column.val := by
  apply MemoryCells.completed_value execution barrier
  · intro store member equal
    obtain ⟨other,ss|⟨offset,xs⟩⟩ := member_origin p buffers member
    · subst store
      have := chunk.isLt; have := column.isLt
      dsimp [ssStore] at equal
      omega
    · subst store
      have same := AffineLayout.scratch_injective other chunk offset column equal
      rcases same with ⟨rfl,rfl⟩
      rfl
  · refine ⟨xsStore p buffers chunk column,List.mem_flatten.mpr ⟨chunkProgram p buffers chunk,
      chunk_member p buffers hsteps chunk,?_⟩,rfl⟩
    exact List.mem_cons_of_mem _ (List.mem_map.mpr ⟨column,List.mem_finRange _,rfl⟩)

theorem ss_completed (hsteps : steps≤15) {schedule after}
    (execution : ThreadgroupWrites.Executes (programs p buffers) schedule after)
    (barrier : ThreadgroupWrites.AtBarrier after) (before : Nat → Float32) (chunk : Fin (steps*32)) :
    MemoryCells.execute schedule before (steps*32*16+chunk.val)=AffineInput.summed (x chunk) AffineInput.groups3 := by
  apply MemoryCells.completed_value execution barrier
  · intro store member equal
    obtain ⟨other,ss|⟨offset,xs⟩⟩ := member_origin p buffers member
    · subst store
      have same : other=chunk := Fin.ext (by simpa [ssStore] using equal)
      subst other
      exact AffineInput3Source.sum_eq (buffers chunk)
    · subst store
      have := other.isLt; have := offset.isLt
      dsimp [xsStore] at equal
      omega
  · refine ⟨ssStore buffers chunk,List.mem_flatten.mpr ⟨chunkProgram p buffers chunk,
      chunk_member p buffers hsteps chunk,by simp [chunkProgram]⟩,rfl⟩

def scratch (memory : Nat → Float32) : AffineScratch4Source.Scratch :=
  ⟨memory,fun chunk => memory (steps*32*16+chunk)⟩

theorem completed_scratch (hsteps : steps≤15) {schedule after}
    (execution : ThreadgroupWrites.Executes (programs p buffers) schedule after)
    (barrier : ThreadgroupWrites.AtBarrier after) (before : Nat → Float32) :
    ∀ chunk : Fin (steps*32),
      (scratch (steps:=steps) (MemoryCells.execute schedule before)).ss chunk.val=AffineInput.summed (x chunk) AffineInput.groups3 ∧
      ∀ (i : Fin 2) (j : Fin 8),
        (scratch (steps:=steps) (MemoryCells.execute schedule before)).xs (chunk.val*16+8*i.val+j.val)=AffineTile.prepared3 p (x chunk) i j := by
  intro chunk
  refine ⟨ss_completed p buffers hsteps execution barrier before chunk,?_⟩
  intro i j
  have cell := xs_completed p buffers hsteps execution barrier before chunk (AffineInput.index8 i j)
  have prepared := AffineInput3Source.private_cells p (buffers chunk) (fun _ => 0) i j
  have index : (AffineInput.index8 i j).val=8*i.val+j.val := by simp [AffineInput.index8,Nat.mul_comm]
  rw [index] at cell
  simpa only [scratch,Nat.add_assoc] using cell.trans prepared

structure SourceTrace (schedule : List (MemoryCells.Store Float32)) (after : List (List (MemoryCells.Store Float32))) : Prop where
  sourceOwned : ∀ thread, sourceThread p buffers thread=some (threadProgram p buffers thread)
  barrierParsed : parseBarrier sourceBarrier=some ()
  execution : ThreadgroupWrites.Executes (programs p buffers) schedule after
  completed : ThreadgroupWrites.AtBarrier after

theorem canonical_source_scratch (hsteps : steps≤15) (before : Nat → Float32) :
    ∃ schedule after, SourceTrace p buffers schedule after ∧
      ∀ chunk : Fin (steps*32),
        (scratch (steps:=steps) (MemoryCells.execute schedule before)).ss chunk.val=AffineInput.summed (x chunk) AffineInput.groups3 ∧
        ∀ (i : Fin 2) (j : Fin 8),
          (scratch (steps:=steps) (MemoryCells.execute schedule before)).xs (chunk.val*16+8*i.val+j.val)=AffineTile.prepared3 p (x chunk) i j := by
  exact ⟨_,_,⟨source_thread p buffers hsteps,parsed_barrier,ThreadgroupWrites.canonical _,ThreadgroupWrites.canonical_barrier _⟩,
    completed_scratch p buffers hsteps (ThreadgroupWrites.canonical _) (ThreadgroupWrites.canonical_barrier _) before⟩

theorem outside_frame {schedule after} (execution : ThreadgroupWrites.Executes (programs p buffers) schedule after)
    (before : Nat → Float32) (word : Nat) (outside : steps*32*17≤word) :
    MemoryCells.execute schedule before word=before word := by
  apply MemoryCells.frame
  intro store member equal
  have origin : store∈(programs p buffers).flatten := by
    have conservation := ThreadgroupWrites.conservation execution
    exact conservation.mem_iff.mpr (List.mem_append_left _ member)
  obtain ⟨chunk,ss|⟨column,xs⟩⟩ := member_origin p buffers origin
  · subst store
    have := chunk.isLt
    dsimp [ssStore] at equal
    omega
  · subst store
    have := chunk.isLt; have := column.isLt
    dsimp [xsStore] at equal
    omega
end Inference.Kernels.Quantization.AffinePreload3Source
