import host.sim.compose.a4b.PLD1Full
import host.sim.compose.a4b.PLEntryFresh
import host.sim.template.a4pre_d1_body.D4
import host.sim.compose.a4b.PLD1Kn_0
import host.sim.compose.a4b.PLD1Kn_1
import host.sim.compose.a4b.PLD1Kn_2
import host.sim.compose.a4b.PLD1Kn_3
import host.sim.compose.a4b.PLD1Kn_4
import host.sim.compose.a4b.PLD1Kn_5
import host.sim.compose.a4b.PLD1Kn_6
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.nnum_end : (((((((List.range PRE_pl_entry.S0.tab.length).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500 = []
theorem PLD1.nnum : (List.range PRE_pl_entry.S0.tab.length).all PLD1.numAt = true :=
  all_take_drop 500 PLD1.nnum_0 (all_take_drop 500 PLD1.nnum_1 (all_take_drop 500 PLD1.nnum_2 (all_take_drop 500 PLD1.nnum_3 (all_take_drop 500 PLD1.nnum_4 (all_take_drop 500 PLD1.nnum_5 (all_take_drop 500 PLD1.nnum_6 (all_of_nil PLD1.nnum_end)))))))
theorem PLD1.num : checkNum PLWalkD1.R.data.map PLD1.θ ⟨PRE_pl_entry.S0.tab, []⟩ ⟨D1Body.S155.tab, []⟩ = true := PLD1.nnum
kernel_rfl PLD1.fixP : PLWalkD1.R.data.a 2665 = 2665
kernel_rfl PLD1.fixC : PLWalkD1.R.data.a D1Frames.chunk = D1Frames.chunk
kernel_rfl PLD1.fixB : PLWalkD1.R.data.a D1Frames.buffer = D1Frames.buffer
kernel_rfl PLD1.fixV : PLWalkD1.R.data.a D1Frames.view = D1Frames.view

end Host.Load.Run.Tpl
