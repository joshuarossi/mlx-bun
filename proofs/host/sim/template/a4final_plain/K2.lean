import host.sim.template.a4final_plain.H0
import host.sim.template.a4final_plain.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
kernel_rfl FinalPlain.stepB3 : interpS (step FinalPlain.F FinalPlain.s8).run FinalPlain.S8 = some (FinalPlain.s9, FinalPlain.S9)
sim_chunk FinalPlain FinalPlain.okB3 9
end Host.Load.Run.Tpl
