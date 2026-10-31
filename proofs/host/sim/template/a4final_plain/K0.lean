import host.sim.template.a4final_plain.H0
import host.sim.template.a4final_plain.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk FinalPlain FinalPlain.okB0 0
kernel_rfl FinalPlain.stepA1 : interpS (step FinalPlain.F FinalPlain.s1).run FinalPlain.S1 = some (FinalPlain.s2, FinalPlain.S2)
kernel_rfl FinalPlain.patchB1 : some (Host.Ts.Sim.Template.Bridge.lenPatch FinalPlain.s2 FinalPlain.S2 (FinalPlain.promptLen)) = some (FinalPlain.s3, FinalPlain.S3)
sim_chunk FinalPlain FinalPlain.okB1 3
end Host.Load.Run.Tpl
