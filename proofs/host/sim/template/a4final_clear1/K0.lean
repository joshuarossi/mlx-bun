import host.sim.template.a4final_clear1.H0
import host.sim.template.a4final_clear1.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk FinalClear1 FinalClear1.okB0 0
kernel_rfl FinalClear1.stepA1 : interpS (step FinalClear1.F FinalClear1.s1).run FinalClear1.S1 = some (FinalClear1.s2, FinalClear1.S2)
kernel_rfl FinalClear1.patchB1 : some (Host.Ts.Sim.Template.Bridge.lenPatch FinalClear1.s2 FinalClear1.S2 (FinalClear1.promptLen)) = some (FinalClear1.s3, FinalClear1.S3)
sim_chunk FinalClear1 FinalClear1.okB1 3
end Host.Load.Run.Tpl
