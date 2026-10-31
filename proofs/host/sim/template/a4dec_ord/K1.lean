import host.sim.template.a4dec_ord.H0
import host.sim.template.a4dec_ord.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_ord DEC_ord.okB2 6
kernel_rfl DEC_ord.stepA3 : interpS (step DEC_ord.F DEC_ord.s7).run DEC_ord.S7 = some (DEC_ord.s8, DEC_ord.S8)
end Host.Load.Run.Tpl
