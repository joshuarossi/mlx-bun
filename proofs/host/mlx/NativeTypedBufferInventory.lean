import host.ts.RenameRetainedAllocation
import host.ts.RenameParametricTypedBuffer

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

/-- The real native typed constructor reads its fixed code/prototype meanings
from captured builtin metadata. Its backing region and length follow from the
source heap. No target metadata role or backing-buffer read is a premise. -/
theorem RetainedInventory.typedBuffer_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn buffer : Nat) (object backing : Obj) (newTarget : Val)
    (region origin count code proto : Nat) (x y : F64) (metadata : NativeCaptureNote)
    (control : s₀.ctl = .construct (.obj fn) [.obj buffer] newTarget)
    (read : s₀.heap.get fn = some (.obj object))
    (kind : object.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (bufferRead : s₀.heap.get buffer = some (.obj backing)) (bufferKind : backing.kind = .extBuf region origin count)
    (kindIndex : F64.toIndex? x = some code) (protoIndex : F64.toIndex? y = some proto)
    (selected : notes.captures.owners fn = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit x)))
    (protoNote : metadata.roles 1 = some (.literal (.lit y)))
    (protoLive : live proto) (protoFixed : R.a proto = proto)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    let sourcePost := (s₀.alloc (typedBuffer (eltOfCode code) buffer 0 (count / (eltOfCode code).size) proto)).2.ret (.obj s₀.next)
    let targetPost := (s.alloc (typedBuffer (eltOfCode code) (R.a buffer) 0 (count / (eltOfCode code).size) proto)).2.ret (.obj s.next)
    interpC (step F s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step F s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live s₀.next)
        framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote (.obj s₀.next)})
        ν₀ ν C₀ C R (LiveAfter live s₀.next) sourcePost targetPost ∧
      (∀ a, a < s₀.next → sourcePost.heap.get a = s₀.heap.get a) ∧
      (∀ a, a < s.next → targetPost.heap.get a = s.heap.get a) ∧
      sourcePost.ffi = s₀.ffi ∧ targetPost.ffi = s.ffi ∧
      sourcePost.next = s₀.next+1 ∧ targetPost.next = s.next+1 := by
  dsimp only
  have codeRole := (inventory.captures.argument fn metadata selected 0 _ codeNote).2.2
  have protoRole := (inventory.captures.argument fn metadata selected 1 _ protoNote).2.2
  obtain ⟨sourceRun,targetRun,post⟩ := step_construct_typedBuffer_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C ν
    live framed before after old old' s₀ s h fn buffer object backing newTarget region origin count code proto x y
    control read kind bufferRead bufferKind kindIndex protoIndex codeRole protoRole protoLive protoFixed sourceBound targetBound
  let object₀ := typedBuffer (eltOfCode code) buffer 0 (count / (eltOfCode code).size) proto
  let object' := typedBuffer (eltOfCode code) (R.a buffer) 0 (count / (eltOfCode code).size) proto
  exact ⟨sourceRun,targetRun,post,inventory.allocate_return h.heap object₀ object' sourceBound targetBound,
    fun a old => alloc_ret_heap_below s₀ object₀ (.obj s₀.next) sourceBound a old,
    fun a old => alloc_ret_heap_below s object' (.obj s.next) targetBound a old,rfl,rfl,rfl,rfl⟩

end Host.Ts.Owned.Annotated
