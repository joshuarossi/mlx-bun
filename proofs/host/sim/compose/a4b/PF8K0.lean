import host.sim.compose.a4b.PF8Na
import host.sim.template.a4pre_first_tail_x8_r0_suffix.m.B0
import host.sim.compose.NumSplit
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF8.numId : numIdB PFW8.R.data 8227 = true
kernel_rfl PF8.numHead : (PRE_pf_vw.S0.tab.take 8227).map (·.subst PF8.θ) = PRE_first_tail_x8_r0_suffix.S8.tab.take 8227
kernel_rfl PF8.numTail : (List.range' 8227 (PRE_pf_vw.S0.tab.length - 8227)).all PF8.numAt = true
theorem PF8.num : checkNum PFW8.R.data.map PF8.θ ⟨PRE_pf_vw.S0.tab, []⟩ ⟨PRE_first_tail_x8_r0_suffix.S8.tab, []⟩ = true :=
  checkNum_split PF8.numId PF8.numHead PF8.numTail (fun i e he h => by
    unfold PF8.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PF8.fixP : PFW8.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
