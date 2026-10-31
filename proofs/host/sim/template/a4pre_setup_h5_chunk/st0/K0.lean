import host.sim.template.a4pre_setup_h5_chunk.st0.H0
import host.sim.template.a4pre_setup_h5_chunk.st0.Ok
import host.sim.Chunk
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_setup_h5_chunk.st0.k0 from PRE_setup_h5_chunk.st0.s0 to PRE_setup_h5_chunk.st0.s1 : runOk PRE_setup_h5_chunk.st0.F PRE_setup_h5_chunk.st0.okL ((nth? PRE_setup_h5_chunk.st0.ks 0).getD 0) PRE_setup_h5_chunk.st0.s0 PRE_setup_h5_chunk.st0.S0 = some (PRE_setup_h5_chunk.st0.s1, PRE_setup_h5_chunk.st0.S1)
boot_rfl PRE_setup_h5_chunk.st0.k1 from PRE_setup_h5_chunk.st0.s1 to PRE_setup_h5_chunk.st0.s2 : runOk PRE_setup_h5_chunk.st0.F PRE_setup_h5_chunk.st0.okL ((nth? PRE_setup_h5_chunk.st0.ks 1).getD 0) PRE_setup_h5_chunk.st0.s1 PRE_setup_h5_chunk.st0.S1 = some (PRE_setup_h5_chunk.st0.s2, PRE_setup_h5_chunk.st0.S2)
boot_rfl PRE_setup_h5_chunk.st0.k2 from PRE_setup_h5_chunk.st0.s2 to PRE_setup_h5_chunk.st0.s3 : runOk PRE_setup_h5_chunk.st0.F PRE_setup_h5_chunk.st0.okL ((nth? PRE_setup_h5_chunk.st0.ks 2).getD 0) PRE_setup_h5_chunk.st0.s2 PRE_setup_h5_chunk.st0.S2 = some (PRE_setup_h5_chunk.st0.s3, PRE_setup_h5_chunk.st0.S3)
boot_rfl PRE_setup_h5_chunk.st0.k3 from PRE_setup_h5_chunk.st0.s3 to PRE_setup_h5_chunk.st0.s4 : runOk PRE_setup_h5_chunk.st0.F PRE_setup_h5_chunk.st0.okL ((nth? PRE_setup_h5_chunk.st0.ks 3).getD 0) PRE_setup_h5_chunk.st0.s3 PRE_setup_h5_chunk.st0.S3 = some (PRE_setup_h5_chunk.st0.s4, PRE_setup_h5_chunk.st0.S4)
end Host.Load.Run.Tpl
