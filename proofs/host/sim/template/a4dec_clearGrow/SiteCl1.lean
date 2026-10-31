import host.sim.template.a4dec_clearGrow.SiteK1
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_clearGrow.ckA1 : (Host.Load.Layers.toLoad DEC_clearGrow.s6.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx.arrs (DEC_clearGrow.clo1.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearGrow.s6.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.cbd1 : (DEC_clearGrow.clo1 ++ DEC_clearGrow.cln1 ++ DEC_clearGrow.cli1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearGrow.cle1 : Conv.Cnt.leB (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (⟨29432, 24977, 3123900, 385⟩ : Conv.Cnt) = true
kernel_rfl DEC_clearGrow.cck1 : Conv.ncleanListB (⟨29432, 24977, 3123900, 385⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s6.ffi).mlx DEC_clearGrow.clo1 DEC_clearGrow.cln1 DEC_clearGrow.cli1 = true
theorem DEC_clearGrow.cncl1 (h : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s4.ffi).mlx) : Conv.NClean (⟨29432, 24977, 3123900, 385⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s6.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_clearGrow.cle1 DEC_clearGrow.ckA1 DEC_clearGrow.cobjsK1 DEC_clearGrow.cnodesK1 DEC_clearGrow.citemsK1 DEC_clearGrow.cbd1 DEC_clearGrow.cck1

end Host.Load.Run.Tpl
