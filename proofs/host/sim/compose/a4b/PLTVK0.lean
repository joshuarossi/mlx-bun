import host.sim.compose.a4b.PLTVNa
import host.sim.template.a4pre_plvw_common.H0
import host.load.boot.World
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.numAll : numPadB PLTVW.R.data PLTV.θ PRE_pl_tail.S0.tab PRE_plvw_common.S1.tab PLTV.numAt = true
theorem PLTV.num : checkNum PLTVW.R.data.map PLTV.θ ⟨PRE_pl_tail.S0.tab, []⟩ ⟨PLTV.tabP, []⟩ = true :=
  checkNum_pad PLTV.numAll (fun i e he h => by
    unfold PLTV.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PLTV.fixP : PLTVW.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
