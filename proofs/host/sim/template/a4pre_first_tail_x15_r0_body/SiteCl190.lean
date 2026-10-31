import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK190
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA190 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo190.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd190 : (PRE_first_tail_x15_r0_body.clo190 ++ PRE_first_tail_x15_r0_body.cln190 ++ PRE_first_tail_x15_r0_body.cli190).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle190 : Conv.Cnt.leB (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck190 : Conv.ncleanListB (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx PRE_first_tail_x15_r0_body.clo190 PRE_first_tail_x15_r0_body.cln190 PRE_first_tail_x15_r0_body.cli190 = true
theorem PRE_first_tail_x15_r0_body.cncl190 (h : Conv.NClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx) : Conv.NClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle190 PRE_first_tail_x15_r0_body.ckA190 PRE_first_tail_x15_r0_body.cobjsK190 PRE_first_tail_x15_r0_body.cnodesK190 PRE_first_tail_x15_r0_body.citemsK190 PRE_first_tail_x15_r0_body.cbd190 PRE_first_tail_x15_r0_body.cck190

end Host.Load.Run.Tpl
