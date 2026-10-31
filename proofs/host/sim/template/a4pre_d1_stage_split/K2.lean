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
boot_rfl D1StageSplit.stepA4 from D1StageSplit.s8 to D1StageSplit.s9 : interpS (step D1StageSplit.F D1StageSplit.s8).run D1StageSplit.S8 = some (D1StageSplit.s9, D1StageSplit.S9)
boot_rfl D1StageSplit.patchB4 from D1StageSplit.s9 to D1StageSplit.s10 : some (Host.Ts.Sim.Template.Bridge.typedPatch D1StageSplit.F D1StageSplit.s9 D1StageSplit.S9 21) = some (D1StageSplit.s10, D1StageSplit.S10)
boot_rfl D1StageSplit.k10 from D1StageSplit.s10 to D1StageSplit.s11 : runOk D1StageSplit.F D1StageSplit.okB4 ((nth? D1StageSplit.ks 10).getD 0) D1StageSplit.s10 D1StageSplit.S10 = some (D1StageSplit.s11, D1StageSplit.S11)
boot_rfl D1StageSplit.stepA5 from D1StageSplit.s11 to D1StageSplit.s12 : interpS (step D1StageSplit.F D1StageSplit.s11).run D1StageSplit.S11 = some (D1StageSplit.s12, D1StageSplit.S12)
end Host.Load.Run.Tpl
