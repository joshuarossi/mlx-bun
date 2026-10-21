import host.sim.template.ordinary.H2
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk ORDINARY ok 64
sim_chunk ORDINARY ok 65
sim_chunk ORDINARY ok 66
sim_chunk ORDINARY ok 67
end Host.Load.Run.Tpl
