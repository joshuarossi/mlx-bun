import host.load.boot.World
import host.sim.compose.a4b.PLTNa
import host.sim.template.a4pre_pl_common.H0
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT.numAll : numPadB PLTP.R.data PLT.θ PRE_pl_tail.S0.tab PRE_pl_common.S4.tab PLT.numAt = true
theorem PLT.num : checkNum PLTP.R.data.map PLT.θ ⟨PRE_pl_tail.S0.tab, []⟩ ⟨PLT.tabP, []⟩ = true :=
  checkNum_pad PLT.numAll (fun i e he h => by
    unfold PLT.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PLT.fixP : PLTP.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
