import host.sim.template.a4pre_d1_stage_split.H0
import host.sim.template.a4pre_d1_stage_split.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl D1StageSplit.k1 from D1StageSplit.s1 to D1StageSplit.s2 : runOk D1StageSplit.F D1StageSplit.okB1 ((nth? D1StageSplit.ks 1).getD 0) D1StageSplit.s1 D1StageSplit.S1 = some (D1StageSplit.s2, D1StageSplit.S2)
boot_rfl D1StageSplit.stepA2 from D1StageSplit.s2 to D1StageSplit.s3 : interpS (step D1StageSplit.F D1StageSplit.s2).run D1StageSplit.S2 = some (D1StageSplit.s3, D1StageSplit.S3)
boot_rfl D1StageSplit.patchB2 from D1StageSplit.s3 to D1StageSplit.s4 : some (Host.Ts.Sim.Template.Bridge.slicePatch D1StageSplit.s3 D1StageSplit.S3) = some (D1StageSplit.s4, D1StageSplit.S4)
end Host.Load.Run.Tpl
