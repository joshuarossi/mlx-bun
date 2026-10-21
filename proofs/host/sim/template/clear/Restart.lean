import host.sim.template.clear.H4
import host.sim.template.RestartCmd
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The restart map of case `CLEAR` (template `Base.s0` to the next readback cut
`CLEAR.s150`), chosen natively; all its properties are kernel checks. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_restart CLEAR.R : Base, CLEAR 150

/-- The cross-iteration map. -/
noncomputable abbrev CLEAR.σ : Map := CLEAR.R.data.map
/-- The next iteration's template variables. -/
noncomputable def CLEAR.θ : Nat → SymE := thetaOf CLEAR.R.theta
/-- The end server with the next iteration's token reference appended (`var 17`, the token
the next readback returns); `CLEAR.σ` sends the template's token reference to it. -/
noncomputable def CLEAR.S1' : SSrv := ⟨CLEAR.S150.tab ++ [.var 17], CLEAR.S150.oracle⟩

end Host.Load.Run.Tpl
