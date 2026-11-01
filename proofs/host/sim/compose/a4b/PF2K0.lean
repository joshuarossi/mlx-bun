import host.sim.compose.a4b.PF2Na
import host.sim.template.a4pre_first_tail_x2_r0_suffix.m.B0
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF2.numAll : numPadB PFW2.R.data PF2.θ PRE_pf_vw.S0.tab PRE_first_tail_x2_r0_suffix.S8.tab PF2.numAt = true
theorem PF2.num : checkNum PFW2.R.data.map PF2.θ ⟨PRE_pf_vw.S0.tab, []⟩ ⟨PF2.tabP, []⟩ = true :=
  checkNum_pad PF2.numAll (fun i e he h => by
    unfold PF2.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PF2.fixP : PFW2.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
