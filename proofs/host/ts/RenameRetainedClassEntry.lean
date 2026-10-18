import host.ts.RenameRuntimeClassNotes
import host.ts.RenameRetainedInventory
import host.ts.RenameClassHeapEffects

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def RuntimeNotes.baseClass (notes : RuntimeNotes) (ctor : Func) (env : Env)
    (members : List InstMember) (args : List Value) (fresh : Nat) : RuntimeNotes :=
  ⟨returnNote .undef,
    classFieldsFrameNote fresh members ((nThis,fresh+1)::env)::
      constructorBodyFrameNote (.obj fresh) ctor env args::notes.stack,
    notes.cells.write (fresh+1) (.obj fresh)⟩

theorem privateFields_identity (NR : NumV → NumV → Prop) {members : List InstMember}
    (onlyPrivate : PrivateFields members) : ClassFieldsR NR identity members members := by
  induction onlyPrivate with
  | nil => exact .node _ .nil
  | @cons brand name init rest _ ih =>
    cases ih with | node _ tail =>
      exact .node _ (.cons (.node _ (.cons (.address brand) (.cons (.atom Name name)
        (.cons (.atom (Option Expr) init) .nil)))) tail)

theorem baseClassEntry_members {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    {ctor : Func} {env : Env} {members targetMembers : List InstMember}
    {args₀ args : List Val} {proto : Nat}
    (post : Parametric.StateR NR FR R live framed before after old old'
      (baseClassEntry s₀ ctor env members args₀ proto)
      (baseClassEntry s ctor (R.env env) targetMembers args (R.a proto))) :
    ClassFieldsR NR R members targetMembers := by
  have frames := post.stack
  change ListR (Parametric.FrameR NR R)
    (.k (.fields s₀.next members ((nThis,s₀.next+1)::env))::_)
    (.k (.fields s.next targetMembers ((nThis,s.next+1)::R.env env))::_) at frames
  cases frames with | cons head _ =>
    obtain ⟨selected,same,related⟩ := head.fields_view
    exact (FnF.fields.inj (Frame.k.inj same)).2.1.symm ▸ related

theorem baseClassEntry_this {S : Type} (s : St S) (ctor : Func) (env : Env)
    (members : List InstMember) (args : List Val) (proto : Nat) (bound : s.next+2 ≤ 2^64) :
    (baseClassEntry s ctor env members args proto).heap.get (s.next+1) =
      some (.cell (some (.obj s.next))) := by
  simp only [baseClassEntry,St.allocObj,St.alloc,St.push,St.ret,
    PTrie.get_set_u64 _ _ _ (show s.next+1 < 2^64 by omega),ite_true]

/-- A real base-class entry retains the current constructor argument meanings,
allocates its instance/this cell, and saves fixed constructor and private-field
notes. Every prior inventory is framed below the two fresh allocations. -/
theorem RetainedInventory.base_class_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (a proto : Nat) (object : Obj) (ctor : Func) (env : Env) (members : List InstMember)
    (args₀ : List Val) (w e : Bool) (fnRole : Value) (argRoles : List Value)
    (control : s₀.ctl = .construct (.obj a) args₀ (.obj a))
    (heap : s₀.heap.get a = some (.obj object))
    (kind : object.kind = .fn (.klass (some ctor) env .null members))
    (prototype : findProp kPrototype object.props = some (.data (.obj proto) w e))
    (onlyPrivate : PrivateFields members)
    (controlNote : notes.runtime.control = constructNote fnRole argRoles)
    (sourceBound : s₀.next+2 ≤ 2^64) (targetBound : s.next+2 ≤ 2^64) :
    ∃ args targetMembers,
      interpC (step F s₀).run C₀ = some (baseClassEntry s₀ ctor env members args₀ proto,C₀) ∧
      interpC (step F s).run C = some (baseClassEntry s ctor (R.env env) targetMembers args (R.a proto),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (BaseClassLive live s₀.next)
        framed before after old old'
        (baseClassEntry s₀ ctor env members args₀ proto)
        (baseClassEntry s ctor (R.env env) targetMembers args (R.a proto)) ∧
      RetainedInventory (notes.withRuntime (notes.runtime.baseClass ctor env members argRoles s₀.next))
        ν₀ ν C₀ C R (BaseClassLive live s₀.next)
        (baseClassEntry s₀ ctor env members args₀ proto)
        (baseClassEntry s ctor (R.env env) targetMembers args (R.a proto)) := by
  obtain ⟨args,targetMembers,targetControl,left,right,post⟩ :=
    step_base_class_entry_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old'
      s₀ s h a proto object ctor env members args₀ w e control heap kind prototype sourceBound targetBound
  have sourceNote := inventory.runtime.source.control
  have targetNote := inventory.runtime.target.control
  rw [controlNote,control] at sourceNote
  rw [controlNote,targetControl] at targetNote
  have sourceArguments := (constructNote_view sourceNote).2.2
  have targetArguments := (constructNote_view targetNote).2.2
  have memberRoles := baseClassEntry_members post
  have grow : ∀ b, live b → BaseClassLive live s₀.next b := fun _ alive => Or.inl (Or.inl alive)
  have sourceFrame := fun b alive => baseClassEntry_heap_below s₀ ctor env members args₀ proto b
    (h.heap.sourceBound b alive) sourceBound
  have targetFrame := fun b alive => baseClassEntry_heap_below s ctor (R.env env) targetMembers args (R.a proto) (R.a b)
    (h.heap.targetBound b alive) targetBound
  have oldHeap := inventory.heapInventory.frame grow sourceFrame targetFrame
  have fresh0 : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  have fresh1 : R.a (s₀.next+1) = s.next+1 := h.heap.fresh 1
  have thisTarget : (Value.obj s₀.next).Holds ν C R (.obj s.next) := by
    simpa only [fresh0] using Value.Holds.obj (ν:=ν) (C:=C) (R:=R) s₀.next
  have cells := oldHeap.cells.annotate (s₀.next+1) (.obj s₀.next) (Or.inr rfl)
    (by simpa only [cellValueAt,identity,id_eq,baseClassEntry_this s₀ ctor env members args₀ proto sourceBound]
      using Value.Holds.obj (ν:=ν₀) (C:=C₀) (R:=identity) s₀.next)
    (by rw [fresh1]; simpa only [cellValueAt,baseClassEntry_this s ctor (R.env env) targetMembers args (R.a proto) targetBound]
      using thisTarget)
  have fieldEnv : R.env ((nThis,s₀.next+1)::env) = (nThis,s.next+1)::R.env env := by
    simp only [Ren.env,List.map_cons,fresh1]
  have sourceAddress : identity.a s₀.next = s₀.next := rfl
  refine ⟨args,targetMembers,left,right,post,⟨cells.keyLive,?_,?_⟩,oldHeap.privates,oldHeap.captures,?_,?_,?_⟩
  · refine ⟨returnNote_holds .undef,?_,cells.source⟩
    change ForestHolds ν₀ C₀ identity _
      (Encode.frame (.k (.fields s₀.next members ((nThis,s₀.next+1)::env)))::
        Encode.frame (.k (.ctorBody (.obj s₀.next) ctor env args₀))::s₀.stack.map Encode.frame)
    exact .cons (by simpa only [identity_environment,sourceAddress] using
      (classFieldsFrameNote_holds (ν:=ν₀) (C:=C₀) (R:=identity) (NR:=NumberRoles ν₀ ν C₀ C) s₀.next members members
        ((nThis,s₀.next+1)::env) onlyPrivate (privateFields_identity _ onlyPrivate)))
      (.cons (by simpa only [identity_environment] using
        (constructorBodyFrameNote_holds (.obj s₀.next) ctor env argRoles (.obj s₀.next) args₀ (.obj _) sourceArguments))
        inventory.runtime.source.stack)
  · refine ⟨returnNote_holds .undef,?_,cells.target⟩
    change ForestHolds ν C R _
      (Encode.frame (.k (.fields s.next targetMembers ((nThis,s.next+1)::R.env env)))::
        Encode.frame (.k (.ctorBody (.obj s.next) ctor (R.env env) args))::s.stack.map Encode.frame)
    exact .cons (by simpa only [fresh0,fieldEnv] using
      (classFieldsFrameNote_holds s₀.next members targetMembers ((nThis,s₀.next+1)::env) onlyPrivate memberRoles))
      (.cons (constructorBodyFrameNote_holds (.obj s₀.next) ctor env argRoles (.obj s.next) args thisTarget targetArguments)
        inventory.runtime.target.stack)
  · exact inventory.arrays.frame grow
      (fun b roles entry => sourceFrame b (inventory.arrays.keyLive b roles entry))
      (fun b roles entry => targetFrame b (inventory.arrays.keyLive b roles entry))
  · exact inventory.publicFields.frame grow
      (fun b name role entry => sourceFrame b (inventory.publicFields.keyLive b name role entry))
      (fun b name role entry => targetFrame b (inventory.publicFields.keyLive b name role entry))
  · exact inventory.buffers.frame grow
      (fun b roles entry => sourceFrame b (inventory.buffers.keyLive b roles entry))
      (fun b roles entry => targetFrame b (inventory.buffers.keyLive b roles entry))

end Host.Ts.Owned.Annotated
