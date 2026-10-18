import host.ts.RenamePrivateInventory
import host.ts.RenameParametricTypedBuffer
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Fixed metadata of an actual builtin closure, including typed-constructor
code and prototype captures. Each argument position has its own meaning. -/
structure NativeCaptureNote where
  code : Native
  roles : Nat → Option Value
structure NativeCaptureNotes where
  owners : Nat → Option NativeCaptureNote

def NativeCaptureNotes.empty : NativeCaptureNotes := ⟨fun _ => none⟩
def NativeCaptureNotes.write (notes : NativeCaptureNotes) (owner : Nat) (note : NativeCaptureNote) : NativeCaptureNotes :=
  ⟨fun a => if a = owner then some note else notes.owners a⟩

def NativeCaptureNote.Holds {S : Type} (note : NativeCaptureNote) (ν : Nat → F64) (C : CSrv)
    (R : Ren) (owner : Nat) (s : St S) : Prop :=
  ∃ o data, s.heap.get (R.a owner) = some (.obj o) ∧ o.kind = .fn (.native note.code data) ∧
    ∀ i role, note.roles i = some role → role.Holds ν C R (Host.Ts.arg data i)
def NativeCaptureNotes.Holds {S : Type} (notes : NativeCaptureNotes) (ν : Nat → F64) (C : CSrv)
    (R : Ren) (s : St S) : Prop := ∀ a note, notes.owners a = some note → note.Holds ν C R a s

def NativeCaptureNotes.Live (notes : NativeCaptureNotes) (live : Nat → Prop) : Prop :=
  ∀ a note, notes.owners a = some note → live a
structure NativeCaptureInventory {S : Type} (notes : NativeCaptureNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (R : Ren) (live : Nat → Prop) (s₀ s : St S) : Prop where
  keyLive : notes.Live live
  source : notes.Holds ν₀ C₀ identity s₀
  target : notes.Holds ν C R s

section
variable {S : Type} {notes : NativeCaptureNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
  {live live' : Nat → Prop} {s₀ s t₀ t : St S}

theorem NativeCaptureInventory.empty : NativeCaptureInventory NativeCaptureNotes.empty ν₀ ν C₀ C R live s₀ s := by
  constructor <;> intro a note entry <;> cases entry

theorem NativeCaptureInventory.annotate (h : NativeCaptureInventory notes ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (note : NativeCaptureNote) (alive : live a)
    (source : note.Holds ν₀ C₀ identity a s₀) (target : note.Holds ν C R a s) :
    NativeCaptureInventory (notes.write a note) ν₀ ν C₀ C R live s₀ s := by
  constructor
  · intro b other entry
    by_cases eq : b = a
    · exact eq ▸ alive
    · exact h.keyLive b other (by simpa only [NativeCaptureNotes.write,ite_eq_right eq] using entry)
  · intro b other entry
    by_cases eq : b = a
    · subst b
      have same : note = other := Option.some.inj (by simpa [NativeCaptureNotes.write] using entry)
      exact same ▸ source
    · exact h.source b other (by simpa only [NativeCaptureNotes.write,ite_eq_right eq] using entry)
  · intro b other entry
    by_cases eq : b = a
    · subst b
      have same : note = other := Option.some.inj (by simpa [NativeCaptureNotes.write] using entry)
      exact same ▸ target
    · exact h.target b other (by simpa only [NativeCaptureNotes.write,ite_eq_right eq] using entry)

theorem NativeCaptureNote.Holds.argument {note : NativeCaptureNote} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {owner : Nat} {s : St S} (h : note.Holds ν C R owner s) (i : Nat) (role : Value) (entry : note.roles i = some role) :
    role.Holds ν C R (nativeDataArgument s (R.a owner) i) := by
  obtain ⟨o,data,object,kind,roles⟩ := h
  simpa only [nativeDataArgument,St.obj?,object,kind] using roles i role entry

theorem NativeCaptureInventory.argument (h : NativeCaptureInventory notes ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (note : NativeCaptureNote) (owner : notes.owners a = some note)
    (i : Nat) (role : Value) (entry : note.roles i = some role) :
    live a ∧ role.Holds ν₀ C₀ identity (nativeDataArgument s₀ a i) ∧
      role.Holds ν C R (nativeDataArgument s (R.a a) i) :=
  ⟨h.keyLive a note owner,(h.source a note owner).argument i role entry,(h.target a note owner).argument i role entry⟩

theorem NativeCaptureNote.Holds.frame {note : NativeCaptureNote} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {owner : Nat} {s t : St S} (h : note.Holds ν C R owner s)
    (frame : t.heap.get (R.a owner) = s.heap.get (R.a owner)) : note.Holds ν C R owner t := by
  obtain ⟨o,data,object,kind,roles⟩ := h
  exact ⟨o,data,frame.trans object,kind,roles⟩

theorem NativeCaptureNote.Holds.mono {note : NativeCaptureNote} {ν : Nat → F64} {C D : CSrv} {R : Ren}
    {owner : Nat} {s : St S} (h : note.Holds ν C R owner s) (extension : TableExtends C D) :
    note.Holds ν D R owner s := by
  obtain ⟨o,data,object,kind,roles⟩ := h
  exact ⟨o,data,object,kind,fun i role entry => (roles i role entry).mono extension⟩

theorem NativeCaptureInventory.frame (h : NativeCaptureInventory notes ν₀ ν C₀ C R live s₀ s)
    (grow : ∀ a, live a → live' a)
    (sourceFrame : ∀ a note, notes.owners a = some note → t₀.heap.get a = s₀.heap.get a)
    (targetFrame : ∀ a note, notes.owners a = some note → t.heap.get (R.a a) = s.heap.get (R.a a)) :
    NativeCaptureInventory notes ν₀ ν C₀ C R live' t₀ t :=
  ⟨fun a note entry => grow a (h.keyLive a note entry),
    fun a note entry => (h.source a note entry).frame (sourceFrame a note entry),
    fun a note entry => (h.target a note entry).frame (targetFrame a note entry)⟩

theorem NativeCaptureInventory.mono {D₀ D : CSrv} (h : NativeCaptureInventory notes ν₀ ν C₀ C R live s₀ s)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D) :
    NativeCaptureInventory notes ν₀ ν D₀ D R live s₀ s :=
  ⟨h.keyLive,fun a note entry => (h.source a note entry).mono sourceExtension,
    fun a note entry => (h.target a note entry).mono targetExtension⟩

theorem NativeCaptureInventory.setCell {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (h : NativeCaptureInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (a : Nat) (prior : Option Val) (v₀ v : Val)
    (alive : live a) (cell : s₀.heap.get a = some (.cell prior)) (sourceBound : a < 2^64) (targetBound : R.a a < 2^64) :
    NativeCaptureInventory notes ν₀ ν C₀ C R live ((s₀.setCell a v₀).ret .undef) ((s.setCell (R.a a) v).ret .undef) := by
  have distinct : ∀ b note, notes.owners b = some note → b ≠ a := by
    intro b note entry same
    obtain ⟨object,_,objectHeap,_,_⟩ := h.source b note entry
    have objectHeap : s₀.heap.get b = some (.obj object) := objectHeap
    rw [same,cell] at objectHeap
    cases objectHeap
  apply h.frame (fun _ alive => alive)
  · intro b note entry
    simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right (distinct b note entry)]
  · intro b note entry
    have other : R.a b ≠ R.a a := fun e => distinct b note entry (heap.inj b a (h.keyLive b note entry) alive e)
    simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right other]

/-- Mutable ordinary objects are distinct from immutable native closures in
this inventory. The distinction follows from the actual source object kinds. -/
theorem NativeCaptureInventory.setOrdinary {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (h : NativeCaptureInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (a : Nat) (old₀ new₀ new : Obj) (v₀ v : Val)
    (alive : live a) (object : s₀.heap.get a = some (.obj old₀)) (ordinary : old₀.kind = .ordinary)
    (sourceBound : a < 2^64) (targetBound : R.a a < 2^64) :
    NativeCaptureInventory notes ν₀ ν C₀ C R live ((s₀.setObj a new₀).ret v₀) ((s.setObj (R.a a) new).ret v) := by
  have distinct : ∀ b note, notes.owners b = some note → b ≠ a := by
    intro b note entry same
    obtain ⟨o,data,objectHeap,kind,_⟩ := h.source b note entry
    have objectHeap : s₀.heap.get b = some (.obj o) := objectHeap
    rw [same] at objectHeap
    have eq : old₀ = o := HObj.obj.inj (Option.some.inj (object.symm.trans objectHeap))
    rw [←eq,ordinary] at kind
    cases kind
  apply h.frame (fun _ alive => alive)
  · intro b note entry
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right (distinct b note entry)]
  · intro b note entry
    have other : R.a b ≠ R.a a := fun e => distinct b note entry (heap.inj b a (h.keyLive b note entry) alive e)
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right other]

theorem NativeCaptureInventory.alloc {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (h : NativeCaptureInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (o₀ o : HObj) (v₀ v : Val)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    NativeCaptureInventory notes ν₀ ν C₀ C R (LiveAfter live s₀.next) ((s₀.alloc o₀).2.ret v₀) ((s.alloc o).2.ret v) := by
  apply h.frame (fun _ alive => Or.inl alive)
  · intro a note entry
    exact alloc_ret_heap_below s₀ o₀ v₀ sourceBound a (heap.sourceBound a (h.keyLive a note entry))
  · intro a note entry
    exact alloc_ret_heap_below s o v targetBound (R.a a) (heap.targetBound a (h.keyLive a note entry))
end
end Host.Ts.Owned.Annotated
