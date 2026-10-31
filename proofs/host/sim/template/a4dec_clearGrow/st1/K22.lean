import host.sim.template.a4dec_clearGrow.st1.H2
import host.sim.template.a4dec_clearGrow.st1.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_clearGrow.st1 DEC_clearGrow.st1.okL 88
sim_chunk DEC_clearGrow.st1 DEC_clearGrow.st1.okL 89
sim_chunk DEC_clearGrow.st1 DEC_clearGrow.st1.okL 90
sim_chunk DEC_clearGrow.st1 DEC_clearGrow.st1.okL 91
end Host.Load.Run.Tpl
