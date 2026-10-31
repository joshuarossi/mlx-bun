import host.sim.template.a4dec_grow.SiteK0
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_grow.ckA0 : (Host.Load.Layers.toLoad DEC_grow.s2.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.arrs (DEC_grow.clo0.filterMap fun i => ((Host.Load.Layers.toLoad DEC_grow.s2.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_grow.cbd0 : (DEC_grow.clo0 ++ DEC_grow.cln0 ++ DEC_grow.cli0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_grow.cle0 : Conv.Cnt.leB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) = true
kernel_rfl DEC_grow.cck0 : Conv.ncleanListB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s2.ffi).mlx DEC_grow.clo0 DEC_grow.cln0 DEC_grow.cli0 = true
theorem DEC_grow.cncl0 (h : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx) : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s2.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_grow.cle0 DEC_grow.ckA0 DEC_grow.cobjsK0 DEC_grow.cnodesK0 DEC_grow.citemsK0 DEC_grow.cbd0 DEC_grow.cck0

end Host.Load.Run.Tpl
