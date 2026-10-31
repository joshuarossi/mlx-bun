import host.sim.template.a4dec_ord.SiteK2
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_ord.ckA2 : (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.arrs (DEC_ord.clo2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_ord.cbd2 : (DEC_ord.clo2 ++ DEC_ord.cln2 ++ DEC_ord.cli2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_ord.cle2 : Conv.Cnt.leB (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) = true
kernel_rfl DEC_ord.cck2 : Conv.ncleanListB (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx DEC_ord.clo2 DEC_ord.cln2 DEC_ord.cli2 = true
theorem DEC_ord.cncl2 (h : Conv.NClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx) : Conv.NClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_ord.cle2 DEC_ord.ckA2 DEC_ord.cobjsK2 DEC_ord.cnodesK2 DEC_ord.citemsK2 DEC_ord.cbd2 DEC_ord.cck2

end Host.Load.Run.Tpl
