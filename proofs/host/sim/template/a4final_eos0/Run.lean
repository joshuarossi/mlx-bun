import host.sim.template.a4final_eos0.K0
import host.sim.template.a4final_eos0.K1
import host.sim.template.a4final_eos0.K2
import host.sim.template.ChainRange
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim Host.Ts.Sim.Template
sim_chain_range FinalEos0 FinalEos0.okB0 0 1 runSeg0
sim_chain_range FinalEos0 FinalEos0.okB1 3 4 runSeg1
sim_chain_range FinalEos0 FinalEos0.okB3 9 10 runSeg3
end Host.Load.Run.Tpl
