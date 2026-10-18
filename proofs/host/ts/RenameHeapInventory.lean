import host.ts.RenameNativeCaptureInventory
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

structure HeapNotes where
  cells : Notes
  privates : PrivateNotes
  captures : NativeCaptureNotes

def HeapNotes.writeCell (notes : HeapNotes) (a : Nat) (role : Value) : HeapNotes :=
  {notes with cells := notes.cells.write a role}
def HeapNotes.writePrivate (notes : HeapNotes) (a : Nat) (note : PrivateNote) : HeapNotes :=
  {notes with privates := notes.privates.write a note}

/-- The three fixed annotation families share the same actual live heap.
Stores update one family while framing the other two by source ownership. -/
structure HeapInventory {S : Type} (notes : HeapNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (R : Ren) (live : Nat → Prop) (s₀ s : St S) : Prop where
  cells : CellInventory notes.cells ν₀ ν C₀ C R live s₀ s
  privates : PrivateInventory notes.privates ν₀ ν C₀ C R live s₀ s
  captures : NativeCaptureInventory notes.captures ν₀ ν C₀ C R live s₀ s

section
variable {S : Type} {notes : HeapNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
  {live live' : Nat → Prop} {s₀ s t₀ t : St S}

theorem HeapInventory.frame (h : HeapInventory notes ν₀ ν C₀ C R live s₀ s)
    (grow : ∀ a, live a → live' a)
    (sourceFrame : ∀ a, live a → t₀.heap.get a = s₀.heap.get a)
    (targetFrame : ∀ a, live a → t.heap.get (R.a a) = s.heap.get (R.a a)) :
    HeapInventory notes ν₀ ν C₀ C R live' t₀ t :=
  ⟨h.cells.frame grow (fun a role entry => sourceFrame a (h.cells.keyLive a role entry))
      (fun a role entry => targetFrame a (h.cells.keyLive a role entry)),
    h.privates.frame grow (fun a note entry => sourceFrame a (h.privates.keyLive a note entry).1)
      (fun a note entry => targetFrame a (h.privates.keyLive a note entry).1),
    h.captures.frame grow (fun a note entry => sourceFrame a (h.captures.keyLive a note entry))
      (fun a note entry => targetFrame a (h.captures.keyLive a note entry))⟩

theorem HeapInventory.mono {D₀ D : CSrv} (h : HeapInventory notes ν₀ ν C₀ C R live s₀ s)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D) :
    HeapInventory notes ν₀ ν D₀ D R live s₀ s :=
  ⟨h.cells.mono sourceExtension targetExtension,h.privates.mono sourceExtension targetExtension,
    h.captures.mono sourceExtension targetExtension⟩

theorem HeapInventory.alloc {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (h : HeapInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (o₀ o : HObj) (v₀ v : Val)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    HeapInventory notes ν₀ ν C₀ C R (LiveAfter live s₀.next) ((s₀.alloc o₀).2.ret v₀) ((s.alloc o).2.ret v) :=
  ⟨h.cells.alloc heap o₀ o v₀ v sourceBound targetBound,h.privates.alloc heap o₀ o v₀ v sourceBound targetBound,
    h.captures.alloc heap o₀ o v₀ v sourceBound targetBound⟩

theorem HeapInventory.setCell {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (h : HeapInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (a : Nat) (prior : Option Val)
    (role : Value) (v₀ v : Val) (alive : live a) (cell : s₀.heap.get a = some (.cell prior))
    (sourceRole : role.Holds ν₀ C₀ identity v₀) (targetRole : role.Holds ν C R v)
    (sourceBound : a < 2^64) (targetBound : R.a a < 2^64) :
    HeapInventory (notes.writeCell a role) ν₀ ν C₀ C R live ((s₀.setCell a v₀).ret .undef) ((s.setCell (R.a a) v).ret .undef) :=
  ⟨h.cells.store heap a role v₀ v alive sourceRole targetRole sourceBound targetBound,
    h.privates.setCell heap a prior v₀ v alive cell sourceBound targetBound,
    h.captures.setCell heap a prior v₀ v alive cell sourceBound targetBound⟩
end

/-- One source-only initialization transition transports every heap annotation
family. Its fixed operand role is retained from the current control. -/
theorem HeapInventory.init_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : HeapNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : HeapInventory notes ν₀ ν C₀ C R live s₀ s)
    (name : Name) (env : Env) (a : Nat) (value : Val) (prior : Option Val) (kind : DeclKind) (role : Value)
    (control : s₀.ctl = .bind (.id name) value env .init kind) (lookup : lookupEnv name env = some a)
    (cell : s₀.heap.get a = some (.cell prior))
    (sourceRole : role.Holds ν₀ C₀ identity value) (targetRole : role.Holds ν C R (initializedValue s.ctl))
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ result, interpC (step F s₀).run C₀ = some ((s₀.setCell a value).ret .undef,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ((s₀.setCell a value).ret .undef) result ∧
      HeapInventory (notes.writeCell a role) ν₀ ν C₀ C R live ((s₀.setCell a value).ret .undef) result := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).bind_view
  have selectedRole : role.Holds ν C R targetValue := by simpa only [initializedValue,targetControl] using targetRole
  have controlLive := h.controlLive
  rw [control] at controlLive
  have alive := env_lookup_live name env a controlLive.2.2.1 lookup
  obtain ⟨sourceRun,targetRun,post⟩ := step_bind_init_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h name value targetValue env kind a prior control targetControl lookup cell sourceBound targetBound
  exact ⟨_,sourceRun,targetRun,post,inventory.setCell h.heap a prior role value targetValue alive cell sourceRole selectedRole
    (Nat.lt_of_lt_of_le (h.heap.sourceBound _ alive) sourceBound)
    (Nat.lt_of_lt_of_le (h.heap.targetBound _ alive) targetBound)⟩

/-- The actual writable private-field step updates the private role and frames
cell and builtin metadata annotations. No post-step role or run is a premise. -/
theorem HeapInventory.private_store_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : HeapNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (oldTrace oldTrace' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after oldTrace oldTrace' s₀ s)
    (inventory : HeapInventory notes ν₀ ν C₀ C R live s₀ s)
    (owner brand : Nat) (name : Name) (role : Value) (value prior old : Val) (e : Bool) (o₀ : Obj) (fs₀ : List Frame)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .a (.put none (.priv (.obj owner) brand name) prior)::fs₀)
    (object : s₀.heap.get owner = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findPriv brand name o₀.priv = some (.data old true e))
    (sourceRole : role.Holds ν₀ C₀ identity value) (targetRole : role.Holds ν C R (returnedValue s.ctl))
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ result, interpC (step F s₀).run C₀ = some (({s₀ with stack := fs₀}.setObj owner
        {o₀ with priv := setPrivL brand name (.data value true e) o₀.priv}).ret value,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after oldTrace oldTrace'
        (({s₀ with stack := fs₀}.setObj owner {o₀ with priv := setPrivL brand name (.data value true e) o₀.priv}).ret value) result ∧
      HeapInventory (notes.writePrivate owner ⟨brand,name,role⟩) ν₀ ν C₀ C R live
        (({s₀ with stack := fs₀}.setObj owner {o₀ with priv := setPrivL brand name (.data value true e) o₀.priv}).ret value) result := by
  obtain ⟨targetValue,o,fs,targetControl,sourceRun,targetRun,post⟩ := step_private_store_from_source
    F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after oldTrace oldTrace' s₀ s h
    owner brand name value prior old e o₀ fs₀ control stack object ordinary descriptor sourceBound targetBound
  obtain ⟨privateResult,_,privateRun,_,privateInventory⟩ := inventory.privates.store_step F FR notes.privates ν₀ ν C₀ C R
    live framed before after oldTrace oldTrace' s₀ s h owner brand name role value prior old e o₀ fs₀
    control stack object ordinary descriptor sourceRole targetRole sourceBound targetBound
  have same := congrArg Prod.fst (Option.some.inj (privateRun.symm.trans targetRun))
  dsimp only at same
  rw [same] at privateInventory
  have hl := h.stackLive
  rw [stack] at hl
  have ownerLive : live owner := hl.1.1.2.1.1
  have sourceWord : owner < 2^64 := Nat.lt_of_lt_of_le (h.heap.sourceBound _ ownerLive) sourceBound
  have targetWord : R.a owner < 2^64 := Nat.lt_of_lt_of_le (h.heap.targetBound _ ownerLive) targetBound
  obtain ⟨oldTarget,oldTargetHeap,_,_⟩ := h.heap.readOrdinary owner o₀ ownerLive object ordinary
  let new₀ := {o₀ with priv := setPrivL brand name (.data value true e) o₀.priv}
  let new := {o with priv := setPrivL (R.a brand) name (.data targetValue true e) o.priv}
  have cells := inventory.cells.setObject h.heap owner o₀ oldTarget new₀ new value targetValue ownerLive object oldTargetHeap sourceWord targetWord
  have captures := inventory.captures.setOrdinary h.heap owner o₀ new₀ new value targetValue ownerLive object ordinary sourceWord targetWord
  refine ⟨_,sourceRun,targetRun,post,⟨?_,privateInventory,?_⟩⟩
  · exact cells.frame (fun _ live => live) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact captures.frame (fun _ live => live) (fun _ _ _ => rfl) (fun _ _ _ => rfl)

/-- A variable read preserves all three inventories and returns its fixed role. -/
theorem HeapInventory.variable_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : HeapNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : HeapInventory notes ν₀ ν C₀ C R live s₀ s)
    (name : Name) (env : Env) (a : Nat) (value : Val) (role : Value)
    (control : s₀.ctl = .ev (.id name) env) (lookup : lookupEnv name env = some a)
    (cell : s₀.heap.get a = some (.cell (some value))) (entry : notes.cells.cells a = some role) :
    ∃ targetValue, interpC (step F s₀).run C₀ = some (s₀.ret value,C₀) ∧
      interpC (step F s).run C = some (s.ret targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (s₀.ret value) (s.ret targetValue) ∧
      HeapInventory notes ν₀ ν C₀ C R live (s₀.ret value) (s.ret targetValue) ∧
      role.Holds ν₀ C₀ identity value ∧ role.Holds ν C R targetValue := by
  obtain ⟨targetValue,sourceRun,targetRun,post,cells,sourceRole,targetRole⟩ := inventory.cells.variable_step
    F FR notes.cells ν₀ ν C₀ C R live framed before after old old' s₀ s h name env a value role control lookup cell entry
  refine ⟨targetValue,sourceRun,targetRun,post,⟨cells,?_,?_⟩,sourceRole,targetRole⟩
  · exact inventory.privates.frame (fun _ live => live) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact inventory.captures.frame (fun _ live => live) (fun _ _ _ => rfl) (fun _ _ _ => rfl)

/-- A real private getter returns its annotated handle while preserving every
cell and builtin capture annotation. -/
theorem HeapInventory.private_read_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : HeapNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : HeapInventory notes ν₀ ν C₀ C R live s₀ s)
    (owner brand : Nat) (name : Name) (role : Value) (o₀ : Obj) (value : Val) (w e : Bool) (fs₀ : List Frame)
    (entry : notes.privates.owners owner = some ⟨brand,name,role⟩)
    (control : s₀.ctl = .ret (.obj owner)) (stack : s₀.stack = .e (.priv brand name false)::fs₀)
    (object : s₀.heap.get owner = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findPriv brand name o₀.priv = some (.data value w e)) :
    ∃ targetValue fs, interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret value,C₀) ∧
      interpC (step F s).run C = some ({s with stack := fs}.ret targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := fs₀}.ret value) ({s with stack := fs}.ret targetValue) ∧
      HeapInventory notes ν₀ ν C₀ C R live ({s₀ with stack := fs₀}.ret value) ({s with stack := fs}.ret targetValue) ∧
      role.Holds ν₀ C₀ identity value ∧ role.Holds ν C R targetValue := by
  obtain ⟨targetValue,fs,sourceRun,targetRun,post,privates,sourceRole,targetRole⟩ := inventory.privates.read_step
    F FR notes.privates ν₀ ν C₀ C R live framed before after old old' s₀ s h owner brand name role o₀ value w e fs₀
    entry control stack object ordinary descriptor
  refine ⟨targetValue,fs,sourceRun,targetRun,post,⟨?_,privates,?_⟩,sourceRole,targetRole⟩
  · exact inventory.cells.frame (fun _ live => live) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact inventory.captures.frame (fun _ live => live) (fun _ _ _ => rfl) (fun _ _ _ => rfl)

end Host.Ts.Owned.Annotated
