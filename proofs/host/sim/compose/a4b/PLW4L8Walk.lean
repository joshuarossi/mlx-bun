import host.sim.template.a4pre_plx4_L8_entry.S
import host.sim.template.a4pre_fd_x4_L8_r0_body.m.B00
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
bridge_empty PLW4L8.s0 from PRE_plx4_L8_entry.s0
server_data PLW4L8.S0 := PRE_plx4_L8_entry.S0
bridge_empty PLW4L8.s451 from PRE_fd_x4_L8_r0_body.s451
server_data PLW4L8.S451 := PRE_fd_x4_L8_r0_body.S451
def PLW4L8.frames : List Nat := PRE_plx4_L8_entry.frames
def PLW4L8.ghosts : List Nat := PRE_plx4_L8_entry.ghosts
def PLW4L8.maps : List Nat := PRE_plx4_L8_entry.maps
set_option interpreter.prefer_native true in
tpl_restart_pad PLW4L8.R : PLW4L8, PLW4L8 451 («world» := Host.Load.Run.Tpl.PRE_first_tail_x4_L8_r0.nativeWorld, primNums := true)

end Host.Load.Run.Tpl
