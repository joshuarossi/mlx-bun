import host.sim.template.growth.H3
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk GROWTH ok 120
sim_chunk GROWTH ok 121
sim_chunk GROWTH ok 122
sim_chunk GROWTH ok 123
end Host.Load.Run.Tpl
