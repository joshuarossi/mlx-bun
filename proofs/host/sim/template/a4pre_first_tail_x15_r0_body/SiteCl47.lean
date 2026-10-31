import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK47
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA47 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo47.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd47 : (PRE_first_tail_x15_r0_body.clo47 ++ PRE_first_tail_x15_r0_body.cln47 ++ PRE_first_tail_x15_r0_body.cli47).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle47 : Conv.Cnt.leB (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck47 : Conv.ncleanListB (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx PRE_first_tail_x15_r0_body.clo47 PRE_first_tail_x15_r0_body.cln47 PRE_first_tail_x15_r0_body.cli47 = true
theorem PRE_first_tail_x15_r0_body.cncl47 (h : Conv.NClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx) : Conv.NClean (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle47 PRE_first_tail_x15_r0_body.ckA47 PRE_first_tail_x15_r0_body.cobjsK47 PRE_first_tail_x15_r0_body.cnodesK47 PRE_first_tail_x15_r0_body.citemsK47 PRE_first_tail_x15_r0_body.cbd47 PRE_first_tail_x15_r0_body.cck47

end Host.Load.Run.Tpl
