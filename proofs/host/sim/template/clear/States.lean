import host.sim.template.base.S
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! Case `CLEAR` of the loop template: one iteration from `Tpl.Base.s0`, natively
chosen boundaries every 10 000 steps (`host.sim.template.Build`). -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_case CLEAR from Base : "CLEAR"

end Host.Load.Run.Tpl
