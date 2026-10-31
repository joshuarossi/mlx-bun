import host.sim.template.a4pre_setup_h5_chunk.NCl0
import host.sim.template.a4pre_setup_h5_chunk.SiteCl0
import host.sim.template.a4pre_setup_h5_chunk.GlueN1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The native bookkeeping of chain `PRE_setup_h5_chunk` at its end (boundary 3): the start's check and every piece's step. -/

theorem PRE_setup_h5_chunk.ncl2 : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_h5_chunk.s2.ffi).mlx := PRE_setup_h5_chunk.cncl0 PRE_setup_h5_chunk.ncl0
theorem PRE_setup_h5_chunk.ncl3 : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_h5_chunk.s3.ffi).mlx := PRE_setup_h5_chunk.gncl1 PRE_setup_h5_chunk.ncl2
theorem PRE_setup_h5_chunk.nclEnd : ∃ c, Conv.NClean c (Host.Load.Layers.toLoad PRE_setup_h5_chunk.s3.ffi).mlx := ⟨_, PRE_setup_h5_chunk.ncl3⟩

end Host.Load.Run.Tpl
