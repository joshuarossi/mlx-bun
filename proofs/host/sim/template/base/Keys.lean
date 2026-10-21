import host.sim.template.base.S
import host.sim.template.RestartCmd
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The template's unframed present addresses as explicit group chunks
(`Base.gc<j>`, concatenated `Base.gks`), checked chunk by chunk against the heap;
`Base.cover` lists every unframed present address. -/

tpl_keys Base

end Host.Load.Run.Tpl
