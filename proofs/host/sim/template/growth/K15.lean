import host.sim.template.growth.H2
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk GROWTH ok 60
sim_chunk GROWTH ok 61
sim_chunk GROWTH ok 62
sim_chunk GROWTH ok 63
end Host.Load.Run.Tpl
