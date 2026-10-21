import host.sim.template.ordinary.H2
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk ORDINARY ok 88
sim_chunk ORDINARY ok 89
sim_chunk ORDINARY ok 90
sim_chunk ORDINARY ok 91
end Host.Load.Run.Tpl
