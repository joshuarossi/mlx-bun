import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK24
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA24 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo24.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd24 : (PRE_first_tail_x15_r0_body.clo24 ++ PRE_first_tail_x15_r0_body.cln24 ++ PRE_first_tail_x15_r0_body.cli24).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle24 : Conv.Cnt.leB (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck24 : Conv.ncleanListB (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx PRE_first_tail_x15_r0_body.clo24 PRE_first_tail_x15_r0_body.cln24 PRE_first_tail_x15_r0_body.cli24 = true
theorem PRE_first_tail_x15_r0_body.cncl24 (h : Conv.NClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx) : Conv.NClean (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle24 PRE_first_tail_x15_r0_body.ckA24 PRE_first_tail_x15_r0_body.cobjsK24 PRE_first_tail_x15_r0_body.cnodesK24 PRE_first_tail_x15_r0_body.citemsK24 PRE_first_tail_x15_r0_body.cbd24 PRE_first_tail_x15_r0_body.cck24

end Host.Load.Run.Tpl
