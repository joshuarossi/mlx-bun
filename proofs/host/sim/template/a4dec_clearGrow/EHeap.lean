import host.sim.template.a4dec_clearGrow.ERestart
import host.sim.template.a4dec.Keys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The heap clause of chain `DEC_clearGrow`'s end shift, block by block. -/

tpl_heap_blocks DEC_clearGrow.R from DT : DEC_clearGrow.σ, DEC_clearGrow.s0, DEC_clearGrow.s11

end Host.Load.Run.Tpl
