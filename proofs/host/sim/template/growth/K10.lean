import host.sim.template.growth.H1
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk GROWTH ok 40
sim_chunk GROWTH ok 41
sim_chunk GROWTH ok 42
sim_chunk GROWTH ok 43
end Host.Load.Run.Tpl
