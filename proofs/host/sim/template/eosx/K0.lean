import host.sim.template.eosx.H0
import host.sim.template.eosx.OkB
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk EOSX ok 0
kernel_rfl EOSX.stepA : interpS (step EOSX.F EOSX.s1).run EOSX.S1 = some (EOSX.s2, EOSX.S2)
kernel_rfl EOSX.stepB : interpS (step EOSX.F EOSX.s2).run EOSX.S2 = some (EOSX.s3, EOSX.S3)
sim_chunk EOSX EOSX.okB 3
end Host.Load.Run.Tpl
