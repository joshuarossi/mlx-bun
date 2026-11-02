import host.sim.template.a4pre_pl_tail.S
import host.sim.template.Ghosts
import host.sim.template.RestartCmd
import host.sim.template.BridgeLiteral
import host.sim.template.ServerData
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The entry's address groups, listed on its bridge-free view: the bridge is not constructor data. -/
bridge_empty PLTEV.s0 from PRE_pl_tail.s0
server_data PLTEV.S0 := PRE_pl_tail.S0
def PLTEV.frames : List Nat := 2665 :: wideList.map Prod.fst
tpl_keys PLTEV
theorem PRE_pl_tail.cover : ∀ a x, PRE_pl_tail.s0.heap.get a = some x → a ∉ PLTEV.frames → ∃ q ∈ PLTEV.gks, a ∈ q.2 :=
  PLTEV.cover

end Host.Load.Run.Tpl
