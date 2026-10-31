import host.sim.template.FullOk
import host.sim.template.Stage
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-- The acceptance of stage `DEC_clearFill.st0` (rb, `itemUint32`): the world's under the caller's frames (its framed
arrays and wide frames the start holds, `Conv.isoCtxW`), at local states only. -/
noncomputable def DEC_clearFill.st0.okL : St Host.Load.Layers.full.S → SSrv → Bool :=
  Host.Ts.Sim.Template.okLocal (Disp.okJSK (Host.Ts.Sim.Template.fullJSPP ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩ [2673448, 12504, 2665, 4910] [(4910, .memo [])]) (fun _ _ => false))

end Host.Load.Run.Tpl
