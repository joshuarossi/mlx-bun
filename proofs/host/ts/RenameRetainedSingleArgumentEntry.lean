import host.ts.RenameSingleParameterEntryFields
import host.ts.RenameRetainedClosure

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def singleArgumentEntry {S : Type} (source : St S) (functionName : Option Name) (parameterName : Name)
    (body : List Stmt) (env : Env) (receiver value : Val) : St S :=
  let fn := singleParameterFunction functionName parameterName body
  let entered := closureState source fn env false .undef receiver [value] .call
  let base := {(entered.setCell (source.next+1) value).ret .undef with stack := .k (.fn .call)::source.stack}
  enterBlock base body (closureEnvironment source fn env false .undef receiver)

def singleArgumentEntryNotes {S : Type} (notes : RetainedNotes) (source : St S) (functionName : Option Name)
    (parameterName : Name) (body : List Stmt) (env : Env) (receiver value : Val) (role thisRole : Value) : RetainedNotes :=
  let fn := singleParameterFunction functionName parameterName body
  let e := closureEnvironment source fn env false .undef receiver
  let entered := closureState source fn env false .undef receiver [value] .call
  let base := {(entered.setCell (source.next+1) value).ret .undef with stack := .k (.fn .call)::source.stack}
  let next := notes.withRuntime (notes.runtime.closure fn [role] e false source.next thisRole)
  singleParameterBodyNotes next functionName parameterName body e (hoist base body e).1
    (source.next+1) role (callBoundaryNote::notes.runtime.stack)

/-- Execute an original single-argument closure and its real parameter/body
scheduler. All four transitions allocate and initialize their own cells,
preserving every retained family for arbitrary heaps, bodies and callers. -/
theorem RetainedInventory.single_argument_entry
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (address : Nat) (function : Obj) (functionName : Option Name) (parameterName : Name)
    (body : List Stmt) (env : Env) (receiver value : Val) (role fnRole thisRole : Value)
    (control : source.ctl = .call (.obj address) receiver [value])
    (read : source.heap.get address = some (.obj function))
    (kind : function.kind = .fn (.closure (singleParameterFunction functionName parameterName body) env false .undef))
    (controlNote : notes.runtime.control = callNote fnRole thisRole [role])
    (inert : noInitFunctions body = true)
    (sourceBound : source.next+3+(blockNames body).length ≤ 2^64)
    (targetBound : target.next+3+(blockNames body).length ≤ 2^64) :
    let fn := singleParameterFunction functionName parameterName body
    let endLive := CellsLive (ClosureLive live source.next false .undef fn) (source.next+2) (blockNames body)
    ∃ result,
      runC F 4 source C₀ = some (singleArgumentEntry source functionName parameterName body env receiver value,C₀) ∧
      runC F 4 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R endLive framed before after old old'
        (singleArgumentEntry source functionName parameterName body env receiver value) result ∧
      RetainedInventory (singleArgumentEntryNotes notes source functionName parameterName body env receiver value role thisRole)
        ν₀ ν C₀ C R endLive (singleArgumentEntry source functionName parameterName body env receiver value) result := by
  dsimp only
  let fn := singleParameterFunction functionName parameterName body
  let entered := closureState source fn env false .undef receiver [value] .call
  let e := closureEnvironment source fn env false .undef receiver
  have sourceClosureBound : source.next+2+(paramNames fn).length ≤ 2^64 := by
    change source.next+2+1 ≤ 2^64
    omega
  have targetClosureBound : target.next+2+(paramNames fn).length ≤ 2^64 := by
    change target.next+2+1 ≤ 2^64
    omega
  obtain ⟨targetHome,targetThis,targetArgs,left1,right1,h1,inv1⟩ := inventory.closure_step F FR notes ν₀ ν C₀ C R live framed
    before after old old' source target h address function fn env false .undef receiver [value] fnRole thisRole [role]
    control read kind controlNote sourceClosureBound targetClosureBound
  have sourceNext : entered.next = source.next+2 := singleParameter_next source functionName parameterName body env receiver value
  have targetNext : (closureState target fn (R.env env) false targetHome targetThis targetArgs .call).next = target.next+2 := by
    have first := h1.heap.fresh 0
    have second := h.heap.fresh 2
    simp only [Nat.add_zero,sourceNext] at first
    exact first.symm.trans second
  obtain ⟨result,left3,right3,post,retained⟩ := inv1.single_parameter_body h1 functionName parameterName body e
    (.k (.fn .call)::source.stack) (source.next+1) value role (callBoundaryNote::notes.runtime.stack)
    rfl (closureState_stack source fn env false .undef receiver [value] .call)
    (singleParameter_lookup source functionName parameterName body env receiver)
    (singleParameter_uninitialized source functionName parameterName body env receiver value (by omega))
    rfl inert (by change entered.next+(blockNames body).length ≤ 2^64; rw [sourceNext]; omega)
    (by rw [targetNext]; omega)
  have sourceRun := runC_cons F 3 source entered _ C₀ C₀ C₀ (by rw [control]; rfl) left1 left3
  have targetRun := runC_cons F 3 target _ _ C C C (h.control.isHalt_eq.trans (by rw [control]; rfl)) right1 right3
  rw [sourceNext] at post retained
  exact ⟨result,sourceRun,targetRun,post,retained⟩

end Host.Ts.Owned.Annotated
