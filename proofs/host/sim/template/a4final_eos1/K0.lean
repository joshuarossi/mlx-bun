import host.sim.template.a4final_eos1.H0
import host.sim.template.a4final_eos1.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk FinalEos1 FinalEos1.okB0 0
kernel_rfl FinalEos1.stepA1 : interpS (step FinalEos1.F FinalEos1.s1).run FinalEos1.S1 = some (FinalEos1.s2, FinalEos1.S2)
kernel_rfl FinalEos1.patchB1 : some (Host.Ts.Sim.Template.Bridge.lenPatch FinalEos1.s2 FinalEos1.S2 (FinalEos1.promptLen)) = some (FinalEos1.s3, FinalEos1.S3)
sim_chunk FinalEos1 FinalEos1.okB1 3
end Host.Load.Run.Tpl
