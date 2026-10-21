import host.sim.template.finalc0.H0
import host.sim.template.finalc0.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk FINALC0 ok 0
kernel_rfl FINALC0.stepA : interpS (step FINALC0.F FINALC0.s1).run FINALC0.S1 = some (FINALC0.s2, FINALC0.S2)
kernel_rfl FINALC0.stepB : interpS (step FINALC0.F FINALC0.s2).run FINALC0.S2 = some (FINALC0.s3, FINALC0.S3)
sim_chunk FINALC0 FINALC0.okB 3
end Host.Load.Run.Tpl
