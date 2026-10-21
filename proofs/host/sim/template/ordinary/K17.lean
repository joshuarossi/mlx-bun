import host.sim.template.ordinary.H2
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk ORDINARY ok 68
sim_chunk ORDINARY ok 69
sim_chunk ORDINARY ok 70
sim_chunk ORDINARY ok 71
end Host.Load.Run.Tpl
