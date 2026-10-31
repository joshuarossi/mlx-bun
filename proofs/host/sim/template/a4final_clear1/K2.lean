import host.sim.template.a4final_clear1.H0
import host.sim.template.a4final_clear1.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
kernel_rfl FinalClear1.stepB3 : interpS (step FinalClear1.F FinalClear1.s8).run FinalClear1.S8 = some (FinalClear1.s9, FinalClear1.S9)
sim_chunk FinalClear1 FinalClear1.okB3 9
end Host.Load.Run.Tpl
