import host.ts.RenameRetainedInventory
import host.ts.RuntimeInventoryStore
import host.ts.RuntimeInventoryStoreFrames
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def RetainedNotes.privateStored (notes : RetainedNotes) (owner brand : Nat) (name : Name)
    (role : Value) (tail : List Tree) : RetainedNotes :=
  ⟨⟨returnNote role,tail,notes.runtime.cells⟩,notes.privates.write owner ⟨brand,name,role⟩,
    notes.captures,notes.arrays,notes.publicFields,notes.buffers⟩
def RetainedNotes.publicStored (notes : RetainedNotes) (owner : Nat) (name : Name)
    (role : Value) (tail : List Tree) : RetainedNotes :=
  ⟨⟨returnNote role,tail,notes.runtime.cells⟩,notes.privates,notes.captures,notes.arrays,
    notes.publicFields.write owner name role,notes.buffers⟩

section
variable {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes} {ν₀ ν : Nat → F64}
  {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
  {s₀ s : St F.S}

theorem RetainedInventory.init_step
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (address : Nat) (value : Val) (prior : Option Val) (kind : DeclKind) (role : Value)
    (control : s₀.ctl = .bind (.id name) value env .init kind) (lookup : lookupEnv name env = some address)
    (cell : s₀.heap.get address = some (.cell prior))
    (controlNote : notes.runtime.control = bindingNote (.id name) role env .init kind)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ targetValue,
      interpC (step F s₀).run C₀ = some ((s₀.setCell address value).ret .undef,C₀) ∧
      interpC (step F s).run C = some ((s.setCell (R.a address) targetValue).ret .undef,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ((s₀.setCell address value).ret .undef) ((s.setCell (R.a address) targetValue).ret .undef) ∧
      RetainedInventory (notes.withRuntime (notes.runtime.initialized address role)) ν₀ ν C₀ C R live
        ((s₀.setCell address value).ret .undef) ((s.setCell (R.a address) targetValue).ret .undef) := by
  obtain ⟨targetValue,left,right,post,runtime,heap,arrays,publics,buffers⟩ := inventory.runtime.init_step_all F FR
    notes.runtime notes.privates notes.captures notes.arrays notes.publicFields notes.buffers ν₀ ν C₀ C R
    live framed before after old old' s₀ s h inventory.heapInventory inventory.arrays inventory.publicFields inventory.buffers
    name env address value prior kind role control lookup cell controlNote sourceBound targetBound
  exact ⟨targetValue,left,right,post,runtime,heap.privates,heap.captures,arrays,publics,buffers⟩

theorem RetainedInventory.private_store_step
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (owner brand : Nat) (name : Name) (role : Value) (value prior previous : Val) (e : Bool) (o₀ : Obj)
    (frames : List Frame) (head : Tree) (tail : List Tree) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .a (.put none (.priv (.obj owner) brand name) prior)::frames)
    (object : s₀.heap.get owner = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findPriv brand name o₀.priv = some (.data previous true e))
    (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = head::tail)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ (targetValue : Val) (targetObject : Obj) (targetFrames : List Frame),
      let t₀ := privateStoreState s₀ owner brand name value e o₀ frames
      let t := privateStoreState s (R.a owner) (R.a brand) name targetValue e targetObject targetFrames
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.privateStored owner brand name role tail) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetObject,targetFrames,left,right,post,runtime,heap,arrays,publics,buffers⟩ :=
    inventory.runtime.private_store_step F FR notes.runtime notes.privates notes.captures notes.arrays notes.publicFields
      notes.buffers ν₀ ν C₀ C R live framed before after old old' s₀ s h inventory.heapInventory inventory.arrays
      inventory.publicFields inventory.buffers owner brand name role value prior previous e o₀ frames head tail
      control stack object ordinary descriptor controlNote stackNotes sourceBound targetBound
  exact ⟨targetValue,targetObject,targetFrames,left,right,post,runtime,heap.privates,heap.captures,arrays,publics,buffers⟩

/-- Ordinary own-field stores update their fixed field role and frame buffers
by source ownership, including possible equal raw words at unrelated owners. -/
theorem RetainedInventory.public_store_step
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (owner : Nat) (name : Name) (value prior previous : Val) (e : Bool) (o₀ : Obj) (role : Value)
    (frames : List Frame) (head : Tree) (tail : List Tree) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .a (.put none (.prop (.obj owner) (.str name)) prior)::frames)
    (object : s₀.heap.get owner = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findProp (.str name) o₀.props = some (.data previous true e))
    (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = head::tail)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ (targetValue : Val) (targetObject : Obj) (targetFrames : List Frame),
      let t₀ := ({s₀ with stack := frames}.setObj owner
        {o₀ with props := setPropL (.str name) (.data value true e) o₀.props}).ret value
      let t := ({s with stack := targetFrames}.setObj (R.a owner)
        {targetObject with props := setPropL (.str name) (.data targetValue true e) targetObject.props}).ret targetValue
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.publicStored owner name role tail) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetObject,targetFrames,left,right,post,runtime,heap,arrays,publics⟩ :=
    inventory.runtime.public_store_step F FR notes.runtime notes.privates notes.captures notes.arrays notes.publicFields
      ν₀ ν C₀ C R live framed before after old old' s₀ s h inventory.heapInventory inventory.arrays inventory.publicFields
      owner name value prior previous e o₀ role frames head tail control stack object ordinary descriptor controlNote stackNotes
      sourceBound targetBound
  have support := h.stackLive
  rw [stack] at support
  have alive : live owner := support.1.1.2.1.1
  have sourceWord := Nat.lt_of_lt_of_le (h.heap.sourceBound owner alive) sourceBound
  have targetWord := Nat.lt_of_lt_of_le (h.heap.targetBound owner alive) targetBound
  have buffers := inventory.buffers.setOrdinary h.heap owner o₀
    {o₀ with props := setPropL (.str name) (.data value true e) o₀.props}
    {targetObject with props := setPropL (.str name) (.data targetValue true e) targetObject.props}
    value targetValue alive object ordinary sourceWord targetWord
  refine ⟨targetValue,targetObject,targetFrames,left,right,post,runtime,heap.privates,heap.captures,arrays,publics,?_⟩
  exact buffers.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
end
end Host.Ts.Owned.Annotated
