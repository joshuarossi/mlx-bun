import host.sim.template.growth.H2
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk GROWTH ok 80
sim_chunk GROWTH ok 81
sim_chunk GROWTH ok 82
sim_chunk GROWTH ok 83
end Host.Load.Run.Tpl
