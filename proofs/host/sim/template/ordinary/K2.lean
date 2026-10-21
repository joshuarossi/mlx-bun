import host.sim.template.ordinary.H0
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk ORDINARY ok 8
sim_chunk ORDINARY ok 9
sim_chunk ORDINARY ok 10
sim_chunk ORDINARY ok 11
end Host.Load.Run.Tpl
