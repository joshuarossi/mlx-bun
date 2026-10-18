import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeClosure
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- The actual closure step retains every annotation family. Its only new
cell annotation is the receiver role taken from the incoming call. -/
theorem RetainedInventory.closure_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (o₀ : Obj) (fn : Func) (env : Env) (arrow : Bool) (home this₀ : Val) (args₀ : List Val)
    (fnRole thisRole : Value) (argRoles : List Value)
    (control : s₀.ctl = .call (.obj a) this₀ args₀) (object : s₀.heap.get a = some (.obj o₀))
    (closure : o₀.kind = .fn (.closure fn env arrow home))
    (controlNote : notes.runtime.control = callNote fnRole thisRole argRoles)
    (sourceBound : s₀.next+2+(paramNames fn).length ≤ 2^64)
    (targetBound : s.next+2+(paramNames fn).length ≤ 2^64) :
    ∃ targetHome targetThis targetArgs,
      interpC (step F s₀).run C₀ = some (closureState s₀ fn env arrow home this₀ args₀ .call,C₀) ∧
      interpC (step F s).run C = some
        (closureState s fn (R.env env) arrow targetHome targetThis targetArgs .call,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (ClosureLive live s₀.next arrow home fn)
        framed before after old old'
        (closureState s₀ fn env arrow home this₀ args₀ .call)
        (closureState s fn (R.env env) arrow targetHome targetThis targetArgs .call) ∧
      RetainedInventory
        (notes.withRuntime (notes.runtime.closure fn argRoles (closureEnvironment s₀ fn env arrow home this₀) arrow s₀.next thisRole))
        ν₀ ν C₀ C R (ClosureLive live s₀.next arrow home fn)
        (closureState s₀ fn env arrow home this₀ args₀ .call)
        (closureState s fn (R.env env) arrow targetHome targetThis targetArgs .call) := by
  obtain ⟨targetHome,targetThis,targetArgs,sourceRun,targetRun,post,runtime⟩ := inventory.runtime.closure_step
    F FR notes.runtime ν₀ ν C₀ C R live framed before after old old' s₀ s h a o₀ fn env arrow home this₀ args₀
    fnRole thisRole argRoles control object closure controlNote sourceBound targetBound
  have grow := ClosureLive.grow live s₀.next arrow home fn
  have sourceFrame := closureState_heap_below F s₀ fn env arrow home this₀ args₀ .call sourceBound
  have targetFrame := closureState_heap_below F s fn (R.env env) arrow targetHome targetThis targetArgs .call targetBound
  have sourceLive : ∀ b, live b →
      (closureState s₀ fn env arrow home this₀ args₀ .call).heap.get b = s₀.heap.get b :=
    fun b alive => sourceFrame b (h.heap.sourceBound b alive)
  have targetLive : ∀ b, live b →
      (closureState s fn (R.env env) arrow targetHome targetThis targetArgs .call).heap.get (R.a b) = s.heap.get (R.a b) :=
    fun b alive => targetFrame (R.a b) (h.heap.targetBound b alive)
  exact ⟨targetHome,targetThis,targetArgs,sourceRun,targetRun,post,runtime,
    inventory.privates.frame grow
      (fun b note entry => sourceLive b (inventory.privates.keyLive b note entry).1)
      (fun b note entry => targetLive b (inventory.privates.keyLive b note entry).1),
    inventory.captures.frame grow
      (fun b note entry => sourceLive b (inventory.captures.keyLive b note entry))
      (fun b note entry => targetLive b (inventory.captures.keyLive b note entry)),
    inventory.arrays.frame grow
      (fun b roles entry => sourceLive b (inventory.arrays.keyLive b roles entry))
      (fun b roles entry => targetLive b (inventory.arrays.keyLive b roles entry)),
    inventory.publicFields.frame grow
      (fun b name role entry => sourceLive b (inventory.publicFields.keyLive b name role entry))
      (fun b name role entry => targetLive b (inventory.publicFields.keyLive b name role entry)),
    inventory.buffers.frame grow
      (fun b roles entry => sourceLive b (inventory.buffers.keyLive b roles entry))
      (fun b roles entry => targetLive b (inventory.buffers.keyLive b roles entry))⟩
end Host.Ts.Owned.Annotated
