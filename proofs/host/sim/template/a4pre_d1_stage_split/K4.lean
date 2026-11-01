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
boot_rfl D1StageSplit.k16 from D1StageSplit.s16 to D1StageSplit.s17 : runOk D1StageSplit.F D1StageSplit.okB6 ((nth? D1StageSplit.ks 16).getD 0) D1StageSplit.s16 D1StageSplit.S16 = some (D1StageSplit.s17, D1StageSplit.S17)
boot_rfl D1StageSplit.stepA7 from D1StageSplit.s17 to D1StageSplit.s18 : interpS (step D1StageSplit.F D1StageSplit.s17).run D1StageSplit.S17 = some (D1StageSplit.s18, D1StageSplit.S18)
boot_rfl D1StageSplit.patchB7 from D1StageSplit.s18 to D1StageSplit.s19 : some (Host.Ts.Sim.Template.Bridge.lenLitPatch D1StageSplit.s18 D1StageSplit.S18 (Host.Ts.F64.ofNat 1)) = some (D1StageSplit.s19, D1StageSplit.S19)
boot_rfl D1StageSplit.stepA8 from D1StageSplit.s19 to D1StageSplit.s20 : interpS (step D1StageSplit.F D1StageSplit.s19).run D1StageSplit.S19 = some (D1StageSplit.s20, D1StageSplit.S20)
end Host.Load.Run.Tpl
