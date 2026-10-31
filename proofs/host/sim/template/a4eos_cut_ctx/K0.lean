import host.sim.template.a4eos_cut_ctx.H0
import host.sim.template.a4eos_cut_ctx.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk EOSCutCtxRest EOSCutCtxRest.okB0 0
kernel_rfl EOSCutCtxRest.stepA1 : interpS (step EOSCutCtxRest.F EOSCutCtxRest.s1).run EOSCutCtxRest.S1 = some (EOSCutCtxRest.s2, EOSCutCtxRest.S2)
kernel_rfl EOSCutCtxRest.patchB1 : some (Host.Ts.Sim.Template.Bridge.lenPatch EOSCutCtxRest.s2 EOSCutCtxRest.S2 (EOSCutCtx.promptLen)) = some (EOSCutCtxRest.s3, EOSCutCtxRest.S3)
end Host.Load.Run.Tpl
