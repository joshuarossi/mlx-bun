import host.ts.RenameRetainedDisposeFree
import host.ts.RenameRuntimeReturns
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated.Dispose
open Parametric

def finishOutput {S : Type} (source : St S) (frames : List Frame) : St S :=
  {source with ctl := .ret .undef,stack := frames}
def finishNotes (notes : RetainedNotes) (tail : List Tree) : RetainedNotes :=
  notes.withRuntime ⟨returnNote .undef,tail,notes.runtime.cells⟩

/-- The empty source block, scope and implicit function return consume exactly
three transitions. The current native state and all heap roles are framed. -/
theorem finish_block {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (frames : List Frame) (head scope call : Tree) (tail : List Tree)
    (value : Val) (role : Value)
    (control : source.ctl = .ret value)
    (stack : source.stack = .s (.block [] env)::.s (.scope [])::.k (.fn .call)::frames)
    (controlNote : notes.runtime.control = returnNote role)
    (stackNotes : notes.runtime.stack = head::scope::call::tail) :
    ∃ result, runC F 3 source C₀ = some (finishOutput source frames,C₀) ∧
      runC F 3 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (finishOutput source frames) result ∧
      RetainedInventory (finishNotes notes tail) ν₀ ν C₀ C R live (finishOutput source frames) result ∧
      result.heap = target.heap ∧ result.ffi = target.ffi ∧ result.next = target.next := by
  obtain ⟨s1,left1,right1,h1,runtime1⟩ := inventory.runtime.return_exit_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    source target state value role .emptyBlock env (.s (.scope [])::.k (.fn .call)::frames) head (scope::call::tail)
    control stack controlNote stackNotes
  have pure1 := PureRuntimeCase.returnExit state value env .emptyBlock (.s (.scope [])::.k (.fn .call)::frames) control stack
  have effects1 := pure1.effects left1 right1
  have inv1 := inventory.pure_step runtime1 pure1 left1 right1 (.refl C₀) (.refl C)
  host_normalize_retained h1, inv1
  obtain ⟨s2,left2,right2,h2,runtime2⟩ := inv1.runtime.return_exit_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h1 .undef .undef .emptyScope env (.k (.fn .call)::frames) scope (call::tail) rfl rfl rfl rfl
  have pure2 := PureRuntimeCase.returnExit h1 .undef env .emptyScope (.k (.fn .call)::frames) rfl rfl
  have effects2 := pure2.effects left2 right2
  have inv2 := inv1.pure_step runtime2 pure2 left2 right2 (.refl C₀) (.refl C)
  host_normalize_retained h2, inv2
  obtain ⟨result,left3,right3,h3,runtime3⟩ := inv2.runtime.return_exit_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h2 .undef .undef .implicitCall env frames call tail rfl rfl rfl rfl
  have pure3 := PureRuntimeCase.returnExit h2 .undef env .implicitCall frames rfl rfl
  have effects3 := pure3.effects left3 right3
  have inv3 := inv2.pure_step runtime3 pure3 left3 right3 (.refl C₀) (.refl C)
  have l1 := one_step F _ _ C₀ (by rw [control]; rfl) left1
  have r1 := one_step F _ _ C (state.control.isHalt_eq.trans (by rw [control]; rfl)) right1
  have l2 := one_step F _ _ C₀ rfl left2
  have r2 := one_step F _ _ C (h1.control.isHalt_eq.trans rfl) right2
  have l3 := one_step F _ _ C₀ rfl left3
  have r3 := one_step F _ _ C (h2.control.isHalt_eq.trans rfl) right3
  exact ⟨result,runC_join F (runC_join F l1 l2) l3,runC_join F (runC_join F r1 r2) r3,h3,inv3,
    effects3.2.heap.trans (effects2.2.heap.trans effects1.2.heap),
    effects3.2.native.trans (effects2.2.native.trans effects1.2.native),
    effects3.2.next.trans (effects2.2.next.trans effects1.2.next)⟩
end Host.Ts.Owned.Annotated.Dispose
