import host.ts.RenameFixedUpdate
import host.ts.RenameRetainedClosedComparison
import host.ts.RenameRetainedStores
import host.ts.RenameRetainedHeapFrame
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def updateOldFrameNote (name : Name) (env : Env) : Tree :=
  .node "Frame.a" [.node "AsgF.updOld" [.atom Bool true,.atom Bool false,
    .node "Target.var" [.atom Name name,environmentNote env]]]
def constantFrameNote (role : Value) : Tree := .node "Frame.e" [.node "ExprF.const" [.value role]]
theorem updateOldFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (name : Name) (env : Env) :
    (updateOldFrameNote name env).Holds ν C R (Encode.frame (.a (.updOld true false (.var name (R.env env))))) := by
  dsimp only [updateOldFrameNote,Encode.frame,Encode.asgF,Encode.target,Encode.atom]
  repeat first | exact environmentNote_holds ν C R env | constructor
theorem constantFrameNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {value : Val}
    (holds : role.Holds ν C R value) : (constantFrameNote role).Holds ν C R (Encode.frame (.e (.const value))) :=
  .node _ (.cons (.node _ (.cons (.value holds) .nil)) .nil)
theorem constantFrameNote_view {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {value : Val}
    (holds : (constantFrameNote role).Holds ν C R (Encode.frame (.e (.const value)))) : role.Holds ν C R value := by
  cases holds with | node _ fields =>
    cases fields with | cons frame fields =>
      cases frame with | node _ fields =>
        cases fields with | cons value fields =>
          cases value with | value holds => exact holds

theorem Value.Holds.closed_literal_same {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {meaning : SymE} {x : F64} {value : Val}
    (source : (Value.literal meaning).Holds ν₀ C₀ identity (.num (.lit x)))
    (target : (Value.literal meaning).Holds ν C R value) (closed : meaning.closed = true) : value = .num (.lit x) := by
  have sourceValue : meaning.eval ν₀ = x := (Option.some.inj (source.numeric_denote (.literal meaning))).symm
  cases target with
  | literal _ y denotation =>
    have equal : y = x := (Option.some.inj denotation).trans ((meaning.eval_closed closed ν ν₀).trans sourceValue)
    rw [equal]

section
variable {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes} {ν₀ ν : Nat → F64}
  {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}

/-- The original postfix-variable read retains the selected cell occurrence
and pushes its original assignment continuation. -/
theorem RetainedInventory.update_variable_step
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (a : Nat) (value : Val) (role : Value)
    (control : s₀.ctl = .ev (.update true false (.id name)) env)
    (lookup : lookupEnv name env = some a) (cell : s₀.heap.get a = some (.cell (some value)))
    (entry : notes.runtime.cells.cells a = some role) :
    ∃ targetValue,
      let t₀ := (s₀.push (.a (.updOld true false (.var name env)))).ret value
      let t := (s.push (.a (.updOld true false (.var name (R.env env))))).ret targetValue
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote role,updateOldFrameNote name env::notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live t₀ t := by
  have alive := inventory.runtime.keyLive a role entry
  obtain ⟨targetValue,targetCell,_,_⟩ := h.heap.readCell a value alive cell
  have sourceRole : role.Holds ν₀ C₀ identity value := by
    simpa only [cellValueAt,identity,id_eq,cell] using inventory.runtime.source.cells a role entry
  have targetRole : role.Holds ν C R targetValue := by
    simpa only [cellValueAt,targetCell] using inventory.runtime.target.cells a role entry
  obtain ⟨left,right,post⟩ := step_update_var_from_source_fixed F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h name env a value targetValue control lookup cell targetCell
  have runtime : RuntimeInventory ⟨returnNote role,updateOldFrameNote name env::notes.runtime.stack,notes.runtime.cells⟩
      ν₀ ν C₀ C R live ((s₀.push (.a (.updOld true false (.var name env)))).ret value)
      ((s.push (.a (.updOld true false (.var name (R.env env))))).ret targetValue) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds sourceRole,.cons (by simpa only [identity_environment] using updateOldFrameNote_holds ν₀ C₀ identity name env)
        inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds targetRole,.cons (updateOldFrameNote_holds ν C R name env) inventory.runtime.target.stack,
        inventory.runtime.target.cells⟩⟩
  exact ⟨targetValue,left,right,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

/-- The original postfix continuation returns its saved incoming occurrence,
independently of the newer value currently returned by the store. -/
theorem RetainedInventory.constant_step
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (value saved : Val) (frames : List Frame) (role : Value) (tail : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .e (.const saved)::frames)
    (stackNotes : notes.runtime.stack = constantFrameNote role::tail) :
    ∃ targetSaved targetFrames,
      let t₀ := {s₀ with stack := frames}.ret saved
      let t := {s with stack := targetFrames}.ret targetSaved
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote role,tail,notes.runtime.cells⟩) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  obtain ⟨targetSaved,frameEq,savedRelation⟩ := frameRelation.constant_view
  rw [frameEq] at targetStack
  have sourceStack := inventory.runtime.source.stack
  have targetStackNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackNotes
  have support := h.stackLive
  rw [stack] at support
  have post := (h.restack tailRelation support.2).go (c := .ret saved) (c' := .ret targetSaved)
    (.node _ (.cons (.value savedRelation) .nil)) ⟨support.1.1.1,True.intro⟩
  have runtime : RuntimeInventory ⟨returnNote role,tail,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      ({s₀ with stack := frames}.ret saved) ({s with stack := targetFrames}.ret targetSaved) :=
    ⟨inventory.runtime.keyLive,⟨returnNote_holds (constantFrameNote_view sourceStack.head),sourceStack.tail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (constantFrameNote_view targetStackNotes.head),targetStackNotes.tail,inventory.runtime.target.cells⟩⟩
  refine ⟨targetSaved,targetFrames,?_,?_,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
  · rw [step_constant_eq F s₀ value saved frames control stack]; rfl
  · rw [step_constant_eq F s targetValue targetSaved targetFrames targetControl targetStack]; rfl

/-- A literal loop-index increment derives target control and cell values
from the current closed meaning, writes its symbolic add-one meaning, and
retains the old meaning in the postfix continuation. -/
theorem RetainedInventory.postincrement_step
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (a : Nat) (x y : F64) (meaning : SymE) (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret (.num (.lit x)))
    (stack : s₀.stack = .a (.updOld true false (.var name env))::frames)
    (lookup : lookupEnv name env = some a) (cell : s₀.heap.get a = some (.cell (some (.num (.lit x)))))
    (entry : notes.runtime.cells.cells a = some (.literal meaning))
    (controlNote : notes.runtime.control = returnNote (.literal meaning)) (stackNotes : notes.runtime.stack = head::tail)
    (closed : meaning.closed = true) (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64)
    (sum : F64.bin .add x (.fin false 1 0) = y) :
    ∃ targetFrames,
      let t₀ := fixedPostincrement s₀ a x y frames
      let t := fixedPostincrement s (R.a a) x y targetFrames
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime
        ⟨returnNote (.literal (.bin .add meaning (.lit (.fin false 1 0)))),constantFrameNote (.literal meaning)::tail,
          notes.runtime.cells.write a (.literal (.bin .add meaning (.lit (.fin false 1 0))))⟩)
        ν₀ ν C₀ C R live t₀ t := by
  have alive := inventory.runtime.keyLive a (.literal meaning) entry
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  have sourceRole := inventory.runtime.source.control
  have targetRole := inventory.runtime.target.control
  rw [controlNote,control] at sourceRole
  rw [controlNote,targetControl] at targetRole
  have sourceRole := returnNote_view sourceRole
  have targetRole := returnNote_view targetRole
  have sameValue := sourceRole.closed_literal_same targetRole closed
  rw [sameValue] at targetControl targetRole
  obtain ⟨cellValue,targetCell,_,_⟩ := h.heap.readCell a (.num (.lit x)) alive cell
  have targetCellRole : (Value.literal meaning).Holds ν C R cellValue := by
    simpa only [cellValueAt,targetCell] using inventory.runtime.target.cells a (.literal meaning) entry
  have sameCell := sourceRole.closed_literal_same targetCellRole closed
  rw [sameCell] at targetCell
  obtain ⟨targetFrames,left,right,post⟩ := step_postinc_fixed_from_source F FR R ν₀ ν C₀ C live framed before after old old'
    s₀ s h name env a x y frames control targetControl stack lookup cell targetCell
    (h.heap.cell_notFramed a (some (.num (.lit x))) alive cell) sourceBound targetBound sum
  have sourceDenote := literal_bin_denote (sourceRole.numeric_denote (.literal meaning))
    (show NumDenote ν₀ C₀ (.lit (.fin false 1 0)) (.lit (.fin false 1 0)) from rfl) .add
  have targetDenote := literal_bin_denote (targetRole.numeric_denote (.literal meaning))
    (show NumDenote ν C (.lit (.fin false 1 0)) (.lit (.fin false 1 0)) from rfl) .add
  rw [sum] at sourceDenote targetDenote
  have sourceNext := Value.Holds.literal (R := identity) (.bin .add meaning (.lit (.fin false 1 0))) y sourceDenote
  have targetNext := Value.Holds.literal (R := R) (.bin .add meaning (.lit (.fin false 1 0))) y targetDenote
  have sourceWord := Nat.lt_of_lt_of_le (h.heap.sourceBound a alive) sourceBound
  have targetWord := Nat.lt_of_lt_of_le (h.heap.targetBound a alive) targetBound
  have heap := inventory.heapInventory.setCell h.heap a (some (.num (.lit x)))
    (.literal (.bin .add meaning (.lit (.fin false 1 0)))) (.num (.lit y)) (.num (.lit y)) alive cell
    sourceNext targetNext sourceWord targetWord
  obtain ⟨frame,actualFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.updateOld_view] at targetStack
  have actualRun := step_postinc_eq F s (.lit x) actualFrames name (R.env env) (R.a a) targetControl targetStack
    (by rw [lookupEnv_map,lookup]; rfl) (by simp only [St.cell?,targetCell])
  have actualRun : interpC (step F s).run C = some (fixedPostincrement s (R.a a) x y actualFrames,C) := by
    rw [actualRun]
    simp only [numBin,one,sum]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (right.symm.trans actualRun))
  dsimp only at same
  rw [same] at post
  have sourceStack := inventory.runtime.source.stack
  have targetStackNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackNotes
  have runtime : RuntimeInventory
      ⟨returnNote (.literal (.bin .add meaning (.lit (.fin false 1 0)))),constantFrameNote (.literal meaning)::tail,
        notes.runtime.cells.write a (.literal (.bin .add meaning (.lit (.fin false 1 0))))⟩
      ν₀ ν C₀ C R live (fixedPostincrement s₀ a x y frames) (fixedPostincrement s (R.a a) x y actualFrames) :=
    ⟨heap.cells.keyLive,⟨returnNote_holds sourceNext,.cons (constantFrameNote_holds sourceRole) sourceStack.tail,heap.cells.source⟩,
      ⟨returnNote_holds targetNext,.cons (constantFrameNote_holds targetRole) targetStackNotes.tail,heap.cells.target⟩⟩
  refine ⟨actualFrames,left,actualRun,post,runtime,?_,?_,?_,?_,?_⟩
  · exact heap.privates.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact heap.captures.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact (inventory.arrays.setCell h.heap a (some (.num (.lit x))) (.num (.lit y)) (.num (.lit y)) alive cell sourceWord targetWord).frame
      (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact (inventory.publicFields.setCell h.heap a (some (.num (.lit x))) (.num (.lit y)) (.num (.lit y)) alive cell sourceWord targetWord).frame
      (fun _ h => h) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)
  · exact (inventory.buffers.setCell h.heap a (some (.num (.lit x))) (.num (.lit y)) (.num (.lit y)) alive cell sourceWord targetWord).frame
      (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
end
end Host.Ts.Owned.Annotated
