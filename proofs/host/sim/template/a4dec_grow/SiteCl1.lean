import host.sim.template.a4dec_grow.SiteK1
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_grow.ckA1 : (Host.Load.Layers.toLoad DEC_grow.s6.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx.arrs (DEC_grow.clo1.filterMap fun i => ((Host.Load.Layers.toLoad DEC_grow.s6.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_grow.cbd1 : (DEC_grow.clo1 ++ DEC_grow.cln1 ++ DEC_grow.cli1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_grow.cle1 : Conv.Cnt.leB (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (⟨29432, 24977, 3123899, 385⟩ : Conv.Cnt) = true
kernel_rfl DEC_grow.cck1 : Conv.ncleanListB (⟨29432, 24977, 3123899, 385⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s6.ffi).mlx DEC_grow.clo1 DEC_grow.cln1 DEC_grow.cli1 = true
theorem DEC_grow.cncl1 (h : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s4.ffi).mlx) : Conv.NClean (⟨29432, 24977, 3123899, 385⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s6.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_grow.cle1 DEC_grow.ckA1 DEC_grow.cobjsK1 DEC_grow.cnodesK1 DEC_grow.citemsK1 DEC_grow.cbd1 DEC_grow.cck1

end Host.Load.Run.Tpl
