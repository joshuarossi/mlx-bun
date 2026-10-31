import host.sim.template.a4pre_g0b.NCl0
import host.sim.template.a4pre_g0b.GlueN0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The native bookkeeping of chain `PRE_g0b` at its end (boundary 10): the start's check and every piece's step. -/

theorem PRE_g0b.ncl10 : Conv.NClean (⟨18155, 15235, 2673457, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_g0b.s10.ffi).mlx := PRE_g0b.gncl0 PRE_g0b.ncl0
theorem PRE_g0b.nclEnd : ∃ c, Conv.NClean c (Host.Load.Layers.toLoad PRE_g0b.s10.ffi).mlx := ⟨_, PRE_g0b.ncl10⟩

end Host.Load.Run.Tpl
