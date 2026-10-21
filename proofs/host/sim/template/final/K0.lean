import host.sim.template.final.H0
import host.sim.template.final.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk FINAL ok 0
kernel_rfl FINAL.stepA : interpS (step FINAL.F FINAL.s1).run FINAL.S1 = some (FINAL.s2, FINAL.S2)
kernel_rfl FINAL.stepB : interpS (step FINAL.F FINAL.s2).run FINAL.S2 = some (FINAL.s3, FINAL.S3)
sim_chunk FINAL FINAL.okB 3
end Host.Load.Run.Tpl
