import host.sim.template.a4pre_first_tail_x15_r0_suffix.NCl0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.GlueN0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.SiteCl0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.GlueN1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The native bookkeeping of chain `PRE_first_tail_x15_r0_suffix` at its end (boundary 8): the start's check and every piece's step. -/

theorem PRE_first_tail_x15_r0_suffix.ncl2 : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx := PRE_first_tail_x15_r0_suffix.gncl0 PRE_first_tail_x15_r0_suffix.ncl0
theorem PRE_first_tail_x15_r0_suffix.ncl4 : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx := PRE_first_tail_x15_r0_suffix.cncl0 PRE_first_tail_x15_r0_suffix.ncl2
theorem PRE_first_tail_x15_r0_suffix.ncl8 : Conv.NClean (⟨21966, 19057, 2825043, 8227⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s8.ffi).mlx := PRE_first_tail_x15_r0_suffix.gncl1 PRE_first_tail_x15_r0_suffix.ncl4
theorem PRE_first_tail_x15_r0_suffix.nclEnd : ∃ c, Conv.NClean c (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s8.ffi).mlx := ⟨_, PRE_first_tail_x15_r0_suffix.ncl8⟩

end Host.Load.Run.Tpl
