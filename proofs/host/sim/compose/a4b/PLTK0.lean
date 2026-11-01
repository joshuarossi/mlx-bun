import host.sim.compose.a4b.PLTNa
import host.sim.template.a4pre_pl_common.H0
import host.sim.compose.NumSplit
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT.numId : numIdB PLTail.R.data 3305 = true
kernel_rfl PLT.numHead : (PRE_pl_tail.S0.tab.take 3305).map (·.subst PLT.θ) = PRE_pl_common.S4.tab.take 3305
kernel_rfl PLT.numTail : (List.range' 3305 (PRE_pl_tail.S0.tab.length - 3305)).all PLT.numAt = true
theorem PLT.num : checkNum PLTail.R.data.map PLT.θ ⟨PRE_pl_tail.S0.tab, []⟩ ⟨PRE_pl_common.S4.tab, []⟩ = true :=
  checkNum_split PLT.numId PLT.numHead PLT.numTail (fun i e he h => by
    unfold PLT.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PLT.fixP : PLTail.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
