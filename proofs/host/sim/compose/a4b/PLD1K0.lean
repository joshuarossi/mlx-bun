import host.sim.compose.a4b.PLD1Na
import host.sim.template.a4pre_d1_body.D4
import host.sim.compose.NumSplit
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.numId : numIdB PLWalkD1.R.data 3190 = true
kernel_rfl PLD1.numHead : (PRE_pl_entry.S0.tab.take 3190).map (·.subst PLD1.θ) = D1Body.S155.tab.take 3190
kernel_rfl PLD1.numTail : (List.range' 3190 (PRE_pl_entry.S0.tab.length - 3190)).all PLD1.numAt = true
theorem PLD1.num : checkNum PLWalkD1.R.data.map PLD1.θ ⟨PRE_pl_entry.S0.tab, []⟩ ⟨D1Body.S155.tab, []⟩ = true :=
  checkNum_split PLD1.numId PLD1.numHead PLD1.numTail (fun i e he h => by
    unfold PLD1.numAt at h
    rw [he] at h
    exact of_decide_eq_true h)
kernel_rfl PLD1.fixP : PLWalkD1.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
