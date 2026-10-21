import host.sim.template.growth.H3
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk GROWTH ok 100
sim_chunk GROWTH ok 101
sim_chunk GROWTH ok 102
sim_chunk GROWTH ok 103
end Host.Load.Run.Tpl
