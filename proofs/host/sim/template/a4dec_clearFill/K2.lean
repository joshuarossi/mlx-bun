import host.sim.template.a4dec_clearFill.H0
import host.sim.template.a4dec_clearFill.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_clearFill DEC_clearFill.okB3 10
end Host.Load.Run.Tpl
