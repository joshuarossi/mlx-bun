import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK182
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA182 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1602.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo182.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1602.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd182 : (PRE_first_tail_x15_r0_body.clo182 ++ PRE_first_tail_x15_r0_body.cln182 ++ PRE_first_tail_x15_r0_body.cli182).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle182 : Conv.Cnt.leB (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) (⟨21779, 18877, 2817512, 7834⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck182 : Conv.ncleanListB (⟨21779, 18877, 2817512, 7834⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1602.ffi).mlx PRE_first_tail_x15_r0_body.clo182 PRE_first_tail_x15_r0_body.cln182 PRE_first_tail_x15_r0_body.cli182 = true
theorem PRE_first_tail_x15_r0_body.cncl182 (h : Conv.NClean (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1600.ffi).mlx) : Conv.NClean (⟨21779, 18877, 2817512, 7834⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1602.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle182 PRE_first_tail_x15_r0_body.ckA182 PRE_first_tail_x15_r0_body.cobjsK182 PRE_first_tail_x15_r0_body.cnodesK182 PRE_first_tail_x15_r0_body.citemsK182 PRE_first_tail_x15_r0_body.cbd182 PRE_first_tail_x15_r0_body.cck182

end Host.Load.Run.Tpl
