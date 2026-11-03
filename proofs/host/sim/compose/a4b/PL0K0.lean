import host.sim.compose.a4b.PL0Na
import host.sim.template.a4pre_fd_x0_r0_body.m.B00
import host.load.boot.World
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL0.numAll : numPadB PLW0.R.data PL0.θ PRE_plx0_entry.S0.tab PRE_fd_x0_r0_body.S447.tab PL0.numAt = true
theorem PL0.num : checkNum PLW0.R.data.map PL0.θ ⟨PRE_plx0_entry.S0.tab, []⟩ ⟨PL0.tabP, []⟩ = true :=
  checkNum_pad PL0.numAll (fun i e he h => by
    unfold PL0.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PL0.fixP : PLW0.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
