import host.ts.RenameRetainedParameterBody
import host.ts.RenameRuntimeParameters
import host.ts.RenameRetainedStores
import host.ts.RenameRetainedPrivateAssignBlock
import host.ts.RenameRuntimePureScheduler
import host.ts.RenameRouteComposition

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.MlxConstruction
open Parametric

def handleAssignment : Expr :=
  .assign .assign (.expr (.priv .this chars!"handle" false)) (.id chars!"handle")
def registerExpression : Expr :=
  .call (.member (.id chars!"registry") chars!"register" false)
    [.expr .this,.expr (.id chars!"handle"),.expr (.priv .this chars!"token" false)] false
def constructorBody : List Stmt := [.expr handleAssignment,.expr registerExpression]
def constructorFunction : Func := .mk none [.id chars!"handle"] none (.block constructorBody) false false []

def parameterOutput {S : Type} (source : St S) (env : Env) (frames : List Frame)
    (address : Nat) (value : Val) : St S :=
  {source.setCell address value with ctl := .ev handleAssignment env, stack := .s (.block [.expr registerExpression] env) :: .s (.scope []) :: frames}
def parameterNotes (notes : RetainedNotes) (env : Env) (address : Nat)
    (role : Value) (tail : List Tree) : RetainedNotes :=
  let n1 := notes.runtime.parameterArgument constructorFunction chars!"handle" [] [role] env tail
  let n2 := n1.initialized address role
  let n3 := n2.bodyEntered constructorBody env tail
  let n4 := n3.blockNext (.expr handleAssignment) [.expr registerExpression] env (emptyScopeNote::tail)
  notes.withRuntime (n4.statement (.expression handleAssignment) env)

private theorem param_one (F : Ffi) (source target : St F.S) (C : CSrv)
    (active : isHalt source.ctl = false) (execution : interpC (step F source).run C = some (target,C)) :
    runC F 1 source C = some (target,C) := runC_cons F 0 source target target C C C active execution rfl

/-- Original constructor parameter binding and block setup. The argument
meaning is consumed from the saved frame, then retained at the actual lexical
cell. The block has no hoisted bindings, so this phase allocates nothing. -/
theorem prepare_parameter {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (frames : List Frame) (address : Nat) (value : Val) (role : Value) (tail : List Tree)
    (control : source.ctl = .ret .undef)
    (stack : source.stack = .k (.params constructorFunction [.id chars!"handle"] [value] env)::frames)
    (lookup : lookupEnv chars!"handle" env = some address)
    (read : source.heap.get address = some (.cell none))
    (stackNotes : notes.runtime.stack = parameterFrameNote constructorFunction [.id chars!"handle"] [role] env::tail)
    (sourceBound : source.next ≤ 2^64) (targetBound : target.next ≤ 2^64) :
    ∃ result,
      runC F 5 source C₀ = some (parameterOutput source env frames address value,C₀) ∧
      runC F 5 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (parameterOutput source env frames address value) result ∧
      RetainedInventory (parameterNotes notes env address role tail) ν₀ ν C₀ C R live
        (parameterOutput source env frames address value) result := by
  obtain ⟨target1,left1,right1,h1,runtime1⟩ := inventory.runtime.parameter_id_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    source target h .undef constructorFunction chars!"handle" [] [value] env frames [role] tail control stack stackNotes
  have pure1 := PureRuntimeCase.parameterId h .undef constructorFunction chars!"handle" [] [value] env frames control stack
  have effects1 := pure1.effects left1 right1
  have inv1 := inventory.pure_step runtime1 pure1 left1 right1 (.refl C₀) (.refl C)
  obtain ⟨_,left2,right2,h2,inv2⟩ := inv1.init_step h1 chars!"handle" env address value none .let_ role
    rfl lookup read rfl sourceBound (by rw [effects1.2.next]; exact targetBound)
  obtain ⟨_,left3,right3,h3,inv3⟩ := inv2.parameter_body_step h2 .undef none [.id chars!"handle"]
    constructorBody [] env frames (parameterFrameNote constructorFunction [] [] env) tail rfl rfl rfl (by decide +kernel)
    (by change source.next ≤ 2^64; exact sourceBound)
    (by change target1.next ≤ 2^64; rw [effects1.2.next]; exact targetBound)
  obtain ⟨_,left4,right4,h4,runtime4⟩ := inv3.runtime.block_next_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h3 .undef (.expr handleAssignment) [.expr registerExpression] env (.s (.scope [])::frames)
    (blockFrameNote constructorBody env) (emptyScopeNote::tail) rfl rfl rfl
  have effects4 := PureRuntimeCase.blockNext h3 .undef (.expr handleAssignment) [.expr registerExpression] env
    (.s (.scope [])::frames) rfl rfl
  have inv4 := inv3.pure_step runtime4 effects4 left4 right4 (.refl C₀) (.refl C)
  obtain ⟨left5,right5,h5,runtime5⟩ := inv4.runtime.statement_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h4 (.expression handleAssignment) env rfl
  have inv5 := inv4.heap_step runtime5 rfl rfl (.refl C₀) (.refl C)
  have l1 := param_one F _ _ C₀ (by rw [control]; rfl) left1
  have r1 := param_one F _ _ C (h.control.isHalt_eq.trans (by rw [control]; rfl)) right1
  have l2 := param_one F _ _ C₀ rfl left2
  have r2 := param_one F _ _ C (h1.control.isHalt_eq.trans rfl) right2
  have l3 := param_one F _ _ C₀ rfl left3
  have r3 := param_one F _ _ C (h2.control.isHalt_eq.trans rfl) right3
  have l4 := param_one F _ _ C₀ rfl left4
  have r4 := param_one F _ _ C (h3.control.isHalt_eq.trans rfl) right4
  have l5 := param_one F _ _ C₀ rfl left5
  have r5 := param_one F _ _ C (h4.control.isHalt_eq.trans rfl) right5
  exact ⟨_,runC_join F (runC_join F (runC_join F (runC_join F l1 l2) l3) l4) l5,
    runC_join F (runC_join F (runC_join F (runC_join F r1 r2) r3) r4) r5,h5,inv5⟩

end Host.Ts.Owned.Annotated.MlxConstruction
