import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK188
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA188 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1656.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1654.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo188.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1656.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd188 : (PRE_first_tail_x15_r0_body.clo188 ++ PRE_first_tail_x15_r0_body.cln188 ++ PRE_first_tail_x15_r0_body.cli188).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle188 : Conv.Cnt.leB (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) (⟨21893, 19003, 2822032, 8092⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck188 : Conv.ncleanListB (⟨21893, 19003, 2822032, 8092⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1656.ffi).mlx PRE_first_tail_x15_r0_body.clo188 PRE_first_tail_x15_r0_body.cln188 PRE_first_tail_x15_r0_body.cli188 = true
theorem PRE_first_tail_x15_r0_body.cncl188 (h : Conv.NClean (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1654.ffi).mlx) : Conv.NClean (⟨21893, 19003, 2822032, 8092⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1656.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle188 PRE_first_tail_x15_r0_body.ckA188 PRE_first_tail_x15_r0_body.cobjsK188 PRE_first_tail_x15_r0_body.cnodesK188 PRE_first_tail_x15_r0_body.citemsK188 PRE_first_tail_x15_r0_body.cbd188 PRE_first_tail_x15_r0_body.cck188

end Host.Load.Run.Tpl
