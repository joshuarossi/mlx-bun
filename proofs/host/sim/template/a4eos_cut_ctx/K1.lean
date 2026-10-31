import host.sim.template.a4eos_cut_ctx.H0
import host.sim.template.a4eos_cut_ctx.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
kernel_rfl EOSCutCtxRest.stepA2 : interpS (step EOSCutCtxRest.F EOSCutCtxRest.s4).run EOSCutCtxRest.S4 = some (EOSCutCtxRest.s5, EOSCutCtxRest.S5)
kernel_rfl EOSCutCtxRest.stepB2 : interpS (step EOSCutCtxRest.F EOSCutCtxRest.s5).run EOSCutCtxRest.S5 = some (EOSCutCtxRest.s6, EOSCutCtxRest.S6)
sim_chunk EOSCutCtxRest EOSCutCtxRest.okB2 6
end Host.Load.Run.Tpl
