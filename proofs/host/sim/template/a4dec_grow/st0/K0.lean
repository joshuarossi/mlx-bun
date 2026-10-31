import host.sim.template.a4dec_grow.st0.H0
import host.sim.template.a4dec_grow.st0.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_grow.st0 DEC_grow.st0.okL 0
kernel_rfl DEC_grow.st0.last : interpS (step DEC_grow.st0.F DEC_grow.st0.s1).run DEC_grow.st0.S1 = some (DEC_grow.st0.s2, DEC_grow.st0.S2)
end Host.Load.Run.Tpl
