import host.sim.template.a4dec_grow.NCl0
import host.sim.template.a4dec_grow.SiteCl0
import host.sim.template.a4dec_grow.GlueN1
import host.sim.template.a4dec_grow.SiteCl1
import host.sim.template.a4dec_grow.GlueN2
import host.sim.template.a4dec_grow.SiteCl2
import host.sim.template.a4dec_grow.GlueN3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The native bookkeeping of chain `DEC_grow` at its end (boundary 11): the start's check and every piece's step. -/

theorem DEC_grow.ncl2 : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s2.ffi).mlx := DEC_grow.cncl0 DEC_grow.ncl0
theorem DEC_grow.ncl4 : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx := DEC_grow.gncl1 DEC_grow.ncl2
theorem DEC_grow.ncl6 : Conv.NClean (⟨29432, 24977, 3123899, 385⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s6.ffi).mlx := DEC_grow.cncl1 DEC_grow.ncl4
theorem DEC_grow.ncl8 : Conv.NClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx := DEC_grow.gncl2 DEC_grow.ncl6
theorem DEC_grow.ncl10 : Conv.NClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx := DEC_grow.cncl2 DEC_grow.ncl8
theorem DEC_grow.ncl11 : Conv.NClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx := DEC_grow.gncl3 DEC_grow.ncl10
theorem DEC_grow.nclEnd : ∃ c, Conv.NClean c (Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx := ⟨_, DEC_grow.ncl11⟩

end Host.Load.Run.Tpl
