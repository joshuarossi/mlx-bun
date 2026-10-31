import host.sim.template.a4dec_clear.NCl0
import host.sim.template.a4dec_clear.SiteCl0
import host.sim.template.a4dec_clear.GlueN1
import host.sim.template.a4dec_clear.SiteCl1
import host.sim.template.a4dec_clear.GlueN2
import host.sim.template.a4dec_clear.SiteCl2
import host.sim.template.a4dec_clear.GlueN3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The native bookkeeping of chain `DEC_clear` at its end (boundary 11): the start's check and every piece's step. -/

theorem DEC_clear.ncl2 : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s2.ffi).mlx := DEC_clear.cncl0 DEC_clear.ncl0
theorem DEC_clear.ncl4 : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx := DEC_clear.gncl1 DEC_clear.ncl2
theorem DEC_clear.ncl6 : Conv.NClean (⟨29432, 24913, 3123900, 353⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s6.ffi).mlx := DEC_clear.cncl1 DEC_clear.ncl4
theorem DEC_clear.ncl8 : Conv.NClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx := DEC_clear.gncl2 DEC_clear.ncl6
theorem DEC_clear.ncl10 : Conv.NClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx := DEC_clear.cncl2 DEC_clear.ncl8
theorem DEC_clear.ncl11 : Conv.NClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx := DEC_clear.gncl3 DEC_clear.ncl10
theorem DEC_clear.nclEnd : ∃ c, Conv.NClean c (Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx := ⟨_, DEC_clear.ncl11⟩

end Host.Load.Run.Tpl
