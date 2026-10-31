import host.sim.template.a4dec_clearGrow.st0.H0
import host.sim.template.a4dec_clearGrow.st0.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_clearGrow.st0 DEC_clearGrow.st0.okL 0
kernel_rfl DEC_clearGrow.st0.last : interpS (step DEC_clearGrow.st0.F DEC_clearGrow.st0.s1).run DEC_clearGrow.st0.S1 = some (DEC_clearGrow.st0.s2, DEC_clearGrow.st0.S2)
end Host.Load.Run.Tpl
