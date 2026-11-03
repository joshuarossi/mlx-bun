import host.sim.compose.a4b.PF15Na
import host.sim.template.a4pre_first_tail_x15_r0_suffix.m.B3
import host.load.boot.World
import host.sim.compose.NumPad
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF15.numAll : numPadB PFW15.R.data PF15.θ PRE_pf_vw.S0.tab PRE_first_tail_x15_r0_suffix.S8.tab PF15.numAt = true
theorem PF15.num : checkNum PFW15.R.data.map PF15.θ ⟨PRE_pf_vw.S0.tab, []⟩ ⟨PF15.tabP, []⟩ = true :=
  checkNum_pad PF15.numAll (fun i e he h => by
    unfold PF15.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PF15.fixP : PFW15.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
