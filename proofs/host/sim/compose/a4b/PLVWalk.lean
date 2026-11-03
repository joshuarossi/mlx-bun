import host.sim.template.a4pre_plvw_entry.S
import host.sim.template.a4pre_fd_vw_r0_body.m.B00
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
bridge_empty PLVW.s0 from PRE_plvw_entry.s0
server_data PLVW.S0 := PRE_plvw_entry.S0
bridge_empty PLVW.s900 from PRE_fd_vw_r0_body.s900
server_data PLVW.S900 := PRE_fd_vw_r0_body.S900
def PLVW.frames : List Nat := PRE_plvw_entry.frames
def PLVW.ghosts : List Nat := PRE_plvw_entry.ghosts
def PLVW.maps : List Nat := PRE_plvw_entry.maps
set_option interpreter.prefer_native true in
tpl_restart_pad PLVW.R : PLVW, PLVW 900 («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld, primNums := true)

end Host.Load.Run.Tpl
