import host.sim.template.a4dec_clearGrow.H0
import host.sim.template.a4dec_clearGrow.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_clearGrow DEC_clearGrow.okB1 2
kernel_rfl DEC_clearGrow.stepA2 : interpS (step DEC_clearGrow.F DEC_clearGrow.s3).run DEC_clearGrow.S3 = some (DEC_clearGrow.s4, DEC_clearGrow.S4)
end Host.Load.Run.Tpl
