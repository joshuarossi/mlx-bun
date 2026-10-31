import host.sim.template.a4eos_cut_ctx.Patch
import host.sim.template.Split
import host.sim.template.Bridges
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
noncomputable def EOSCutCtxBase.s0 := EOSCutCtx.start
noncomputable def EOSCutCtxBase.S0 := EOSCutCtx.inputSrv
set_option interpreter.prefer_native true in
tpl_case_split EOSCutCtxRest from EOSCutCtxBase : "EOSX"
  bridging (Bridge.routeBridges { kinds := ["len", "spread"], lens := [(2665, EOSCutCtx.promptLen)] })
(world := full, spec := "/Users/joshrossi/proofdev/devout-sol-eos-framed/rest-spec.json", cap := 1000)
end Host.Load.Run.Tpl
