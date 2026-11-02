import host.sim.compose.a4b.PF8Na
import host.sim.template.a4pre_first_tail_x8_r0_suffix.m.B0
import host.load.boot.World
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF8.numAll : numPadB PFW8.R.data PF8.θ PRE_pf_vw.S0.tab PRE_first_tail_x8_r0_suffix.S8.tab PF8.numAt = true
theorem PF8.num : checkNum PFW8.R.data.map PF8.θ ⟨PRE_pf_vw.S0.tab, []⟩ ⟨PF8.tabP, []⟩ = true :=
  checkNum_pad PF8.numAll (fun i e he h => by
    unfold PF8.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PF8.fixP : PFW8.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
