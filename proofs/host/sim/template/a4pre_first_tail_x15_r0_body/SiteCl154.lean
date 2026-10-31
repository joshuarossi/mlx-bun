import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK154
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA154 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1492.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo154.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1492.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd154 : (PRE_first_tail_x15_r0_body.clo154 ++ PRE_first_tail_x15_r0_body.cln154 ++ PRE_first_tail_x15_r0_body.cli154).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle154 : Conv.Cnt.leB (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck154 : Conv.ncleanListB (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1492.ffi).mlx PRE_first_tail_x15_r0_body.clo154 PRE_first_tail_x15_r0_body.cln154 PRE_first_tail_x15_r0_body.cli154 = true
theorem PRE_first_tail_x15_r0_body.cncl154 (h : Conv.NClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx) : Conv.NClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1492.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle154 PRE_first_tail_x15_r0_body.ckA154 PRE_first_tail_x15_r0_body.cobjsK154 PRE_first_tail_x15_r0_body.cnodesK154 PRE_first_tail_x15_r0_body.citemsK154 PRE_first_tail_x15_r0_body.cbd154 PRE_first_tail_x15_r0_body.cck154

end Host.Load.Run.Tpl
