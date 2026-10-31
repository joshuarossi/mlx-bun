import host.sim.template.a4dec_clearGrow.st1.H4
import host.sim.template.a4dec_clearGrow.st1.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
kernel_rfl DEC_clearGrow.st1.last : interpS (step DEC_clearGrow.st1.F DEC_clearGrow.st1.s152).run DEC_clearGrow.st1.S152 = some (DEC_clearGrow.st1.s153, DEC_clearGrow.st1.S153)
end Host.Load.Run.Tpl
