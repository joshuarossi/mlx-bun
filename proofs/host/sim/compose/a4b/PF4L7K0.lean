import host.sim.compose.a4b.PF4L7Na
import host.sim.template.a4pre_first_tail_x4_L7_r0_suffix.m.B3
import host.load.boot.World
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF4L7.numAll : numPadB PFW4L7.R.data PF4L7.θ PRE_pf_x4_L7.S0.tab PRE_first_tail_x4_L7_r0_suffix.S8.tab PF4L7.numAt = true
theorem PF4L7.num : checkNum PFW4L7.R.data.map PF4L7.θ ⟨PRE_pf_x4_L7.S0.tab, []⟩ ⟨PF4L7.tabP, []⟩ = true :=
  checkNum_pad PF4L7.numAll (fun i e he h => by
    unfold PF4L7.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PF4L7.fixP : PFW4L7.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
