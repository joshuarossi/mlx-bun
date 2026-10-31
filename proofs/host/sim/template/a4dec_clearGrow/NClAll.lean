import host.sim.template.a4dec_clearGrow.NCl0
import host.sim.template.a4dec_clearGrow.SiteCl0
import host.sim.template.a4dec_clearGrow.GlueN1
import host.sim.template.a4dec_clearGrow.SiteCl1
import host.sim.template.a4dec_clearGrow.GlueN2
import host.sim.template.a4dec_clearGrow.SiteCl2
import host.sim.template.a4dec_clearGrow.GlueN3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The native bookkeeping of chain `DEC_clearGrow` at its end (boundary 11): the start's check and every piece's step. -/

theorem DEC_clearGrow.ncl2 : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s2.ffi).mlx := DEC_clearGrow.cncl0 DEC_clearGrow.ncl0
theorem DEC_clearGrow.ncl4 : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx := DEC_clearGrow.gncl1 DEC_clearGrow.ncl2
theorem DEC_clearGrow.ncl6 : Conv.NClean (⟨29432, 24977, 3123900, 385⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s6.ffi).mlx := DEC_clearGrow.cncl1 DEC_clearGrow.ncl4
theorem DEC_clearGrow.ncl8 : Conv.NClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx := DEC_clearGrow.gncl2 DEC_clearGrow.ncl6
theorem DEC_clearGrow.ncl10 : Conv.NClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx := DEC_clearGrow.cncl2 DEC_clearGrow.ncl8
theorem DEC_clearGrow.ncl11 : Conv.NClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx := DEC_clearGrow.gncl3 DEC_clearGrow.ncl10
theorem DEC_clearGrow.nclEnd : ∃ c, Conv.NClean c (Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx := ⟨_, DEC_clearGrow.ncl11⟩

end Host.Load.Run.Tpl
