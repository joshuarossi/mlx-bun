import host.sim.compose.a4b.PLVNa
import host.sim.template.a4pre_fd_vw_r0_body.m.B00
import host.load.boot.World
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLV.numAll : numPadB PLVW.R.data PLV.θ PRE_plvw_entry.S0.tab PRE_fd_vw_r0_body.S900.tab PLV.numAt = true
theorem PLV.num : checkNum PLVW.R.data.map PLV.θ ⟨PRE_plvw_entry.S0.tab, []⟩ ⟨PLV.tabP, []⟩ = true :=
  checkNum_pad PLV.numAll (fun i e he h => by
    unfold PLV.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PLV.fixP : PLVW.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
