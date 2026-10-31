import host.sim.template.a4final_plain.K0
import host.sim.template.a4final_plain.K1
import host.sim.template.a4final_plain.K2
import host.sim.template.ChainRange
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim Host.Ts.Sim.Template
sim_chain_range FinalPlain FinalPlain.okB0 0 1 runSeg0
sim_chain_range FinalPlain FinalPlain.okB1 3 4 runSeg1
sim_chain_range FinalPlain FinalPlain.okB3 9 10 runSeg3
end Host.Load.Run.Tpl
