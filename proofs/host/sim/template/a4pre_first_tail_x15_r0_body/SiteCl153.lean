import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK153
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA153 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1354.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1352.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo153.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1354.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd153 : (PRE_first_tail_x15_r0_body.clo153 ++ PRE_first_tail_x15_r0_body.cln153 ++ PRE_first_tail_x15_r0_body.cli153).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle153 : Conv.Cnt.leB (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) (⟨21229, 18326, 2795515, 6639⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck153 : Conv.ncleanListB (⟨21229, 18326, 2795515, 6639⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1354.ffi).mlx PRE_first_tail_x15_r0_body.clo153 PRE_first_tail_x15_r0_body.cln153 PRE_first_tail_x15_r0_body.cli153 = true
theorem PRE_first_tail_x15_r0_body.cncl153 (h : Conv.NClean (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1352.ffi).mlx) : Conv.NClean (⟨21229, 18326, 2795515, 6639⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1354.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle153 PRE_first_tail_x15_r0_body.ckA153 PRE_first_tail_x15_r0_body.cobjsK153 PRE_first_tail_x15_r0_body.cnodesK153 PRE_first_tail_x15_r0_body.citemsK153 PRE_first_tail_x15_r0_body.cbd153 PRE_first_tail_x15_r0_body.cck153

end Host.Load.Run.Tpl
