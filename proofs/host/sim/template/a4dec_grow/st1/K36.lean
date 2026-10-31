import host.sim.template.a4dec_grow.st1.H4
import host.sim.template.a4dec_grow.st1.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_grow.st1 DEC_grow.st1.okL 144
sim_chunk DEC_grow.st1 DEC_grow.st1.okL 145
sim_chunk DEC_grow.st1 DEC_grow.st1.okL 146
sim_chunk DEC_grow.st1 DEC_grow.st1.okL 147
end Host.Load.Run.Tpl
