import host.sim.template.a4dec_ord.SiteK0
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_ord.ckA0 : (Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.arrs (DEC_ord.clo0.filterMap fun i => ((Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_ord.cbd0 : (DEC_ord.clo0 ++ DEC_ord.cln0 ++ DEC_ord.cli0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_ord.cle0 : Conv.Cnt.leB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) = true
kernel_rfl DEC_ord.cck0 : Conv.ncleanListB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx DEC_ord.clo0 DEC_ord.cln0 DEC_ord.cli0 = true
theorem DEC_ord.cncl0 (h : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx) : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_ord.cle0 DEC_ord.ckA0 DEC_ord.cobjsK0 DEC_ord.cnodesK0 DEC_ord.citemsK0 DEC_ord.cbd0 DEC_ord.cck0

end Host.Load.Run.Tpl
