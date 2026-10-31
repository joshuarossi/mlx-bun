import host.sim.template.a4final_eos1.H0
import host.sim.template.a4final_eos1.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
kernel_rfl FinalEos1.stepB3 : interpS (step FinalEos1.F FinalEos1.s8).run FinalEos1.S8 = some (FinalEos1.s9, FinalEos1.S9)
sim_chunk FinalEos1 FinalEos1.okB3 9
end Host.Load.Run.Tpl
