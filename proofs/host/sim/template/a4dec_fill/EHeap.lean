import host.sim.template.a4dec_fill.ERestart
import host.sim.template.a4dec.Keys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The heap clause of chain `DEC_fill`'s end shift, block by block. -/

tpl_heap_blocks DEC_fill.R from DT : DEC_fill.σ, DEC_fill.s0, DEC_fill.s11

end Host.Load.Run.Tpl
