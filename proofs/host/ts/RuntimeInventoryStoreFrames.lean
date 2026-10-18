import host.ts.RenameRuntimeBinding
import host.ts.RenamePublicInventory
import host.ts.RenameBufferInventory

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem PublicData.setPrivs {S : Type} {s : St S} {owner : Nat} {name : Name} {value : Val}
    (field : PublicData s owner name value) (address : Nat) (object : Obj) (privates : Privs)
    (read : s.heap.get address = some (.obj object)) (bound : address < 2^64) :
    PublicData (s.setObj address {object with priv := privates}) owner name value := by
  by_cases same : owner = address
  · subst owner
    obtain ⟨prior,w,e,priorRead,descriptor⟩ := field
    have equal := HObj.obj.inj (Option.some.inj (priorRead.symm.trans read))
    subst prior
    refine ⟨{object with priv := privates},w,e,?_,descriptor⟩
    simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_true]
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

theorem PublicInventory.setPrivs {S : Type} {notes : PublicNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : PublicInventory notes ν₀ ν C₀ C R live s₀ s)
    (address : Nat) (object₀ object : Obj) (privates₀ privates : Privs)
    (source : s₀.heap.get address = some (.obj object₀)) (target : s.heap.get (R.a address) = some (.obj object))
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64) :
    PublicInventory notes ν₀ ν C₀ C R live
      (s₀.setObj address {object₀ with priv := privates₀}) (s.setObj (R.a address) {object with priv := privates}) := by
  refine ⟨inventory.keyLive,?_,?_⟩
  · intro a name role entry
    obtain ⟨value,field,meaning⟩ := inventory.source a name role entry
    exact ⟨value,field.setPrivs address object₀ privates₀ source sourceBound,meaning⟩
  · intro a name role entry
    obtain ⟨value,field,meaning⟩ := inventory.target a name role entry
    exact ⟨value,field.setPrivs (R.a address) object privates target targetBound,meaning⟩

theorem PublicInventory.setCell {S : Type} {notes : PublicNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    {NR : NumV → NumV → Prop} (inventory : PublicInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (address : Nat) (prior : Option Val) (sourceValue targetValue : Val) (alive : live address)
    (cell : s₀.heap.get address = some (.cell prior))
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64) :
    PublicInventory notes ν₀ ν C₀ C R live ((s₀.setCell address sourceValue).ret .undef) ((s.setCell (R.a address) targetValue).ret .undef) := by
  have different : ∀ a name role, notes.fields a name = some role → a ≠ address := by
    intro a name role entry same
    obtain ⟨value,field,_⟩ := inventory.source a name role entry
    obtain ⟨o,w,e,object,_⟩ := field
    have object : s₀.heap.get a = some (.obj o) := object
    rw [same,cell] at object
    cases object
  apply inventory.frame (fun _ alive => alive)
  · intro a name role entry
    simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right (different a name role entry)]
  · intro a name role entry
    have mapped : R.a a ≠ R.a address := fun same => different a name role entry
      (heap.inj a address (inventory.keyLive a name role entry) alive same)
    simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right mapped]

theorem BufferInventory.setOrdinary {S : Type} {notes : BufferNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    {NR : NumV → NumV → Prop} (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (address : Nat) (prior sourceObject targetObject : Obj) (sourceValue targetValue : Val) (alive : live address)
    (read : s₀.heap.get address = some (.obj prior)) (ordinary : prior.kind = .ordinary)
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64) :
    BufferInventory notes ν₀ ν C₀ C R live
      ((s₀.setObj address sourceObject).ret sourceValue) ((s.setObj (R.a address) targetObject).ret targetValue) := by
  have nonBuffer : ∀ bytes, prior.kind ≠ .buf bytes := by intro bytes equal; rw [ordinary] at equal; cases equal
  exact (inventory.set_nonBuffer heap address prior sourceObject targetObject alive read nonBuffer sourceBound targetBound).frame
    (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)

/-- Initializing a source lexical cell updates its fixed cell meaning and
preserves public fields, arrays and buffers by actual owner disjointness. -/
theorem RuntimeInventory.init_step_all (F : Ffi) (FR : Ren → F.S → F.S → Prop)
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
    (name : Name) (env : Env) (address : Nat) (value : Val) (prior : Option Val) (kind : DeclKind) (role : Value)
    (control : s₀.ctl = .bind (.id name) value env .init kind) (lookup : lookupEnv name env = some address)
    (cell : s₀.heap.get address = some (.cell prior))
    (controlNote : notes.control = bindingNote (.id name) role env .init kind)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ targetValue,
      let t₀ := (s₀.setCell address value).ret .undef
      let t := (s.setCell (R.a address) targetValue).ret .undef
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RuntimeInventory (notes.initialized address role) ν₀ ν C₀ C R live t₀ t ∧
      HeapInventory ((HeapNotes.mk notes.cells privates captures).writeCell address role) ν₀ ν C₀ C R live t₀ t ∧
      ArrayInventory arrays ν₀ ν C₀ C R live t₀ t ∧ PublicInventory publics ν₀ ν C₀ C R live t₀ t ∧
      BufferInventory buffers ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,sourceRun,targetRun,post,runtime,heap⟩ := inventory.init_step F FR notes privates captures ν₀ ν C₀ C R
    live framed before after old old' s₀ s h heapInventory name env address value prior kind role
    control lookup cell controlNote sourceBound targetBound
  have support := h.controlLive
  rw [control] at support
  have alive := env_lookup_live name env address support.2.2.1 lookup
  have sourceWord := Nat.lt_of_lt_of_le (h.heap.sourceBound address alive) sourceBound
  have targetWord := Nat.lt_of_lt_of_le (h.heap.targetBound address alive) targetBound
  refine ⟨targetValue,sourceRun,targetRun,post,runtime,heap,?_,?_,?_⟩
  · exact arrayInventory.setCell h.heap address prior value targetValue alive cell sourceWord targetWord
  · exact publicInventory.setCell h.heap address prior value targetValue alive cell sourceWord targetWord
  · exact (bufferInventory.setCell h.heap address prior value targetValue alive cell sourceWord targetWord).frame
      (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)

def privateStoreState {S : Type} (s : St S) (owner brand : Nat) (name : Name) (value : Val)
    (e : Bool) (object : Obj) (frames : List Frame) : St S :=
  ({s with stack := frames}.setObj owner {object with priv := setPrivL brand name (.data value true e) object.priv}).ret value

/-- A private store consumes the retained current return role, updates the
private inventory, and preserves all public/array/buffer annotations. -/
theorem RuntimeInventory.private_store_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
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
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ targetValue targetObject targetFrames,
      let t₀ := privateStoreState s₀ owner brand name value e o₀ frames
      let t := privateStoreState s (R.a owner) (R.a brand) name targetValue e targetObject targetFrames
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RuntimeInventory {notes with control := returnNote role,stack := tail} ν₀ ν C₀ C R live t₀ t ∧
      HeapInventory ((HeapNotes.mk notes.cells privates captures).writePrivate owner ⟨brand,name,role⟩) ν₀ ν C₀ C R live t₀ t ∧
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
    refine ⟨targetValue,o,targetFrames,sourceRun,actual,post,?_,heap,?_,?_,?_⟩
    · exact ⟨heap.cells.keyLive,⟨returnNote_holds sourceRole,sourceNotes.tail,heap.cells.source⟩,
        ⟨returnNote_holds targetRole,targetNotes.tail,heap.cells.target⟩⟩
    · exact arrays.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
    · exact publics.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)
    · exact buffers.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)

end Host.Ts.Owned.Annotated
