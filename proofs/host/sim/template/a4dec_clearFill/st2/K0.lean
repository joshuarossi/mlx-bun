import host.sim.template.a4dec_clearFill.st2.H0
import host.sim.template.a4dec_clearFill.st2.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk DEC_clearFill.st2 DEC_clearFill.st2.okL 0
kernel_rfl DEC_clearFill.st2.last : interpS (step DEC_clearFill.st2.F DEC_clearFill.st2.s1).run DEC_clearFill.st2.S1 = some (DEC_clearFill.st2.s2, DEC_clearFill.st2.S2)
end Host.Load.Run.Tpl
