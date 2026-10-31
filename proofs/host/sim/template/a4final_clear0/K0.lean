import host.sim.template.a4final_clear0.H0
import host.sim.template.a4final_clear0.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk FinalClear0 FinalClear0.okB0 0
kernel_rfl FinalClear0.stepA1 : interpS (step FinalClear0.F FinalClear0.s1).run FinalClear0.S1 = some (FinalClear0.s2, FinalClear0.S2)
kernel_rfl FinalClear0.patchB1 : some (Host.Ts.Sim.Template.Bridge.lenPatch FinalClear0.s2 FinalClear0.S2 (FinalClear0.promptLen)) = some (FinalClear0.s3, FinalClear0.S3)
sim_chunk FinalClear0 FinalClear0.okB1 3
end Host.Load.Run.Tpl
