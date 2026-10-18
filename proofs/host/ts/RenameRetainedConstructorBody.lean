import host.ts.RenameRetainedClassEntry
import host.ts.RenameRuntimeClosure

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def RuntimeNotes.constructorBody (notes : RuntimeNotes) (fn : Func) (args : List Value)
    (env : Env) (receiver : Nat) (thisRole : Value) (tail : List Tree) : RuntimeNotes :=
  ⟨returnNote .undef,parameterFrameNote fn (fnParams fn) args env::constructorBoundaryNote thisRole::tail,
    notes.cells.write receiver thisRole⟩

theorem constructorEnvironment_from_state {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (fn : Func) (env : Env) (this₀ this : Val) (args₀ args : List Val)
    (post : Parametric.StateR NR FR R live framed before after old old'
      (closureState s₀ fn env false .undef this₀ args₀ (.ctor this₀))
      (closureState s fn (R.env env) false .undef this args (.ctor this))) :
    closureEnvironment s fn (R.env env) false .undef this =
      R.env (closureEnvironment s₀ fn env false .undef this₀) := by
  have frames := post.stack
  rw [closureState_stack,closureState_stack] at frames
  cases frames with | cons head _ =>
    obtain ⟨_,same,_⟩ := head.params_view
    exact (FnF.params.inj (Frame.k.inj same)).2.2.2

/-- Constructor-body entry takes receiver and argument meanings from its saved
frame, rather than selecting new interpretations of the incoming handle.
It records the new receiver cell, schedules the original parameters and
constructor boundary, and frames every older annotation family. -/
theorem RetainedInventory.constructor_body_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (v₀ this₀ : Val) (fn : Func) (env : Env) (args₀ : List Val) (frames₀ : List Frame)
    (thisRole : Value) (argRoles : List Value) (tail : List Tree)
    (control : s₀.ctl = .ret v₀) (stack : s₀.stack = .k (.ctorBody this₀ fn env args₀)::frames₀)
    (stackNotes : notes.runtime.stack = constructorBodyFrameNote thisRole fn env argRoles::tail)
    (sourceBound : s₀.next+2+(paramNames fn).length ≤ 2^64)
    (targetBound : s.next+2+(paramNames fn).length ≤ 2^64) :
    ∃ this args frames,
      interpC (step F s₀).run C₀ = some
        (closureState {s₀ with stack := frames₀} fn env false .undef this₀ args₀ (.ctor this₀),C₀) ∧
      interpC (step F s).run C = some
        (closureState {s with stack := frames} fn (R.env env) false .undef this args (.ctor this),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (ConstructorBodyLive live s₀.next fn)
        framed before after old old'
        (closureState {s₀ with stack := frames₀} fn env false .undef this₀ args₀ (.ctor this₀))
        (closureState {s with stack := frames} fn (R.env env) false .undef this args (.ctor this)) ∧
      RetainedInventory (notes.withRuntime (notes.runtime.constructorBody fn argRoles
        (closureEnvironment {s₀ with stack := frames₀} fn env false .undef this₀) s₀.next thisRole tail))
        ν₀ ν C₀ C R (ConstructorBodyLive live s₀.next fn)
        (closureState {s₀ with stack := frames₀} fn env false .undef this₀ args₀ (.ctor this₀))
        (closureState {s with stack := frames} fn (R.env env) false .undef this args (.ctor this)) := by
  obtain ⟨v,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,frames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨this,args,frameEq,_,_⟩ := frameRelation.constructorBody_view
  rw [frameEq] at targetStack
  obtain ⟨sourcePost,targetPost,left,right,post,_⟩ := step_constructor_body_from_source F
    (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s₀ s h
    v₀ this₀ fn env args₀ frames₀ control stack (by omega) (by omega)
  have actualSource : interpC (step F s₀).run C₀ = some
      (closureState {s₀ with stack := frames₀} fn env false .undef this₀ args₀ (.ctor this₀),C₀) := by
    rw [step_constructor_body_eq F s₀ v₀ this₀ fn env args₀ frames₀ control stack,enterClosure_state]; rfl
  have actualTarget : interpC (step F s).run C = some
      (closureState {s with stack := frames} fn (R.env env) false .undef this args (.ctor this),C) := by
    rw [step_constructor_body_eq F s v this fn (R.env env) args frames targetControl targetStack,enterClosure_state]; rfl
  have sourceEq := congrArg Prod.fst (Option.some.inj (left.symm.trans actualSource))
  have targetEq := congrArg Prod.fst (Option.some.inj (right.symm.trans actualTarget))
  dsimp only at sourceEq targetEq
  rw [sourceEq,targetEq] at post
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  cases sourceNotes with | cons sourceBody sourceTail =>
   cases targetNotes with | cons targetBody targetTail =>
    have sourceBody' : (constructorBodyFrameNote thisRole fn env argRoles).Holds ν₀ C₀ identity
        (Encode.frame (.k (.ctorBody this₀ fn (identity.env env) args₀))) := by
      simpa only [identity_environment] using sourceBody
    have sourceHeld := constructorBodyFrameNote_view thisRole fn env argRoles this₀ args₀ sourceBody'
    have targetHeld := constructorBodyFrameNote_view thisRole fn env argRoles this args targetBody
    have grow : ∀ a, live a → ConstructorBodyLive live s₀.next fn a :=
      fun a alive => CellsLive.grow _ _ _ a (Or.inl alive)
    have sourceFrame := fun a alive => closureState_heap_below F {s₀ with stack := frames₀} fn env false .undef
      this₀ args₀ (.ctor this₀) sourceBound a (h.heap.sourceBound a alive)
    have targetFrame := fun a alive => closureState_heap_below F {s with stack := frames} fn (R.env env) false .undef
      this args (.ctor this) targetBound (R.a a) (h.heap.targetBound a alive)
    have oldHeap := inventory.heapInventory.frame grow sourceFrame targetFrame
    have fresh : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
    have cells := oldHeap.cells.annotate s₀.next thisRole (CellsLive.grow _ _ _ _ (Or.inr rfl))
      (by simpa only [cellValueAt,identity,id_eq,(closureState_receiver F {s₀ with stack := frames₀} fn env
        .undef this₀ args₀ (.ctor this₀) sourceBound)] using sourceHeld.1)
      (by rw [fresh]; simpa only [cellValueAt,(closureState_receiver F {s with stack := frames} fn (R.env env)
        .undef this args (.ctor this) targetBound)] using targetHeld.1)
    have environment := constructorEnvironment_from_state fn env this₀ this args₀ args post
    refine ⟨this,args,frames,actualSource,actualTarget,post,⟨cells.keyLive,?_,?_⟩,oldHeap.privates,oldHeap.captures,?_,?_,?_⟩
    · refine ⟨returnNote_holds .undef,?_,cells.source⟩
      rw [RuntimeNotes.constructorBody,closureState_stack,List.map_cons,List.map_cons]
      exact .cons (by simpa only [identity_environment] using
        (parameterFrameNote_holds (R:=identity) fn (fnParams fn) argRoles
          (closureEnvironment {s₀ with stack := frames₀} fn env false .undef this₀) args₀ sourceHeld.2))
        (.cons (constructorBoundaryNote_holds thisRole this₀ sourceHeld.1) sourceTail)
    · refine ⟨returnNote_holds .undef,?_,cells.target⟩
      rw [RuntimeNotes.constructorBody,closureState_stack,List.map_cons,List.map_cons,environment]
      exact .cons (parameterFrameNote_holds fn (fnParams fn) argRoles
        (closureEnvironment {s₀ with stack := frames₀} fn env false .undef this₀) args targetHeld.2)
        (.cons (constructorBoundaryNote_holds thisRole this targetHeld.1) targetTail)
    · exact inventory.arrays.frame grow
        (fun a roles entry => sourceFrame a (inventory.arrays.keyLive a roles entry))
        (fun a roles entry => targetFrame a (inventory.arrays.keyLive a roles entry))
    · exact inventory.publicFields.frame grow
        (fun a name role entry => sourceFrame a (inventory.publicFields.keyLive a name role entry))
        (fun a name role entry => targetFrame a (inventory.publicFields.keyLive a name role entry))
    · exact inventory.buffers.frame grow
        (fun a roles entry => sourceFrame a (inventory.buffers.keyLive a roles entry))
        (fun a roles entry => targetFrame a (inventory.buffers.keyLive a roles entry))

end Host.Ts.Owned.Annotated
