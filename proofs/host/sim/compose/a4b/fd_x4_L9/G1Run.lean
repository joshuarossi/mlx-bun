import host.sim.compose.a4b.fd_x4_L9.G1Data

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX4L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

def g1Framed (K : Ctx) (π : List Nat) : Ctx :=
  Disp.typedK (Disp.Ctx.frameAt K FDX4L9Frames.chunk ([], (lastRows π).map natV)) FDX4L9Frames.buffer

end Host.Ts.Sim.Compose.FDX4L9
