import host.sim.template.a4dec_ord.st1.H4
import host.sim.template.a4dec_ord.st1.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_ord.st1 DEC_ord.st1.okL 148
kernel_rfl DEC_ord.st1.last : interpS (step DEC_ord.st1.F DEC_ord.st1.s149).run DEC_ord.st1.S149 = some (DEC_ord.st1.s150, DEC_ord.st1.S150)
end Host.Load.Run.Tpl
