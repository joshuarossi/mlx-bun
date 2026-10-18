import host.ts.RenamePrivateInventory
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- An array retains the fixed meaning of each element, including dimensions
and handles. The address role alone does not retain these meanings. -/
structure ArrayNotes where
  owners : Nat → Option (List Value)

def ArrayNotes.empty : ArrayNotes := ⟨fun _ => none⟩
def ArrayNotes.write (notes : ArrayNotes) (owner : Nat) (roles : List Value) : ArrayNotes :=
  ⟨fun a => if a = owner then some roles else notes.owners a⟩
def ArrayContents {S : Type} (roles : List Value) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (owner : Nat) (s : St S) : Prop :=
  ∃ o values, s.heap.get (R.a owner) = some (.obj o) ∧ o.kind = .array values ∧
    ListR (fun role value => role.Holds ν C R value) roles values

def ArrayNotes.Holds {S : Type} (notes : ArrayNotes) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (s : St S) : Prop := ∀ a roles, notes.owners a = some roles → ArrayContents roles ν C R a s

def ArrayNotes.Closed {S : Type} (notes : ArrayNotes) (live : Nat → Prop) (s : St S) : Prop :=
  ∀ a roles, notes.owners a = some roles → ∀ o values,
    s.heap.get a = some (.obj o) → o.kind = .array values → listSupport (valueSupport live) values

structure ArrayInventory {S : Type} (notes : ArrayNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (R : Ren) (live : Nat → Prop) (s₀ s : St S) : Prop where
  keyLive : ∀ a roles, notes.owners a = some roles → live a
  source : notes.Holds ν₀ C₀ identity s₀
  target : notes.Holds ν C R s
  sourceClosed : notes.Closed live s₀

section
variable {S : Type} {notes : ArrayNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
  {live live' : Nat → Prop} {s₀ s t₀ t : St S}

theorem annotated_values_paired {roles : List Value} {source target : List Val}
    (hs : ListR (fun role value => role.Holds ν₀ C₀ identity value) roles source)
    (ht : ListR (fun role value => role.Holds ν C R value) roles target) :
    ListR (Parametric.ValueR (NumberRoles ν₀ ν C₀ C) R) source target := by
  induction hs generalizing target with
  | nil => cases ht; exact .nil
  | cons head tail ih => cases ht with | cons other rest => exact .cons (Value.paired head other) (ih rest)

theorem ArrayInventory.empty : ArrayInventory ArrayNotes.empty ν₀ ν C₀ C R live s₀ s := by
  constructor <;> intro a roles entry <;> cases entry

theorem ArrayContents.frame {roles : List Value} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {owner : Nat} {s t : St S} (h : ArrayContents roles ν C R owner s)
    (frame : t.heap.get (R.a owner) = s.heap.get (R.a owner)) : ArrayContents roles ν C R owner t := by
  obtain ⟨o,values,object,kind,roles⟩ := h
  exact ⟨o,values,frame.trans object,kind,roles⟩

theorem array_roles_mono {roles : List Value} {values : List Val} {ν : Nat → F64} {C D : CSrv} {R : Ren}
    (h : ListR (fun role value => role.Holds ν C R value) roles values) (extension : TableExtends C D) :
    ListR (fun role value => role.Holds ν D R value) roles values := by
  induction h with
  | nil => exact .nil
  | cons head _ ih => exact .cons (head.mono extension) ih

theorem ArrayContents.mono {roles : List Value} {ν : Nat → F64} {C D : CSrv} {R : Ren}
    {owner : Nat} {s : St S} (h : ArrayContents roles ν C R owner s) (extension : TableExtends C D) :
    ArrayContents roles ν D R owner s := by
  obtain ⟨o,values,object,kind,roles⟩ := h
  exact ⟨o,values,object,kind,array_roles_mono roles extension⟩

theorem ArrayInventory.frame (h : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (grow : ∀ a, live a → live' a)
    (sourceFrame : ∀ a roles, notes.owners a = some roles → t₀.heap.get a = s₀.heap.get a)
    (targetFrame : ∀ a roles, notes.owners a = some roles → t.heap.get (R.a a) = s.heap.get (R.a a)) :
    ArrayInventory notes ν₀ ν C₀ C R live' t₀ t := by
  refine ⟨fun a roles entry => grow a (h.keyLive a roles entry),
    fun a roles entry => (h.source a roles entry).frame (sourceFrame a roles entry),
    fun a roles entry => (h.target a roles entry).frame (targetFrame a roles entry),?_⟩
  intro a roles entry o values object kind
  exact listSupport_mono (valueSupport_mono grow) values
    (h.sourceClosed a roles entry o values ((sourceFrame a roles entry).symm.trans object) kind)

theorem ArrayInventory.mono {D₀ D : CSrv} (h : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D) :
    ArrayInventory notes ν₀ ν D₀ D R live s₀ s :=
  ⟨h.keyLive,fun a roles entry => (h.source a roles entry).mono sourceExtension,
    fun a roles entry => (h.target a roles entry).mono targetExtension,h.sourceClosed⟩

/-- Existing array contents determine the annotation; later reads cannot
choose a fresh interpretation of the same element. -/
theorem ArrayInventory.annotate (h : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (roles : List Value) (alive : live a)
    (source : ArrayContents roles ν₀ C₀ identity a s₀) (target : ArrayContents roles ν C R a s)
    (closed : ∀ o values, s₀.heap.get a = some (.obj o) → o.kind = .array values →
      listSupport (valueSupport live) values) :
    ArrayInventory (notes.write a roles) ν₀ ν C₀ C R live s₀ s := by
  constructor
  · intro b other entry
    by_cases eq : b = a
    · exact eq ▸ alive
    · exact h.keyLive b other (by simpa only [ArrayNotes.write,ite_eq_right eq] using entry)
  · intro b other entry
    by_cases eq : b = a
    · subst b
      have same : roles = other := Option.some.inj (by simpa [ArrayNotes.write] using entry)
      exact same ▸ source
    · exact h.source b other (by simpa only [ArrayNotes.write,ite_eq_right eq] using entry)
  · intro b other entry
    by_cases eq : b = a
    · subst b
      have same : roles = other := Option.some.inj (by simpa [ArrayNotes.write] using entry)
      exact same ▸ target
    · exact h.target b other (by simpa only [ArrayNotes.write,ite_eq_right eq] using entry)
  · intro b other entry o values object kind
    by_cases eq : b = a
    · subst b; exact closed o values object kind
    · exact h.sourceClosed b other (by simpa only [ArrayNotes.write,ite_eq_right eq] using entry) o values object kind

theorem ArrayInventory.selected (h : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (roles : List Value) (entry : notes.owners a = some roles) :
    ∃ o₀ o source target, s₀.heap.get a = some (.obj o₀) ∧ o₀.kind = .array source ∧
      s.heap.get (R.a a) = some (.obj o) ∧ o.kind = .array target ∧
      ListR (fun role value => role.Holds ν₀ C₀ identity value) roles source ∧
      ListR (fun role value => role.Holds ν C R value) roles target ∧
      ListR (Parametric.ValueR (NumberRoles ν₀ ν C₀ C) R) source target ∧ listSupport (valueSupport live) source := by
  obtain ⟨o₀,source,sourceObject,sourceKind,sourceRoles⟩ := h.source a roles entry
  obtain ⟨o,target,targetObject,targetKind,targetRoles⟩ := h.target a roles entry
  exact ⟨o₀,o,source,target,sourceObject,sourceKind,targetObject,targetKind,sourceRoles,targetRoles,
    annotated_values_paired sourceRoles targetRoles,h.sourceClosed a roles entry o₀ source sourceObject sourceKind⟩

theorem ArrayInventory.alloc {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (h : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (o₀ o : HObj) (v₀ v : Val)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    ArrayInventory notes ν₀ ν C₀ C R (LiveAfter live s₀.next) ((s₀.alloc o₀).2.ret v₀) ((s.alloc o).2.ret v) := by
  apply h.frame (fun _ alive => Or.inl alive)
  · intro a roles entry
    exact alloc_ret_heap_below s₀ o₀ v₀ sourceBound a (heap.sourceBound a (h.keyLive a roles entry))
  · intro a roles entry
    exact alloc_ret_heap_below s o v targetBound (R.a a) (heap.targetBound a (h.keyLive a roles entry))

theorem ArrayInventory.setCell {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (h : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (a : Nat) (prior : Option Val) (v₀ v : Val)
    (alive : live a) (cell : s₀.heap.get a = some (.cell prior)) (sourceBound : a < 2^64) (targetBound : R.a a < 2^64) :
    ArrayInventory notes ν₀ ν C₀ C R live ((s₀.setCell a v₀).ret .undef) ((s.setCell (R.a a) v).ret .undef) := by
  have distinct : ∀ b roles, notes.owners b = some roles → b ≠ a := by
    intro b roles entry same
    obtain ⟨object,_,objectHeap,_,_⟩ := h.source b roles entry
    have objectHeap : s₀.heap.get b = some (.obj object) := objectHeap
    rw [same,cell] at objectHeap
    cases objectHeap
  apply h.frame (fun _ alive => alive)
  · intro b roles entry
    simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right (distinct b roles entry)]
  · intro b roles entry
    have other : R.a b ≠ R.a a := fun e => distinct b roles entry (heap.inj b a (h.keyLive b roles entry) alive e)
    simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right other]

theorem ArrayInventory.setOrdinary {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (h : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (a : Nat) (old new₀ new : Obj) (v₀ v : Val)
    (alive : live a) (object : s₀.heap.get a = some (.obj old)) (ordinary : old.kind = .ordinary)
    (sourceBound : a < 2^64) (targetBound : R.a a < 2^64) :
    ArrayInventory notes ν₀ ν C₀ C R live ((s₀.setObj a new₀).ret v₀) ((s.setObj (R.a a) new).ret v) := by
  have distinct : ∀ b roles, notes.owners b = some roles → b ≠ a := by
    intro b roles entry same
    obtain ⟨o,values,objectHeap,kind,_⟩ := h.source b roles entry
    have objectHeap : s₀.heap.get b = some (.obj o) := objectHeap
    rw [same,object] at objectHeap
    have eq := HObj.obj.inj (Option.some.inj objectHeap)
    subst o
    rw [ordinary] at kind
    cases kind
  apply h.frame (fun _ alive => alive)
  · intro b roles entry
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right (distinct b roles entry)]
  · intro b roles entry
    have other : R.a b ≠ R.a a := fun e => distinct b roles entry (heap.inj b a (h.keyLive b roles entry) alive e)
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right other]
end
end Host.Ts.Owned.Annotated
