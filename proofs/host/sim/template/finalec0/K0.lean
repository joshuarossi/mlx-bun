import host.sim.template.finalec0.H0
import host.sim.template.finalec0.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk FINALEC0 ok 0
kernel_rfl FINALEC0.stepA : interpS (step FINALEC0.F FINALEC0.s1).run FINALEC0.S1 = some (FINALEC0.s2, FINALEC0.S2)
kernel_rfl FINALEC0.stepB : interpS (step FINALEC0.F FINALEC0.s2).run FINALEC0.S2 = some (FINALEC0.s3, FINALEC0.S3)
sim_chunk FINALEC0 FINALEC0.okB 3
end Host.Load.Run.Tpl
