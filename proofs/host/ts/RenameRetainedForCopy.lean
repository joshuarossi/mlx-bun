import host.ts.RenameRuntimeForNotes

set_option Elab.async false

namespace Host.Ts.Owned.Annotated
open Parametric

inductive ForCopyPhase where
  | testPhase
  | updatePhase

def ForCopyPhase.frame : ForCopyPhase → Option Expr → Option Expr → Stmt → Env → Name → List Name → LoopF
  | .testPhase,test,update,body,env,name,labels => .forTest true test update body env [name] labels
  | .updatePhase,test,update,body,env,name,labels => .forUpd test update body env [name] labels
def ForCopyPhase.schedule {S : Type} (phase : ForCopyPhase) (s : St S)
    (test update : Option Expr) (body : Stmt) (env : Env) (name : Name) (labels : List Name) : St S :=
  match phase with
  | .testPhase => forTestState s test update body env [name] labels
  | .updatePhase => forUpdateState s test update body env [name] labels
def ForCopyPhase.notes (phase : ForCopyPhase) (notes : RuntimeNotes) (test update : Option Expr)
    (body : Stmt) (env : Env) (name : Name) (labels : List Name) (tail : List Tree) : RuntimeNotes :=
  match phase with
  | .testPhase => notes.forTest test update body env [name] labels tail
  | .updatePhase => notes.forUpdate test update body env [name] labels tail

theorem ForCopyPhase.schedule_heap {S : Type} (phase : ForCopyPhase) (s : St S)
    (test update : Option Expr) (body : Stmt) (env : Env) (name : Name) (labels : List Name) :
    (phase.schedule s test update body env name labels).heap = s.heap := by
  cases phase <;> cases test <;> cases update <;> rfl
theorem ForCopyPhase.notes_holds {S : Type} (phase : ForCopyPhase) (notes : RuntimeNotes)
    (ν : Nat → F64) (C : CSrv) (R : Ren) (test update : Option Expr) (body : Stmt)
    (env : Env) (name : Name) (labels : List Name) (tail : List Tree) (s : St S)
    (frames : ForestHolds ν C R tail (s.stack.map Encode.frame)) (cells : notes.cells.Holds ν C R s) :
    (phase.notes notes test update body env name labels tail).Holds ν C R
      (phase.schedule s test update body (R.env env) name labels) := by
  cases phase with
  | testPhase => exact notes.forTest_holds ν C R test update body env [name] labels tail s frames cells
  | updatePhase => exact notes.forUpdate_holds ν C R test update body env [name] labels tail s frames cells

theorem step_for_copy_phase_eq (F : Ffi) (phase : ForCopyPhase) (s : St F.S) (value : Val)
    (test update : Option Expr) (body : Stmt) (env : Env) (name : Name) (labels : List Name) (frames : List Frame)
    (control : s.ctl = .ret value) (stack : s.stack = .lp (phase.frame test update body env name labels)::frames) :
    step F s = M.pure (phase.schedule (nextIter F {s with stack := frames} [name] env).2 test update body
      (nextIter F {s with stack := frames} [name] env).1 name labels) := by
  cases phase with
  | testPhase => exact step_for_copy_eq F s value test update body env name labels frames control stack
  | updatePhase => exact step_for_update_eq F s value test update body env name labels frames control stack

theorem step_for_copy_phase_from_source (F : Ffi) (phase : ForCopyPhase)
    (NR : NumV → NumV → Prop) (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (value : Val) (test update : Option Expr) (body : Stmt) (env : Env) (name : Name) (labels : List Name)
    (frames : List Frame) (cell : Nat) (cellValue : Val)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .lp (phase.frame test update body env name labels)::frames)
    (lookup : lookupEnv name env = some cell) (read : s₀.heap.get cell = some (.cell (some cellValue)))
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    ∃ result, interpC (step F s₀).run C₀ = some
        (phase.schedule (nextIter F {s₀ with stack := frames} [name] env).2 test update body
          (nextIter F {s₀ with stack := frames} [name] env).1 name labels,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      Parametric.StateR NR FR R (LiveAfter live s₀.next) framed before after old old'
        (phase.schedule (nextIter F {s₀ with stack := frames} [name] env).2 test update body
          (nextIter F {s₀ with stack := frames} [name] env).1 name labels) result := by
  cases phase with
  | testPhase =>
    exact step_for_copy_from_source F NR FR R C₀ C live framed before after old old' s₀ s h
      value test update body env name labels frames cell cellValue control stack lookup read sourceBound targetBound
  | updatePhase =>
    exact step_for_update_from_source F NR FR R C₀ C live framed before after old old' s₀ s h
      value test update body env name labels frames cell cellValue control stack lookup read sourceBound targetBound

/-- The fresh per-iteration cell keeps its selected predecessor's fixed
meaning. Original reads, lexical allocation and scheduling establish both
runs and all retained postconditions; no future role is supplied. -/
theorem RetainedInventory.for_copy_step (F : Ffi) (phase : ForCopyPhase) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (test update : Option Expr) (body : Stmt) (env : Env) (name : Name) (labels : List Name)
    (frames : List Frame) (cell : Nat) (cellValue : Val) (role : Value) (headNote : Tree) (tailNotes : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .lp (phase.frame test update body env name labels)::frames)
    (lookup : lookupEnv name env = some cell) (read : s₀.heap.get cell = some (.cell (some cellValue)))
    (entry : notes.runtime.cells.cells cell = some role) (stackNotes : notes.runtime.stack = headNote::tailNotes)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    ∃ sourcePost targetPost, interpC (step F s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step F s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live s₀.next) framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.withRuntime (phase.notes (notes.runtime.copyIndex s₀.next role) test update body
        ((name,s₀.next)::env.drop 1) name labels tailNotes)) ν₀ ν C₀ C R (LiveAfter live s₀.next) sourcePost targetPost := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨targetFrame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  have targetFrameEq : targetFrame = .lp (phase.frame test update body (R.env env) name labels) := by
    cases phase with
    | testPhase => exact frameRelation.forTest_view
    | updatePhase => exact frameRelation.forUpd_view
  rw [targetFrameEq] at targetStack
  have environmentLive : treeSupport live (Encode.env env) := by
    have alive := h.stackLive
    rw [stack] at alive
    cases phase with
    | testPhase => exact alive.1.1.2.2.2.2.1
    | updatePhase => exact alive.1.1.2.2.2.1
  have cellLive := env_lookup_live name env cell environmentLive lookup
  obtain ⟨targetCellValue,targetCellRead,_,_⟩ := h.heap.readCell cell cellValue cellLive read
  have targetLookup : lookupEnv name (R.env env) = some (R.a cell) := by rw [lookupEnv_map,lookup]; rfl
  have sourceCopy := nextIter_one_eq F {s₀ with stack := frames} name env cell cellValue lookup read
  have targetCopy := nextIter_one_eq F {s with stack := targetFrames} name (R.env env) (R.a cell) targetCellValue targetLookup targetCellRead
  have fresh : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  let copiedEnv := (name,s₀.next)::env.drop 1
  have environmentMap : (name,s.next)::(R.env env).drop 1 = R.env copiedEnv := by
    simp only [copiedEnv,Ren.env,List.map_cons,List.map_drop,fresh]
  let sourceBase := ({s₀ with stack := frames}.alloc (.cell (some cellValue))).2
  let targetBase := ({s with stack := targetFrames}.alloc (.cell (some targetCellValue))).2
  obtain ⟨result,left,right,post⟩ := step_for_copy_phase_from_source F phase (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h value test update body env name labels frames cell cellValue control stack lookup read sourceBound targetBound
  simp only [sourceCopy] at left post
  have targetActual : interpC (step F s).run C = some (phase.schedule targetBase test update body (R.env copiedEnv) name labels,C) := by
    rw [step_for_copy_phase_eq F phase s targetValue test update body (R.env env) name labels targetFrames targetControl targetStack]
    simp only [targetCopy,environmentMap]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (right.symm.trans targetActual))
  dsimp only at same
  rw [same] at post
  have sourceRole : role.Holds ν₀ C₀ identity cellValue := by
    simpa only [cellValueAt,identity,id_eq,read] using inventory.runtime.source.cells cell role entry
  have targetRole : role.Holds ν C R targetCellValue := by
    simpa only [cellValueAt,targetCellRead] using inventory.runtime.target.cells cell role entry
  have copiedCells := inventory.runtime.cellInventory.alloc h.heap (.cell (some cellValue)) (.cell (some targetCellValue)) .undef .undef sourceBound targetBound
  have baseCells : CellInventory notes.runtime.cells ν₀ ν C₀ C R (LiveAfter live s₀.next) sourceBase targetBase :=
    copiedCells.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  have newCells := baseCells.annotate s₀.next role (Or.inr rfl)
    (by simpa only [cellValueAt,sourceBase,St.alloc,PTrie.get_set_u64 _ _ _ sourceBound,identity,ite_true] using sourceRole)
    (by simpa only [cellValueAt,targetBase,St.alloc,fresh,PTrie.get_set_u64 _ _ _ targetBound,ite_true] using targetRole)
  have sourceStack := inventory.runtime.source.stack
  have targetStackRole := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  have runtime : RuntimeInventory (phase.notes (notes.runtime.copyIndex s₀.next role) test update body copiedEnv name labels tailNotes)
      ν₀ ν C₀ C R (LiveAfter live s₀.next)
      (phase.schedule sourceBase test update body copiedEnv name labels)
      (phase.schedule targetBase test update body (R.env copiedEnv) name labels) :=
    ⟨by cases phase <;> cases test <;> cases update <;> exact newCells.keyLive,
      by simpa only [identity_environment] using phase.notes_holds (notes.runtime.copyIndex s₀.next role) ν₀ C₀ identity test update body copiedEnv name labels tailNotes sourceBase sourceStack.tail newCells.source,
      phase.notes_holds (notes.runtime.copyIndex s₀.next role) ν C R test update body copiedEnv name labels tailNotes targetBase targetStackRole.tail newCells.target⟩
  have sourceOutside : ∀ a, live a → (phase.schedule sourceBase test update body copiedEnv name labels).heap.get a = s₀.heap.get a := by
    intro a alive
    rw [phase.schedule_heap]
    have different := Nat.ne_of_lt (h.heap.sourceBound a alive)
    simp only [sourceBase,St.alloc,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right different]
  have targetOutside : ∀ a, live a → (phase.schedule targetBase test update body (R.env copiedEnv) name labels).heap.get (R.a a) = s.heap.get (R.a a) := by
    intro a alive
    rw [phase.schedule_heap]
    have different := Nat.ne_of_lt (h.heap.targetBound a alive)
    simp only [targetBase,St.alloc,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right different]
  exact ⟨_,_,left,targetActual,post,inventory.grow_heap_step runtime (fun _ alive => Or.inl alive) sourceOutside targetOutside⟩

end Host.Ts.Owned.Annotated
