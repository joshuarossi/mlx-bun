import host.ts.RenameClosureEntryFields
import host.ts.RenameMapIndexEffects
import host.ts.RenameParametricHoist

set_option Elab.async false
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated
open Parametric

def twoParameterFunction (functionName : Option Name) (firstName secondName : Name)
    (body : List Stmt) : Func :=
  .mk functionName [.id firstName, .id secondName] none (.block body) false false []

theorem twoParameter_param_length (functionName : Option Name) (firstName secondName : Name)
    (body : List Stmt) :
    paramNames (twoParameterFunction functionName firstName secondName body) = [firstName, secondName] := by
  rfl

theorem twoParameter_environment {S : Type} (s : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver : Val) :
    closureEnvironment s (twoParameterFunction functionName firstName secondName body)
      env false .undef receiver =
      (secondName,s.next+2)::(firstName,s.next+1)::(nThis,s.next)::env := rfl

theorem twoParameter_next {S : Type} (s : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val) :
    (closureState s (twoParameterFunction functionName firstName secondName body) env false .undef
      receiver [firstValue,secondValue] .call).next = s.next+3 := by
  change s.next+1+1+1 = s.next+3
  omega

theorem twoParameter_heap {S : Type} (s : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val) :
    (closureState s (twoParameterFunction functionName firstName secondName body) env false .undef
      receiver [firstValue,secondValue] .call).heap =
      ((s.heap.set s.next (.cell (some receiver))).set (s.next+1) (.cell none)).set (s.next+2) (.cell none) := rfl

theorem twoParameter_uninitialized_first {S : Type} (s : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val)
    (bound : s.next+2 < 2^64) :
    (closureState s (twoParameterFunction functionName firstName secondName body) env false .undef
      receiver [firstValue,secondValue] .call).heap.get (s.next+1) = some (.cell none) := by
  rw [twoParameter_heap,PTrie.get_set_u64 _ _ _ (by omega),
    ite_eq_right (by omega : (s.next+1 : Nat) ≠ s.next+2),
    PTrie.get_set_u64 _ _ _ (by omega)]
  simp

theorem twoParameter_uninitialized_second {S : Type} (s : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val)
    (bound : s.next+2 < 2^64) :
    (closureState s (twoParameterFunction functionName firstName secondName body) env false .undef
      receiver [firstValue,secondValue] .call).heap.get (s.next+2) = some (.cell none) := by
  rw [twoParameter_heap,PTrie.get_set_u64 _ _ _ bound]
  simp only [ite_true]

theorem twoParameter_lookup_first {S : Type} (s : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver : Val)
    (distinct : nameEq firstName secondName = false) :
    lookupEnv firstName (closureEnvironment s (twoParameterFunction functionName firstName secondName body)
      env false .undef receiver) = some (s.next+1) := by
  rw [twoParameter_environment,
    lookupEnv_skip firstName secondName (s.next+2) ((firstName,s.next+1)::(nThis,s.next)::env) distinct]
  change brec (Nat.beq (pack firstName) (pack firstName)) _ _ = _
  rw [Nat.beq_refl]

theorem twoParameter_lookup_second {S : Type} (s : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver : Val) :
    lookupEnv secondName (closureEnvironment s (twoParameterFunction functionName firstName secondName body)
      env false .undef receiver) = some (s.next+2) := by
  rw [twoParameter_environment]
  change brec (Nat.beq (pack secondName) (pack secondName)) _ _ = _
  rw [Nat.beq_refl]

theorem twoParameter_heap_below {S : Type} (s : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val)
    (bound : s.next+2 < 2^64) (a : Nat) (below : a < s.next) :
    (closureState s (twoParameterFunction functionName firstName secondName body) env false .undef
      receiver [firstValue,secondValue] .call).heap.get a = s.heap.get a := by
  rw [twoParameter_heap,
    PTrie.get_set_u64 _ _ _ (by omega),ite_eq_right (by omega : a ≠ s.next+2),
    PTrie.get_set_u64 _ _ _ (by omega),ite_eq_right (by omega : a ≠ s.next+1),
    PTrie.get_set_u64 _ _ _ (by omega),ite_eq_right (Nat.ne_of_lt below)]

theorem allocCells_aux {S : Type} (s : St S) (names : List Name) (env : Env) :
    (allocCells s names env).2.aux = s.aux := by
  induction names generalizing s env with
  | nil => rfl
  | cons _ _ ih => simp only [allocCells,ih,St.alloc]

theorem allocCells_ffi {S : Type} (s : St S) (names : List Name) (env : Env) :
    (allocCells s names env).2.ffi = s.ffi := by
  simp only [St.ffi,allocCells_aux]

theorem closureStart_aux {S : Type} (s : St S) (env : Env) (arrow : Bool) (home this : Val) :
    (closureStart s env arrow home this).2.aux = s.aux := by
  cases arrow <;> cases home <;> rfl

theorem closureStart_ffi {S : Type} (s : St S) (env : Env) (arrow : Bool) (home this : Val) :
    (closureStart s env arrow home this).2.ffi = s.ffi := by
  simp only [St.ffi,closureStart_aux]

theorem closureState_aux {S : Type} (s : St S) (f : Func) (env : Env) (arrow : Bool) (home this : Val)
    (args : List Val) (boundary : Boundary) :
    (closureState s f env arrow home this args boundary).aux = s.aux := by
  simp only [closureState,parameterContinuation,St.push,St.ret]
  rw [allocCells_aux,closureStart_aux]

theorem closureState_ffi {S : Type} (s : St S) (f : Func) (env : Env) (arrow : Bool) (home this : Val)
    (args : List Val) (boundary : Boundary) :
    (closureState s f env arrow home this args boundary).ffi = s.ffi := by
  simp only [St.ffi,closureState_aux]

theorem enterBlock_next {S : Type} (s : St S) (ss : List Stmt) (env : Env)
    (inert : noInitFunctions ss = true) :
    (enterBlock s ss env).next = s.next + (blockNames ss).length := by
  have hoistNext : (hoist s ss env).2.next = s.next + (blockNames ss).length := by
    rw [hoist_inert_eq s env ss inert]
    exact allocCells_next s (blockNames ss) env
  simp only [enterBlock,St.push,St.ret,hoistNext]

theorem enterBlock_aux {S : Type} (s : St S) (ss : List Stmt) (env : Env)
    (inert : noInitFunctions ss = true) : (enterBlock s ss env).aux = s.aux := by
  have hoistAux : (hoist s ss env).2.aux = s.aux := by
    rw [hoist_inert_eq s env ss inert]
    exact allocCells_aux s (blockNames ss) env
  simp only [enterBlock,St.push,St.ret,hoistAux]

theorem enterBlock_ffi {S : Type} (s : St S) (ss : List Stmt) (env : Env)
    (inert : noInitFunctions ss = true) : (enterBlock s ss env).ffi = s.ffi := by
  simp only [St.ffi,enterBlock_aux _ _ _ inert]

theorem with_stack_eq {S : Type} {s t : St S} {frames : List Frame}
    (heap : s.heap = t.heap) (next : s.next = t.next) (control : s.ctl = t.ctl) (aux : s.aux = t.aux) :
    {s with stack := frames} = {t with stack := frames} := by
  cases s; cases t
  cases heap; cases next; cases control; cases aux
  rfl

end Host.Ts.Owned.Annotated
