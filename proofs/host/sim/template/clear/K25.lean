import host.sim.template.clear.H3
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk CLEAR ok 100
sim_chunk CLEAR ok 101
sim_chunk CLEAR ok 102
sim_chunk CLEAR ok 103
end Host.Load.Run.Tpl
