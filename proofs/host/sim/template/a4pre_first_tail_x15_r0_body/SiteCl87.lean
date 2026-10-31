import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK87
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA87 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s778.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo87.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s778.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd87 : (PRE_first_tail_x15_r0_body.clo87 ++ PRE_first_tail_x15_r0_body.cln87 ++ PRE_first_tail_x15_r0_body.cli87).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle87 : Conv.Cnt.leB (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) (⟨19928, 17027, 2743633, 3821⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck87 : Conv.ncleanListB (⟨19928, 17027, 2743633, 3821⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s778.ffi).mlx PRE_first_tail_x15_r0_body.clo87 PRE_first_tail_x15_r0_body.cln87 PRE_first_tail_x15_r0_body.cli87 = true
theorem PRE_first_tail_x15_r0_body.cncl87 (h : Conv.NClean (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx) : Conv.NClean (⟨19928, 17027, 2743633, 3821⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s778.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle87 PRE_first_tail_x15_r0_body.ckA87 PRE_first_tail_x15_r0_body.cobjsK87 PRE_first_tail_x15_r0_body.cnodesK87 PRE_first_tail_x15_r0_body.citemsK87 PRE_first_tail_x15_r0_body.cbd87 PRE_first_tail_x15_r0_body.cck87

end Host.Load.Run.Tpl
