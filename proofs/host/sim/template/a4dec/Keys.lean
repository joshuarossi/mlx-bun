import host.sim.template.a4dec.S
import host.sim.template.RestartCmd
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The template's unframed present addresses as explicit group chunks (`DT.gc<j>`, `DT.gks`); `DT.cover`. -/

tpl_keys DT

end Host.Load.Run.Tpl
