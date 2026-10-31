import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK15
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA15 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s162.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo15.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s162.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd15 : (PRE_first_tail_x15_r0_body.clo15 ++ PRE_first_tail_x15_r0_body.cln15 ++ PRE_first_tail_x15_r0_body.cli15).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle15 : Conv.Cnt.leB (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck15 : Conv.ncleanListB (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s162.ffi).mlx PRE_first_tail_x15_r0_body.clo15 PRE_first_tail_x15_r0_body.cln15 PRE_first_tail_x15_r0_body.cli15 = true
theorem PRE_first_tail_x15_r0_body.cncl15 (h : Conv.NClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx) : Conv.NClean (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s162.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle15 PRE_first_tail_x15_r0_body.ckA15 PRE_first_tail_x15_r0_body.cobjsK15 PRE_first_tail_x15_r0_body.cnodesK15 PRE_first_tail_x15_r0_body.citemsK15 PRE_first_tail_x15_r0_body.cbd15 PRE_first_tail_x15_r0_body.cck15

end Host.Load.Run.Tpl
