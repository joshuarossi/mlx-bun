import host.sim.compose.a4b.PLT4L8Na
import host.sim.template.a4pre_plx4_L8_common.H0
import host.load.boot.World
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT4L8.numAll : numPadB PLTW4L8.R.data PLT4L8.θ PRE_pl_tail.S0.tab PRE_plx4_L8_common.S1.tab PLT4L8.numAt = true
theorem PLT4L8.num : checkNum PLTW4L8.R.data.map PLT4L8.θ ⟨PRE_pl_tail.S0.tab, []⟩ ⟨PLT4L8.tabP, []⟩ = true :=
  checkNum_pad PLT4L8.numAll (fun i e he h => by
    unfold PLT4L8.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PLT4L8.fixP : PLTW4L8.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
