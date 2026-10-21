import host.sim.template.growth.H0
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk GROWTH ok 24
sim_chunk GROWTH ok 25
sim_chunk GROWTH ok 26
sim_chunk GROWTH ok 27
end Host.Load.Run.Tpl
