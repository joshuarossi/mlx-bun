import host.sim.template.a4dec_fill.st1.H0
import host.sim.template.a4dec_fill.st1.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_fill.st1 DEC_fill.st1.okL 0
sim_chunk DEC_fill.st1 DEC_fill.st1.okL 1
sim_chunk DEC_fill.st1 DEC_fill.st1.okL 2
sim_chunk DEC_fill.st1 DEC_fill.st1.okL 3
end Host.Load.Run.Tpl
