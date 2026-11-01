import host.sim.template.a4pre_pl_entry.S
import host.sim.template.RestartCmd
import host.sim.template.BridgeLiteral
import host.sim.template.ServerData
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The entry's address groups, listed on its bridge-free view: the bridge is not constructor data. -/
bridge_empty PLEntryV.s0 from PRE_pl_entry.s0
server_data PLEntryV.S0 := PRE_pl_entry.S0
def PLEntryV.frames : List Nat := PRE_pl_entry.frames
tpl_keys PLEntryV
theorem PRE_pl_entry.cover : ∀ a x, PRE_pl_entry.s0.heap.get a = some x → a ∉ PRE_pl_entry.frames → ∃ q ∈ PLEntryV.gks, a ∈ q.2 :=
  PLEntryV.cover

end Host.Load.Run.Tpl
