import host.sim.template.a4pre_first_tail_x15_r0.NCl0
import host.sim.template.a4pre_first_tail_x15_r0.GlueN0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0.ncl4 : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx := PRE_first_tail_x15_r0.gncl0 PRE_first_tail_x15_r0.ncl0

end Host.Load.Run.Tpl
