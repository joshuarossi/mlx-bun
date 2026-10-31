import host.sim.template.a4pre_pl_entry.S
import host.sim.template.a4pre_d1_body.D4
import host.sim.template.RestartCmd
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
/-! The map from the L-general POST entry into the singleton forward's return, chosen natively
on the bridge-free views of both states. Everything about it is a later kernel check. -/
bridge_empty PLWalkD1.s0 from PRE_pl_entry.s0
server_data PLWalkD1.S0 := PRE_pl_entry.S0
bridge_empty PLWalkD1.s155 from D1Body.s155
server_data PLWalkD1.S155 := D1Body.S155
def PLWalkD1.frames : List Nat := PRE_pl_entry.frames
def PLWalkD1.ghosts : List Nat := PRE_pl_entry.ghosts
def PLWalkD1.maps : List Nat := PRE_pl_entry.maps
set_option interpreter.prefer_native true in
tpl_restart PLWalkD1.R : PLWalkD1, PLWalkD1 155 («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
