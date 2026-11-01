import host.sim.compose.a4b.PLD1Na
import host.sim.template.a4pre_d1_body.D4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.nnum_6 : ((((((((List.range PRE_pl_entry.S0.tab.length).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500).take 500).all PLD1.numAt = true

end Host.Load.Run.Tpl
