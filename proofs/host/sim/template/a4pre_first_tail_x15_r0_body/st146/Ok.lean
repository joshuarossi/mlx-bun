import host.sim.template.FullOk
import host.sim.template.Stage
import host.sim.full.BackSim
import host.sim.dispatch.OkJs
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance of stage `PRE_first_tail_x15_r0_body.st146` (plan, `plan`): the world's under the caller's frames (its framed
arrays and wide frames the start holds, `Conv.isoCtxW`), at local states only. -/
noncomputable def PRE_first_tail_x15_r0_body.st146.okL : St Host.Load.Layers.full.S → SSrv → Bool :=
  Host.Ts.Sim.Template.okLocal (Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665, 2673467, 2673472, 2673473] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096)

end Host.Load.Run.Tpl
