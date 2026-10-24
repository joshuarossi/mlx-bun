import host.sim.template.finale.H0
import host.sim.template.finale.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk FINALE ok 0
kernel_rfl FINALE.stepA : interpS (step FINALE.F FINALE.s1).run FINALE.S1 = some (FINALE.s2, FINALE.S2)
kernel_rfl FINALE.stepB : interpS (step FINALE.F FINALE.s2).run FINALE.S2 = some (FINALE.s3, FINALE.S3)
sim_chunk FINALE FINALE.okB 3
end Host.Load.Run.Tpl
