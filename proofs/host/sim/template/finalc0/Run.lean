import host.sim.template.finalc0.K0
import host.sim.template.ChainRange
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim Host.Ts.Sim.Template
sim_chain_range FINALC0 ok 0 1 runA
sim_chain_range FINALC0 FINALC0.okB 3 4 runB
end Host.Load.Run.Tpl
