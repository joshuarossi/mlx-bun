import host.sim.template.a4dec_fill.NCl0
import host.sim.template.a4dec_fill.SiteCl0
import host.sim.template.a4dec_fill.GlueN1
import host.sim.template.a4dec_fill.SiteCl1
import host.sim.template.a4dec_fill.GlueN2
import host.sim.template.a4dec_fill.SiteCl2
import host.sim.template.a4dec_fill.GlueN3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The native bookkeeping of chain `DEC_fill` at its end (boundary 11): the start's check and every piece's step. -/

theorem DEC_fill.ncl2 : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s2.ffi).mlx := DEC_fill.cncl0 DEC_fill.ncl0
theorem DEC_fill.ncl4 : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx := DEC_fill.gncl1 DEC_fill.ncl2
theorem DEC_fill.ncl6 : Conv.NClean (⟨29432, 24881, 3123899, 289⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s6.ffi).mlx := DEC_fill.cncl1 DEC_fill.ncl4
theorem DEC_fill.ncl8 : Conv.NClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx := DEC_fill.gncl2 DEC_fill.ncl6
theorem DEC_fill.ncl10 : Conv.NClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx := DEC_fill.cncl2 DEC_fill.ncl8
theorem DEC_fill.ncl11 : Conv.NClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx := DEC_fill.gncl3 DEC_fill.ncl10
theorem DEC_fill.nclEnd : ∃ c, Conv.NClean c (Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx := ⟨_, DEC_fill.ncl11⟩

end Host.Load.Run.Tpl
