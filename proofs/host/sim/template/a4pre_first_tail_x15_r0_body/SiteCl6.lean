import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK6
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA6 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo6.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd6 : (PRE_first_tail_x15_r0_body.clo6 ++ PRE_first_tail_x15_r0_body.cln6 ++ PRE_first_tail_x15_r0_body.cli6).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle6 : Conv.Cnt.leB (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck6 : Conv.ncleanListB (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx PRE_first_tail_x15_r0_body.clo6 PRE_first_tail_x15_r0_body.cln6 PRE_first_tail_x15_r0_body.cli6 = true
theorem PRE_first_tail_x15_r0_body.cncl6 (h : Conv.NClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx) : Conv.NClean (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle6 PRE_first_tail_x15_r0_body.ckA6 PRE_first_tail_x15_r0_body.cobjsK6 PRE_first_tail_x15_r0_body.cnodesK6 PRE_first_tail_x15_r0_body.citemsK6 PRE_first_tail_x15_r0_body.cbd6 PRE_first_tail_x15_r0_body.cck6

end Host.Load.Run.Tpl
