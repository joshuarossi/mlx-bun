import host.sim.template.a4pre_pl_tail.S
import host.sim.template.a4pre_plx4_L7_common.H0
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
bridge_empty PLTW4L7.s0 from PRE_pl_tail.s0
server_data PLTW4L7.S0 := PRE_pl_tail.S0
bridge_empty PLTW4L7.s1 from PRE_plx4_L7_common.s1
server_data PLTW4L7.S1 := PRE_plx4_L7_common.S1
def PLTW4L7.frames : List Nat := PRE_pl_tail.frames
def PLTW4L7.ghosts : List Nat := PRE_pl_tail.ghosts
def PLTW4L7.maps : List Nat := PRE_pl_tail.maps
set_option interpreter.prefer_native true in
tpl_restart_pad PLTW4L7.R : PLTW4L7, PLTW4L7 1 («world» := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0.nativeWorld, primNums := true)

end Host.Load.Run.Tpl
