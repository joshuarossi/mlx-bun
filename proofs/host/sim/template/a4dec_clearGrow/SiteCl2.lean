import host.sim.template.a4dec_clearGrow.SiteK2
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_clearGrow.ckA2 : (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.arrs (DEC_clearGrow.clo2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.cbd2 : (DEC_clearGrow.clo2 ++ DEC_clearGrow.cln2 ++ DEC_clearGrow.cli2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearGrow.cle2 : Conv.Cnt.leB (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) = true
kernel_rfl DEC_clearGrow.cck2 : Conv.ncleanListB (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx DEC_clearGrow.clo2 DEC_clearGrow.cln2 DEC_clearGrow.cli2 = true
theorem DEC_clearGrow.cncl2 (h : Conv.NClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx) : Conv.NClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_clearGrow.cle2 DEC_clearGrow.ckA2 DEC_clearGrow.cobjsK2 DEC_clearGrow.cnodesK2 DEC_clearGrow.citemsK2 DEC_clearGrow.cbd2 DEC_clearGrow.cck2

end Host.Load.Run.Tpl
