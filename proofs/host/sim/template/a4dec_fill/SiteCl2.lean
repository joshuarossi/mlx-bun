import host.sim.template.a4dec_fill.SiteK2
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_fill.ckA2 : (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.arrs (DEC_fill.clo2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_fill.cbd2 : (DEC_fill.clo2 ++ DEC_fill.cln2 ++ DEC_fill.cli2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_fill.cle2 : Conv.Cnt.leB (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) = true
kernel_rfl DEC_fill.cck2 : Conv.ncleanListB (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx DEC_fill.clo2 DEC_fill.cln2 DEC_fill.cli2 = true
theorem DEC_fill.cncl2 (h : Conv.NClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx) : Conv.NClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_fill.cle2 DEC_fill.ckA2 DEC_fill.cobjsK2 DEC_fill.cnodesK2 DEC_fill.citemsK2 DEC_fill.cbd2 DEC_fill.cck2

end Host.Load.Run.Tpl
