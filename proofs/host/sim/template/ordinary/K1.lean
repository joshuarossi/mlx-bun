import host.sim.template.ordinary.H0
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk ORDINARY ok 4
sim_chunk ORDINARY ok 5
sim_chunk ORDINARY ok 6
sim_chunk ORDINARY ok 7
end Host.Load.Run.Tpl
