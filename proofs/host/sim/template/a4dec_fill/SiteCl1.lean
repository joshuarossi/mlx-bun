import host.sim.template.a4dec_fill.SiteK1
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_fill.ckA1 : (Host.Load.Layers.toLoad DEC_fill.s6.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.arrs (DEC_fill.clo1.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.s6.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_fill.cbd1 : (DEC_fill.clo1 ++ DEC_fill.cln1 ++ DEC_fill.cli1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_fill.cle1 : Conv.Cnt.leB (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (⟨29432, 24881, 3123899, 289⟩ : Conv.Cnt) = true
kernel_rfl DEC_fill.cck1 : Conv.ncleanListB (⟨29432, 24881, 3123899, 289⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s6.ffi).mlx DEC_fill.clo1 DEC_fill.cln1 DEC_fill.cli1 = true
theorem DEC_fill.cncl1 (h : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx) : Conv.NClean (⟨29432, 24881, 3123899, 289⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s6.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_fill.cle1 DEC_fill.ckA1 DEC_fill.cobjsK1 DEC_fill.cnodesK1 DEC_fill.citemsK1 DEC_fill.cbd1 DEC_fill.cck1

end Host.Load.Run.Tpl
