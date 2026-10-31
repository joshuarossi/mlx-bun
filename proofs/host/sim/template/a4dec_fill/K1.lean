import host.sim.template.a4dec_fill.H0
import host.sim.template.a4dec_fill.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_fill DEC_fill.okB2 6
kernel_rfl DEC_fill.stepA3 : interpS (step DEC_fill.F DEC_fill.s7).run DEC_fill.S7 = some (DEC_fill.s8, DEC_fill.S8)
end Host.Load.Run.Tpl
