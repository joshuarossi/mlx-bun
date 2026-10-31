import host.sim.template.a4pre_setup_early_r0.NCl0
import host.sim.template.a4pre_setup_early_r0.GlueN0
import host.sim.template.a4pre_setup_early_r0.SiteCl0
import host.sim.template.a4pre_setup_early_r0.GlueN1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The native bookkeeping of chain `PRE_setup_early_r0` at its end (boundary 16): the start's check and every piece's step. -/

theorem PRE_setup_early_r0.ncl4 : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_early_r0.s4.ffi).mlx := PRE_setup_early_r0.gncl0 PRE_setup_early_r0.ncl0
theorem PRE_setup_early_r0.ncl6 : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_early_r0.s6.ffi).mlx := PRE_setup_early_r0.cncl0 PRE_setup_early_r0.ncl4
theorem PRE_setup_early_r0.ncl16 : Conv.NClean (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_early_r0.s16.ffi).mlx := PRE_setup_early_r0.gncl1 PRE_setup_early_r0.ncl6
theorem PRE_setup_early_r0.nclEnd : ∃ c, Conv.NClean c (Host.Load.Layers.toLoad PRE_setup_early_r0.s16.ffi).mlx := ⟨_, PRE_setup_early_r0.ncl16⟩

end Host.Load.Run.Tpl
