import host.ts.RenameRetainedObjectValue
import host.ts.RenameRetainedHeapFrame
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def objectValueFrameNote (owner : Nat) (name : Name) (rest : List Property) (env : Env) : Tree :=
  .node "Frame.l" [.node "LitF.objVal"
    [.address owner,.node "PKey.str" [.atom Name name],.atom (List Property) rest,environmentNote env]]

theorem objectValueFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren)
    (owner : Nat) (name : Name) (rest : List Property) (env : Env) :
    (objectValueFrameNote owner name rest env).Holds ν C R
      (Encode.frame (.l (.objVal (R.a owner) (.str name) rest (R.env env)))) := by
  dsimp only [objectValueFrameNote,Encode.frame,Encode.litF,Encode.key,Encode.atom]
  repeat first | exact environmentNote_holds ν C R env | constructor

def objectShortState {S : Type} (s : St S) (owner : Nat) (name : Name) (rest : List Property)
    (env : Env) (value : Val) : St S :=
  (s.push (.l (.objVal owner (.str name) rest env))).ret value

theorem objNext_short_eq (F : Ffi) (s : St F.S) (owner : Nat) (name : Name)
    (rest : List Property) (env : Env) (a : Nat) (value : Val)
    (lookup : lookupEnv name env = some a) (cell : s.heap.get a = some (.cell (some value))) :
    objNext F s owner (.short name::rest) env = M.pure (objectShortState s owner name rest env value) := by
  simp only [objNext,readVar,lookup,St.cell?,St.push,cell,retS,objectShortState]

/-- Execute the original shorthand scheduler's lexical read in the current
heap. This is the same readVar call made inside objNext, with its original
object-value continuation; no extra interpreter step is introduced. -/
theorem RetainedInventory.object_short_advance {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (owner : Nat) (name : Name) (rest : List Property) (env : Env) (a : Nat) (value : Val) (role : Value)
    (ownerLive : live owner) (envLive : treeSupport live (Encode.env env))
    (lookup : lookupEnv name env = some a) (cell : s₀.heap.get a = some (.cell (some value)))
    (entry : notes.runtime.cells.cells a = some role) :
    ∃ targetValue,
      objNext F s₀ owner (.short name::rest) env = M.pure (objectShortState s₀ owner name rest env value) ∧
      objNext F s (R.a owner) (.short name::rest) (R.env env) =
        M.pure (objectShortState s (R.a owner) name rest (R.env env) targetValue) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (objectShortState s₀ owner name rest env value)
        (objectShortState s (R.a owner) name rest (R.env env) targetValue) ∧
      RetainedInventory (notes.withRuntime
        ⟨returnNote role,objectValueFrameNote owner name rest env::notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live (objectShortState s₀ owner name rest env value)
        (objectShortState s (R.a owner) name rest (R.env env) targetValue) := by
  have alive := inventory.runtime.keyLive a role entry
  obtain ⟨targetValue,targetCell,valueRelation,valueLive⟩ := h.heap.readCell a value alive cell
  have targetLookup : lookupEnv name (R.env env) = some (R.a a) := by rw [lookupEnv_map,lookup]; rfl
  have sourceRole : role.Holds ν₀ C₀ identity value := by
    simpa only [cellValueAt,identity,id_eq,cell] using inventory.runtime.source.cells a role entry
  have targetRole : role.Holds ν C R targetValue := by
    simpa only [cellValueAt,targetCell] using inventory.runtime.target.cells a role entry
  have sourceOwner : identity.a owner = owner := rfl
  have frameRelation : Parametric.FrameR (NumberRoles ν₀ ν C₀ C) R
      (.l (.objVal owner (.str name) rest env)) (.l (.objVal (R.a owner) (.str name) rest (R.env env))) :=
    Tree.paired (by simpa only [identity_environment,sourceOwner] using objectValueFrameNote_holds ν₀ C₀ identity owner name rest env)
      (objectValueFrameNote_holds ν C R owner name rest env)
  have frameLive : treeSupport live (Encode.frame (.l (.objVal owner (.str name) rest env))) :=
    ⟨⟨ownerLive,⟨True.intro,True.intro⟩,True.intro,envLive,True.intro⟩,True.intro⟩
  have post := (h.restack (.cons frameRelation h.stack) ⟨frameLive,h.stackLive⟩).go
    (c := .ret value) (c' := .ret targetValue) (.node _ (.cons (.value valueRelation) .nil)) ⟨valueLive,True.intro⟩
  have runtime : RuntimeInventory
      ⟨returnNote role,objectValueFrameNote owner name rest env::notes.runtime.stack,notes.runtime.cells⟩
      ν₀ ν C₀ C R live (objectShortState s₀ owner name rest env value)
      (objectShortState s (R.a owner) name rest (R.env env) targetValue) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds sourceRole,
        .cons (by simpa only [identity_environment,sourceOwner] using objectValueFrameNote_holds ν₀ C₀ identity owner name rest env)
          inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds targetRole,.cons (objectValueFrameNote_holds ν C R owner name rest env)
        inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  exact ⟨targetValue,objNext_short_eq F s₀ owner name rest env a value lookup cell,
    objNext_short_eq F s (R.a owner) name rest (R.env env) (R.a a) targetValue targetLookup targetCell,
    post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

def objectFieldState {S : Type} (s : St S) (owner : Nat) (o : Obj) (name : Name) (value : Val)
    (frames : List Frame) : St S :=
  ({s with stack := frames}.setObj owner {o with props := setPropL (.str name) (.data value true true) o.props}).ret value

/-- The field-installation part of retL.objVal, before its next-property
scheduler. The current return role fixes the new field and every other
retained inventory survives the ordinary-object update. -/
theorem RetainedInventory.object_field_store {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (owner : Nat) (name : Name) (value : Val) (o₀ : Obj) (frames : List Frame) (properties : List Property) (env : Env)
    (role : Value) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .l (.objVal owner (.str name) properties env)::frames)
    (object : s₀.heap.get owner = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = head::tail)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ targetValue targetObject targetFrames,
      s.ctl = .ret targetValue ∧
      s.stack = .l (.objVal (R.a owner) (.str name) properties (R.env env))::targetFrames ∧
      s.heap.get (R.a owner) = some (.obj targetObject) ∧ targetObject.kind = .ordinary ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (objectFieldState s₀ owner o₀ name value frames) (objectFieldState s (R.a owner) targetObject name targetValue targetFrames) ∧
      RetainedInventory (notes.publicStored owner name role tail) ν₀ ν C₀ C R live
        (objectFieldState s₀ owner o₀ name value frames) (objectFieldState s (R.a owner) targetObject name targetValue targetFrames) := by
  obtain ⟨targetValue,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.objectValue_view] at targetStack
  have support := h.stackLive
  rw [stack] at support
  have alive : live owner := support.1.1.1
  have valueLive : valueSupport live value := by have hl := h.controlLive; rw [control] at hl; exact hl.1
  have sourceWord := Nat.lt_of_lt_of_le (h.heap.sourceBound owner alive) sourceBound
  have targetWord := Nat.lt_of_lt_of_le (h.heap.targetBound owner alive) targetBound
  obtain ⟨targetObject,targetRead,objectRelation,objectLive⟩ := h.heap.readOrdinary owner o₀ alive object ordinary
  have sourceRole := inventory.runtime.source.control
  have targetRole := inventory.runtime.target.control
  rw [controlNote,control] at sourceRole
  rw [controlNote,targetControl] at targetRole
  have sourceRole := returnNote_view sourceRole
  have targetRole := returnNote_view targetRole
  have sourceStack := inventory.runtime.source.stack
  have targetStackNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackNotes
  let new₀ := {o₀ with props := setPropL (.str name) (.data value true true) o₀.props}
  let new := {targetObject with props := setPropL (.str name) (.data targetValue true true) targetObject.props}
  have propertyRole : PropR (NumberRoles ν₀ ν C₀ C) R (.data value true true) (.data targetValue true true) :=
    .node _ (.cons (.value valueRelation) (.cons (.atom _ _) (.cons (.atom _ _) .nil)))
  have newSupport : treeSupport live (Encode.obj new₀) :=
    ⟨objectLive.1,objectLive.2.1,props_support_set objectLive.2.2.1 name (.data value true true)
      ⟨valueLive,True.intro,True.intro,True.intro⟩,objectLive.2.2.2⟩
  have post := (h.restack tailRelation support.2).setObject owner new₀ new alive
    (h.heap.ordinary_notFramed owner o₀ alive object ordinary)
    (objectRelation.with_props _ _ (objectRelation.properties.set_string name _ _ propertyRole)) newSupport sourceWord targetWord
  have post : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      (objectFieldState s₀ owner o₀ name value frames)
      (objectFieldState s (R.a owner) targetObject name targetValue targetFrames) := by
    simpa only [objectFieldState,St.setObj,St.ret,control,targetControl,new₀,new] using post
  have cells := inventory.runtime.cellInventory.setObject h.heap owner o₀ targetObject new₀ new value targetValue
    alive object targetRead sourceWord targetWord
  have runtime : RuntimeInventory ⟨returnNote role,tail,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      (objectFieldState s₀ owner o₀ name value frames) (objectFieldState s (R.a owner) targetObject name targetValue targetFrames) :=
    ⟨cells.keyLive,⟨returnNote_holds sourceRole,sourceStack.tail,cells.source⟩,
      ⟨returnNote_holds targetRole,targetStackNotes.tail,cells.target⟩⟩
  refine ⟨targetValue,targetObject,targetFrames,targetControl,targetStack,targetRead,objectRelation.ordinary ordinary,
    post,runtime,?_,?_,?_,?_,?_⟩
  · exact (inventory.privates.setProps owner o₀ targetObject new₀.props new.props object targetRead sourceWord targetWord).frame
      (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact (inventory.captures.setOrdinary h.heap owner o₀ new₀ new value targetValue alive object ordinary sourceWord targetWord).frame
      (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact (inventory.arrays.setOrdinary h.heap owner o₀ new₀ new value targetValue alive object ordinary sourceWord targetWord).frame
      (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact (inventory.publicFields.store h.heap owner o₀ targetObject name role value targetValue true true
      alive object targetRead sourceRole targetRole sourceWord targetWord).frame
      (fun _ h => h) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)
  · exact (inventory.buffers.setOrdinary h.heap owner o₀ new₀ new value targetValue alive object ordinary sourceWord targetWord).frame
      (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)

theorem step_object_field_next_eq (F : Ffi) (s : St F.S) (owner : Nat) (name : Name) (value : Val)
    (o : Obj) (frames : List Frame) (properties : List Property) (env : Env)
    (control : s.ctl = .ret value)
    (stack : s.stack = .l (.objVal owner (.str name) properties env)::frames)
    (object : s.heap.get owner = some (.obj o)) (ordinary : o.kind = .ordinary) :
    step F s = objNext F (objectFieldState s owner o name value frames) owner properties env := by
  simp only [step,control,stepRet,stack,retStep,retL,defineData,St.obj?,object,ordinary]
  simp only [objectFieldState,St.ret,St.setObj,ordinary]

/-- The original single machine step stores the current field, reads the
next shorthand identifier through readVar, and saves its real objVal frame.
The shorthand value's meaning comes from the current lexical-cell inventory. -/
theorem RetainedInventory.object_value_short_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (owner : Nat) (name : Name) (value : Val) (o₀ : Obj) (frames : List Frame) (env : Env)
    (nextName : Name) (rest : List Property) (a : Nat) (nextValue : Val) (role nextRole : Value)
    (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .l (.objVal owner (.str name) (.short nextName::rest) env)::frames)
    (object : s₀.heap.get owner = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (lookup : lookupEnv nextName env = some a) (cell : s₀.heap.get a = some (.cell (some nextValue)))
    (entry : notes.runtime.cells.cells a = some nextRole)
    (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = head::tail)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ targetValue targetObject targetFrames targetNextValue,
      let b₀ := objectFieldState s₀ owner o₀ name value frames
      let b := objectFieldState s (R.a owner) targetObject name targetValue targetFrames
      let t₀ := objectShortState b₀ owner nextName rest env nextValue
      let t := objectShortState b (R.a owner) nextName rest (R.env env) targetNextValue
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory ((notes.publicStored owner name role tail).withRuntime
        ⟨returnNote nextRole,objectValueFrameNote owner nextName rest env::tail,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetObject,targetFrames,targetControl,targetStack,targetObjectRead,targetOrdinary,stored,retained⟩ :=
    inventory.object_field_store h owner name value o₀ frames (.short nextName::rest) env role head tail
      control stack object ordinary controlNote stackNotes sourceBound targetBound
  have support := h.stackLive
  rw [stack] at support
  have alive : live owner := support.1.1.1
  have envLive : treeSupport live (Encode.env env) := support.1.1.2.2.2.1
  have different : a ≠ owner := by
    intro same
    rw [same,object] at cell
    cases cell
  have sourceWord := Nat.lt_of_lt_of_le (h.heap.sourceBound owner alive) sourceBound
  have storedCell : (objectFieldState s₀ owner o₀ name value frames).heap.get a = some (.cell (some nextValue)) := by
    simp only [objectFieldState,St.ret,St.setObj,PTrie.get_set_u64 _ _ _ sourceWord,ite_eq_right different,cell]
  obtain ⟨targetNextValue,left,right,post,retained⟩ := retained.object_short_advance stored owner nextName rest env a nextValue nextRole
    alive envLive lookup storedCell entry
  refine ⟨targetValue,targetObject,targetFrames,targetNextValue,?_,?_,post,retained⟩
  · rw [step_object_field_next_eq F s₀ owner name value o₀ frames (.short nextName::rest) env control stack object ordinary,left]
    rfl
  · rw [step_object_field_next_eq F s (R.a owner) name targetValue targetObject targetFrames (.short nextName::rest) (R.env env)
      targetControl targetStack targetObjectRead targetOrdinary,right]
    rfl
end Host.Ts.Owned.Annotated
