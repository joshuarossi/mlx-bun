import host.sim.template.a4dec_clearFill.st1.H1
import host.sim.template.a4dec_clearFill.st1.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_clearFill.st1 DEC_clearFill.st1.okL 56
sim_chunk DEC_clearFill.st1 DEC_clearFill.st1.okL 57
sim_chunk DEC_clearFill.st1 DEC_clearFill.st1.okL 58
sim_chunk DEC_clearFill.st1 DEC_clearFill.st1.okL 59
end Host.Load.Run.Tpl
