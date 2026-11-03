import host.sim.compose.a4b.PF0Na
import host.sim.template.a4pre_first_tail_x0_r0_suffix.m.B3
import host.load.boot.World
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF0.numAll : numPadB PFW0.R.data PF0.θ PRE_pf_x0.S0.tab PRE_first_tail_x0_r0_suffix.S8.tab PF0.numAt = true
theorem PF0.num : checkNum PFW0.R.data.map PF0.θ ⟨PRE_pf_x0.S0.tab, []⟩ ⟨PF0.tabP, []⟩ = true :=
  checkNum_pad PF0.numAll (fun i e he h => by
    unfold PF0.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PF0.fixP : PFW0.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
