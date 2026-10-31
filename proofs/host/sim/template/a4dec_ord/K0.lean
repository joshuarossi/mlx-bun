import host.sim.template.a4dec_ord.H0
import host.sim.template.a4dec_ord.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_ord DEC_ord.okB1 2
kernel_rfl DEC_ord.stepA2 : interpS (step DEC_ord.F DEC_ord.s3).run DEC_ord.S3 = some (DEC_ord.s4, DEC_ord.S4)
end Host.Load.Run.Tpl
