import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK177
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA177 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1564.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1562.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo177.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1564.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd177 : (PRE_first_tail_x15_r0_body.clo177 ++ PRE_first_tail_x15_r0_body.cln177 ++ PRE_first_tail_x15_r0_body.cli177).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle177 : Conv.Cnt.leB (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) (⟨21701, 18800, 2814359, 7665⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck177 : Conv.ncleanListB (⟨21701, 18800, 2814359, 7665⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1564.ffi).mlx PRE_first_tail_x15_r0_body.clo177 PRE_first_tail_x15_r0_body.cln177 PRE_first_tail_x15_r0_body.cli177 = true
theorem PRE_first_tail_x15_r0_body.cncl177 (h : Conv.NClean (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1562.ffi).mlx) : Conv.NClean (⟨21701, 18800, 2814359, 7665⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1564.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle177 PRE_first_tail_x15_r0_body.ckA177 PRE_first_tail_x15_r0_body.cobjsK177 PRE_first_tail_x15_r0_body.cnodesK177 PRE_first_tail_x15_r0_body.citemsK177 PRE_first_tail_x15_r0_body.cbd177 PRE_first_tail_x15_r0_body.cck177

end Host.Load.Run.Tpl
