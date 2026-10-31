import host.sim.template.a4pre_first_tail_x15_r0.NClCall2
import host.sim.template.a4pre_first_tail_x15_r0.SiteCl2
import host.sim.template.a4pre_first_tail_x15_r0.GlueN3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0.ncl40 : Conv.NClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx := PRE_first_tail_x15_r0.cncl2 PRE_first_tail_x15_r0.ncl38
theorem PRE_first_tail_x15_r0.ncl41 : Conv.NClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s41.ffi).mlx := PRE_first_tail_x15_r0.gncl3 PRE_first_tail_x15_r0.ncl40
theorem PRE_first_tail_x15_r0.nclEnd : ∃ c, Conv.NClean c (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s41.ffi).mlx := ⟨_, PRE_first_tail_x15_r0.ncl41⟩

end Host.Load.Run.Tpl
