import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK93
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA93 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo93.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd93 : (PRE_first_tail_x15_r0_body.clo93 ++ PRE_first_tail_x15_r0_body.cln93 ++ PRE_first_tail_x15_r0_body.cli93).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle93 : Conv.Cnt.leB (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) (⟨20049, 17141, 2748423, 4074⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck93 : Conv.ncleanListB (⟨20049, 17141, 2748423, 4074⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx PRE_first_tail_x15_r0_body.clo93 PRE_first_tail_x15_r0_body.cln93 PRE_first_tail_x15_r0_body.cli93 = true
theorem PRE_first_tail_x15_r0_body.cncl93 (h : Conv.NClean (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx) : Conv.NClean (⟨20049, 17141, 2748423, 4074⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle93 PRE_first_tail_x15_r0_body.ckA93 PRE_first_tail_x15_r0_body.cobjsK93 PRE_first_tail_x15_r0_body.cnodesK93 PRE_first_tail_x15_r0_body.citemsK93 PRE_first_tail_x15_r0_body.cbd93 PRE_first_tail_x15_r0_body.cck93

end Host.Load.Run.Tpl
