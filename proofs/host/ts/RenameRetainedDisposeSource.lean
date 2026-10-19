import host.ts.ast.mlx.Array
import host.ts.RenameRetainedGetterCall
import host.ts.RenameRetainedPrivateOther
import host.ts.RenameRetainedPrivateAssign
import host.ts.RenameRetainedPrivateObjectRead
import host.ts.RenameRetainedObjectVariable
import host.ts.RuntimeInventoryMethod
import host.ts.RenameRuntimeDriverUnregister
import host.mlx.NativeArrayFreeRetained

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated.Dispose
open Parametric

def flag : Name := chars!"disposed"
def handle : Name := chars!"handle"
def token : Name := chars!"token"
def registry : Name := chars!"registry"
def unregister : Name := chars!"unregister"
def nativeModule : Name := chars!"C"
def free : Name := chars!"mlx_array_free"

def guard : Stmt := .if_ (.priv .this flag false) (.ret none) none
def assign : Stmt := .expr (.assign .assign (.expr (.priv .this flag false)) (.lit (.bool true)))
def unregisterStmt : Stmt := .expr (.call (.member (.id registry) unregister false) [.expr (.priv .this token false)] false)
def freeStmt : Stmt := .expr (.call (.member (.id nativeModule) free false) [.expr (.priv .this handle false)] false)
def statements : List Stmt := [guard,assign,unregisterStmt,freeStmt]
def function : Func := .mk none [] none (.block statements) false false []

theorem pinned_function : function = Host.Ts.Sources.Mlx.Array.ast_n170 := by rfl

def entryRuntime (notes : RuntimeNotes) (env : Env) (receiver owner : Nat) : RuntimeNotes :=
  (((notes.closure function [] env false receiver (.obj owner)).bodyEntered
    statements env (callBoundaryNote::notes.stack)).blockNext guard [assign,unregisterStmt,freeStmt] env
    (emptyScopeNote::callBoundaryNote::notes.stack)).statement
    (.ifTest (.priv .this flag false) (.ret none) none) env

def entryState {S : Type} (s : St S) (env : Env) (home : Val) (owner : Nat) : St S :=
  let base := closureState s function env false home (.obj owner) [] .call
  let e := closureEnvironment s function env false home (.obj owner)
  let entered := enterBlock {base with stack := .k (.fn .call)::s.stack} statements e
  let next := ({entered with stack := .s (.scope [])::.k (.fn .call)::s.stack}.push
    (.s (.block [assign,unregisterStmt,freeStmt] e))).go (.ex guard e)
  (StatementAction.ifTest (.priv .this flag false) (.ret none) none).advance next e

def liveAfter {S : Type} (live : Nat → Prop) (s : St S) (env : Env) (home : Val) (owner : Nat) : Nat → Prop :=
  CellsLive (ClosureLive live s.next false home function)
    (closureState s function env false home (.obj owner) [] .call).next []

private theorem closure_room {S : Type} (s : St S) (env : Env) (home receiver : Val) (args : List Val) :
    (closureState s function env false home receiver args .call).next ≤ s.next+2 := by
  cases home <;> first
    | change s.next+1 ≤ s.next+2; omega
    | change s.next+1+1 ≤ s.next+2; omega

theorem one_step (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

/-- The first four original disposal transitions create the receiver/home
cells and evaluate the actual pinned source guard, with arbitrary callers. -/
theorem entry_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (method owner : Nat) (object : Obj) (env : Env) (home : Val)
    (control : source.ctl = .call (.obj method) (.obj owner) [])
    (objectRead : source.heap.get method = some (.obj object))
    (closure : object.kind = .fn (.closure function env false home))
    (controlNote : notes.runtime.control = callNote (.obj method) (.obj owner) [])
    (sourceBound : source.next+2 ≤ 2^64) (targetBound : target.next+2 ≤ 2^64) :
    ∃ result,
      runC F 4 source C₀ = some (entryState source env home owner,C₀) ∧
      runC F 4 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R
        (liveAfter live source env home owner) framed before after old old' (entryState source env home owner) result ∧
      RetainedInventory (notes.withRuntime (entryRuntime notes.runtime
        (closureEnvironment source function env false home (.obj owner)) source.next owner))
        ν₀ ν C₀ C R (liveAfter live source env home owner) (entryState source env home owner) result ∧
      result.ffi = target.ffi ∧ result.next ≤ target.next+2 ∧
      (∀ a, a < target.next → result.heap.get a = target.heap.get a) := by
  let e := closureEnvironment source function env false home (.obj owner)
  obtain ⟨targetHome,targetThis,targetArgs,left1,right1,h1,inv1⟩ := inventory.closure_step F FR notes ν₀ ν C₀ C R
    live framed before after old old' source target h method object function env false home (.obj owner) []
    (.obj method) (.obj owner) [] control objectRead closure controlNote sourceBound targetBound
  have sourceRoom : (closureState source function env false home (.obj owner) [] .call).next +
      (blockNames statements).length ≤ 2^64 := by
    change (closureState source function env false home (.obj owner) [] .call).next+0 ≤ 2^64
    exact Nat.le_trans (by simpa only [Nat.add_zero] using closure_room source env home (.obj owner) []) sourceBound
  have targetRoom : (closureState target function (R.env env) false targetHome targetThis targetArgs .call).next +
      (blockNames statements).length ≤ 2^64 := by
    change (closureState target function (R.env env) false targetHome targetThis targetArgs .call).next+0 ≤ 2^64
    exact Nat.le_trans (by simpa only [Nat.add_zero] using closure_room target (R.env env) targetHome targetThis targetArgs) targetBound
  obtain ⟨frames,left2,right2,h2,inv2⟩ := inv1.parameter_body_step h1 .undef none [] statements [] e
    (.k (.fn .call)::source.stack) (parameterFrameNote function [] [] e) (callBoundaryNote::notes.runtime.stack)
    rfl (closureState_stack source function env false home (.obj owner) [] .call) rfl rfl sourceRoom targetRoom
  obtain ⟨s3,left3,right3,h3,runtime3⟩ := inv2.runtime.block_next_step F FR _ ν₀ ν C₀ C R _ framed before after old old'
    _ _ h2 .undef guard [assign,unregisterStmt,freeStmt] e
    (.s (.scope [])::.k (.fn .call)::source.stack) (blockFrameNote statements e)
    (emptyScopeNote::callBoundaryNote::notes.runtime.stack) rfl rfl rfl
  have pure3 := PureRuntimeCase.blockNext h2 .undef guard [assign,unregisterStmt,freeStmt] e
    (.s (.scope [])::.k (.fn .call)::source.stack) rfl rfl
  have effects3 := pure3.effects left3 right3
  have inv3 := inv2.pure_step runtime3 pure3 left3 right3 (.refl C₀) (.refl C)
  obtain ⟨left4,right4,h4,runtime4⟩ := runtime3.statement_step F FR _ ν₀ ν C₀ C R _ framed before after old old'
    _ _ h3 (.ifTest (.priv .this flag false) (.ret none) none) e rfl
  have inv4 := inv3.heap_step runtime4 rfl rfl (.refl C₀) (.refl C)
  have source1 := one_step F _ _ C₀ (by rw [control]; rfl) left1
  have target1 := one_step F _ _ C (h.control.isHalt_eq.trans (by rw [control]; rfl)) right1
  have source2 := one_step F _ _ C₀ rfl left2
  have target2 := one_step F _ _ C (h1.control.isHalt_eq.trans rfl) right2
  have source3 := one_step F _ _ C₀ rfl left3
  have target3 := one_step F _ _ C (h2.control.isHalt_eq.trans rfl) right3
  have source4 := one_step F _ _ C₀ rfl left4
  have target4 := one_step F _ _ C (h3.control.isHalt_eq.trans rfl) right4
  refine ⟨_,runC_join F (runC_join F (runC_join F source1 source2) source3) source4,
    runC_join F (runC_join F (runC_join F target1 target2) target3) target4,h4,?_,?_,?_,?_⟩
  · exact inv4
  · have initial : (closureState target function (R.env env) false targetHome targetThis targetArgs .call).ffi = target.ffi := by
      cases targetHome <;> rfl
    exact effects3.2.native.trans initial
  · have room : (closureState target function (R.env env) false targetHome targetThis targetArgs .call).next ≤ target.next+2 := by
      cases targetHome <;> first
        | change target.next+1 ≤ target.next+2; omega
        | change target.next+1+1 ≤ target.next+2; omega
    exact Nat.le_trans (Nat.le_of_eq effects3.2.next) room
  · intro a below
    exact (congrArg (fun heap : PTrie HObj => heap.get a) effects3.2.heap).trans
      (closureState_heap_below F target function (R.env env) false targetHome targetThis targetArgs .call targetBound a below)

end Host.Ts.Owned.Annotated.Dispose
