import host.sim.template.a4final_eos0.H0
import host.sim.template.a4final_eos0.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk FinalEos0 FinalEos0.okB0 0
kernel_rfl FinalEos0.stepA1 : interpS (step FinalEos0.F FinalEos0.s1).run FinalEos0.S1 = some (FinalEos0.s2, FinalEos0.S2)
kernel_rfl FinalEos0.patchB1 : some (Host.Ts.Sim.Template.Bridge.lenPatch FinalEos0.s2 FinalEos0.S2 (FinalEos0.promptLen)) = some (FinalEos0.s3, FinalEos0.S3)
sim_chunk FinalEos0 FinalEos0.okB1 3
end Host.Load.Run.Tpl
