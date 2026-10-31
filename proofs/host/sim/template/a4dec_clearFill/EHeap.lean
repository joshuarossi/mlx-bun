import host.sim.template.a4dec_clearFill.ERestart
import host.sim.template.a4dec.Keys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The heap clause of chain `DEC_clearFill`'s end shift, block by block. -/

tpl_heap_blocks DEC_clearFill.R from DT : DEC_clearFill.σ, DEC_clearFill.s0, DEC_clearFill.s11

end Host.Load.Run.Tpl
