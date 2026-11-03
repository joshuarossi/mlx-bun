import host.sim.template.a4pre_plx0_entry.S
import host.sim.template.a4pre_fd_x0_r0_body.m.B00
import host.sim.template.RestartPad
import host.sim.template.BridgeLiteral
import host.sim.template.ServerData
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The map from the pre-final template into the tail's end, chosen natively on the bridge-free views
of both states. Everything about it is a later kernel check. -/
bridge_empty PLW0.s0 from PRE_plx0_entry.s0
server_data PLW0.S0 := PRE_plx0_entry.S0
bridge_empty PLW0.s447 from PRE_fd_x0_r0_body.s447
server_data PLW0.S447 := PRE_fd_x0_r0_body.S447
def PLW0.frames : List Nat := PRE_plx0_entry.frames
def PLW0.ghosts : List Nat := PRE_plx0_entry.ghosts
def PLW0.maps : List Nat := PRE_plx0_entry.maps
set_option interpreter.prefer_native true in
tpl_restart_pad PLW0.R : PLW0, PLW0 447 («world» := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.nativeWorld, primNums := true)

end Host.Load.Run.Tpl
