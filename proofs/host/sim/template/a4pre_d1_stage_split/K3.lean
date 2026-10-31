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
boot_rfl D1StageSplit.patchB5 from D1StageSplit.s12 to D1StageSplit.s13 : some (Host.Ts.Sim.Template.Bridge.ptrPatch D1StageSplit.s12 D1StageSplit.S12 2673484 0) = some (D1StageSplit.s13, D1StageSplit.S13)
boot_rfl D1StageSplit.k13 from D1StageSplit.s13 to D1StageSplit.s14 : runOk D1StageSplit.F D1StageSplit.okB5 ((nth? D1StageSplit.ks 13).getD 0) D1StageSplit.s13 D1StageSplit.S13 = some (D1StageSplit.s14, D1StageSplit.S14)
boot_rfl D1StageSplit.stepA6 from D1StageSplit.s14 to D1StageSplit.s15 : interpS (step D1StageSplit.F D1StageSplit.s14).run D1StageSplit.S14 = some (D1StageSplit.s15, D1StageSplit.S15)
boot_rfl D1StageSplit.patchB6 from D1StageSplit.s15 to D1StageSplit.s16 : Host.Ts.Sim.Template.Bridge.newdataPatch D1StageSplit.F D1StageSplit.s15 D1StageSplit.S15 [] = some (D1StageSplit.s16, D1StageSplit.S16)
end Host.Load.Run.Tpl
