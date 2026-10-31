import host.sim.template.a4dec_fill.H0
import host.sim.template.a4dec_fill.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_fill DEC_fill.okB1 2
kernel_rfl DEC_fill.stepA2 : interpS (step DEC_fill.F DEC_fill.s3).run DEC_fill.S3 = some (DEC_fill.s4, DEC_fill.S4)
end Host.Load.Run.Tpl
