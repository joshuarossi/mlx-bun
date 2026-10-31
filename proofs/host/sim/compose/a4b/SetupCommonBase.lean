import host.sim.compose.a4b.SetupChunkC
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupCommon
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route

def m : List (Nat × Q) := [(9, .L), (10, .C)]

end Host.Ts.Sim.Compose.SetupCommon
