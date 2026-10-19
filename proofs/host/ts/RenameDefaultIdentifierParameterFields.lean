import host.ts.RenameRetainedStores
import host.ts.RenameParametricDefaults
import host.ts.RenameRuntimeParameterNotes

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Ts.Owned.Annotated
open Parametric

/-- The source endpoint after an identifier default has initialized its
original parameter cell. `args` is the original argument tail before the
missing parameter was removed by the default scheduler. -/
def defaultIdentifierParameterReached {S : Type} (source : St S) (parameterAddress : Nat)
    (defaultValue : Val) (fn : Func) (remainingParams : List Pat) (args : List Val)
    (env : Env) (callerFrames : List Frame) : St S :=
  St.ret (St.setCell {source with stack := .k (.params fn remainingParams args.tail env)::callerFrames}
    parameterAddress defaultValue) .undef

/-- The four source transitions leave the caller notes in place, retain the
remaining parameter roles, and transfer the default cell's role to the
initialized parameter cell. -/
def defaultIdentifierParameterNotes (notes : RetainedNotes) (fn : Func)
    (remainingParams : List Pat) (roles : List Value) (env : Env) (tailNotes : List Tree)
    (parameterAddress : Nat) (defaultRole : Value) : RetainedNotes :=
  notes.withRuntime ⟨returnNote .undef,
    parameterFrameNote fn remainingParams roles.tail env::tailNotes,
    notes.runtime.cells.write parameterAddress defaultRole⟩

end Host.Ts.Owned.Annotated
