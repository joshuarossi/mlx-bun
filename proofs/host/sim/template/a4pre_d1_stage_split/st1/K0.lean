import host.sim.template.a4pre_d1_stage_split.st1.H0
import host.sim.template.a4pre_d1_stage_split.st1.Ok
import host.sim.Chunk
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl D1StageSplit.st1.k0 from D1StageSplit.st1.s0 to D1StageSplit.st1.s1 : runOk D1StageSplit.st1.F D1StageSplit.st1.okL ((nth? D1StageSplit.st1.ks 0).getD 0) D1StageSplit.st1.s0 D1StageSplit.st1.S0 = some (D1StageSplit.st1.s1, D1StageSplit.st1.S1)
boot_rfl D1StageSplit.st1.last from D1StageSplit.st1.s1 to D1StageSplit.st1.s2 : interpS (step D1StageSplit.st1.F D1StageSplit.st1.s1).run D1StageSplit.st1.S1 = some (D1StageSplit.st1.s2, D1StageSplit.st1.S2)
end Host.Load.Run.Tpl
