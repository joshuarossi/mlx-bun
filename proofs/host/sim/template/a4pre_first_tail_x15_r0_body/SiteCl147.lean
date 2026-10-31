import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK147
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA147 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1303.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1301.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo147.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1303.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd147 : (PRE_first_tail_x15_r0_body.clo147 ++ PRE_first_tail_x15_r0_body.cln147 ++ PRE_first_tail_x15_r0_body.cli147).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle147 : Conv.Cnt.leB (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) (⟨21108, 18212, 2790725, 6386⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck147 : Conv.ncleanListB (⟨21108, 18212, 2790725, 6386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1303.ffi).mlx PRE_first_tail_x15_r0_body.clo147 PRE_first_tail_x15_r0_body.cln147 PRE_first_tail_x15_r0_body.cli147 = true
theorem PRE_first_tail_x15_r0_body.cncl147 (h : Conv.NClean (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1301.ffi).mlx) : Conv.NClean (⟨21108, 18212, 2790725, 6386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1303.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle147 PRE_first_tail_x15_r0_body.ckA147 PRE_first_tail_x15_r0_body.cobjsK147 PRE_first_tail_x15_r0_body.cnodesK147 PRE_first_tail_x15_r0_body.citemsK147 PRE_first_tail_x15_r0_body.cbd147 PRE_first_tail_x15_r0_body.cck147

end Host.Load.Run.Tpl
