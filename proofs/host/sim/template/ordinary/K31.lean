import host.sim.template.ordinary.H4
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk ORDINARY ok 124
sim_chunk ORDINARY ok 125
sim_chunk ORDINARY ok 126
sim_chunk ORDINARY ok 127
end Host.Load.Run.Tpl
