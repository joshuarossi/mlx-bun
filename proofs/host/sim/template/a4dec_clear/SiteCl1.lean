import host.sim.template.a4dec_clear.SiteK1
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_clear.ckA1 : (Host.Load.Layers.toLoad DEC_clear.s6.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.arrs (DEC_clear.clo1.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clear.s6.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clear.cbd1 : (DEC_clear.clo1 ++ DEC_clear.cln1 ++ DEC_clear.cli1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clear.cle1 : Conv.Cnt.leB (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (⟨29432, 24913, 3123900, 353⟩ : Conv.Cnt) = true
kernel_rfl DEC_clear.cck1 : Conv.ncleanListB (⟨29432, 24913, 3123900, 353⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s6.ffi).mlx DEC_clear.clo1 DEC_clear.cln1 DEC_clear.cli1 = true
theorem DEC_clear.cncl1 (h : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx) : Conv.NClean (⟨29432, 24913, 3123900, 353⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s6.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_clear.cle1 DEC_clear.ckA1 DEC_clear.cobjsK1 DEC_clear.cnodesK1 DEC_clear.citemsK1 DEC_clear.cbd1 DEC_clear.cck1

end Host.Load.Run.Tpl
