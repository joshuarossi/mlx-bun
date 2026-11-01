import host.load.boot.World
import host.sim.compose.a4b.PLTVNa
import host.sim.template.a4pre_plvw_common.H0
import host.sim.compose.NumSplit
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.numId : numIdB PLTailVW.R.data 3305 = true
kernel_rfl PLTV.numHead : (PRE_pl_tail.S0.tab.take 3305).map (·.subst PLTV.θ) = PRE_plvw_common.S4.tab.take 3305
kernel_rfl PLTV.numTail : (List.range' 3305 (PRE_pl_tail.S0.tab.length - 3305)).all PLTV.numAt = true
theorem PLTV.num : checkNum PLTailVW.R.data.map PLTV.θ ⟨PRE_pl_tail.S0.tab, []⟩ ⟨PRE_plvw_common.S4.tab, []⟩ = true :=
  checkNum_split PLTV.numId PLTV.numHead PLTV.numTail (fun i e he h => by
    unfold PLTV.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PLTV.fixP : PLTailVW.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
