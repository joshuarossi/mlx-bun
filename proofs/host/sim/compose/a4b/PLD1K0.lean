import host.sim.compose.a4b.PLD1Full
import host.sim.compose.a4b.PLEntryFresh
import host.sim.template.a4pre_d1_body.D4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

noncomputable def PLD1.θ : Nat → SymE := thetaOf PLWalkD1.R.theta
kernel_rfl PLD1.num : checkNum PLWalkD1.R.data.map PLD1.θ ⟨PRE_pl_entry.S0.tab, []⟩ ⟨D1Body.S155.tab, []⟩ = true
kernel_rfl PLD1.fixP : PLWalkD1.R.data.a 2665 = 2665
kernel_rfl PLD1.fixC : PLWalkD1.R.data.a D1Frames.chunk = D1Frames.chunk
kernel_rfl PLD1.fixB : PLWalkD1.R.data.a D1Frames.buffer = D1Frames.buffer
kernel_rfl PLD1.fixV : PLWalkD1.R.data.a D1Frames.view = D1Frames.view

end Host.Load.Run.Tpl
