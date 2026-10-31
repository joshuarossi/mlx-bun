import host.sim.template.FullOk
import host.sim.template.Stage
import host.sim.full.BackSim
import host.sim.dispatch.OkJs
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance of stage `D1StageSplit.st0` (nps, `nextPrefillStep`): the world's under the caller's frames (its framed
arrays and wide frames the start holds, `Conv.isoCtxW`), at local states only. -/
noncomputable def D1StageSplit.st0.okL : St Host.Load.Layers.full.S → SSrv → Bool :=
  Host.Ts.Sim.Template.okLocal (Disp.okJSJ (Host.Ts.Sim.Template.fullJSPPXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩ [2665] [(4910, .memo [])]) (Host.Ts.Sim.Full.okBackFXS ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩) 4096)

end Host.Load.Run.Tpl
