import host.sim.template.a4dec_clearFill.SiteK2
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_clearFill.ckA2 : (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.arrs (DEC_clearFill.clo2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clearFill.cbd2 : (DEC_clearFill.clo2 ++ DEC_clearFill.cln2 ++ DEC_clearFill.cli2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearFill.cle2 : Conv.Cnt.leB (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) = true
kernel_rfl DEC_clearFill.cck2 : Conv.ncleanListB (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx DEC_clearFill.clo2 DEC_clearFill.cln2 DEC_clearFill.cli2 = true
theorem DEC_clearFill.cncl2 (h : Conv.NClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx) : Conv.NClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_clearFill.cle2 DEC_clearFill.ckA2 DEC_clearFill.cobjsK2 DEC_clearFill.cnodesK2 DEC_clearFill.citemsK2 DEC_clearFill.cbd2 DEC_clearFill.cck2

end Host.Load.Run.Tpl
