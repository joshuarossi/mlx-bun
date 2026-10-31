import host.sim.template.a4dec_grow.SiteK2
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_grow.ckA2 : (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.arrs (DEC_grow.clo2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_grow.cbd2 : (DEC_grow.clo2 ++ DEC_grow.cln2 ++ DEC_grow.cli2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_grow.cle2 : Conv.Cnt.leB (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) = true
kernel_rfl DEC_grow.cck2 : Conv.ncleanListB (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx DEC_grow.clo2 DEC_grow.cln2 DEC_grow.cli2 = true
theorem DEC_grow.cncl2 (h : Conv.NClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx) : Conv.NClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_grow.cle2 DEC_grow.ckA2 DEC_grow.cobjsK2 DEC_grow.cnodesK2 DEC_grow.citemsK2 DEC_grow.cbd2 DEC_grow.cck2

end Host.Load.Run.Tpl
