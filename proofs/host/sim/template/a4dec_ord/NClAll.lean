import host.sim.template.a4dec_ord.NCl0
import host.sim.template.a4dec_ord.SiteCl0
import host.sim.template.a4dec_ord.GlueN1
import host.sim.template.a4dec_ord.SiteCl1
import host.sim.template.a4dec_ord.GlueN2
import host.sim.template.a4dec_ord.SiteCl2
import host.sim.template.a4dec_ord.GlueN3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The native bookkeeping of chain `DEC_ord` at its end (boundary 11): the start's check and every piece's step. -/

theorem DEC_ord.ncl2 : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx := DEC_ord.cncl0 DEC_ord.ncl0
theorem DEC_ord.ncl4 : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx := DEC_ord.gncl1 DEC_ord.ncl2
theorem DEC_ord.ncl6 : Conv.NClean (⟨29432, 24913, 3123899, 353⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s6.ffi).mlx := DEC_ord.cncl1 DEC_ord.ncl4
theorem DEC_ord.ncl8 : Conv.NClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx := DEC_ord.gncl2 DEC_ord.ncl6
theorem DEC_ord.ncl10 : Conv.NClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx := DEC_ord.cncl2 DEC_ord.ncl8
theorem DEC_ord.ncl11 : Conv.NClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx := DEC_ord.gncl3 DEC_ord.ncl10
theorem DEC_ord.nclEnd : ∃ c, Conv.NClean c (Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx := ⟨_, DEC_ord.ncl11⟩

end Host.Load.Run.Tpl
