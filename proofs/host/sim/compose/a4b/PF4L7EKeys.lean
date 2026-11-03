import host.sim.template.a4pre_pf_x4_L7.S
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
bridge_empty PF4L7EV.s0 from PRE_pf_x4_L7.s0
server_data PF4L7EV.S0 := PRE_pf_x4_L7.S0
def PF4L7EV.frames : List Nat := 2665 :: wideListPf.map Prod.fst
tpl_keys PF4L7EV
theorem PRE_pf_x4_L7.cover : ∀ a x, PRE_pf_x4_L7.s0.heap.get a = some x → a ∉ PF4L7EV.frames → ∃ q ∈ PF4L7EV.gks, a ∈ q.2 :=
  PF4L7EV.cover

end Host.Load.Run.Tpl
