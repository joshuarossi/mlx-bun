import host.sim.template.a4final_clear0.H0
import host.sim.template.a4final_clear0.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
kernel_rfl FinalClear0.stepB3 : interpS (step FinalClear0.F FinalClear0.s8).run FinalClear0.S8 = some (FinalClear0.s9, FinalClear0.S9)
sim_chunk FinalClear0 FinalClear0.okB3 9
end Host.Load.Run.Tpl
