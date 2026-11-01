import host.sim.compose.a4b.PF6Na
import host.sim.template.a4pre_first_tail_x6_r0_suffix.m.B0
import host.sim.compose.NumSplit
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF6.numId : numIdB PFW6.R.data 8227 = true
kernel_rfl PF6.numHead : (PRE_pf_vw.S0.tab.take 8227).map (·.subst PF6.θ) = PRE_first_tail_x6_r0_suffix.S8.tab.take 8227
kernel_rfl PF6.numTail : (List.range' 8227 (PRE_pf_vw.S0.tab.length - 8227)).all PF6.numAt = true
theorem PF6.num : checkNum PFW6.R.data.map PF6.θ ⟨PRE_pf_vw.S0.tab, []⟩ ⟨PRE_first_tail_x6_r0_suffix.S8.tab, []⟩ = true :=
  checkNum_split PF6.numId PF6.numHead PF6.numTail (fun i e he h => by
    unfold PF6.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PF6.fixP : PFW6.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
