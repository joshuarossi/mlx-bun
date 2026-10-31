import host.sim.template.a4eos_cut_ctx.SpreadH0
import host.sim.template.a4eos_cut_ctx.OkB
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
noncomputable abbrev EOSCutCtx.spPre := EOSCutCtxSp.s1
noncomputable abbrev EOSCutCtx.spPreSrv := EOSCutCtxSp.S1
noncomputable def EOSCutCtx.spOpen := EOSCutCtx.spPre.ret (.obj 2665)
noncomputable abbrev EOSCutCtx.spOpenSrv := EOSCutCtx.spPreSrv
kernel_rfl EOSCutCtx.spRun : runOk EOSCutCtxRest.F EOSCutCtxRest.okB1 33 EOSCutCtxRest.s3 EOSCutCtxRest.S3 =
  some (EOSCutCtx.spPre, EOSCutCtx.spPreSrv)
kernel_rfl EOSCutCtx.spInto : interpS (step EOSCutCtxRest.F EOSCutCtx.spPre).run EOSCutCtx.spPreSrv =
  some (EOSCutCtx.spOpen, EOSCutCtx.spOpenSrv)
end Host.Load.Run.Tpl
