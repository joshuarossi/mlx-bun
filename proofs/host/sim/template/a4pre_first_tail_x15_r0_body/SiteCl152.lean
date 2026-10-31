import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK152
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA152 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo152.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd152 : (PRE_first_tail_x15_r0_body.clo152 ++ PRE_first_tail_x15_r0_body.cln152 ++ PRE_first_tail_x15_r0_body.cli152).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle152 : Conv.Cnt.leB (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) (⟨21185, 18292, 2793764, 6553⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck152 : Conv.ncleanListB (⟨21185, 18292, 2793764, 6553⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx PRE_first_tail_x15_r0_body.clo152 PRE_first_tail_x15_r0_body.cln152 PRE_first_tail_x15_r0_body.cli152 = true
theorem PRE_first_tail_x15_r0_body.cncl152 (h : Conv.NClean (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx) : Conv.NClean (⟨21185, 18292, 2793764, 6553⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle152 PRE_first_tail_x15_r0_body.ckA152 PRE_first_tail_x15_r0_body.cobjsK152 PRE_first_tail_x15_r0_body.cnodesK152 PRE_first_tail_x15_r0_body.citemsK152 PRE_first_tail_x15_r0_body.cbd152 PRE_first_tail_x15_r0_body.cck152

end Host.Load.Run.Tpl
