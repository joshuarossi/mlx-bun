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
boot_rfl D1StageSplit.k4 from D1StageSplit.s4 to D1StageSplit.s5 : runOk D1StageSplit.F D1StageSplit.okB2 ((nth? D1StageSplit.ks 4).getD 0) D1StageSplit.s4 D1StageSplit.S4 = some (D1StageSplit.s5, D1StageSplit.S5)
boot_rfl D1StageSplit.stepA3 from D1StageSplit.s5 to D1StageSplit.s6 : interpS (step D1StageSplit.F D1StageSplit.s5).run D1StageSplit.S5 = some (D1StageSplit.s6, D1StageSplit.S6)
boot_rfl D1StageSplit.patchB3 from D1StageSplit.s6 to D1StageSplit.s7 : some (Host.Ts.Sim.Template.Bridge.lenPatch D1StageSplit.s6 D1StageSplit.S6 (.var 9)) = some (D1StageSplit.s7, D1StageSplit.S7)
boot_rfl D1StageSplit.k7 from D1StageSplit.s7 to D1StageSplit.s8 : runOk D1StageSplit.F D1StageSplit.okB3 ((nth? D1StageSplit.ks 7).getD 0) D1StageSplit.s7 D1StageSplit.S7 = some (D1StageSplit.s8, D1StageSplit.S8)
end Host.Load.Run.Tpl
