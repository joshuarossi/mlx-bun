import host.sim.template.a4final_eos0.H0
import host.sim.template.a4final_eos0.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
kernel_rfl FinalEos0.stepB3 : interpS (step FinalEos0.F FinalEos0.s8).run FinalEos0.S8 = some (FinalEos0.s9, FinalEos0.S9)
sim_chunk FinalEos0 FinalEos0.okB3 9
end Host.Load.Run.Tpl
