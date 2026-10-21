import host.sim.template.growth.H4
import host.sim.template.ok.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim
sim_chunk GROWTH ok 136
sim_chunk GROWTH ok 137
sim_chunk GROWTH ok 138
sim_chunk GROWTH ok 139
end Host.Load.Run.Tpl
