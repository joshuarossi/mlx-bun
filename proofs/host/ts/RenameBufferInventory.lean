import host.ts.RenameArrayInventory
import host.ts.RenameOwnedBuffer

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

/-- Each byte occurrence retains its fixed cell meaning. Native writes replace
the written occurrences; reads do not select a new interpretation. -/
structure BufferNotes where
  owners : Nat → Option (List Byte)

def BufferNotes.empty : BufferNotes := ⟨fun _ => none⟩
def BufferNotes.write (notes : BufferNotes) (owner : Nat) (roles : List Byte) : BufferNotes :=
  ⟨fun a => if a = owner then some roles else notes.owners a⟩

def BufferContents {S : Type} (roles : List Byte) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (owner : Nat) (s : St S) : Prop :=
  ∃ object bytes, s.heap.get (R.a owner) = some (.obj object) ∧ object.kind = .buf bytes ∧
    ListR (fun role byte => role.Holds ν C R byte) roles bytes

def BufferNotes.Holds {S : Type} (notes : BufferNotes) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (s : St S) : Prop := ∀ a roles, notes.owners a = some roles → BufferContents roles ν C R a s

structure BufferInventory {S : Type} (notes : BufferNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (R : Ren) (live : Nat → Prop) (s₀ s : St S) : Prop where
  keyLive : ∀ a roles, notes.owners a = some roles → live a
  source : notes.Holds ν₀ C₀ identity s₀
  target : notes.Holds ν C R s

theorem byte_roles_mono {roles : List Byte} {bytes : List Host.Ts.Byte}
    {ν : Nat → F64} {C D : CSrv} {R : Ren}
    (held : ListR (fun role byte => role.Holds ν C R byte) roles bytes) (extension : TableExtends C D) :
    ListR (fun role byte => role.Holds ν D R byte) roles bytes := by
  induction held with
  | nil => exact .nil
  | cons head _ ih => exact .cons (head.mono extension) ih

/-- Byte patching follows exactly the original take/write/drop update. The
write length is derived from the byte annotations on each side. -/
theorem byte_roles_patch {oldRoles writeRoles : List Byte} {bytes writes : List Host.Ts.Byte}
    {ν : Nat → F64} {C : CSrv} {R : Ren}
    (old : ListR (fun role byte => role.Holds ν C R byte) oldRoles bytes)
    (new : ListR (fun role byte => role.Holds ν C R byte) writeRoles writes) (off : Nat) :
    ListR (fun role byte => role.Holds ν C R byte)
      (oldRoles.take off ++ writeRoles ++ oldRoles.drop (off + len writeRoles))
      (bytes.take off ++ writes ++ bytes.drop (off + len writes)) := by
  have suffix : ListR (fun role byte => role.Holds ν C R byte)
      (oldRoles.drop (off + len writeRoles)) (bytes.drop (off + len writes)) := by
    rw [← new.len_eq]
    exact old.drop _
  exact ((old.take off).append new).append suffix

theorem BufferContents.frame {S : Type} {roles : List Byte} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {owner : Nat} {s t : St S} (held : BufferContents roles ν C R owner s)
    (frame : t.heap.get (R.a owner) = s.heap.get (R.a owner)) : BufferContents roles ν C R owner t := by
  obtain ⟨object,bytes,read,kind,roles⟩ := held
  exact ⟨object,bytes,frame.trans read,kind,roles⟩

theorem BufferContents.mono {S : Type} {roles : List Byte} {ν : Nat → F64} {C D : CSrv} {R : Ren}
    {owner : Nat} {s : St S} (held : BufferContents roles ν C R owner s) (extension : TableExtends C D) :
    BufferContents roles ν D R owner s := by
  obtain ⟨object,bytes,read,kind,roles⟩ := held
  exact ⟨object,bytes,read,kind,byte_roles_mono roles extension⟩

section
variable {S : Type} {notes : BufferNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
  {live live' : Nat → Prop} {s₀ s t₀ t : St S}

theorem BufferInventory.empty : BufferInventory BufferNotes.empty ν₀ ν C₀ C R live s₀ s := by
  constructor <;> intro a roles entry <;> cases entry

theorem BufferInventory.frame (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (grow : ∀ a, live a → live' a)
    (source : ∀ a roles, notes.owners a = some roles → t₀.heap.get a = s₀.heap.get a)
    (target : ∀ a roles, notes.owners a = some roles → t.heap.get (R.a a) = s.heap.get (R.a a)) :
    BufferInventory notes ν₀ ν C₀ C R live' t₀ t :=
  ⟨fun a roles selected => grow a (inventory.keyLive a roles selected),
    fun a roles selected => (inventory.source a roles selected).frame (source a roles selected),
    fun a roles selected => (inventory.target a roles selected).frame (target a roles selected)⟩

theorem BufferInventory.mono {D₀ D : CSrv} (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (source : TableExtends C₀ D₀) (target : TableExtends C D) : BufferInventory notes ν₀ ν D₀ D R live s₀ s :=
  ⟨inventory.keyLive,fun a roles selected => (inventory.source a roles selected).mono source,
    fun a roles selected => (inventory.target a roles selected).mono target⟩

theorem BufferInventory.annotate (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (owner : Nat) (roles : List Byte) (alive : live owner)
    (source : BufferContents roles ν₀ C₀ identity owner s₀) (target : BufferContents roles ν C R owner s) :
    BufferInventory (notes.write owner roles) ν₀ ν C₀ C R live s₀ s := by
  constructor
  · intro a other selected
    by_cases same : a = owner
    · exact same ▸ alive
    · exact inventory.keyLive a other (by simpa only [BufferNotes.write,ite_eq_right same] using selected)
  · intro a other selected
    by_cases same : a = owner
    · subst a
      have equal : roles = other := Option.some.inj (by simpa only [BufferNotes.write,ite_true] using selected)
      exact equal ▸ source
    · exact inventory.source a other (by simpa only [BufferNotes.write,ite_eq_right same] using selected)
  · intro a other selected
    by_cases same : a = owner
    · subst a
      have equal : roles = other := Option.some.inj (by simpa only [BufferNotes.write,ite_true] using selected)
      exact equal ▸ target
    · exact inventory.target a other (by simpa only [BufferNotes.write,ite_eq_right same] using selected)

theorem BufferInventory.selected (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (owner : Nat) (roles : List Byte) (selected : notes.owners owner = some roles) :
    ∃ object₀ object bytes₀ bytes, s₀.heap.get owner = some (.obj object₀) ∧ object₀.kind = .buf bytes₀ ∧
      s.heap.get (R.a owner) = some (.obj object) ∧ object.kind = .buf bytes ∧
      ListR (fun role byte => role.Holds ν₀ C₀ identity byte) roles bytes₀ ∧
      ListR (fun role byte => role.Holds ν C R byte) roles bytes := by
  obtain ⟨object₀,bytes₀,read₀,kind₀,source⟩ := inventory.source owner roles selected
  obtain ⟨object,bytes,read,kind,target⟩ := inventory.target owner roles selected
  exact ⟨object₀,object,bytes₀,bytes,read₀,kind₀,read,kind,source,target⟩

theorem BufferInventory.replace_owner (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (owner : Nat) (roles : List Byte) (alive : live owner)
    (source : BufferContents roles ν₀ C₀ identity owner t₀) (target : BufferContents roles ν C R owner t)
    (sourceFrame : ∀ a other, notes.owners a = some other → a ≠ owner → t₀.heap.get a = s₀.heap.get a)
    (targetFrame : ∀ a other, notes.owners a = some other → a ≠ owner → t.heap.get (R.a a) = s.heap.get (R.a a)) :
    BufferInventory (notes.write owner roles) ν₀ ν C₀ C R live t₀ t := by
  constructor
  · intro a other selected
    by_cases same : a = owner
    · exact same ▸ alive
    · exact inventory.keyLive a other (by simpa only [BufferNotes.write,ite_eq_right same] using selected)
  · intro a other selected
    by_cases same : a = owner
    · subst a
      have equal : roles = other := Option.some.inj (by simpa only [BufferNotes.write,ite_true] using selected)
      exact equal ▸ source
    · have old : notes.owners a = some other := by simpa only [BufferNotes.write,ite_eq_right same] using selected
      exact (inventory.source a other old).frame (sourceFrame a other old same)
  · intro a other selected
    by_cases same : a = owner
    · subst a
      have equal : roles = other := Option.some.inj (by simpa only [BufferNotes.write,ite_true] using selected)
      exact equal ▸ target
    · have old : notes.owners a = some other := by simpa only [BufferNotes.write,ite_eq_right same] using selected
      exact (inventory.target a other old).frame (targetFrame a other old same)

/-- The selected buffer determines both original writes. The post-note is the
fixed take/write/drop patch; every other selected buffer is framed using heap
injectivity. No target buffer lookup or post-note is assumed. -/
theorem BufferInventory.write_bytes (F : Ffi) {s₀ s : St F.S}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (owner off : Nat) (oldRoles writeRoles : List Byte) (writes₀ writes : List Host.Ts.Byte)
    (selected : notes.owners owner = some oldRoles)
    (sourceRoles : ListR (fun role byte => role.Holds ν₀ C₀ identity byte) writeRoles writes₀)
    (targetRoles : ListR (fun role byte => role.Holds ν C R byte) writeRoles writes)
    (sourceBound : owner < 2^64) (targetBound : R.a owner < 2^64) :
    ∃ t₀ t, applyWrites F s₀ [(owner,off,writes₀)] = some t₀ ∧
      applyWrites F s [(R.a owner,off,writes)] = some t ∧
      BufferInventory (notes.write owner
        (oldRoles.take off ++ writeRoles ++ oldRoles.drop (off + len writeRoles))) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨object₀,object,bytes₀,bytes,read₀,kind₀,read,kind,held₀,held⟩ := inventory.selected owner oldRoles selected
  let new₀ := {object₀ with kind := Kind.buf (bytes₀.take off ++ writes₀ ++ bytes₀.drop (off + len writes₀))}
  let new := {object with kind := Kind.buf (bytes.take off ++ writes ++ bytes.drop (off + len writes))}
  refine ⟨s₀.setObj owner new₀,s.setObj (R.a owner) new,?_,?_,?_⟩
  · exact applyWrites_one_buffer F s₀ owner off writes₀ bytes₀ object₀ (by simp only [St.obj?,read₀]) kind₀
  · exact applyWrites_one_buffer F s (R.a owner) off writes bytes object (by simp only [St.obj?,read]) kind
  · apply inventory.replace_owner owner _ (inventory.keyLive owner oldRoles selected)
    · refine ⟨new₀,_,?_,rfl,byte_roles_patch held₀ sourceRoles off⟩
      simp only [St.setObj,PTrie.get_set_u64 _ _ _ sourceBound,identity,id_eq,ite_true]
    · refine ⟨new,_,?_,rfl,byte_roles_patch held targetRoles off⟩
      simp only [St.setObj,PTrie.get_set_u64 _ _ _ targetBound,ite_true]
    · intro a other _ different
      simp only [St.setObj,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right different]
    · intro a other entry different
      have mapped : R.a a ≠ R.a owner := fun same => different
        (heap.inj a owner (inventory.keyLive a other entry) (inventory.keyLive owner oldRoles selected) same)
      simp only [St.setObj,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right mapped]

theorem BufferInventory.alloc {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s) (object₀ object : HObj) (value₀ value : Val)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    BufferInventory notes ν₀ ν C₀ C R (LiveAfter live s₀.next)
      ((s₀.alloc object₀).2.ret value₀) ((s.alloc object).2.ret value) := by
  apply inventory.frame (fun _ alive => Or.inl alive)
  · intro a roles selected
    exact alloc_ret_heap_below s₀ object₀ value₀ sourceBound a (heap.sourceBound a (inventory.keyLive a roles selected))
  · intro a roles selected
    exact alloc_ret_heap_below s object value targetBound (R.a a) (heap.targetBound a (inventory.keyLive a roles selected))

/-- A real paired buffer allocation installs its byte meanings immediately.
Freshness determines the target owner; no target heap read is a premise. -/
theorem BufferInventory.allocate_buffer {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (object₀ object : Obj) (bytes₀ bytes : List Host.Ts.Byte) (roles : List Byte) (value₀ value : Val)
    (sourceKind : object₀.kind = .buf bytes₀) (targetKind : object.kind = .buf bytes)
    (sourceRoles : ListR (fun role byte => role.Holds ν₀ C₀ identity byte) roles bytes₀)
    (targetRoles : ListR (fun role byte => role.Holds ν C R byte) roles bytes)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    BufferInventory (notes.write s₀.next roles) ν₀ ν C₀ C R (LiveAfter live s₀.next)
      ((s₀.alloc (.obj object₀)).2.ret value₀) ((s.alloc (.obj object)).2.ret value) := by
  have fresh : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using heap.fresh 0
  apply (inventory.alloc heap (.obj object₀) (.obj object) value₀ value sourceBound targetBound).annotate
    s₀.next roles (Or.inr rfl)
  · refine ⟨object₀,bytes₀,?_,sourceKind,sourceRoles⟩
    simp only [St.alloc,St.ret,identity,id_eq,PTrie.get_set_u64 _ _ _ sourceBound,ite_true]
  · refine ⟨object,bytes,?_,targetKind,targetRoles⟩
    simp only [St.alloc,St.ret,fresh,PTrie.get_set_u64 _ _ _ targetBound,ite_true]

theorem BufferInventory.set_nonBuffer {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (address : Nat) (prior sourceObject targetObject : Obj) (alive : live address)
    (read : s₀.heap.get address = some (.obj prior)) (nonBuffer : ∀ bytes, prior.kind ≠ .buf bytes)
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64) :
    BufferInventory notes ν₀ ν C₀ C R live (s₀.setObj address sourceObject) (s.setObj (R.a address) targetObject) := by
  have different : ∀ a roles, notes.owners a = some roles → a ≠ address := by
    intro a roles selected same
    obtain ⟨object,bytes,objectRead,kind,_⟩ := inventory.source a roles selected
    have objectRead : s₀.heap.get a = some (.obj object) := objectRead
    rw [same,read] at objectRead
    have equal := HObj.obj.inj (Option.some.inj objectRead)
    subst object
    exact nonBuffer bytes kind
  apply inventory.frame (fun _ held => held)
  · intro a roles selected
    simp only [St.setObj,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right (different a roles selected)]
  · intro a roles selected
    have mapped : R.a a ≠ R.a address := fun same => different a roles selected
      (heap.inj a address (inventory.keyLive a roles selected) alive same)
    simp only [St.setObj,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right mapped]

theorem BufferInventory.setCell {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (address : Nat) (prior : Option Val) (sourceValue targetValue : Val) (alive : live address)
    (read : s₀.heap.get address = some (.cell prior))
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64) :
    BufferInventory notes ν₀ ν C₀ C R live (s₀.setCell address sourceValue) (s.setCell (R.a address) targetValue) := by
  have different : ∀ a roles, notes.owners a = some roles → a ≠ address := by
    intro a roles selected same
    obtain ⟨object,_,objectRead,_,_⟩ := inventory.source a roles selected
    have objectRead : s₀.heap.get a = some (.obj object) := objectRead
    rw [same,read] at objectRead
    cases objectRead
  apply inventory.frame (fun _ held => held)
  · intro a roles selected
    simp only [St.setCell,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right (different a roles selected)]
  · intro a roles selected
    have mapped : R.a a ≠ R.a address := fun same => different a roles selected
      (heap.inj a address (inventory.keyLive a roles selected) alive same)
    simp only [St.setCell,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right mapped]

end
end Host.Ts.Owned.Annotated
