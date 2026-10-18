import host.ts.RenameRetainedAllocation
import host.ts.RenameParametricObjectNext
import host.ts.RenameRuntimeStatements
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def objectControlNote (owner : Nat) (env : Env) : ObjectAction → Tree
  | .done => returnNote (.obj owner)
  | .initial _ _ value _ | .spread value _ => expressionNote value env
def objectFrameNotes (owner : Nat) (env : Env) : ObjectAction → List Tree
  | .done => []
  | .initial _ name _ rest => [.node "Frame.l" [.node "LitF.objVal"
      [.address owner,.node "PKey.str" [.atom Name name],.atom (List Property) rest,environmentNote env]]]
  | .spread _ rest => [.node "Frame.l" [.node "LitF.objSpread"
      [.address owner,.atom (List Property) rest,environmentNote env]]]
def RuntimeNotes.objectAction (notes : RuntimeNotes) (action : ObjectAction) (owner : Nat) (env : Env) : RuntimeNotes :=
  ⟨objectControlNote owner env action,objectFrameNotes owner env action ++ notes.stack,notes.cells⟩

theorem objectControlNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (action : ObjectAction) (owner : Nat) (env : Env) :
    (objectControlNote owner env action).Holds ν C R (Encode.ctl (action.control (R.a owner) (R.env env))) := by
  cases action with
  | done => exact returnNote_holds (.obj owner)
  | initial _ _ value _ => exact expressionNote_holds ν C R value env
  | spread value _ => exact expressionNote_holds ν C R value env
theorem objectFrameNotes_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (action : ObjectAction) (owner : Nat) (env : Env) :
    ForestHolds ν C R (objectFrameNotes owner env action) ((action.frames (R.a owner) (R.env env)).map Encode.frame) := by
  cases action <;> dsimp only [objectFrameNotes,ObjectAction.frames,List.map_cons,List.map_nil,Encode.frame,Encode.litF,Encode.key,Encode.atom]
  all_goals repeat first | exact environmentNote_holds ν C R env | constructor
theorem RuntimeNotes.Holds.objectAction {S : Type} {notes : RuntimeNotes} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {s : St S} (held : notes.Holds ν C R s) (action : ObjectAction) (owner : Nat) (env : Env) :
    (notes.objectAction action owner env).Holds ν C R (action.advance s (R.a owner) (R.env env)) :=
  ⟨objectControlNote_holds ν C R action owner env,
    by simpa only [RuntimeNotes.objectAction,ObjectAction.advance,St.go,List.map_append] using
      (objectFrameNotes_holds ν C R action owner env).append held.stack,
    held.cells⟩

/-- The real object-literal allocation, followed by its original static-key or
spread-expression scheduler. Fresh-owner annotations and all previous fields
remain fixed while the initializer expression begins. -/
theorem RetainedInventory.object_action_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (env : Env) (action : ObjectAction) (valid : action.valid)
    (control : s₀.ctl = .ev (.object action.properties) env)
    (prototypeLive : live aObjectProto) (prototypeFixed : R.a aObjectProto = aObjectProto)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    let object : HObj := .obj ⟨.ordinary,.obj aObjectProto,[],[],true⟩
    let t₀ := action.advance (s₀.alloc object).2 s₀.next env
    let t := action.advance (s.alloc object).2 s.next (R.env env)
    interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live s₀.next) framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime (notes.runtime.objectAction action s₀.next env)) ν₀ ν C₀ C R
        (LiveAfter live s₀.next) t₀ t := by
  let object : HObj := .obj ⟨.ordinary,.obj aObjectProto,[],[],true⟩
  have targetControl := (h.control_view control).ev_view
  have support := h.controlLive
  rw [control] at support
  have protoRole : Parametric.ValueR (NumberRoles ν₀ ν C₀ C) R (.obj aObjectProto) (.obj aObjectProto) := by
    simpa only [prototypeFixed] using (Parametric.ValueR.obj (NR:=NumberRoles ν₀ ν C₀ C) (R:=R) aObjectProto)
  have objectRelation : Parametric.HeapObjectR (NumberRoles ν₀ ν C₀ C) R object object :=
    .obj (.node _ (.cons (.node _ .nil) (.cons (.value protoRole)
      (.cons (.node _ .nil) (.cons (.node _ .nil) (.cons (.atom _ _) .nil))))))
  have objectLive : treeSupport (LiveAfter live s₀.next) (Encode.hobj object) :=
    ⟨⟨True.intro,Or.inl prototypeLive,True.intro,True.intro,True.intro,True.intro⟩,True.intro⟩
  have allocated := h.alloc object object objectRelation objectLive sourceBound targetBound
  have fresh : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  have envLive := treeSupport_mono (fun _ h => Or.inl h : ∀ a, live a → LiveAfter live s₀.next a) (Encode.env env) support.2.1
  have post := action.advance_roles allocated s₀.next env (Or.inr rfl) envLive
  rw [fresh] at post
  have held := inventory.allocate_return h.heap object object sourceBound targetBound
  have sourceOwner : identity.a s₀.next = s₀.next := rfl
  have runtime : RuntimeInventory (notes.runtime.objectAction action s₀.next env) ν₀ ν C₀ C R (LiveAfter live s₀.next)
      (action.advance (s₀.alloc object).2 s₀.next env) (action.advance (s.alloc object).2 s.next (R.env env)) := by
    refine ⟨held.runtime.keyLive,?_,?_⟩
    · simpa only [RetainedNotes.withRuntime,RuntimeNotes.objectAction,identity_environment,ObjectAction.advance,St.ret,St.go,sourceOwner] using
        held.runtime.source.objectAction action s₀.next env
    · simpa only [RetainedNotes.withRuntime,RuntimeNotes.objectAction,ObjectAction.advance,St.ret,St.go,fresh] using
        held.runtime.target.objectAction action s₀.next env
  refine ⟨?_,?_,post,runtime,?_,?_,?_,?_,?_⟩
  · rw [step_object_action_eq F s₀ env action valid control]; rfl
  · rw [step_object_action_eq F s (R.env env) action valid targetControl]; rfl
  · exact held.privates.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact held.captures.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact held.arrays.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact held.publicFields.frame (fun _ h => h) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)
  · exact held.buffers.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
end Host.Ts.Owned.Annotated
