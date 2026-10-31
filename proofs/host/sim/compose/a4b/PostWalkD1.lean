import host.sim.template.a4pre_pl_entry.S
import host.sim.template.a4pre_d1_body.H4
import host.sim.template.RestartCmd
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
/-! The map from the L-general POST entry into the singleton forward's return, chosen natively. -/
tpl_restart D1Body.PLR : PRE_pl_entry, D1Body 155 (world := full)
end Host.Load.Run.Tpl
