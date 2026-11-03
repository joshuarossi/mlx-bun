import host.sim.template.a4pre_plvw_entry.S
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
bridge_empty PLVEV.s0 from PRE_plvw_entry.s0
server_data PLVEV.S0 := PRE_plvw_entry.S0
def PLVEV.frames : List Nat := 2665 :: wideListPf.map Prod.fst
tpl_keys PLVEV
theorem PRE_plvw_entry.cover : ∀ a x, PRE_plvw_entry.s0.heap.get a = some x → a ∉ PLVEV.frames → ∃ q ∈ PLVEV.gks, a ∈ q.2 :=
  PLVEV.cover

end Host.Load.Run.Tpl
