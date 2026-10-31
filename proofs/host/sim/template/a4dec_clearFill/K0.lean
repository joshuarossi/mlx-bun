import host.sim.template.a4dec_clearFill.H0
import host.sim.template.a4dec_clearFill.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_clearFill DEC_clearFill.okB1 2
kernel_rfl DEC_clearFill.stepA2 : interpS (step DEC_clearFill.F DEC_clearFill.s3).run DEC_clearFill.S3 = some (DEC_clearFill.s4, DEC_clearFill.S4)
end Host.Load.Run.Tpl
