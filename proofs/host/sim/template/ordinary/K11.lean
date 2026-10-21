import host.sim.template.ordinary.H1
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk ORDINARY ok 44
sim_chunk ORDINARY ok 45
sim_chunk ORDINARY ok 46
sim_chunk ORDINARY ok 47
end Host.Load.Run.Tpl
