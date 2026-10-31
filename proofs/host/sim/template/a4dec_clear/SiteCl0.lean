import host.sim.template.a4dec_clear.SiteK0
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_clear.ckA0 : (Host.Load.Layers.toLoad DEC_clear.s2.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.arrs (DEC_clear.clo0.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clear.s2.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clear.cbd0 : (DEC_clear.clo0 ++ DEC_clear.cln0 ++ DEC_clear.cli0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clear.cle0 : Conv.Cnt.leB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) = true
kernel_rfl DEC_clear.cck0 : Conv.ncleanListB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s2.ffi).mlx DEC_clear.clo0 DEC_clear.cln0 DEC_clear.cli0 = true
theorem DEC_clear.cncl0 (h : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx) : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s2.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_clear.cle0 DEC_clear.ckA0 DEC_clear.cobjsK0 DEC_clear.cnodesK0 DEC_clear.citemsK0 DEC_clear.cbd0 DEC_clear.cck0

end Host.Load.Run.Tpl
