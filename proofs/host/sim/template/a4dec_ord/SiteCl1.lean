import host.sim.template.a4dec_ord.SiteK1
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_ord.ckA1 : (Host.Load.Layers.toLoad DEC_ord.s6.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.arrs (DEC_ord.clo1.filterMap fun i => ((Host.Load.Layers.toLoad DEC_ord.s6.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_ord.cbd1 : (DEC_ord.clo1 ++ DEC_ord.cln1 ++ DEC_ord.cli1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_ord.cle1 : Conv.Cnt.leB (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (⟨29432, 24913, 3123899, 353⟩ : Conv.Cnt) = true
kernel_rfl DEC_ord.cck1 : Conv.ncleanListB (⟨29432, 24913, 3123899, 353⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s6.ffi).mlx DEC_ord.clo1 DEC_ord.cln1 DEC_ord.cli1 = true
theorem DEC_ord.cncl1 (h : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx) : Conv.NClean (⟨29432, 24913, 3123899, 353⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s6.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_ord.cle1 DEC_ord.ckA1 DEC_ord.cobjsK1 DEC_ord.cnodesK1 DEC_ord.citemsK1 DEC_ord.cbd1 DEC_ord.cck1

end Host.Load.Run.Tpl
