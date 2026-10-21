import host.sim.template.clear.H0
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk CLEAR ok 12
sim_chunk CLEAR ok 13
sim_chunk CLEAR ok 14
sim_chunk CLEAR ok 15
end Host.Load.Run.Tpl
