import host.sim.compose.a4b.PF4L9Na
import host.sim.template.a4pre_first_tail_x4_L9_r0_suffix.m.B3
import host.load.boot.World
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF4L9.numAll : numPadB PFW4L9.R.data PF4L9.θ PRE_pf_x4_L9.S0.tab PRE_first_tail_x4_L9_r0_suffix.S8.tab PF4L9.numAt = true
theorem PF4L9.num : checkNum PFW4L9.R.data.map PF4L9.θ ⟨PRE_pf_x4_L9.S0.tab, []⟩ ⟨PF4L9.tabP, []⟩ = true :=
  checkNum_pad PF4L9.numAll (fun i e he h => by
    unfold PF4L9.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PF4L9.fixP : PFW4L9.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
