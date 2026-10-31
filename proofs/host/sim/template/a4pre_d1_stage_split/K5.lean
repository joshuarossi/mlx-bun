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
boot_rfl D1StageSplit.k21 from D1StageSplit.s21 to D1StageSplit.s22 : runOk D1StageSplit.F D1StageSplit.okB8 ((nth? D1StageSplit.ks 21).getD 0) D1StageSplit.s21 D1StageSplit.S21 = some (D1StageSplit.s22, D1StageSplit.S22)
end Host.Load.Run.Tpl
