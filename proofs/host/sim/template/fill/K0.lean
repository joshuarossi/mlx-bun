import host.sim.template.fill.H0
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk FILL ok 0
sim_chunk FILL ok 1
sim_chunk FILL ok 2
sim_chunk FILL ok 3
end Host.Load.Run.Tpl
