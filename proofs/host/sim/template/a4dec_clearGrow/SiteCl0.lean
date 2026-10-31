import host.sim.template.a4dec_clearGrow.SiteK0
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_clearGrow.ckA0 : (Host.Load.Layers.toLoad DEC_clearGrow.s2.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.arrs (DEC_clearGrow.clo0.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearGrow.s2.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.cbd0 : (DEC_clearGrow.clo0 ++ DEC_clearGrow.cln0 ++ DEC_clearGrow.cli0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearGrow.cle0 : Conv.Cnt.leB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) = true
kernel_rfl DEC_clearGrow.cck0 : Conv.ncleanListB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s2.ffi).mlx DEC_clearGrow.clo0 DEC_clearGrow.cln0 DEC_clearGrow.cli0 = true
theorem DEC_clearGrow.cncl0 (h : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx) : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s2.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_clearGrow.cle0 DEC_clearGrow.ckA0 DEC_clearGrow.cobjsK0 DEC_clearGrow.cnodesK0 DEC_clearGrow.citemsK0 DEC_clearGrow.cbd0 DEC_clearGrow.cck0

end Host.Load.Run.Tpl
