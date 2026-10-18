import Lean

namespace Host.Ts
open Lean Elab Tactic Meta

/-- Submit the reflexivity proof directly to the kernel. This avoids duplicate
elaborator conversion on large closed state expressions. A false equation is
rejected by the kernel exactly as any other ill-typed proof term is. -/
elab "host_kernel_rfl" : tactic => do
  let goal ← getMainGoal
  let type ← instantiateMVars (← goal.getType)
  unless type.isAppOfArity ``Eq 3 do throwError "host_kernel_rfl: equality expected"
  goal.assign (← mkEqRefl type.getAppArgs[1]!)
  replaceMainGoal []

end Host.Ts
