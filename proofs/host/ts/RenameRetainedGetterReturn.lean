import host.ts.RenameRetainedGetterBody
import host.ts.RenameRuntimeReturns
import host.ts.RenameStackEffects

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

private theorem one_step (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

private theorem retained_exit
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (value : Val) (role : Value) (exit : ReturnExit) (env : Env) (frames : List Frame)
    (head : Tree) (tail : List Tree) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = exit.frame env::frames) (controlNote : notes.runtime.control = returnNote role)
    (stackNotes : notes.runtime.stack = head::tail) :
    ∃ result,
      runC F 1 s₀ C₀ = some ({s₀ with stack := frames}.go (exit.control value),C₀) ∧
      runC F 1 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.go (exit.control value)) result ∧
      RetainedInventory (notes.withRuntime (notes.runtime.exitReturn exit role tail))
        ν₀ ν C₀ C R live ({s₀ with stack := frames}.go (exit.control value)) result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next ∧ result.stack = s.stack.tail := by
  obtain ⟨result,left,right,post,runtime⟩ := inventory.runtime.return_exit_step F FR _ ν₀ ν C₀ C R
    live framed before after old old' s₀ s h value role exit env frames head tail control stack controlNote stackNotes
  have pure := PureRuntimeCase.returnExit h value env exit frames control stack
  have effects := pure.effects left right
  have active : isHalt s₀.ctl = false := by rw [control]; rfl
  exact ⟨result,one_step F _ _ C₀ active left,one_step F _ _ C (h.control.isHalt_eq.trans active) right,
    post,inventory.pure_step runtime pure left right (.refl C₀) (.refl C),effects.2.heap,effects.2.native,
    effects.2.next,step_return_exit_stack F _ FR R live framed before after old old' s₀ s result C C h
      value exit env frames control stack right⟩

private theorem retained_unwind
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (value : Val) (role : Value) (unwind : ReturnUnwind) (env : Env) (frames : List Frame)
    (head : Tree) (tail : List Tree) (control : s₀.ctl = .abr (.ret value))
    (stack : s₀.stack = unwind.frame env::frames) (controlNote : notes.runtime.control = abruptReturnNote role)
    (stackNotes : notes.runtime.stack = head::tail) :
    ∃ result,
      runC F 1 s₀ C₀ = some ({s₀ with stack := frames}.go (unwind.control value),C₀) ∧
      runC F 1 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.go (unwind.control value)) result ∧
      RetainedInventory (notes.withRuntime (notes.runtime.unwindReturn unwind role tail))
        ν₀ ν C₀ C R live ({s₀ with stack := frames}.go (unwind.control value)) result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next ∧ result.stack = s.stack.tail := by
  obtain ⟨result,left,right,post,runtime⟩ := inventory.runtime.return_unwind_step F FR _ ν₀ ν C₀ C R
    live framed before after old old' s₀ s h value role unwind env frames head tail control stack controlNote stackNotes
  have pure := PureRuntimeCase.returnUnwind h value env unwind frames control stack
  have effects := pure.effects left right
  have active : isHalt s₀.ctl = false := by rw [control]; rfl
  exact ⟨result,one_step F _ _ C₀ active left,one_step F _ _ C (h.control.isHalt_eq.trans active) right,
    post,inventory.pure_step runtime pure left right (.refl C₀) (.refl C),effects.2.heap,effects.2.native,
    effects.2.next,step_return_unwind_stack F _ FR R live framed before after old old' s₀ s result C C h
      value unwind env frames control stack right⟩

/-- The four real return transitions preserve the selected field meaning
through explicit return, block, lexical scope and ordinary call boundary.
Both callers' stacks are resumed, with no heap, native or counter change. -/
theorem RetainedInventory.getter_return_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (value : Val) (role : Value) (env : Env) (caller : List Frame)
    (retNote blockNote scopeNote callNote : Tree) (callerNotes : List Tree)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .s .ret :: .s (.block [] env) :: .s (.scope []) :: .k (.fn .call) :: caller)
    (controlNote : notes.runtime.control = returnNote role)
    (stackNotes : notes.runtime.stack = retNote::blockNote::scopeNote::callNote::callerNotes) :
    ∃ result,
      runC F 4 s₀ C₀ = some ({s₀ with ctl := .ret value,stack := caller},C₀) ∧
      runC F 4 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        {s₀ with ctl := .ret value,stack := caller} result ∧
      RetainedInventory (notes.withRuntime ⟨returnNote role,callerNotes,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live {s₀ with ctl := .ret value,stack := caller} result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next ∧ result.stack = s.stack.drop 4 := by
  obtain ⟨s1,left1,right1,h1,inv1,heap1,ffi1,next1,stack1⟩ := retained_exit inventory h value role .explicitReturn env
    (.s (.block [] env) :: .s (.scope []) :: .k (.fn .call) :: caller)
    retNote (blockNote::scopeNote::callNote::callerNotes) control stack controlNote stackNotes
  obtain ⟨s2,left2,right2,h2,inv2,heap2,ffi2,next2,stack2⟩ := retained_unwind inv1 h1 value role (.block []) env
    (.s (.scope []) :: .k (.fn .call) :: caller) blockNote (scopeNote::callNote::callerNotes) rfl rfl rfl rfl
  obtain ⟨s3,left3,right3,h3,inv3,heap3,ffi3,next3,stack3⟩ := retained_unwind inv2 h2 value role .scope env
    (.k (.fn .call) :: caller) scopeNote (callNote::callerNotes) rfl rfl rfl rfl
  obtain ⟨result,left4,right4,h4,inv4,heap4,ffi4,next4,stack4⟩ := retained_unwind inv3 h3 value role .call env
    caller callNote callerNotes rfl rfl rfl rfl
  refine ⟨result,runC_join F (runC_join F (runC_join F left1 left2) left3) left4,
    runC_join F (runC_join F (runC_join F right1 right2) right3) right4,h4,inv4,
    heap4.trans (heap3.trans (heap2.trans heap1)),ffi4.trans (ffi3.trans (ffi2.trans ffi1)),
    next4.trans (next3.trans (next2.trans next1)),?_⟩
  rw [stack4,stack3,stack2,stack1]
  generalize s.stack = frames
  cases frames with
  | nil => rfl
  | cons _ frames => cases frames with
    | nil => rfl
    | cons _ frames => cases frames with
      | nil => rfl
      | cons _ frames => cases frames <;> rfl

/-- The complete non-disposed getter returns its owned field to an arbitrary
caller in thirteen original interpreter transitions. All source data, fresh
counters, value meanings and callers remain parameters of the theorem. -/
theorem RetainedInventory.getter_body_return_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (env : Env) (thisCell owner brand : Nat) (disposedName handleName : Name)
    (object : Obj) (value : Val) (role : Value) (dw de hw he : Bool)
    (yes : Stmt) (caller : List Frame) (ifNote blockNote scopeNote callNote : Tree) (callerNotes : List Tree)
    (control : s₀.ctl = .ev (.priv .this disposedName false) env)
    (stack : s₀.stack = .s (.if_ yes none env) :: .s (.block [.ret (some (.priv .this handleName false))] env) ::
      .s (.scope []) :: .k (.fn .call) :: caller)
    (thisLookup : lookupEnv nThis env = some thisCell)
    (disposedLookup : lookupEnv (privName disposedName) env = some brand)
    (handleLookup : lookupEnv (privName handleName) env = some brand)
    (thisRead : s₀.heap.get thisCell = some (.cell (some (.obj owner))))
    (objectRead : s₀.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (disposed : findPriv brand disposedName object.priv = some (.data (.bool false) dw de))
    (handle : findPriv brand handleName object.priv = some (.data value hw he))
    (thisNote : notes.runtime.cells.cells thisCell = some (.obj owner))
    (fieldNote : notes.privates.owners owner = some ⟨brand,handleName,role⟩)
    (stackNotes : notes.runtime.stack = ifNote::blockNote::scopeNote::callNote::callerNotes) :
    ∃ result,
      runC F 13 s₀ C₀ = some ({s₀ with ctl := .ret value,stack := caller},C₀) ∧
      runC F 13 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        {s₀ with ctl := .ret value,stack := caller} result ∧
      RetainedInventory (notes.withRuntime ⟨returnNote role,callerNotes,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live {s₀ with ctl := .ret value,stack := caller} result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next := by
  obtain ⟨s9,left9,right9,h9,inv9,heap9,ffi9,next9⟩ := inventory.getter_body_block h
    env thisCell owner brand disposedName handleName object value role dw de hw he yes
    (.s (.scope []) :: .k (.fn .call) :: caller) ifNote blockNote (scopeNote::callNote::callerNotes)
    control stack thisLookup disposedLookup handleLookup thisRead objectRead ordinary disposed handle thisNote fieldNote stackNotes
  obtain ⟨result,left13,right13,h13,inv13,heap13,ffi13,next13,_⟩ := inv9.getter_return_block h9
    value role env caller (.node "Frame.s" [.node "StmtF.ret" []]) (blockFrameNote [] env)
    scopeNote callNote callerNotes rfl rfl rfl rfl
  exact ⟨result,runC_join F left9 left13,runC_join F right9 right13,h13,inv13,
    heap13.trans heap9,ffi13.trans ffi9,next13.trans next9⟩

end Host.Ts.Owned.Annotated
