import host.ts.RenameRetainedClosure
import host.ts.RenameRetainedExpressionBody
import host.ts.RenameRetainedMapperBody
set_option Elab.async false
set_option maxHeartbeats 1000000
set_option maxRecDepth 1000000
namespace Host.Ts.Owned.Annotated
open Parametric

def literalArrow (name : Option Name) (literal : Lit) : Func :=
  .mk name [] none (.expr (.lit literal)) false false []

private theorem one_step (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

/-- A zero-parameter literal arrow ignores its supplied arguments and returns
its syntax-determined value in five original transitions. Its captured
environment, caller, heaps and native states are arbitrary and unchanged. -/
theorem RetainedInventory.literal_arrow_call_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (callee : Nat) (function : Obj) (name : Option Name) (literal : Lit) (value : Val)
    (parsed : LiteralValue literal value) (env : Env) (home receiver : Val) (args : List Val)
    (fnRole thisRole : Value) (argRoles : List Value)
    (control : s₀.ctl = .call (.obj callee) receiver args)
    (read : s₀.heap.get callee = some (.obj function))
    (kind : function.kind = .fn (.closure (literalArrow name literal) env true home))
    (controlNote : notes.runtime.control = callNote fnRole thisRole argRoles)
    (sourceBound : s₀.next+2 ≤ 2^64) (targetBound : s.next+2 ≤ 2^64) :
    ∃ result, runC F 5 s₀ C₀ = some (s₀.ret value,C₀) ∧
      runC F 5 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (s₀.ret value) result ∧
      RetainedInventory (notes.withRuntime ⟨returnNote parsed.role,notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live (s₀.ret value) result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next := by
  obtain ⟨targetHome,targetThis,targetArgs,left1,right1,h1,inv1⟩ := inventory.closure_step F FR notes
    ν₀ ν C₀ C R live framed before after old old' s₀ s h callee function (literalArrow name literal)
    env true home receiver args fnRole thisRole argRoles control read kind controlNote sourceBound targetBound
  obtain ⟨targetFrames,left2,right2,h2,inv2⟩ := inv1.parameter_expression_step h1 .undef name [] (.lit literal)
    args env (.k (.fn .call)::s₀.stack) (parameterFrameNote (literalArrow name literal) [] argRoles env)
    (callBoundaryNote::notes.runtime.stack) rfl rfl rfl
  obtain ⟨left3,right3,h3,runtime3⟩ := inv2.runtime.literal_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h2 literal value env parsed rfl
  have inv3 := inv2.heap_step runtime3 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨result,left4,right4,h4,inv4,heap4,ffi4,next4⟩ := inv3.mapper_return_block h3 value parsed.role env s₀.stack
    expressionReturnNote callBoundaryNote notes.runtime.stack rfl rfl rfl rfl
  have active : isHalt s₀.ctl = false := by rw [control]; rfl
  exact ⟨result,
    runC_join F (runC_join F (runC_join F (one_step F _ _ C₀ active left1) (one_step F _ _ C₀ rfl left2))
      (one_step F _ _ C₀ rfl left3)) left4,
    runC_join F (runC_join F (runC_join F (one_step F _ _ C (h.control.isHalt_eq.trans active) right1)
      (one_step F _ _ C rfl right2)) (one_step F _ _ C (h2.control.isHalt_eq.trans rfl) right3)) right4,
    h4,inv4,heap4,ffi4,next4⟩
end Host.Ts.Owned.Annotated
