import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK127
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA127 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo127.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd127 : (PRE_first_tail_x15_r0_body.clo127 ++ PRE_first_tail_x15_r0_body.cln127 ++ PRE_first_tail_x15_r0_body.cli127).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle127 : Conv.Cnt.leB (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck127 : Conv.ncleanListB (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx PRE_first_tail_x15_r0_body.clo127 PRE_first_tail_x15_r0_body.cln127 PRE_first_tail_x15_r0_body.cli127 = true
theorem PRE_first_tail_x15_r0_body.cncl127 (h : Conv.NClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx) : Conv.NClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle127 PRE_first_tail_x15_r0_body.ckA127 PRE_first_tail_x15_r0_body.cobjsK127 PRE_first_tail_x15_r0_body.cnodesK127 PRE_first_tail_x15_r0_body.citemsK127 PRE_first_tail_x15_r0_body.cbd127 PRE_first_tail_x15_r0_body.cck127

end Host.Load.Run.Tpl
