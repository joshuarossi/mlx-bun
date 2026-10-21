import host.sim.template.clear.H1
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk CLEAR ok 52
sim_chunk CLEAR ok 53
sim_chunk CLEAR ok 54
sim_chunk CLEAR ok 55
end Host.Load.Run.Tpl
