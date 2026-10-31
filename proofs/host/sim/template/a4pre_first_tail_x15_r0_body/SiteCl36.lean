import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK36
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA36 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo36.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd36 : (PRE_first_tail_x15_r0_body.clo36 ++ PRE_first_tail_x15_r0_body.cln36 ++ PRE_first_tail_x15_r0_body.cli36).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle36 : Conv.Cnt.leB (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck36 : Conv.ncleanListB (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx PRE_first_tail_x15_r0_body.clo36 PRE_first_tail_x15_r0_body.cln36 PRE_first_tail_x15_r0_body.cli36 = true
theorem PRE_first_tail_x15_r0_body.cncl36 (h : Conv.NClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx) : Conv.NClean (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle36 PRE_first_tail_x15_r0_body.ckA36 PRE_first_tail_x15_r0_body.cobjsK36 PRE_first_tail_x15_r0_body.cnodesK36 PRE_first_tail_x15_r0_body.citemsK36 PRE_first_tail_x15_r0_body.cbd36 PRE_first_tail_x15_r0_body.cck36

end Host.Load.Run.Tpl
