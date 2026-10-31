import host.sim.template.a4dec_clearFill.NCl0
import host.sim.template.a4dec_clearFill.SiteCl0
import host.sim.template.a4dec_clearFill.GlueN1
import host.sim.template.a4dec_clearFill.SiteCl1
import host.sim.template.a4dec_clearFill.GlueN2
import host.sim.template.a4dec_clearFill.SiteCl2
import host.sim.template.a4dec_clearFill.GlueN3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The native bookkeeping of chain `DEC_clearFill` at its end (boundary 11): the start's check and every piece's step. -/

theorem DEC_clearFill.ncl2 : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx := DEC_clearFill.cncl0 DEC_clearFill.ncl0
theorem DEC_clearFill.ncl4 : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx := DEC_clearFill.gncl1 DEC_clearFill.ncl2
theorem DEC_clearFill.ncl6 : Conv.NClean (⟨29432, 24881, 3123900, 289⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s6.ffi).mlx := DEC_clearFill.cncl1 DEC_clearFill.ncl4
theorem DEC_clearFill.ncl8 : Conv.NClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx := DEC_clearFill.gncl2 DEC_clearFill.ncl6
theorem DEC_clearFill.ncl10 : Conv.NClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx := DEC_clearFill.cncl2 DEC_clearFill.ncl8
theorem DEC_clearFill.ncl11 : Conv.NClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx := DEC_clearFill.gncl3 DEC_clearFill.ncl10
theorem DEC_clearFill.nclEnd : ∃ c, Conv.NClean c (Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx := ⟨_, DEC_clearFill.ncl11⟩

end Host.Load.Run.Tpl
