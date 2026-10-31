import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK41
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA41 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo41.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd41 : (PRE_first_tail_x15_r0_body.clo41 ++ PRE_first_tail_x15_r0_body.cln41 ++ PRE_first_tail_x15_r0_body.cli41).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle41 : Conv.Cnt.leB (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck41 : Conv.ncleanListB (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx PRE_first_tail_x15_r0_body.clo41 PRE_first_tail_x15_r0_body.cln41 PRE_first_tail_x15_r0_body.cli41 = true
theorem PRE_first_tail_x15_r0_body.cncl41 (h : Conv.NClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx) : Conv.NClean (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle41 PRE_first_tail_x15_r0_body.ckA41 PRE_first_tail_x15_r0_body.cobjsK41 PRE_first_tail_x15_r0_body.cnodesK41 PRE_first_tail_x15_r0_body.citemsK41 PRE_first_tail_x15_r0_body.cbd41 PRE_first_tail_x15_r0_body.cck41

end Host.Load.Run.Tpl
