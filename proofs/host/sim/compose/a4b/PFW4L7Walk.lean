import host.sim.template.a4pre_pf_x4_L7.S
import host.sim.template.a4pre_first_tail_x4_L7_r0_suffix.m.B3
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
bridge_empty PFW4L7.s0 from PRE_pf_x4_L7.s0
server_data PFW4L7.S0 := PRE_pf_x4_L7.S0
bridge_empty PFW4L7.s8 from PRE_first_tail_x4_L7_r0_suffix.s8
server_data PFW4L7.S8 := PRE_first_tail_x4_L7_r0_suffix.S8
def PFW4L7.frames : List Nat := PRE_pf_x4_L7.frames
def PFW4L7.ghosts : List Nat := PRE_pf_x4_L7.ghosts
def PFW4L7.maps : List Nat := PRE_pf_x4_L7.maps
set_option interpreter.prefer_native true in
tpl_restart_pad PFW4L7.R : PFW4L7, PFW4L7 8 («world» := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0.nativeWorld, primNums := true)

end Host.Load.Run.Tpl
