import host.sim.template.a4pre_plx4_L8_entry.S
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
bridge_empty PL4L8EV.s0 from PRE_plx4_L8_entry.s0
server_data PL4L8EV.S0 := PRE_plx4_L8_entry.S0
def PL4L8EV.frames : List Nat := 2665 :: wideListPf.map Prod.fst
tpl_keys PL4L8EV
theorem PRE_plx4_L8_entry.cover : ∀ a x, PRE_plx4_L8_entry.s0.heap.get a = some x → a ∉ PL4L8EV.frames → ∃ q ∈ PL4L8EV.gks, a ∈ q.2 :=
  PL4L8EV.cover

end Host.Load.Run.Tpl
