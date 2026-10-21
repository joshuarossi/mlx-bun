import host.sim.template.growth.Restart
import host.sim.template.base.Keys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The heap clause of the `GROWTH` shift, block by block (kernel evaluation):
every unframed present address of `Base.s0` holds, at its image in
`GROWTH.s153`, the image of its entry. -/

tpl_heap_blocks GROWTH.R from Base : GROWTH.σ, Base.s0, GROWTH.s153

end Host.Load.Run.Tpl
