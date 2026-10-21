import host.sim.template.clear.H4
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk CLEAR ok 132
sim_chunk CLEAR ok 133
sim_chunk CLEAR ok 134
sim_chunk CLEAR ok 135
end Host.Load.Run.Tpl
