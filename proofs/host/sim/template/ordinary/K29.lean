import host.sim.template.ordinary.H3
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk ORDINARY ok 116
sim_chunk ORDINARY ok 117
sim_chunk ORDINARY ok 118
sim_chunk ORDINARY ok 119
end Host.Load.Run.Tpl
