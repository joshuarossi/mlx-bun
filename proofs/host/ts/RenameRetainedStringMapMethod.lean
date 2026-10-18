import host.ts.RenameParametricStringMapMethod
import host.ts.RuntimeInventoryMethod
import host.ts.RenameRetainedHeapFrame

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Resolve an initialized Map prototype method from current source metadata,
retaining the receiver, caller and every annotation family. -/
theorem RetainedInventory.map_object_method
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (relation : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (owner prototype callee : Nat) (object parent : Obj) (entries : List (Val × Val))
    (name : Name) (args : List Elem) (env : Env) (optionalObject optionalCall writable enumerable : Bool)
    (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : source.ctl = .ret (.obj owner))
    (stack : source.stack = .c (.member (.str name) args env optionalObject optionalCall)::frames)
    (read : source.heap.get owner = some (.obj object)) (kind : object.kind = .map entries)
    (notSize : keyEq (.str name) (.str chars!"size") = false)
    (absent : findProp (.str name) object.props = none) (proto : object.proto = .obj prototype)
    (parentRead : source.heap.get prototype = some (.obj parent)) (ordinary : parent.kind = .ordinary)
    (descriptor : findProp (.str name) parent.props = some (.data (.obj callee) writable enumerable))
    (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      interpC (step F source).run C₀ = some (methodReturnState source owner args env optionalCall frames (.obj callee),C₀) ∧
      interpC (step F target).run C = some
        (methodReturnState target (R.a owner) args (R.env env) optionalCall targetFrames (.obj (R.a callee)),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (methodReturnState source owner args env optionalCall frames (.obj callee))
        (methodReturnState target (R.a owner) args (R.env env) optionalCall targetFrames (.obj (R.a callee))) ∧
      RetainedInventory (notes.withRuntime (notes.runtime.methodResult owner args env optionalCall (.obj callee) tail))
        ν₀ ν C₀ C R live (methodReturnState source owner args env optionalCall frames (.obj callee))
        (methodReturnState target (R.a owner) args (R.env env) optionalCall targetFrames (.obj (R.a callee))) := by
  obtain ⟨value,targetFrames,targetStack,left,right,post,valueRelation⟩ := step_map_method_from_source_fields F
    (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' source target relation
    owner prototype object parent entries name args env optionalObject optionalCall (.obj callee) writable enumerable frames
    control stack read kind notSize absent proto parentRead ordinary descriptor
  cases valueRelation
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have runtime : RuntimeInventory (notes.runtime.methodResult owner args env optionalCall (.obj callee) tail)
      ν₀ ν C₀ C R live (methodReturnState source owner args env optionalCall frames (.obj callee))
      (methodReturnState target (R.a owner) args (R.env env) optionalCall targetFrames (.obj (R.a callee))) := by
    refine ⟨inventory.runtime.keyLive,⟨returnNote_holds (.obj callee),.cons ?_ sourceNotes.tail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (.obj callee),.cons ?_ targetNotes.tail,inventory.runtime.target.cells⟩⟩
    · simpa only [identity_environment,CallStart.frame] using callStartFrameNote_holds (ν:=ν₀) (C:=C₀) (R:=identity)
        (.method optionalCall) (.obj owner) args env (.obj owner) (Value.Holds.obj owner)
    · exact callStartFrameNote_holds (.method optionalCall) (.obj owner) args env (.obj (R.a owner)) (Value.Holds.obj owner)
  exact ⟨targetFrames,left,right,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
