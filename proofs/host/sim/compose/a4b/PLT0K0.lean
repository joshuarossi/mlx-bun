import host.sim.compose.a4b.PLT0Na
import host.sim.template.a4pre_plx0_common.H0
import host.load.boot.World
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT0.numAll : numPadB PLTW0.R.data PLT0.θ PRE_pl_tail.S0.tab PRE_plx0_common.S1.tab PLT0.numAt = true
theorem PLT0.num : checkNum PLTW0.R.data.map PLT0.θ ⟨PRE_pl_tail.S0.tab, []⟩ ⟨PLT0.tabP, []⟩ = true :=
  checkNum_pad PLT0.numAll (fun i e he h => by
    unfold PLT0.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PLT0.fixP : PLTW0.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
