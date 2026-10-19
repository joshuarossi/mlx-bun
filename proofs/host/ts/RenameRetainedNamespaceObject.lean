import host.ts.RuntimeInventoryMethod
import host.ts.RenameRetainedHeapFrame
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- An object-valued namespace export has its structural meaning fixed by
its initialized live cell. Numeric exports still need a retained value note. -/
theorem RetainedInventory.namespace_object_method_step
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a cell callee : Nat) (object : Obj) (exports : Env) (name : Name) (args : List Elem)
    (env : Env) (optObj optCall : Bool) (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret (.obj a))
    (stack : s₀.stack = .c (.member (.str name) args env optObj optCall)::frames)
    (read : s₀.heap.get a = some (.obj object)) (kind : object.kind = .ns exports)
    (exportCell : findExport name exports = some cell)
    (sourceCell : s₀.heap.get cell = some (.cell (some (.obj callee))))
    (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := methodReturnState s₀ a args env optCall frames (.obj callee)
      let t := methodReturnState s (R.a a) args (R.env env) optCall targetFrames (.obj (R.a callee))
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime (notes.runtime.methodResult a args env optCall (.obj callee) tail))
        ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨receiver,targetControl,receiverRole⟩ := (h.control_view control).ret_view
  cases receiverRole
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.callMember_view] at targetStack
  have alive : live a := by have support := h.controlLive; rw [control] at support; exact support.1
  obtain ⟨targetObject,targetRead,targetKind,exportLive⟩ := h.heap.read_namespace a object exports alive read kind
  have cellLive := env_lookup_live name exports cell exportLive (by rw [← findExport_eq_lookupEnv]; exact exportCell)
  obtain ⟨targetValue,targetCell,valueRelation,_⟩ := h.heap.readCell cell (.obj callee) cellLive sourceCell
  cases valueRelation
  have targetExport : findExport name (R.env exports) = some (R.a cell) := by
    rw [findExport_eq_lookupEnv,lookupEnv_map,← findExport_eq_lookupEnv,exportCell]; rfl
  obtain ⟨result,left,right,post⟩ := step_namespace_method_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h a object exports name args env optObj optCall cell (.obj callee) frames
    control stack read kind exportCell sourceCell
  have actual : interpC (step F s).run C = some
      (methodReturnState s (R.a a) args (R.env env) optCall targetFrames (.obj (R.a callee)),C) := by
    rw [step_namespace_method_eq F s (R.a a) targetObject (R.env exports) name args (R.env env) optObj optCall (R.a cell)
      (.obj (R.a callee)) targetFrames targetControl targetStack targetRead targetKind targetExport targetCell]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (right.symm.trans actual))
  dsimp only at same
  rw [same] at post
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have runtime : RuntimeInventory (notes.runtime.methodResult a args env optCall (.obj callee) tail)
      ν₀ ν C₀ C R live (methodReturnState s₀ a args env optCall frames (.obj callee))
      (methodReturnState s (R.a a) args (R.env env) optCall targetFrames (.obj (R.a callee))) := by
    refine ⟨inventory.runtime.keyLive,⟨returnNote_holds (.obj callee),.cons ?_ sourceNotes.tail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (.obj callee),.cons ?_ targetNotes.tail,inventory.runtime.target.cells⟩⟩
    · simpa only [identity_environment,CallStart.frame] using callStartFrameNote_holds (ν:=ν₀) (C:=C₀) (R:=identity)
        (.method optCall) (.obj a) args env (.obj a) (Value.Holds.obj a)
    · exact callStartFrameNote_holds (.method optCall) (.obj a) args env (.obj (R.a a)) (Value.Holds.obj a)
  exact ⟨targetFrames,left,actual,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
end Host.Ts.Owned.Annotated
