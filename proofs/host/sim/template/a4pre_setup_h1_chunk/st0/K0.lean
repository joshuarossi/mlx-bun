import host.sim.template.a4pre_setup_h1_chunk.st0.H0
import host.sim.template.a4pre_setup_h1_chunk.st0.Ok
import host.sim.Chunk
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_setup_h1_chunk.st0.k0 from PRE_setup_h1_chunk.st0.s0 to PRE_setup_h1_chunk.st0.s1 : runOk PRE_setup_h1_chunk.st0.F PRE_setup_h1_chunk.st0.okL ((nth? PRE_setup_h1_chunk.st0.ks 0).getD 0) PRE_setup_h1_chunk.st0.s0 PRE_setup_h1_chunk.st0.S0 = some (PRE_setup_h1_chunk.st0.s1, PRE_setup_h1_chunk.st0.S1)
boot_rfl PRE_setup_h1_chunk.st0.k1 from PRE_setup_h1_chunk.st0.s1 to PRE_setup_h1_chunk.st0.s2 : runOk PRE_setup_h1_chunk.st0.F PRE_setup_h1_chunk.st0.okL ((nth? PRE_setup_h1_chunk.st0.ks 1).getD 0) PRE_setup_h1_chunk.st0.s1 PRE_setup_h1_chunk.st0.S1 = some (PRE_setup_h1_chunk.st0.s2, PRE_setup_h1_chunk.st0.S2)
boot_rfl PRE_setup_h1_chunk.st0.last from PRE_setup_h1_chunk.st0.s2 to PRE_setup_h1_chunk.st0.s3 : interpS (step PRE_setup_h1_chunk.st0.F PRE_setup_h1_chunk.st0.s2).run PRE_setup_h1_chunk.st0.S2 = some (PRE_setup_h1_chunk.st0.s3, PRE_setup_h1_chunk.st0.S3)
end Host.Load.Run.Tpl
