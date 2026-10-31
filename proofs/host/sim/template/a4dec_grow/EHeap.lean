import host.sim.template.a4dec_grow.ERestart
import host.sim.template.a4dec.Keys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The heap clause of chain `DEC_grow`'s end shift, block by block. -/

tpl_heap_blocks DEC_grow.R from DT : DEC_grow.σ, DEC_grow.s0, DEC_grow.s11

end Host.Load.Run.Tpl
