import host.sim.template.a4pre_d1_stage_split.K0
import host.sim.template.a4pre_d1_stage_split.K1
import host.sim.template.a4pre_d1_stage_split.K2
import host.sim.template.a4pre_d1_stage_split.K3
import host.sim.template.a4pre_d1_stage_split.K4
import host.sim.template.a4pre_d1_stage_split.K5
import host.sim.template.ChainRange
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim Host.Ts.Sim.Template
sim_chain_range D1StageSplit D1StageSplit.okB1 1 2 runSeg1
sim_chain_range D1StageSplit D1StageSplit.okB2 4 5 runSeg2
sim_chain_range D1StageSplit D1StageSplit.okB3 7 8 runSeg3
sim_chain_range D1StageSplit D1StageSplit.okB4 10 11 runSeg4
sim_chain_range D1StageSplit D1StageSplit.okB5 13 14 runSeg5
sim_chain_range D1StageSplit D1StageSplit.okB6 16 17 runSeg6
sim_chain_range D1StageSplit D1StageSplit.okB8 21 22 runSeg8
end Host.Load.Run.Tpl
