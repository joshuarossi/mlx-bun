import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK174
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA174 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1686.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo174.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1686.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd174 : (PRE_first_tail_x15_r0_body.clo174 ++ PRE_first_tail_x15_r0_body.cln174 ++ PRE_first_tail_x15_r0_body.cli174).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle174 : Conv.Cnt.leB (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) (⟨21637, 18749, 2811825, 7541⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck174 : Conv.ncleanListB (⟨21637, 18749, 2811825, 7541⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1686.ffi).mlx PRE_first_tail_x15_r0_body.clo174 PRE_first_tail_x15_r0_body.cln174 PRE_first_tail_x15_r0_body.cli174 = true
theorem PRE_first_tail_x15_r0_body.cncl174 (h : Conv.NClean (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx) : Conv.NClean (⟨21637, 18749, 2811825, 7541⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1686.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle174 PRE_first_tail_x15_r0_body.ckA174 PRE_first_tail_x15_r0_body.cobjsK174 PRE_first_tail_x15_r0_body.cnodesK174 PRE_first_tail_x15_r0_body.citemsK174 PRE_first_tail_x15_r0_body.cbd174 PRE_first_tail_x15_r0_body.cck174

end Host.Load.Run.Tpl
