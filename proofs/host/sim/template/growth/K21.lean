import host.sim.template.growth.H2
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk GROWTH ok 84
sim_chunk GROWTH ok 85
sim_chunk GROWTH ok 86
sim_chunk GROWTH ok 87
end Host.Load.Run.Tpl
