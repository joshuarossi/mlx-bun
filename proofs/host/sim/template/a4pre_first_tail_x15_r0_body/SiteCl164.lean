import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK164
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA164 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1581.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo164.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd164 : (PRE_first_tail_x15_r0_body.clo164 ++ PRE_first_tail_x15_r0_body.cln164 ++ PRE_first_tail_x15_r0_body.cli164).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle164 : Conv.Cnt.leB (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) (⟨21421, 18529, 2803176, 7066⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck164 : Conv.ncleanListB (⟨21421, 18529, 2803176, 7066⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx PRE_first_tail_x15_r0_body.clo164 PRE_first_tail_x15_r0_body.cln164 PRE_first_tail_x15_r0_body.cli164 = true
theorem PRE_first_tail_x15_r0_body.cncl164 (h : Conv.NClean (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1581.ffi).mlx) : Conv.NClean (⟨21421, 18529, 2803176, 7066⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle164 PRE_first_tail_x15_r0_body.ckA164 PRE_first_tail_x15_r0_body.cobjsK164 PRE_first_tail_x15_r0_body.cnodesK164 PRE_first_tail_x15_r0_body.citemsK164 PRE_first_tail_x15_r0_body.cbd164 PRE_first_tail_x15_r0_body.cck164

end Host.Load.Run.Tpl
