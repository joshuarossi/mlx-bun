import host.ts.RuntimeInventoryStoreFrames
import host.ts.RenamePrivateListFrame
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- Writing a differently named private field preserves the selected descriptor. -/
theorem PrivateData.setPrivateOther {S : Type} {s : St S} {owner brand : Nat} {name : Name} {value : Val}
    (field : PrivateData s owner brand name value) (address writtenBrand : Nat) (writtenName : Name)
    (object : Obj) (property : PropV) (read : s.heap.get address = some (.obj object))
    (bound : address < 2^64) (different : owner = address → nameEq name writtenName = false) :
    PrivateData (s.setObj address {object with priv := setPrivL writtenBrand writtenName property object.priv})
      owner brand name value := by
  by_cases same : owner = address
  · subst owner
    obtain ⟨prior,w,e,priorRead,descriptor⟩ := field
    have equal := HObj.obj.inj (Option.some.inj (priorRead.symm.trans read))
    subst prior
    refine ⟨{object with priv := setPrivL writtenBrand writtenName property object.priv},w,e,?_,?_⟩
    · simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_true]
    · simpa only [findPriv_set_name_ne brand writtenBrand name writtenName property object.priv (different rfl)] using descriptor
  · exact field.heap_at (by simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_eq_right same])

private theorem private_store_eq (F : Ffi) (s : St F.S) (a brand : Nat) (name : Name)
    (value previous prior : Val) (e : Bool) (o : Obj) (frames : List Frame)
    (control : s.ctl = .ret value)
    (stack : s.stack = .a (.put none (.priv (.obj a) brand name) prior)::frames)
    (object : s.heap.get a = some (.obj o)) (descriptor : findPriv brand name o.priv = some (.data previous true e)) :
    step F s = M.pure (({s with stack := frames}.setObj a
      {o with priv := setPrivL brand name (.data value true e) o.priv}).ret value) := by
  funext β k
  simp only [step,control,stepRet,stack,retStep,retA,storeTarget,privPutV,St.obj?,object,descriptor,retS,M.pure]
end Host.Ts.Owned.Parametric
namespace Host.Ts.Owned.Annotated
open Parametric

theorem PrivateInventory.setPrivateOther {S : Type} {notes : PrivateNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop} {before after : List Val}
    {s₀ s : St S} {NR : NumV → NumV → Prop}
    (h : PrivateInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (address brand : Nat) (name : Name) (object₀ object : Obj) (property₀ property : PropV)
    (alive : live address)
    (source : s₀.heap.get address = some (.obj object₀))
    (target : s.heap.get (R.a address) = some (.obj object))
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64)
    (different : ∀ note, notes.owners address = some note → nameEq note.name name = false) :
    PrivateInventory notes ν₀ ν C₀ C R live
      (s₀.setObj address {object₀ with priv := setPrivL brand name property₀ object₀.priv})
      (s.setObj (R.a address) {object with priv := setPrivL (R.a brand) name property object.priv}) := by
  refine ⟨h.keyLive,?_,?_⟩
  · intro a note entry
    obtain ⟨value,field,role⟩ := h.source a note entry
    refine ⟨value,field.setPrivateOther address brand name object₀ property₀ source sourceBound ?_,role⟩
    intro same
    exact different note (same ▸ entry)
  · intro a note entry
    obtain ⟨value,field,role⟩ := h.target a note entry
    refine ⟨value,field.setPrivateOther (R.a address) (R.a brand) name object property target targetBound ?_,role⟩
    intro same
    have equal := heap.inj a address (h.keyLive a note entry).1 alive same
    exact different note (equal ▸ entry)

theorem RuntimeInventory.private_store_other_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (privates : PrivateNotes) (captures : NativeCaptureNotes)
    (arrays : ArrayNotes) (publics : PublicNotes) (buffers : BufferNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (heapInventory : HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrays ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publics ν₀ ν C₀ C R live s₀ s)
    (bufferInventory : BufferInventory buffers ν₀ ν C₀ C R live s₀ s)
    (owner brand : Nat) (name : Name) (role : Value) (value prior previous : Val) (e : Bool) (o₀ : Obj)
    (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .a (.put none (.priv (.obj owner) brand name) prior)::frames)
    (object : s₀.heap.get owner = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findPriv brand name o₀.priv = some (.data previous true e))
    (controlNote : notes.control = returnNote role) (stackNotes : notes.stack = head::tail)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64)
    (different : ∀ note, privates.owners owner = some note → nameEq note.name name = false) :
    ∃ targetValue targetObject targetFrames,
      let t₀ := privateStoreState s₀ owner brand name value e o₀ frames
      let t := privateStoreState s (R.a owner) (R.a brand) name targetValue e targetObject targetFrames
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RuntimeInventory {notes with control := returnNote role,stack := tail} ν₀ ν C₀ C R live t₀ t ∧
      HeapInventory (HeapNotes.mk notes.cells privates captures) ν₀ ν C₀ C R live t₀ t ∧
      ArrayInventory arrays ν₀ ν C₀ C R live t₀ t ∧ PublicInventory publics ν₀ ν C₀ C R live t₀ t ∧
      BufferInventory buffers ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetPrior,frameEq⟩ := frameRelation.privatePut_view
  rw [frameEq] at targetStack
  have sourceControl := inventory.source.control
  have targetControlRole := inventory.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceRole := returnNote_view sourceControl
  have targetRole := returnNote_view targetControlRole
  have sourceNotes := inventory.source.stack
  have targetNotes := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have support := h.stackLive
  rw [stack] at support
  have alive : live owner := support.1.1.2.1.1
  have brandAlive : live brand := support.1.1.2.1.2.1
  have sourceWord := Nat.lt_of_lt_of_le (h.heap.sourceBound owner alive) sourceBound
  have targetWord := Nat.lt_of_lt_of_le (h.heap.targetBound owner alive) targetBound
  obtain ⟨o,targetObject,objectRelation,objectLive⟩ := h.heap.readOrdinary owner o₀ alive object ordinary
  have privateRelation := objectRelation.privateFields.find objectLive.2.2.2.1 h.heap.inj brand name brandAlive
  rw [descriptor] at privateRelation
  generalize found : findPriv (R.a brand) name o.priv = targetProperty at privateRelation
  cases privateRelation with | some relation =>
    obtain ⟨targetPrevious,rfl,_⟩ := relation.data
    have actual : interpC (step F s).run C = some
        (privateStoreState s (R.a owner) (R.a brand) name targetValue e o targetFrames,C) := by
      rw [private_store_eq F s (R.a owner) (R.a brand) name targetValue targetPrevious targetPrior e o targetFrames
        targetControl targetStack targetObject found]
      rfl
    obtain ⟨result,sourceRun,targetRun,post,heap⟩ := heapInventory.private_store_step F FR _ ν₀ ν C₀ C R
      live framed before after old old' s₀ s h owner brand name role value prior previous e o₀ frames
      control stack object ordinary descriptor sourceRole
      (by simpa only [returnedValue,targetControl] using targetRole) sourceBound targetBound
    have same := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans actual))
    dsimp only at same
    rw [same] at post heap
    let new₀ := {o₀ with priv := setPrivL brand name (.data value true e) o₀.priv}
    let new := {o with priv := setPrivL (R.a brand) name (.data targetValue true e) o.priv}
    have arrays := arrayInventory.setOrdinary h.heap owner o₀ new₀ new value targetValue alive object ordinary sourceWord targetWord
    have publics := publicInventory.setPrivs owner o₀ o new₀.priv new.priv object targetObject sourceWord targetWord
    have buffers := bufferInventory.setOrdinary h.heap owner o₀ new₀ new value targetValue alive object ordinary sourceWord targetWord
    have privateFields := heapInventory.privates.setPrivateOther h.heap owner brand name o₀ o
      (.data value true e) (.data targetValue true e) alive object targetObject sourceWord targetWord different
    have privateFields : PrivateInventory privates ν₀ ν C₀ C R live
        (privateStoreState s₀ owner brand name value e o₀ frames)
        (privateStoreState s (R.a owner) (R.a brand) name targetValue e o targetFrames) :=
      privateFields.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
    refine ⟨targetValue,o,targetFrames,sourceRun,actual,post,?_,⟨heap.cells,privateFields,heap.captures⟩,?_,?_,?_⟩
    · exact ⟨heap.cells.keyLive,⟨returnNote_holds sourceRole,sourceNotes.tail,heap.cells.source⟩,
        ⟨returnNote_holds targetRole,targetNotes.tail,heap.cells.target⟩⟩
    · exact arrays.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
    · exact publics.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)
    · exact buffers.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)

end Host.Ts.Owned.Annotated
