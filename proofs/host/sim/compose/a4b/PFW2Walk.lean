import host.sim.template.a4pre_pf_vw.S
import host.sim.template.a4pre_first_tail_x2_r0_suffix.m.B0
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
bridge_empty PFW2.s0 from PRE_pf_vw.s0
server_data PFW2.S0 := PRE_pf_vw.S0
bridge_empty PFW2.s8 from PRE_first_tail_x2_r0_suffix.s8
server_data PFW2.S8 := PRE_first_tail_x2_r0_suffix.S8
def PFW2.frames : List Nat := PRE_pf_vw.frames
def PFW2.ghosts : List Nat := PRE_pf_vw.ghosts
def PFW2.maps : List Nat := PRE_pf_vw.maps
set_option interpreter.prefer_native true in
tpl_restart_pad PFW2.R : PFW2, PFW2 8 («world» := Host.Load.Run.Tpl.PRE_first_tail_x2_r0.nativeWorld)

end Host.Load.Run.Tpl
