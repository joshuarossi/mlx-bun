import host.ts.RenameRetainedSingleParameterBody
import host.ts.RenameClosureEntryFields

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

theorem singleParameter_environment {S : Type} (s : St S) (functionName : Option Name) (parameterName : Name)
    (body : List Stmt) (env : Env) (receiver : Val) :
    closureEnvironment s (singleParameterFunction functionName parameterName body) env false .undef receiver =
      (parameterName,s.next+1)::(nThis,s.next)::env := rfl

theorem singleParameter_next {S : Type} (s : St S) (functionName : Option Name) (parameterName : Name)
    (body : List Stmt) (env : Env) (receiver value : Val) :
    (closureState s (singleParameterFunction functionName parameterName body) env false .undef receiver [value] .call).next = s.next+2 := by
  change s.next+1+1 = s.next+2
  omega

theorem singleParameter_heap {S : Type} (s : St S) (functionName : Option Name) (parameterName : Name)
    (body : List Stmt) (env : Env) (receiver value : Val) :
    (closureState s (singleParameterFunction functionName parameterName body) env false .undef receiver [value] .call).heap =
      (s.heap.set s.next (.cell (some receiver))).set (s.next+1) (.cell none) := rfl

/-- The real parameter allocator installs the uninitialized cell at start+1. -/
theorem singleParameter_uninitialized {S : Type} (s : St S) (functionName : Option Name) (parameterName : Name)
    (body : List Stmt) (env : Env) (receiver value : Val) (bound : s.next+2 ≤ 2^64) :
    (closureState s (singleParameterFunction functionName parameterName body) env false .undef receiver [value] .call).heap.get (s.next+1) =
      some (.cell none) := by
  rw [singleParameter_heap,PTrie.get_set_u64 _ _ _ (by omega)]
  simp only [ite_true]

/-- Use reflexivity of the packed-name comparison before evaluating its code. -/
theorem singleParameter_lookup {S : Type} (s : St S) (functionName : Option Name) (parameterName : Name)
    (body : List Stmt) (env : Env) (receiver : Val) :
    lookupEnv parameterName (closureEnvironment s (singleParameterFunction functionName parameterName body) env false .undef receiver) =
      some (s.next+1) := by
  rw [singleParameter_environment]
  change brec (Nat.beq (pack parameterName) (pack parameterName)) _ _ = _
  rw [Nat.beq_refl]

/-- Only the new parameter/receiver names shadow captured lexical bindings. -/
theorem singleParameter_lookup_other {S : Type} (s : St S) (functionName : Option Name) (parameterName query : Name)
    (body : List Stmt) (env : Env) (receiver : Val)
    (notParameter : nameEq query parameterName = false) (notReceiver : nameEq query nThis = false) :
    lookupEnv query (closureEnvironment s (singleParameterFunction functionName parameterName body) env false .undef receiver) = lookupEnv query env := by
  rw [singleParameter_environment]
  change Nat.beq (pack query) (pack parameterName) = false at notParameter
  change Nat.beq (pack query) (pack nThis) = false at notReceiver
  change brec (Nat.beq (pack query) (pack parameterName)) _ (brec (Nat.beq (pack query) (pack nThis)) _ _) = _
  rw [notParameter,notReceiver]
  rfl

end Host.Ts.Owned.Annotated
