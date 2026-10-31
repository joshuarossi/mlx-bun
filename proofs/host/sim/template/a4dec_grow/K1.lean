import host.sim.template.a4dec_grow.H0
import host.sim.template.a4dec_grow.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_grow DEC_grow.okB2 6
kernel_rfl DEC_grow.stepA3 : interpS (step DEC_grow.F DEC_grow.s7).run DEC_grow.S7 = some (DEC_grow.s8, DEC_grow.S8)
end Host.Load.Run.Tpl
