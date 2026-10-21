import host.sim.template.finalc1.H0
import host.sim.template.finalc1.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk FINALC1 ok 0
kernel_rfl FINALC1.stepA : interpS (step FINALC1.F FINALC1.s1).run FINALC1.S1 = some (FINALC1.s2, FINALC1.S2)
kernel_rfl FINALC1.stepB : interpS (step FINALC1.F FINALC1.s2).run FINALC1.S2 = some (FINALC1.s3, FINALC1.S3)
sim_chunk FINALC1 FINALC1.okB 3
end Host.Load.Run.Tpl
