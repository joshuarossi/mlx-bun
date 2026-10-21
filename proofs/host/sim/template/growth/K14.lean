import host.sim.template.growth.H1
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk GROWTH ok 56
sim_chunk GROWTH ok 57
sim_chunk GROWTH ok 58
sim_chunk GROWTH ok 59
end Host.Load.Run.Tpl
