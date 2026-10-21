import host.sim.template.fill.H4
import host.sim.template.RestartCmd
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The restart map of case `FILL` (template `Base.s0` to the next readback cut
`FILL.s150`), chosen natively; all its properties are kernel checks. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_restart FILL.R : Base, FILL 150

/-- The cross-iteration map. -/
noncomputable abbrev FILL.σ : Map := FILL.R.data.map
/-- The next iteration's template variables. -/
noncomputable def FILL.θ : Nat → SymE := thetaOf FILL.R.theta
/-- The end server with the next iteration's token reference appended (`var 17`, the token
the next readback returns); `FILL.σ` sends the template's token reference to it. -/
noncomputable def FILL.S1' : SSrv := ⟨FILL.S150.tab ++ [.var 17], FILL.S150.oracle⟩

end Host.Load.Run.Tpl
