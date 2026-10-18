import host.ts.RenamePrivateInventory
import host.ts.RenameParametricPropWrites
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- A direct own string data descriptor, independently of accessors and
prototype-chain dispatch. -/
def PublicData {S : Type} (s : St S) (owner : Nat) (name : Name) (value : Val) : Prop :=
  ∃ o w e, s.heap.get owner = some (.obj o) ∧ findProp (.str name) o.props = some (.data value w e)

theorem PublicData.unique {S : Type} {s : St S} {a : Nat} {name : Name} {v w : Val}
    (left : PublicData s a name v) (right : PublicData s a name w) : v = w := by
  obtain ⟨o,_,_,object,field⟩ := left
  obtain ⟨other,_,_,otherObject,otherField⟩ := right
  have same := HObj.obj.inj (Option.some.inj (object.symm.trans otherObject))
  subst other
  exact (PropV.data.inj (Option.some.inj (field.symm.trans otherField))).1

theorem PublicData.heap_at {S : Type} {s t : St S} {a : Nat} {name : Name} {v : Val}
    (h : PublicData s a name v) (frame : t.heap.get a = s.heap.get a) : PublicData t a name v := by
  obtain ⟨o,w,e,object,field⟩ := h
  exact ⟨o,w,e,frame.trans object,field⟩

theorem PublicData.name_code {S : Type} {s : St S} {a : Nat} {name other : Name} {v : Val}
    (h : PublicData s a name v) (same : pack other = pack name) : PublicData s a other v := by
  obtain ⟨o,w,e,object,field⟩ := h
  refine ⟨o,w,e,object,?_⟩
  have key : (PKey.str other).code = (PKey.str name).code := by simp only [PKey.code,same]
  unfold findProp findPropLinear at field ⊢
  simpa only [key] using field

theorem PublicData.setKind {S : Type} {s : St S} {owner : Nat} {name : Name} {value : Val}
    (field : PublicData s owner name value) (a : Nat) (o : Obj) (kind : Kind)
    (read : s.heap.get a = some (.obj o)) (bound : a < 2^64) :
    PublicData (s.setObj a {o with kind := kind}) owner name value := by
  by_cases same : owner = a
  · subst owner
    obtain ⟨old,w,e,object,descriptor⟩ := field
    have eq := HObj.obj.inj (Option.some.inj (object.symm.trans read))
    subst old
    refine ⟨{o with kind := kind},w,e,?_,descriptor⟩
    simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_true]
  · exact field.heap_at (by simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_eq_right same])
end Host.Ts.Owned.Parametric

namespace Host.Ts.Owned.Annotated
open Parametric

/-- One owning object may carry several numeric fields. Selection uses the
same packed name code as the actual ordered-property interpreter. -/
structure PublicNotes where
  fields : Nat → Name → Option Value

def PublicNotes.empty : PublicNotes := ⟨fun _ _ => none⟩
def PublicNotes.write (notes : PublicNotes) (owner : Nat) (name : Name) (role : Value) : PublicNotes :=
  ⟨fun a n => if a = owner ∧ pack n = pack name then some role else notes.fields a n⟩
def PublicNotes.Live (notes : PublicNotes) (live : Nat → Prop) : Prop :=
  ∀ a name role, notes.fields a name = some role → live a

def PublicFieldHolds {S : Type} (role : Value) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (owner : Nat) (name : Name) (s : St S) : Prop :=
  ∃ value, PublicData s (R.a owner) name value ∧ role.Holds ν C R value

def PublicNotes.Holds {S : Type} (notes : PublicNotes) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (s : St S) : Prop := ∀ a name role, notes.fields a name = some role → PublicFieldHolds role ν C R a name s

structure PublicInventory {S : Type} (notes : PublicNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (R : Ren) (live : Nat → Prop) (s₀ s : St S) : Prop where
  keyLive : notes.Live live
  source : notes.Holds ν₀ C₀ identity s₀
  target : notes.Holds ν C R s

section
variable {S : Type} {notes : PublicNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
  {live live' : Nat → Prop} {s₀ s t₀ t : St S}

theorem PublicInventory.empty : PublicInventory PublicNotes.empty ν₀ ν C₀ C R live s₀ s := by
  constructor <;> intro a name role entry <;> cases entry

theorem PublicFieldHolds.frame {role : Value} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {a : Nat} {name : Name} {s t : St S} (h : PublicFieldHolds role ν C R a name s)
    (frame : t.heap.get (R.a a) = s.heap.get (R.a a)) : PublicFieldHolds role ν C R a name t := by
  obtain ⟨value,field,role⟩ := h
  exact ⟨value,field.heap_at frame,role⟩

theorem PublicFieldHolds.mono {role : Value} {ν : Nat → F64} {C D : CSrv} {R : Ren}
    {a : Nat} {name : Name} {s : St S} (h : PublicFieldHolds role ν C R a name s) (extension : TableExtends C D) :
    PublicFieldHolds role ν D R a name s := by
  obtain ⟨value,field,role⟩ := h
  exact ⟨value,field,role.mono extension⟩

theorem PublicFieldHolds.setKind {role : Value} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {a : Nat} {name : Name} {s : St S} (h : PublicFieldHolds role ν C R a name s)
    (address : Nat) (object : Obj) (kind : Kind) (read : s.heap.get address = some (.obj object)) (bound : address < 2^64) :
    PublicFieldHolds role ν C R a name (s.setObj address {object with kind := kind}) := by
  obtain ⟨value,field,role⟩ := h
  exact ⟨value,field.setKind address object kind read bound,role⟩

theorem PublicInventory.frame (h : PublicInventory notes ν₀ ν C₀ C R live s₀ s)
    (grow : ∀ a, live a → live' a)
    (sourceFrame : ∀ a name role, notes.fields a name = some role → t₀.heap.get a = s₀.heap.get a)
    (targetFrame : ∀ a name role, notes.fields a name = some role → t.heap.get (R.a a) = s.heap.get (R.a a)) :
    PublicInventory notes ν₀ ν C₀ C R live' t₀ t :=
  ⟨fun a name role entry => grow a (h.keyLive a name role entry),
    fun a name role entry => (h.source a name role entry).frame (sourceFrame a name role entry),
    fun a name role entry => (h.target a name role entry).frame (targetFrame a name role entry)⟩

theorem PublicInventory.mono {D₀ D : CSrv} (h : PublicInventory notes ν₀ ν C₀ C R live s₀ s)
    (left : TableExtends C₀ D₀) (right : TableExtends C D) :
    PublicInventory notes ν₀ ν D₀ D R live s₀ s :=
  ⟨h.keyLive,fun a name role entry => (h.source a name role entry).mono left,
    fun a name role entry => (h.target a name role entry).mono right⟩

theorem PublicInventory.annotate (h : PublicInventory notes ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (name : Name) (role : Value) (alive : live a)
    (source : PublicFieldHolds role ν₀ C₀ identity a name s₀) (target : PublicFieldHolds role ν C R a name s) :
    PublicInventory (notes.write a name role) ν₀ ν C₀ C R live s₀ s := by
  constructor
  · intro b n r entry
    by_cases same : b = a ∧ pack n = pack name
    · exact same.1 ▸ alive
    · exact h.keyLive b n r (by simpa only [PublicNotes.write,ite_eq_right same] using entry)
  · intro b n r entry
    by_cases same : b = a ∧ pack n = pack name
    · obtain ⟨rfl,codes⟩ := same
      have eq : role = r := Option.some.inj (by simpa [PublicNotes.write,codes] using entry)
      subst r
      obtain ⟨value,field,role⟩ := source
      exact ⟨value,field.name_code codes,role⟩
    · exact h.source b n r (by simpa only [PublicNotes.write,ite_eq_right same] using entry)
  · intro b n r entry
    by_cases same : b = a ∧ pack n = pack name
    · obtain ⟨rfl,codes⟩ := same
      have eq : role = r := Option.some.inj (by simpa [PublicNotes.write,codes] using entry)
      subst r
      obtain ⟨value,field,role⟩ := target
      exact ⟨value,field.name_code codes,role⟩
    · exact h.target b n r (by simpa only [PublicNotes.write,ite_eq_right same] using entry)

theorem PublicInventory.alloc {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (h : PublicInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (o₀ o : HObj) (v₀ v : Val)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    PublicInventory notes ν₀ ν C₀ C R (LiveAfter live s₀.next) ((s₀.alloc o₀).2.ret v₀) ((s.alloc o).2.ret v) := by
  apply h.frame (fun _ alive => Or.inl alive)
  · intro a name role entry
    exact alloc_ret_heap_below s₀ o₀ v₀ sourceBound a (heap.sourceBound a (h.keyLive a name role entry))
  · intro a name role entry
    exact alloc_ret_heap_below s o v targetBound (R.a a) (heap.targetBound a (h.keyLive a name role entry))

theorem PublicInventory.setKind (h : PublicInventory notes ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (o₀ o : Obj) (kind₀ kind : Kind)
    (source : s₀.heap.get a = some (.obj o₀)) (target : s.heap.get (R.a a) = some (.obj o))
    (sourceBound : a < 2^64) (targetBound : R.a a < 2^64) :
    PublicInventory notes ν₀ ν C₀ C R live (s₀.setObj a {o₀ with kind := kind₀}) (s.setObj (R.a a) {o with kind := kind}) :=
  ⟨h.keyLive,fun b name role entry => (h.source b name role entry).setKind a o₀ kind₀ source sourceBound,
    fun b name role entry => (h.target b name role entry).setKind (R.a a) o kind target targetBound⟩
end
end Host.Ts.Owned.Annotated
