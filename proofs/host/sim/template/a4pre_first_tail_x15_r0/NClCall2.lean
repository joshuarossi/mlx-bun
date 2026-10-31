import host.sim.template.a4pre_first_tail_x15_r0.NClCall1
import host.sim.template.a4pre_first_tail_x15_r0.SiteCl1
import host.sim.template.a4pre_first_tail_x15_r0.GlueN2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0.ncl19 : Conv.NClean (⟨18155, 15235, 2673458, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx := PRE_first_tail_x15_r0.cncl1 PRE_first_tail_x15_r0.ncl17
theorem PRE_first_tail_x15_r0.ncl38 : Conv.NClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s38.ffi).mlx := PRE_first_tail_x15_r0.gncl2 PRE_first_tail_x15_r0.ncl19

end Host.Load.Run.Tpl
