import host.ts.RenameRoleInventory
import host.ts.RenameParametricPrivateAssign
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- The active fixed data-field annotation for one owning object. In particular,
Array.handle has its own annotation while disposed booleans remain structural. -/
structure PrivateNote where
  brand : Nat
  name : Name
  role : Value
structure PrivateNotes where
  owners : Nat → Option PrivateNote

def PrivateNotes.empty : PrivateNotes := ⟨fun _ => none⟩
def PrivateNotes.write (notes : PrivateNotes) (owner : Nat) (note : PrivateNote) : PrivateNotes :=
  ⟨fun a => if a = owner then some note else notes.owners a⟩
def PrivateNotes.Live (notes : PrivateNotes) (live : Nat → Prop) : Prop :=
  ∀ a note, notes.owners a = some note → live a ∧ live note.brand

def PrivateNote.Holds {S : Type} (note : PrivateNote) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (owner : Nat) (s : St S) : Prop :=
  ∃ value, PrivateData s (R.a owner) (R.a note.brand) note.name value ∧ note.role.Holds ν C R value

def PrivateNotes.Holds {S : Type} (notes : PrivateNotes) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (s : St S) : Prop := ∀ a note, notes.owners a = some note → note.Holds ν C R a s

structure PrivateInventory {S : Type} (notes : PrivateNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (R : Ren) (live : Nat → Prop) (s₀ s : St S) : Prop where
  keyLive : notes.Live live
  source : notes.Holds ν₀ C₀ identity s₀
  target : notes.Holds ν C R s

section
variable {S : Type} {notes : PrivateNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
  {live live' : Nat → Prop} {s₀ s t₀ t : St S}

theorem privateData_unique {owner brand : Nat} {name : Name} {v w : Val}
    (hv : PrivateData s owner brand name v) (hw : PrivateData s owner brand name w) : v = w := by
  obtain ⟨o,vw,ve,ho,hv⟩ := hv
  obtain ⟨other,ww,we,hother,hw⟩ := hw
  have same : o = other := HObj.obj.inj (Option.some.inj (ho.symm.trans hother))
  subst other
  exact (PropV.data.inj (Option.some.inj (hv.symm.trans hw))).1

theorem PrivateInventory.empty : PrivateInventory PrivateNotes.empty ν₀ ν C₀ C R live s₀ s := by
  constructor <;> intro a note entry <;> cases entry

theorem PrivateNote.Holds.mono {ν : Nat → F64} {C D : CSrv} {R : Ren} {note : PrivateNote}
    {owner : Nat} {s : St S} (h : note.Holds ν C R owner s) (extension : TableExtends C D) :
    note.Holds ν D R owner s := by
  obtain ⟨value,field,role⟩ := h
  exact ⟨value,field,role.mono extension⟩

theorem PrivateNote.Holds.frame {ν : Nat → F64} {C : CSrv} {R : Ren} {note : PrivateNote}
    {owner : Nat} {s t : St S} (h : note.Holds ν C R owner s)
    (frame : t.heap.get (R.a owner) = s.heap.get (R.a owner)) : note.Holds ν C R owner t := by
  obtain ⟨value,field,role⟩ := h
  exact ⟨value,field.heap_at frame,role⟩

theorem PrivateInventory.frame (h : PrivateInventory notes ν₀ ν C₀ C R live s₀ s)
    (grow : ∀ a, live a → live' a)
    (sourceFrame : ∀ a note, notes.owners a = some note → t₀.heap.get a = s₀.heap.get a)
    (targetFrame : ∀ a note, notes.owners a = some note → t.heap.get (R.a a) = s.heap.get (R.a a)) :
    PrivateInventory notes ν₀ ν C₀ C R live' t₀ t := by
  refine ⟨fun a note entry => ⟨grow a (h.keyLive a note entry).1,grow note.brand (h.keyLive a note entry).2⟩,?_,?_⟩
  · exact fun a note entry => (h.source a note entry).frame (sourceFrame a note entry)
  · exact fun a note entry => (h.target a note entry).frame (targetFrame a note entry)

theorem PrivateInventory.mono {D₀ D : CSrv} (h : PrivateInventory notes ν₀ ν C₀ C R live s₀ s)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D) :
    PrivateInventory notes ν₀ ν D₀ D R live s₀ s :=
  ⟨h.keyLive,fun a note entry => (h.source a note entry).mono sourceExtension,
    fun a note entry => (h.target a note entry).mono targetExtension⟩

/-- Update the owning object's one active annotation, preserving every other
owner by live-address injectivity. The actual store helper derives its fields
and heap effects before applying this composition law. -/
theorem PrivateInventory.write_owner {NR : NumV → NumV → Prop} {framed : Nat → Prop}
    {before after : List Val} (h : PrivateInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (owner : Nat) (note : PrivateNote)
    (ownerLive : live owner) (brandLive : live note.brand)
    (sourceField : note.Holds ν₀ C₀ identity owner t₀) (targetField : note.Holds ν C R owner t)
    (sourceFrame : ∀ a, a ≠ owner → t₀.heap.get a = s₀.heap.get a)
    (targetFrame : ∀ a, a ≠ R.a owner → t.heap.get a = s.heap.get a) :
    PrivateInventory (notes.write owner note) ν₀ ν C₀ C R live t₀ t := by
  constructor
  · intro a other entry
    by_cases eq : a = owner
    · subst a
      have same : note = other := Option.some.inj (by simpa [PrivateNotes.write] using entry)
      exact same ▸ ⟨ownerLive,brandLive⟩
    · exact h.keyLive a other (by simpa only [PrivateNotes.write,ite_eq_right eq] using entry)
  · intro a other entry
    by_cases eq : a = owner
    · subst a
      have same : note = other := Option.some.inj (by simpa [PrivateNotes.write] using entry)
      exact same ▸ sourceField
    · have oldEntry : notes.owners a = some other := by simpa only [PrivateNotes.write,ite_eq_right eq] using entry
      exact (h.source a other oldEntry).frame (sourceFrame a eq)
  · intro a other entry
    by_cases eq : a = owner
    · subst a
      have same : note = other := Option.some.inj (by simpa [PrivateNotes.write] using entry)
      exact same ▸ targetField
    · have oldEntry : notes.owners a = some other := by simpa only [PrivateNotes.write,ite_eq_right eq] using entry
      have distinct : R.a a ≠ R.a owner := fun same => eq (heap.inj a owner (h.keyLive a other oldEntry).1 ownerLive same)
      exact (h.target a other oldEntry).frame (targetFrame (R.a a) distinct)
end

/-- The source private data descriptor selects the annotation. The actual
mapped field read determines the return value and retains the inventory. -/
theorem PrivateInventory.read_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : PrivateNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : PrivateInventory notes ν₀ ν C₀ C R live s₀ s)
    (owner brand : Nat) (name : Name) (role : Value) (o₀ : Obj) (value : Val) (w e : Bool) (fs₀ : List Frame)
    (entry : notes.owners owner = some ⟨brand,name,role⟩)
    (control : s₀.ctl = .ret (.obj owner)) (stack : s₀.stack = .e (.priv brand name false)::fs₀)
    (object : s₀.heap.get owner = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findPriv brand name o₀.priv = some (.data value w e)) :
    ∃ targetValue fs, interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret value,C₀) ∧
      interpC (step F s).run C = some ({s with stack := fs}.ret targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := fs₀}.ret value) ({s with stack := fs}.ret targetValue) ∧
      PrivateInventory notes ν₀ ν C₀ C R live ({s₀ with stack := fs₀}.ret value) ({s with stack := fs}.ret targetValue) ∧
      role.Holds ν₀ C₀ identity value ∧ role.Holds ν C R targetValue := by
  obtain ⟨sourceValue,sourceField,sourceRole⟩ := inventory.source owner _ entry
  have sourceField' : PrivateData s₀ owner brand name value := ⟨o₀,w,e,object,descriptor⟩
  have sourceEq := privateData_unique sourceField sourceField'
  subst sourceValue
  obtain ⟨targetValue,targetField,targetRole⟩ := inventory.target owner _ entry
  obtain ⟨p,_,sourceRun,targetRun,post,_⟩ := step_private_read_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h owner brand name o₀ (.data value w e) fs₀ control stack object ordinary descriptor
  obtain ⟨receiver,targetControl,receiverRole⟩ := (h.control_view control).ret_view
  cases receiverRole
  obtain ⟨frame,fs,targetStack,frameRole,_⟩ := h.stack_view stack
  rw [frameRole.private_view] at targetStack
  have actualRun : interpC (step F s).run C = some ({s with stack := fs}.ret targetValue,C) := by
    rw [step_private_data_eq F s (R.a owner) (R.a brand) name targetValue fs targetControl targetStack targetField]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans actualRun))
  dsimp only at same

  rw [same] at post
  refine ⟨targetValue,fs,sourceRun,actualRun,post,?_,sourceRole,targetRole⟩
  exact inventory.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)

/-- Extract the current return operand without selecting a meaning from bits. -/
def returnedValue : Ctl → Val
  | .ret value => value
  | _ => .undef

/-- The original writable private-data assignment updates the owner inventory.
The fixed new role comes from its current operand, and every other owner is
framed by the actual bounded object store. -/
theorem PrivateInventory.store_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : PrivateNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (oldTrace oldTrace' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after oldTrace oldTrace' s₀ s)
    (inventory : PrivateInventory notes ν₀ ν C₀ C R live s₀ s)
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
      PrivateInventory (notes.write owner ⟨brand,name,role⟩) ν₀ ν C₀ C R live
        (({s₀ with stack := fs₀}.setObj owner {o₀ with priv := setPrivL brand name (.data value true e) o₀.priv}).ret value) result := by
  obtain ⟨targetValue,o,fs,targetControl,sourceRun,targetRun,post⟩ := step_private_store_from_source
    F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after oldTrace oldTrace' s₀ s h
    owner brand name value prior old e o₀ fs₀ control stack object ordinary descriptor sourceBound targetBound
  have selectedRole : role.Holds ν C R targetValue := by simpa only [returnedValue,targetControl] using targetRole
  have hl := h.stackLive
  rw [stack] at hl
  have ownerLive : live owner := hl.1.1.2.1.1
  have brandLive : live brand := hl.1.1.2.1.2.1
  have sourceWord : owner < 2^64 := Nat.lt_of_lt_of_le (h.heap.sourceBound _ ownerLive) sourceBound
  have targetWord : R.a owner < 2^64 := Nat.lt_of_lt_of_le (h.heap.targetBound _ ownerLive) targetBound
  refine ⟨_,sourceRun,targetRun,post,inventory.write_owner h.heap owner ⟨brand,name,role⟩ ownerLive brandLive ?_ ?_ ?_ ?_⟩
  · refine ⟨value,⟨{o₀ with priv := setPrivL brand name (.data value true e) o₀.priv},true,e,?_,findPriv_set_same _ _ _ _⟩,sourceRole⟩
    simp only [identity,id_eq,St.setObj,St.ret,PTrie.get_set_u64 _ _ _ sourceWord,ite_true]
  · refine ⟨targetValue,⟨{o with priv := setPrivL (R.a brand) name (.data targetValue true e) o.priv},true,e,?_,findPriv_set_same _ _ _ _⟩,selectedRole⟩
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ targetWord,ite_true]
  · intro a other
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ sourceWord,ite_eq_right other]
  · intro a other
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ targetWord,ite_eq_right other]


/-- Adding an already established field annotation does not change execution. -/
theorem PrivateInventory.annotate {S : Type} {notes : PrivateNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {s₀ s : St S} {NR : NumV → NumV → Prop} {before after : List Val}
    (h : PrivateInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (owner : Nat) (note : PrivateNote)
    (ownerLive : live owner) (brandLive : live note.brand)
    (sourceField : note.Holds ν₀ C₀ identity owner s₀) (targetField : note.Holds ν C R owner s) :
    PrivateInventory (notes.write owner note) ν₀ ν C₀ C R live s₀ s :=
  h.write_owner heap owner note ownerLive brandLive sourceField targetField (fun _ _ => rfl) (fun _ _ => rfl)

/-- A real lexical cell and an owned private-field object cannot occupy the
same source address. Injectivity carries this disjointness to the target. -/
theorem PrivateInventory.setCell {S : Type} {notes : PrivateNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {s₀ s : St S} {NR : NumV → NumV → Prop} {before after : List Val}
    (h : PrivateInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (a : Nat) (prior : Option Val) (v₀ v : Val) (alive : live a)
    (cell : s₀.heap.get a = some (.cell prior)) (sourceBound : a < 2^64) (targetBound : R.a a < 2^64) :
    PrivateInventory notes ν₀ ν C₀ C R live ((s₀.setCell a v₀).ret .undef) ((s.setCell (R.a a) v).ret .undef) := by
  have distinct : ∀ b note, notes.owners b = some note → b ≠ a := by
    intro b note entry same
    obtain ⟨_,⟨object,_,_,objectHeap,_⟩,_⟩ := h.source b note entry
    have objectHeap : s₀.heap.get b = some (.obj object) := objectHeap
    rw [same,cell] at objectHeap
    cases objectHeap
  apply h.frame (fun _ live => live)
  · intro b note entry
    simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right (distinct b note entry)]
  · intro b note entry
    have other : R.a b ≠ R.a a := fun e => distinct b note entry (heap.inj b a (h.keyLive b note entry).1 alive e)
    simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right other]

/-- Fresh heap objects leave all prior private-field annotations unchanged. -/
theorem PrivateInventory.alloc {S : Type} {notes : PrivateNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {s₀ s : St S} {NR : NumV → NumV → Prop} {before after : List Val}
    (h : PrivateInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (o₀ o : HObj) (v₀ v : Val)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    PrivateInventory notes ν₀ ν C₀ C R (LiveAfter live s₀.next) ((s₀.alloc o₀).2.ret v₀) ((s.alloc o).2.ret v) := by
  apply h.frame (fun _ live => Or.inl live)
  · intro a note entry
    exact alloc_ret_heap_below s₀ o₀ v₀ sourceBound a (heap.sourceBound a (h.keyLive a note entry).1)
  · intro a note entry
    exact alloc_ret_heap_below s o v targetBound (R.a a) (heap.targetBound a (h.keyLive a note entry).1)

end Host.Ts.Owned.Annotated
