import host.sim.template.a4pre_pf_x0.S
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
bridge_empty PF0EV.s0 from PRE_pf_x0.s0
server_data PF0EV.S0 := PRE_pf_x0.S0
def PF0EV.frames : List Nat := 2665 :: wideListPf.map Prod.fst
tpl_keys PF0EV
theorem PRE_pf_x0.cover : ∀ a x, PRE_pf_x0.s0.heap.get a = some x → a ∉ PF0EV.frames → ∃ q ∈ PF0EV.gks, a ∈ q.2 :=
  PF0EV.cover

end Host.Load.Run.Tpl
