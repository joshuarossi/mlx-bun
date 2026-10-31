import host.sim.template.a4dec_clear.st1.H0
import host.sim.template.a4dec_clear.st1.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_clear.st1 DEC_clear.st1.okL 16
sim_chunk DEC_clear.st1 DEC_clear.st1.okL 17
sim_chunk DEC_clear.st1 DEC_clear.st1.okL 18
sim_chunk DEC_clear.st1 DEC_clear.st1.okL 19
end Host.Load.Run.Tpl
