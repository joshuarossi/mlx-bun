import host.sim.template.a4dec_clear.st0.K0
import host.sim.template.ChainRange
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim Host.Ts.Sim.Template
sim_chain_range DEC_clear.st0 DEC_clear.st0.okL 0 1 run
end Host.Load.Run.Tpl
