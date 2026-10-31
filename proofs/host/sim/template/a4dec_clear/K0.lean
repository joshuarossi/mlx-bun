import host.sim.template.a4dec_clear.H0
import host.sim.template.a4dec_clear.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_clear DEC_clear.okB1 2
kernel_rfl DEC_clear.stepA2 : interpS (step DEC_clear.F DEC_clear.s3).run DEC_clear.S3 = some (DEC_clear.s4, DEC_clear.S4)
end Host.Load.Run.Tpl
