import host.sim.template.ordinary.H3
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk ORDINARY ok 112
sim_chunk ORDINARY ok 113
sim_chunk ORDINARY ok 114
sim_chunk ORDINARY ok 115
end Host.Load.Run.Tpl
