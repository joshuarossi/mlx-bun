import host.ts.RenameRetainedGetterEntry
import host.ts.RenameRetainedClosure
import host.ts.ast.mlx.Array

set_option Elab.async false
set_option maxHeartbeats 1000000
set_option maxRecDepth 1000000

/-!
# Original `ndim`-shaped accessor: closure entry

A generic, source-parameterised entry for a zero-parameter accessor whose body is
the single statement `return <expr>` — the shape of `MlxArray.ndim` (`ast_n61`,
`return Number(C.mlx_array_ndim(this.handle))`). The receiver wrapper, receiver
home cell, lexical scope, body block and the return-statement frame are all
produced by the four real interpreter transitions; every heap, environment,
caller and fresh counter stays arbitrary and is a theorem parameter.

This is a *constituent* of the complete `ndim_call_block`. It is deliberately
not claimed to close the full accessor: the expression evaluation that follows
(`this.handle` accessor dispatch, the native rank ABI call and `Number`) is not
part of this block.
-/
namespace Host.Ts.Owned.Annotated
open Parametric

def singleReturnStatements (expr : Expr) : List Stmt := [.ret (some expr)]

def singleReturnFunction (name : Option Name) (expr : Expr) : Func :=
  .mk name [] none (.block (singleReturnStatements expr)) false false []

def singleReturnEntryRuntime (notes : RuntimeNotes) (fn : Func) (env : Env)
    (receiver owner : Nat) (expr : Expr) : RuntimeNotes :=
  (((notes.closure fn [] env false receiver (.obj owner)).bodyEntered
      (singleReturnStatements expr) env (callBoundaryNote::notes.stack)).blockNext
      (.ret (some expr)) [] env (emptyScopeNote::callBoundaryNote::notes.stack)).statement
      (.returnExpression expr) env

def singleReturnEntryState {S : Type} (s : St S) (name : Option Name) (env : Env)
    (home : Val) (owner : Nat) (expr : Expr) : St S :=
  let fn := singleReturnFunction name expr
  let base := closureState s fn env false home (.obj owner) [] .call
  let e := closureEnvironment s fn env false home (.obj owner)
  let entered := enterBlock {base with stack := .k (.fn .call)::s.stack}
    (singleReturnStatements expr) e
  let next := ({entered with stack := .s (.scope [])::.k (.fn .call)::s.stack}.push
    (.s (.block [] e))).go (.ex (.ret (some expr)) e)
  (StatementAction.returnExpression expr).advance next e

private theorem singleReturn_closure_room {S : Type} (s : St S) (name : Option Name)
    (env : Env) (home receiver : Val) (args : List Val) (expr : Expr) :
    (closureState s (singleReturnFunction name expr) env false home receiver args .call).next ≤ s.next+2 := by
  cases home <;> first
    | change s.next+1 ≤ s.next+2; omega
    | change s.next+1+1 ≤ s.next+2; omega

private theorem one_step (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

/-- A zero-parameter `return <expr>` accessor call allocates its real
receiver/home cells, enters the body block and schedules the return expression in
four original interpreter transitions, for arbitrary source closure, heap,
environment, caller and fresh counters. -/
theorem RetainedInventory.single_return_entry_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (getter owner : Nat) (object : Obj) (name : Option Name) (env : Env) (home : Val) (expr : Expr)
    (control : s₀.ctl = .call (.obj getter) (.obj owner) [])
    (objectRead : s₀.heap.get getter = some (.obj object))
    (closure : object.kind = .fn (.closure (singleReturnFunction name expr) env false home))
    (controlNote : notes.runtime.control = callNote (.obj getter) (.obj owner) [])
    (sourceBound : s₀.next+2 ≤ 2^64) (targetBound : s.next+2 ≤ 2^64) :
    let fn := singleReturnFunction name expr
    let sourceClosure := closureState s₀ fn env false home (.obj owner) [] .call
    let sourceEnv := closureEnvironment s₀ fn env false home (.obj owner)
    let reachedLive := CellsLive (ClosureLive live s₀.next false home fn) sourceClosure.next []
    ∃ result,
      runC F 4 s₀ C₀ = some (singleReturnEntryState s₀ name env home owner expr,C₀) ∧
      runC F 4 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R reachedLive framed before after old old'
        (singleReturnEntryState s₀ name env home owner expr) result ∧
      RetainedInventory
        (notes.withRuntime (singleReturnEntryRuntime notes.runtime fn sourceEnv s₀.next owner expr))
        ν₀ ν C₀ C R reachedLive (singleReturnEntryState s₀ name env home owner expr) result ∧
      result.ffi = s.ffi ∧ result.next ≤ s.next+2 ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  let fn := singleReturnFunction name expr
  let body := singleReturnStatements expr
  let e := closureEnvironment s₀ fn env false home (.obj owner)
  obtain ⟨targetHome,targetThis,targetArgs,left1,right1,h1,inv1⟩ := inventory.closure_step F FR notes ν₀ ν C₀ C R
    live framed before after old old' s₀ s h getter object fn env false home (.obj owner) []
    (.obj getter) (.obj owner) [] control objectRead closure controlNote sourceBound targetBound
  have sourceRoom : (closureState s₀ fn env false home (.obj owner) [] .call).next + (blockNames body).length ≤ 2^64 := by
    have room := singleReturn_closure_room s₀ name env home (.obj owner) [] expr
    change (closureState s₀ fn env false home (.obj owner) [] .call).next+0 ≤ 2^64
    exact Nat.le_trans (by simpa only [Nat.add_zero] using room) sourceBound
  have targetRoom : (closureState s fn (R.env env) false targetHome targetThis targetArgs .call).next + (blockNames body).length ≤ 2^64 := by
    have room := singleReturn_closure_room s name (R.env env) targetHome targetThis targetArgs expr
    change (closureState s fn (R.env env) false targetHome targetThis targetArgs .call).next+0 ≤ 2^64
    exact Nat.le_trans (by simpa only [Nat.add_zero] using room) targetBound
  obtain ⟨frames,left2,right2,h2,inv2⟩ := inv1.parameter_body_step h1 .undef name [] body [] e
    (.k (.fn .call)::s₀.stack) (parameterFrameNote fn [] [] e) (callBoundaryNote::notes.runtime.stack)
    rfl (closureState_stack s₀ fn env false home (.obj owner) [] .call) rfl rfl sourceRoom targetRoom
  obtain ⟨s3,left3,right3,h3,runtime3⟩ := inv2.runtime.block_next_step F FR _ ν₀ ν C₀ C R _ framed before after old old'
    _ _ h2 .undef (.ret (some expr)) [] e
    (.s (.scope [])::.k (.fn .call)::s₀.stack) (blockFrameNote body e) (emptyScopeNote::callBoundaryNote::notes.runtime.stack)
    rfl rfl rfl
  have pure3 := PureRuntimeCase.blockNext h2 .undef (.ret (some expr)) [] e
    (.s (.scope [])::.k (.fn .call)::s₀.stack) rfl rfl
  have effects3 := pure3.effects left3 right3
  have inv3 := inv2.pure_step runtime3 pure3 left3 right3 (.refl C₀) (.refl C)
  obtain ⟨left4,right4,h4,runtime4⟩ := runtime3.statement_step F FR _ ν₀ ν C₀ C R _ framed before after old old'
    _ _ h3 (.returnExpression expr) e rfl
  have inv4 := inv3.heap_step runtime4 rfl rfl (.refl C₀) (.refl C)
  have sourceActive : isHalt s₀.ctl = false := by rw [control]; rfl
  have source1 := one_step F _ _ C₀ sourceActive left1
  have target1 := one_step F _ _ C (h.control.isHalt_eq.trans sourceActive) right1
  have source2 := one_step F _ _ C₀ rfl left2
  have target2 := one_step F _ _ C (h1.control.isHalt_eq.trans rfl) right2
  have source3 := one_step F _ _ C₀ rfl left3
  have target3 := one_step F _ _ C (h2.control.isHalt_eq.trans rfl) right3
  have source4 := one_step F _ _ C₀ rfl left4
  have target4 := one_step F _ _ C (h3.control.isHalt_eq.trans rfl) right4
  refine ⟨(StatementAction.returnExpression expr).advance s3 (R.env e),?_,?_,?_,?_,?_,?_,?_⟩
  · exact runC_join F (runC_join F (runC_join F source1 source2) source3) source4
  · exact runC_join F (runC_join F (runC_join F target1 target2) target3) target4
  · exact h4
  · simpa only [fn,body,e,singleReturnEntryState,singleReturnStatements,blockNames,stmtNames,List.nil_append,
      singleReturnEntryRuntime,RetainedNotes.withRuntime,RuntimeNotes.closure,
      RuntimeNotes.bodyEntered,RuntimeNotes.blockNext,RuntimeNotes.statement] using inv4
  · have unchanged : (closureState s fn (R.env env) false targetHome targetThis targetArgs .call).ffi = s.ffi := by
      cases targetHome <;> rfl
    exact effects3.2.native.trans unchanged
  · exact Nat.le_trans (Nat.le_of_eq effects3.2.next)
      (singleReturn_closure_room s name (R.env env) targetHome targetThis targetArgs expr)
  · intro a below
    exact (congrArg (fun heap : PTrie HObj => heap.get a) effects3.2.heap).trans
      (closureState_heap_below F s fn (R.env env) false targetHome targetThis targetArgs .call targetBound a below)

/-- The generic `singleReturnFunction` really is a one-statement `return` block. -/
theorem singleReturnFunction_eq (name : Option Name) (expr : Expr) :
    singleReturnFunction name expr =
      .mk name [] none (.block [.ret (some expr)]) false false [] := rfl

/-- The pinned `MlxArray.ndim` closure (`ast_n61`) is exactly the one-statement
`return` block whose sole statement is the pinned return `ast_n60`; combined with
`Sources.Mlx.Array.ndim_source_return`, that statement is
`return Number(C.mlx_array_ndim(this.handle))`. -/
theorem ndim_body_is_single_return :
    Sources.Mlx.Array.ast_n61 =
      .mk none [] none (.block [Sources.Mlx.Array.ast_n60]) false false [] := rfl

end Host.Ts.Owned.Annotated
