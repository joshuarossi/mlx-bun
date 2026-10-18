import host.mlx.NativeArrayBufferInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

/-- Constant folding a fixed meaning is valid for every valuation; this is
not a new role selected by examining a current numeric value. -/
theorem Value.Holds.literal_constant {ν : Nat → F64} {C : CSrv} {R : Ren}
    {meaning : SymE} {value : Val} {x : F64} (held : (Value.literal meaning).Holds ν C R value)
    (closed : ∀ valuation, meaning.eval valuation = x) : (Value.literal (.lit x)).Holds ν C R value := by
  cases held with
  | literal e y denotation =>
    have same : y = x := (Option.some.inj denotation).trans (closed ν)
    subst y
    exact .literal _ _ rfl

/-- ABI counts/offsets may retain closed arithmetic syntax such as 3*4.
The driver supplies a checked constant-meaning certificate over all valuations,
and literal ABI decoding is derived without a target operand-value premise. -/
theorem RetainedInventory.toArrayBuffer_closed_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn : Nat) (object : Obj) (data : List Val) (this : Val)
    (region origin off count : Nat) (x y : F64) (offsetMeaning countMeaning : SymE) (fnRole thisRole pointerRole : Value)
    (control : s₀.ctl = .call (.obj fn) this [.ptr (.ext region) origin,.num (.lit x),.num (.lit y)])
    (read : s₀.heap.get fn = some (.obj object)) (kind : object.kind = .fn (.native (.ffi .toArrayBuffer) data))
    (offset : F64.toIndex? x = some off) (size : F64.toIndex? y = some count)
    (note : notes.runtime.control = callNote fnRole thisRole [pointerRole,.literal offsetMeaning,.literal countMeaning])
    (offsetClosed : ∀ valuation, offsetMeaning.eval valuation = x)
    (countClosed : ∀ valuation, countMeaning.eval valuation = y)
    (protoLive : live aArrayBufferProto) (protoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    let sourcePost := (s₀.alloc (externalBuffer region (origin+off) count)).2.ret (.obj s₀.next)
    let targetPost := (s.alloc (externalBuffer (R.region region) (origin+off) count)).2.ret (.obj s.next)
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
  have offsetRole := (inventory.runtime.call_argument_role fnRole thisRole
    [pointerRole,.literal offsetMeaning,.literal countMeaning] (.obj fn) this _ control note
      1 (.literal offsetMeaning) rfl).2
  have countRole := (inventory.runtime.call_argument_role fnRole thisRole
    [pointerRole,.literal offsetMeaning,.literal countMeaning] (.obj fn) this _ control note
      2 (.literal countMeaning) rfl).2
  have concreteOffset := offsetRole.literal_constant offsetClosed
  have concreteCount := countRole.literal_constant countClosed
  obtain ⟨sourceRun,targetRun,post⟩ := step_toArrayBuffer_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C ν
    live framed before after old old' s₀ s h fn object data this region origin off count x y
    control read kind offset size concreteOffset concreteCount protoLive protoFixed sourceBound targetBound
  let object₀ := externalBuffer region (origin+off) count
  let object' := externalBuffer (R.region region) (origin+off) count
  exact ⟨sourceRun,targetRun,post,inventory.allocate_return h.heap object₀ object' sourceBound targetBound,
    fun a old => alloc_ret_heap_below s₀ object₀ (.obj s₀.next) sourceBound a old,
    fun a old => alloc_ret_heap_below s object' (.obj s.next) targetBound a old,rfl,rfl,rfl,rfl⟩

end Host.Ts.Owned.Annotated
