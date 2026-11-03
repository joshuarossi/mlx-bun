import host.sim.compose.a4b.PL4L8Na
import host.sim.template.a4pre_fd_x4_L8_r0_body.m.B00
import host.load.boot.World
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL4L8.numAll : numPadB PLW4L8.R.data PL4L8.θ PRE_plx4_L8_entry.S0.tab PRE_fd_x4_L8_r0_body.S451.tab PL4L8.numAt = true
theorem PL4L8.num : checkNum PLW4L8.R.data.map PL4L8.θ ⟨PRE_plx4_L8_entry.S0.tab, []⟩ ⟨PL4L8.tabP, []⟩ = true :=
  checkNum_pad PL4L8.numAll (fun i e he h => by
    unfold PL4L8.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PL4L8.fixP : PLW4L8.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
