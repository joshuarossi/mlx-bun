import host.ts.RenameRetainedConstructorReturn
import host.ts.RenameRuntimeReturns
import host.ts.RenameRetainedParameterBody
import host.ts.RenameRouteComposition

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Complete an original empty constructor block, lexical scope and constructor
boundary. Its result is the receiver meaning saved at entry, with the caller
stack restored and every retained heap/native inventory preserved. -/
theorem RetainedInventory.constructor_completion_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (receiver : Val) (role : Value) (caller : List Frame) (callerNotes : List Tree)
    (control : source.ctl = .ret .undef)
    (stack : source.stack = .s (.block [] env)::.s (.scope [])::.k (.fn (.ctor receiver))::caller)
    (controlNote : notes.runtime.control = returnNote .undef)
    (stackNotes : notes.runtime.stack = blockFrameNote [] env::emptyScopeNote::constructorBoundaryNote role::callerNotes) :
    ∃ result,
      runC F 3 source C₀ = some ({source with ctl := .ret receiver,stack := caller},C₀) ∧
      runC F 3 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        {source with ctl := .ret receiver,stack := caller} result ∧
      RetainedInventory (notes.withRuntime ⟨returnNote role,callerNotes,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live {source with ctl := .ret receiver,stack := caller} result ∧
      result.heap = target.heap ∧ result.ffi = target.ffi ∧ result.next = target.next := by
  obtain ⟨s1,left1,right1,h1,runtime1⟩ := inventory.runtime.return_exit_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' source target h .undef .undef .emptyBlock env
    (.s (.scope [])::.k (.fn (.ctor receiver))::caller) (blockFrameNote [] env)
    (emptyScopeNote::constructorBoundaryNote role::callerNotes) control stack controlNote stackNotes
  have pure1 := PureRuntimeCase.returnExit h .undef env .emptyBlock
    (.s (.scope [])::.k (.fn (.ctor receiver))::caller) control stack
  have effects1 := pure1.effects left1 right1
  have inv1 := inventory.pure_step runtime1 pure1 left1 right1 (.refl C₀) (.refl C)
  obtain ⟨s2,left2,right2,h2,runtime2⟩ := inv1.runtime.return_exit_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h1 .undef .undef .emptyScope env
    (.k (.fn (.ctor receiver))::caller) emptyScopeNote (constructorBoundaryNote role::callerNotes) rfl rfl rfl rfl
  have pure2 := PureRuntimeCase.returnExit h1 .undef env .emptyScope (.k (.fn (.ctor receiver))::caller) rfl rfl
  have effects2 := pure2.effects left2 right2
  have inv2 := inv1.pure_step runtime2 pure2 left2 right2 (.refl C₀) (.refl C)
  obtain ⟨_,_,left3,right3,h3,inv3⟩ := inv2.constructor_return_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h2 .undef receiver caller role callerNotes rfl rfl rfl
  have l1 := runC_cons F 0 source _ _ C₀ C₀ C₀ (by rw [control]; rfl) left1 rfl
  have r1 := runC_cons F 0 target _ _ C C C (h.control.isHalt_eq.trans (by rw [control]; rfl)) right1 rfl
  have l2 := runC_cons F 0 _ _ _ C₀ C₀ C₀ rfl left2 rfl
  have r2 := runC_cons F 0 _ _ _ C C C (h1.control.isHalt_eq.trans rfl) right2 rfl
  have l3 := runC_cons F 0 _ _ _ C₀ C₀ C₀ rfl left3 rfl
  have r3 := runC_cons F 0 _ _ _ C C C (h2.control.isHalt_eq.trans rfl) right3 rfl
  exact ⟨_,runC_join F (m:=2) (n:=1) (runC_join F l1 l2) l3,
    runC_join F (m:=2) (n:=1) (runC_join F r1 r2) r3,h3,inv3,
    effects2.2.heap.trans effects1.2.heap,effects2.2.native.trans effects1.2.native,effects2.2.next.trans effects1.2.next⟩

end Host.Ts.Owned.Annotated
