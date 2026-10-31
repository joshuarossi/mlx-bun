import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK145
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA145 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1404.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo145.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd145 : (PRE_first_tail_x15_r0_body.clo145 ++ PRE_first_tail_x15_r0_body.cln145 ++ PRE_first_tail_x15_r0_body.cli145).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle145 : Conv.Cnt.leB (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck145 : Conv.ncleanListB (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx PRE_first_tail_x15_r0_body.clo145 PRE_first_tail_x15_r0_body.cln145 PRE_first_tail_x15_r0_body.cli145 = true
theorem PRE_first_tail_x15_r0_body.cncl145 (h : Conv.NClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1404.ffi).mlx) : Conv.NClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle145 PRE_first_tail_x15_r0_body.ckA145 PRE_first_tail_x15_r0_body.cobjsK145 PRE_first_tail_x15_r0_body.cnodesK145 PRE_first_tail_x15_r0_body.citemsK145 PRE_first_tail_x15_r0_body.cbd145 PRE_first_tail_x15_r0_body.cck145

end Host.Load.Run.Tpl
