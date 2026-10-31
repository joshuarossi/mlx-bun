import host.sim.template.a4pre_pl_tail.S
import host.sim.template.a4pre_pl_common.States
import host.sim.template.a4pre_first_tail_x15_r0.States
import host.sim.template.BridgeLiteral
import host.sim.template.ServerData
import host.sim.template.RestartCmd
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
/-! The map from a history class's POST stretch into the shared tail template, chosen natively on the bridge-free
views of both states. Everything about it is a later kernel check. -/
bridge_empty PLTail.s0 from PRE_pl_tail.s0
server_data PLTail.S0 := PRE_pl_tail.S0
bridge_empty PLTail.s4 from PRE_pl_common.s4
server_data PLTail.S4 := PRE_pl_common.S4
def PLTail.frames : List Nat := PRE_pl_tail.frames
def PLTail.ghosts : List Nat := PRE_pl_tail.ghosts
def PLTail.maps : List Nat := PRE_pl_tail.maps
set_option interpreter.prefer_native true in
tpl_restart PLTail.R : PLTail, PLTail 4 («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
