import host.sim.template.growth.H4
import host.sim.template.RestartCmd
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The restart map of case `GROWTH` (template `Base.s0` to the next readback cut
`GROWTH.s153`), chosen natively; all its properties are kernel checks. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_restart GROWTH.R : Base, GROWTH 153

/-- The cross-iteration map. -/
noncomputable abbrev GROWTH.σ : Map := GROWTH.R.data.map
/-- The next iteration's template variables. -/
noncomputable def GROWTH.θ : Nat → SymE := thetaOf GROWTH.R.theta
/-- The end server with the next iteration's token reference appended (`var 17`, the token
the next readback returns); `GROWTH.σ` sends the template's token reference to it. -/
noncomputable def GROWTH.S1' : SSrv := ⟨GROWTH.S153.tab ++ [.var 17], GROWTH.S153.oracle⟩

end Host.Load.Run.Tpl
