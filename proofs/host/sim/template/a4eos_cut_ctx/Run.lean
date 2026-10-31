import host.sim.template.a4eos_cut_ctx.K0
import host.sim.template.a4eos_cut_ctx.K1
import host.sim.template.ChainRange
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim Host.Ts.Sim.Template
sim_chain_range EOSCutCtxRest EOSCutCtxRest.okB0 0 1 runSeg0
sim_chain_range EOSCutCtxRest EOSCutCtxRest.okB2 6 7 runSeg2
end Host.Load.Run.Tpl
