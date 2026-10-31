import host.sim.template.a4dec_clearFill.st1.H2
import host.sim.template.a4dec_clearFill.st1.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_clearFill.st1 DEC_clearFill.st1.okL 64
sim_chunk DEC_clearFill.st1 DEC_clearFill.st1.okL 65
sim_chunk DEC_clearFill.st1 DEC_clearFill.st1.okL 66
sim_chunk DEC_clearFill.st1 DEC_clearFill.st1.okL 67
end Host.Load.Run.Tpl
