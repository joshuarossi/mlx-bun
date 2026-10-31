import host.sim.template.a4pre_setup_h5_chunk.H0
import host.sim.template.a4pre_setup_h5_chunk.OkB
import host.sim.Chunk
import host.sim.template.BootEq
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_setup_h5_chunk.k2 from PRE_setup_h5_chunk.s2 to PRE_setup_h5_chunk.s3 : runOk PRE_setup_h5_chunk.F PRE_setup_h5_chunk.okB1 ((nth? PRE_setup_h5_chunk.ks 2).getD 0) PRE_setup_h5_chunk.s2 PRE_setup_h5_chunk.S2 = some (PRE_setup_h5_chunk.s3, PRE_setup_h5_chunk.S3)
end Host.Load.Run.Tpl
