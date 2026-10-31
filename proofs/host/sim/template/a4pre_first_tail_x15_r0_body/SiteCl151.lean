import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK151
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA151 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1462.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo151.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd151 : (PRE_first_tail_x15_r0_body.clo151 ++ PRE_first_tail_x15_r0_body.cln151 ++ PRE_first_tail_x15_r0_body.cli151).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle151 : Conv.Cnt.leB (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck151 : Conv.ncleanListB (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx PRE_first_tail_x15_r0_body.clo151 PRE_first_tail_x15_r0_body.cln151 PRE_first_tail_x15_r0_body.cli151 = true
theorem PRE_first_tail_x15_r0_body.cncl151 (h : Conv.NClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1462.ffi).mlx) : Conv.NClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle151 PRE_first_tail_x15_r0_body.ckA151 PRE_first_tail_x15_r0_body.cobjsK151 PRE_first_tail_x15_r0_body.cnodesK151 PRE_first_tail_x15_r0_body.citemsK151 PRE_first_tail_x15_r0_body.cbd151 PRE_first_tail_x15_r0_body.cck151

end Host.Load.Run.Tpl
