import host.sim.compose.a4b.PF4L8Na
import host.sim.template.a4pre_first_tail_x4_L8_r0_suffix.m.B3
import host.load.boot.World
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF4L8.numAll : numPadB PFW4L8.R.data PF4L8.θ PRE_pf_x4_L8.S0.tab PRE_first_tail_x4_L8_r0_suffix.S8.tab PF4L8.numAt = true
theorem PF4L8.num : checkNum PFW4L8.R.data.map PF4L8.θ ⟨PRE_pf_x4_L8.S0.tab, []⟩ ⟨PF4L8.tabP, []⟩ = true :=
  checkNum_pad PF4L8.numAll (fun i e he h => by
    unfold PF4L8.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PF4L8.fixP : PFW4L8.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
