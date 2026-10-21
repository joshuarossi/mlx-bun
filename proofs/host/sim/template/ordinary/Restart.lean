import host.sim.template.ordinary.H4
import host.sim.template.RestartCmd
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The restart map of case `ORDINARY` (template `Base.s0` to the next readback cut
`ORDINARY.s150`), chosen natively; all its properties are kernel checks. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_restart ORDINARY.R : Base, ORDINARY 150

/-- The cross-iteration map. -/
noncomputable abbrev ORDINARY.σ : Map := ORDINARY.R.data.map
/-- The next iteration's template variables. -/
noncomputable def ORDINARY.θ : Nat → SymE := thetaOf ORDINARY.R.theta
/-- The end server with the next iteration's token reference appended (`var 17`, the token
the next readback returns); `ORDINARY.σ` sends the template's token reference to it. -/
noncomputable def ORDINARY.S1' : SSrv := ⟨ORDINARY.S150.tab ++ [.var 17], ORDINARY.S150.oracle⟩

end Host.Load.Run.Tpl
