import host.ts.RenameRetainedStores

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def RetainedNotes.privateInitialized (notes : RetainedNotes) (owner brand : Nat) (name : Name) (role : Value) : RetainedNotes :=
  {notes with privates := notes.privates.write owner ⟨brand,name,role⟩}

/-- The field initializer's original define-private operation installs the
current value's existing role. It frames lexical cells, native captures,
arrays, public fields and backing buffers by source ownership. -/
theorem RetainedInventory.initialize_private {S : Type} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {s₀ s : St S} {NR : NumV → NumV → Prop}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (owner brand : Nat) (name : Name) (role : Value) (value targetValue : Val) (object targetObject : Obj)
    (ownerLive : live owner) (brandLive : live brand)
    (sourceObject : s₀.heap.get owner = some (.obj object))
    (targetObjectRead : s.heap.get (R.a owner) = some (.obj targetObject))
    (ordinary : object.kind = .ordinary)
    (sourceRole : role.Holds ν₀ C₀ identity value) (targetRole : role.Holds ν C R targetValue)
    (sourceBound : owner < 2^64) (targetBound : R.a owner < 2^64) :
    RetainedInventory (notes.privateInitialized owner brand name role) ν₀ ν C₀ C R live
      (s₀.setObj owner {object with priv := setPrivL brand name (.data value true false) object.priv})
      (s.setObj (R.a owner) {targetObject with priv := setPrivL (R.a brand) name (.data targetValue true false) targetObject.priv}) := by
  let new₀ := {object with priv := setPrivL brand name (.data value true false) object.priv}
  let new := {targetObject with priv := setPrivL (R.a brand) name (.data targetValue true false) targetObject.priv}
  have cells : CellInventory notes.runtime.cells ν₀ ν C₀ C R live (s₀.setObj owner new₀) (s.setObj (R.a owner) new) :=
    (inventory.runtime.cellInventory.setObject heap owner object targetObject new₀ new .undef .undef
    ownerLive sourceObject targetObjectRead sourceBound targetBound).frame (fun _ alive => alive)
      (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  have captures : NativeCaptureInventory notes.captures ν₀ ν C₀ C R live (s₀.setObj owner new₀) (s.setObj (R.a owner) new) :=
    (inventory.captures.setOrdinary heap owner object new₀ new .undef .undef
    ownerLive sourceObject ordinary sourceBound targetBound).frame (fun _ alive => alive)
      (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  have arrays : ArrayInventory notes.arrays ν₀ ν C₀ C R live (s₀.setObj owner new₀) (s.setObj (R.a owner) new) :=
    (inventory.arrays.setOrdinary heap owner object new₀ new .undef .undef
    ownerLive sourceObject ordinary sourceBound targetBound).frame (fun _ alive => alive)
      (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  have publics := inventory.publicFields.setPrivs owner object targetObject new₀.priv new.priv
    sourceObject targetObjectRead sourceBound targetBound
  have buffers : BufferInventory notes.buffers ν₀ ν C₀ C R live (s₀.setObj owner new₀) (s.setObj (R.a owner) new) :=
    (inventory.buffers.setOrdinary heap owner object new₀ new .undef .undef
    ownerLive sourceObject ordinary sourceBound targetBound).frame (fun _ alive => alive)
      (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  refine ⟨⟨cells.keyLive,⟨inventory.runtime.source.control,inventory.runtime.source.stack,cells.source⟩,
    ⟨inventory.runtime.target.control,inventory.runtime.target.stack,cells.target⟩⟩,?_,captures,arrays,publics,buffers⟩
  apply inventory.privates.write_owner heap owner ⟨brand,name,role⟩ ownerLive brandLive
  · refine ⟨value,⟨new₀,true,false,?_,findPriv_set_same _ _ _ _⟩,sourceRole⟩
    simp only [identity,id_eq,St.setObj,PTrie.get_set_u64 _ _ _ sourceBound,ite_true]
    rfl
  · refine ⟨targetValue,⟨new,true,false,?_,findPriv_set_same _ _ _ _⟩,targetRole⟩
    simp only [St.setObj,PTrie.get_set_u64 _ _ _ targetBound,ite_true]
    rfl
  · intro a other
    simp only [St.setObj,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right other]
  · intro a other
    simp only [St.setObj,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right other]

end Host.Ts.Owned.Annotated
