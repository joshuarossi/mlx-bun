import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK10
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA10 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo10.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd10 : (PRE_first_tail_x15_r0_body.clo10 ++ PRE_first_tail_x15_r0_body.cln10 ++ PRE_first_tail_x15_r0_body.cli10).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle10 : Conv.Cnt.leB (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck10 : Conv.ncleanListB (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx PRE_first_tail_x15_r0_body.clo10 PRE_first_tail_x15_r0_body.cln10 PRE_first_tail_x15_r0_body.cli10 = true
theorem PRE_first_tail_x15_r0_body.cncl10 (h : Conv.NClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx) : Conv.NClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle10 PRE_first_tail_x15_r0_body.ckA10 PRE_first_tail_x15_r0_body.cobjsK10 PRE_first_tail_x15_r0_body.cnodesK10 PRE_first_tail_x15_r0_body.citemsK10 PRE_first_tail_x15_r0_body.cbd10 PRE_first_tail_x15_r0_body.cck10

end Host.Load.Run.Tpl
