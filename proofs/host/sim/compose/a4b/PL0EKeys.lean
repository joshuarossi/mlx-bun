import host.sim.template.a4pre_plx0_entry.S
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
bridge_empty PL0EV.s0 from PRE_plx0_entry.s0
server_data PL0EV.S0 := PRE_plx0_entry.S0
def PL0EV.frames : List Nat := 2665 :: wideListPf.map Prod.fst
tpl_keys PL0EV
theorem PRE_plx0_entry.cover : ∀ a x, PRE_plx0_entry.s0.heap.get a = some x → a ∉ PL0EV.frames → ∃ q ∈ PL0EV.gks, a ∈ q.2 :=
  PL0EV.cover

end Host.Load.Run.Tpl
