import host.ts.RenameCleanupNotes

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def RetainedNotes.cleanup (notes : RetainedNotes) (pairs pending : Tree) (tail : List Tree) : RetainedNotes :=
  notes.withRuntime (notes.runtime.cleanup pairs pending tail)

theorem cleanupNext_heap {S : Type} (s : St S) (resources : List (Val × Val)) (pending : Comp) :
    (cleanupNext s resources pending).heap = s.heap := by cases resources <;> cases pending <;> rfl
theorem cleanupNext_ffi {S : Type} (s : St S) (resources : List (Val × Val)) (pending : Comp) :
    (cleanupNext s resources pending).ffi = s.ffi := by cases resources <;> cases pending <;> rfl
theorem cleanupNext_next {S : Type} (s : St S) (resources : List (Val × Val)) (pending : Comp) :
    (cleanupNext s resources pending).next = s.next := by cases resources <;> cases pending <;> rfl

/-- The current scope pair notes determine the disposal call notes. All six
inventories, native relation and pending completion survive unchanged. -/
theorem RetainedInventory.scope_cleanup_step {F : Ffi} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (FR : Ren → F.S → F.S → Prop)
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (pending : Comp) (resource method : Val) (rest : List (Val × Val)) (frames : List Frame)
    (control : s₀.ctl = completionControl pending)
    (stack : s₀.stack = .s (.scope ((resource,method)::rest))::frames)
    (pairsNote : Tree) (tailNotes : List Tree)
    (stackNotes : notes.runtime.stack = cleanupScopeNote pairsNote::tailNotes) :
    ∃ targetPending targetResources targetFrames,
      interpC (step F s₀).run C₀ = some (cleanupNext {s₀ with stack := frames} ((resource,method)::rest) pending,C₀) ∧
      interpC (step F s).run C = some (cleanupNext {s with stack := targetFrames} targetResources targetPending,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (cleanupNext {s₀ with stack := frames} ((resource,method)::rest) pending)
        (cleanupNext {s with stack := targetFrames} targetResources targetPending) ∧
      RetainedInventory (notes.cleanup pairsNote (cleanupCompletionNote notes.runtime.control) tailNotes)
        ν₀ ν C₀ C R live (cleanupNext {s₀ with stack := frames} ((resource,method)::rest) pending)
        (cleanupNext {s with stack := targetFrames} targetResources targetPending) := by
  obtain ⟨targetPending,targetResources,targetFrames,targetControl,targetStack,left,right,post⟩ :=
    step_scope_cleanup_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old'
      s₀ s h pending resource method rest frames control stack
  have sourceStack := inventory.runtime.source.stack
  have targetHeld := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetHeld
  have sourceControl := inventory.runtime.source.control
  have targetControlHeld := inventory.runtime.target.control
  rw [control] at sourceControl
  rw [targetControl] at targetControlHeld
  have runtime : RuntimeInventory
      (notes.runtime.cleanup pairsNote (cleanupCompletionNote notes.runtime.control) tailNotes)
      ν₀ ν C₀ C R live (cleanupNext {s₀ with stack := frames} ((resource,method)::rest) pending)
      (cleanupNext {s with stack := targetFrames} targetResources targetPending) :=
    ⟨by simpa only [RuntimeNotes.cleanup_cells] using inventory.runtime.keyLive,
      RuntimeNotes.cleanup_holds (cleanupScopeNote_view sourceStack.head) (cleanupCompletionNote_holds sourceControl)
        sourceStack.tail inventory.runtime.source.cells,
      RuntimeNotes.cleanup_holds (cleanupScopeNote_view targetHeld.head) (cleanupCompletionNote_holds targetControlHeld)
        targetHeld.tail inventory.runtime.target.cells⟩
  exact ⟨targetPending,targetResources,targetFrames,left,right,post,
    inventory.heap_step runtime (cleanupNext_heap _ _ _) (cleanupNext_heap _ _ _) (.refl C₀) (.refl C)⟩

/-- A disposer return consumes its saved pair list and resumes precisely its
saved completion. No role is inferred from the discarded return value. -/
theorem RetainedInventory.dispose_cleanup_step {F : Ffi} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (FR : Ren → F.S → F.S → Prop)
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (returned : Val) (pending : Comp) (resources : List (Val × Val)) (frames : List Frame)
    (control : s₀.ctl = .ret returned) (stack : s₀.stack = .s (.dispose resources pending)::frames)
    (pairsNote pendingNote : Tree) (tailNotes : List Tree)
    (stackNotes : notes.runtime.stack = cleanupDisposeNote pairsNote pendingNote::tailNotes) :
    ∃ targetPending targetResources targetFrames,
      interpC (step F s₀).run C₀ = some (cleanupNext {s₀ with stack := frames} resources pending,C₀) ∧
      interpC (step F s).run C = some (cleanupNext {s with stack := targetFrames} targetResources targetPending,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (cleanupNext {s₀ with stack := frames} resources pending)
        (cleanupNext {s with stack := targetFrames} targetResources targetPending) ∧
      RetainedInventory (notes.cleanup pairsNote pendingNote tailNotes) ν₀ ν C₀ C R live
        (cleanupNext {s₀ with stack := frames} resources pending)
        (cleanupNext {s with stack := targetFrames} targetResources targetPending) := by
  obtain ⟨targetReturned,targetPending,targetResources,targetFrames,_targetControl,targetStack,left,right,post⟩ :=
    step_dispose_cleanup_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old'
      s₀ s h returned pending resources frames control stack
  have sourceStack := inventory.runtime.source.stack
  have targetHeld := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetHeld
  have sourceParts := cleanupDisposeNote_view sourceStack.head
  have targetParts := cleanupDisposeNote_view targetHeld.head
  have runtime : RuntimeInventory (notes.runtime.cleanup pairsNote pendingNote tailNotes) ν₀ ν C₀ C R live
      (cleanupNext {s₀ with stack := frames} resources pending)
      (cleanupNext {s with stack := targetFrames} targetResources targetPending) :=
    ⟨by simpa only [RuntimeNotes.cleanup_cells] using inventory.runtime.keyLive,RuntimeNotes.cleanup_holds sourceParts.1 sourceParts.2 sourceStack.tail inventory.runtime.source.cells,
      RuntimeNotes.cleanup_holds targetParts.1 targetParts.2 targetHeld.tail inventory.runtime.target.cells⟩
  exact ⟨targetPending,targetResources,targetFrames,left,right,post,
    inventory.heap_step runtime (cleanupNext_heap _ _ _) (cleanupNext_heap _ _ _) (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
