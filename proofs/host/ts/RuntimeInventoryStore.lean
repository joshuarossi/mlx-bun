import host.ts.RenamePublicStore
import host.ts.RenameRuntimeDispatch
import host.ts.RenameHeapInventory
import host.ts.RenameArrayInventory

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem FrameR.publicPut_view {NR : NumV → NumV → Prop} {R : Ren}
    {a : Nat} {name : Name} {prior : Val} {f : Frame}
    (h : FrameR NR R (.a (.put none (.prop (.obj a) (.str name)) prior)) f) :
    ∃ prior', f = .a (.put none (.prop (.obj (R.a a)) (.str name)) prior') := by
  obtain ⟨af',rfl,hh⟩ := h.a_view
  have ht := hh.tag_eq
  cases af' <;> simp only [Encode.asgF,treeTag] at ht
  all_goals try contradiction
  case put op' target' prior' =>
    cases hh with | node tag hs =>
      cases hs with | cons hop hs =>
        cases hs with | cons htarget hs =>
          cases hs with | cons hp hs =>
            cases hop
            have ht := htarget.tag_eq
            cases target' <;> simp only [Encode.target,treeTag] at ht
            all_goals try contradiction
            case prop receiver' key' =>
              cases htarget with | node tag ts =>
                cases ts with | cons hv ts =>
                  cases ts with | cons hk ts =>
                    cases hv with | value hv =>
                      cases hv
                      rw [KeyR.eq_map hk]
                      exact ⟨prior',rfl⟩

/-- Public descriptor replacement retains the selected private descriptor,
including private fields on the object receiving the public store. -/
theorem PrivateData.setProps {S : Type} {s : St S} {owner brand : Nat} {name : Name} {value : Val}
    (field : PrivateData s owner brand name value) (address : Nat) (object : Obj) (props : Props)
    (read : s.heap.get address = some (.obj object)) (bound : address < 2^64) :
    PrivateData (s.setObj address {object with props := props}) owner brand name value := by
  by_cases same : owner = address
  · subst owner
    obtain ⟨prior,w,e,priorRead,descriptor⟩ := field
    have equal := HObj.obj.inj (Option.some.inj (priorRead.symm.trans read))
    subst prior
    refine ⟨{object with props := props},w,e,?_,descriptor⟩
    simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_true]
  · exact field.heap_at (by simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_eq_right same])

private theorem public_store_eq (F : Ffi) (s : St F.S) (a : Nat) (name : Name)
    (v old prior : Val) (e : Bool) (o : Obj) (fs : List Frame)
    (control : s.ctl = .ret v) (stack : s.stack = .a (.put none (.prop (.obj a) (.str name)) prior)::fs)
    (object : s.heap.get a = some (.obj o)) (ordinary : o.kind = .ordinary)
    (descriptor : findProp (.str name) o.props = some (.data old true e)) :
    step F s = M.pure (({s with stack := fs}.setObj a
      {o with props := setPropL (.str name) (.data v true e) o.props}).ret v) := by
  funext β k
  simp only [step,control,stepRet,stack,retStep,retA,storeTarget,putV,St.obj?,object,ordinary,
    putV.putOrd,descriptor,Bool.cond_true,retS,M.pure]

end Host.Ts.Owned.Parametric
namespace Host.Ts.Owned.Annotated
open Parametric

theorem PrivateInventory.setProps {S : Type} {notes : PrivateNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (h : PrivateInventory notes ν₀ ν C₀ C R live s₀ s)
    (address : Nat) (object₀ object : Obj) (props₀ props : Props)
    (source : s₀.heap.get address = some (.obj object₀))
    (target : s.heap.get (R.a address) = some (.obj object))
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64) :
    PrivateInventory notes ν₀ ν C₀ C R live
      (s₀.setObj address {object₀ with props := props₀}) (s.setObj (R.a address) {object with props := props}) := by
  refine ⟨h.keyLive,?_,?_⟩
  · intro a note entry
    obtain ⟨value,field,role⟩ := h.source a note entry
    exact ⟨value,field.setProps address object₀ props₀ source sourceBound,role⟩
  · intro a note entry
    obtain ⟨value,field,role⟩ := h.target a note entry
    exact ⟨value,field.setProps (R.a address) object props target targetBound,role⟩

/-- The source writable own-string assignment stores the current return
value's retained role. Every other heap and array annotation survives; the
selected public-field annotation is updated from that role. -/
theorem RuntimeInventory.public_store_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (privates : PrivateNotes) (captures : NativeCaptureNotes)
    (arrays : ArrayNotes) (publics : PublicNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (heapInventory : HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrays ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publics ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (name : Name) (value prior previous : Val) (e : Bool) (o₀ : Obj) (role : Value)
    (frames : List Frame) (headNote : Tree) (tailNotes : List Tree)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .a (.put none (.prop (.obj a) (.str name)) prior)::frames)
    (object : s₀.heap.get a = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findProp (.str name) o₀.props = some (.data previous true e))
    (controlNote : notes.control = returnNote role) (stackNotes : notes.stack = headNote::tailNotes)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ (targetValue : Val) (o : Obj) (targetFrames : List Frame),
      let t₀ := ({s₀ with stack := frames}.setObj a
        {o₀ with props := setPropL (.str name) (.data value true e) o₀.props}).ret value
      let t := ({s with stack := targetFrames}.setObj (R.a a)
        {o with props := setPropL (.str name) (.data targetValue true e) o.props}).ret targetValue
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RuntimeInventory {notes with control := returnNote role,stack := tailNotes} ν₀ ν C₀ C R live t₀ t ∧
      HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live t₀ t ∧
      ArrayInventory arrays ν₀ ν C₀ C R live t₀ t ∧
      PublicInventory (publics.write a name role) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetPrior,frameEq⟩ := frameRelation.publicPut_view
  rw [frameEq] at targetStack
  have sourceControl := inventory.source.control
  have targetControlRole := inventory.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceRole := returnNote_view sourceControl
  have targetRole := returnNote_view targetControlRole
  have sourceStack := inventory.source.stack
  have targetStackRole := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  have stackLive := h.stackLive
  rw [stack] at stackLive
  have alive : live a := stackLive.1.1.2.1.1
  have sourceWord : a < 2^64 := Nat.lt_of_lt_of_le (h.heap.sourceBound a alive) sourceBound
  have targetWord : R.a a < 2^64 := Nat.lt_of_lt_of_le (h.heap.targetBound a alive) targetBound
  obtain ⟨actual,sourceRun,targetRun,post⟩ := step_property_store_roles F (NumberRoles ν₀ ν C₀ C) FR R
    C₀ C live framed before after old old' s₀ s h a name value targetValue prior targetPrior previous e o₀ frames targetFrames
    (Value.paired sourceRole targetRole) control targetControl stack targetStack alive object ordinary descriptor sourceWord targetWord
  obtain ⟨o,targetObject,objectRelation,_⟩ := h.heap.readOrdinary a o₀ alive object ordinary
  obtain ⟨targetPrevious,targetDescriptor,_⟩ := objectRelation.properties.find_data name previous true e descriptor
  have run : interpC (step F s).run C = some
      (({s with stack := targetFrames}.setObj (R.a a)
        {o with props := setPropL (.str name) (.data targetValue true e) o.props}).ret targetValue,C) := by
    rw [public_store_eq F s (R.a a) name targetValue targetPrevious targetPrior e o targetFrames
      targetControl targetStack targetObject (objectRelation.ordinary ordinary) targetDescriptor]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans run))
  dsimp only at same
  rw [same] at post
  let new₀ := {o₀ with props := setPropL (.str name) (.data value true e) o₀.props}
  let new := {o with props := setPropL (.str name) (.data targetValue true e) o.props}
  have cells := heapInventory.cells.setObject h.heap a o₀ o new₀ new value targetValue alive object targetObject sourceWord targetWord
  have privateFields := heapInventory.privates.setProps a o₀ o new₀.props new.props object targetObject sourceWord targetWord
  have captures := heapInventory.captures.setOrdinary h.heap a o₀ new₀ new value targetValue alive object ordinary sourceWord targetWord
  have arrays := arrayInventory.setOrdinary h.heap a o₀ new₀ new value targetValue alive object ordinary sourceWord targetWord
  have publics := publicInventory.store h.heap a o₀ o name role value targetValue true e alive object targetObject
    sourceRole targetRole sourceWord targetWord
  refine ⟨targetValue,o,targetFrames,sourceRun,run,post,?_,?_,?_,?_⟩
  · exact ⟨cells.keyLive,⟨returnNote_holds sourceRole,sourceStack.tail,cells.source⟩,
      ⟨returnNote_holds targetRole,targetStackRole.tail,cells.target⟩⟩
  · exact ⟨cells.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      privateFields.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      captures.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩
  · exact arrays.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact publics.frame (fun _ h => h) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)

end Host.Ts.Owned.Annotated
