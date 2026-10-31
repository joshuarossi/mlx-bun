import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK162
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA162 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1569.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo162.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd162 : (PRE_first_tail_x15_r0_body.clo162 ++ PRE_first_tail_x15_r0_body.cln162 ++ PRE_first_tail_x15_r0_body.cli162).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle162 : Conv.Cnt.leB (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) (⟨21401, 18512, 2802397, 7028⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck162 : Conv.ncleanListB (⟨21401, 18512, 2802397, 7028⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx PRE_first_tail_x15_r0_body.clo162 PRE_first_tail_x15_r0_body.cln162 PRE_first_tail_x15_r0_body.cli162 = true
theorem PRE_first_tail_x15_r0_body.cncl162 (h : Conv.NClean (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1569.ffi).mlx) : Conv.NClean (⟨21401, 18512, 2802397, 7028⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle162 PRE_first_tail_x15_r0_body.ckA162 PRE_first_tail_x15_r0_body.cobjsK162 PRE_first_tail_x15_r0_body.cnodesK162 PRE_first_tail_x15_r0_body.citemsK162 PRE_first_tail_x15_r0_body.cbd162 PRE_first_tail_x15_r0_body.cck162

end Host.Load.Run.Tpl
