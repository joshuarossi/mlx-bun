import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK52
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA52 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s470.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s468.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo52.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s470.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd52 : (PRE_first_tail_x15_r0_body.clo52 ++ PRE_first_tail_x15_r0_body.cln52 ++ PRE_first_tail_x15_r0_body.cli52).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle52 : Conv.Cnt.leB (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck52 : Conv.ncleanListB (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s470.ffi).mlx PRE_first_tail_x15_r0_body.clo52 PRE_first_tail_x15_r0_body.cln52 PRE_first_tail_x15_r0_body.cli52 = true
theorem PRE_first_tail_x15_r0_body.cncl52 (h : Conv.NClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s468.ffi).mlx) : Conv.NClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s470.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle52 PRE_first_tail_x15_r0_body.ckA52 PRE_first_tail_x15_r0_body.cobjsK52 PRE_first_tail_x15_r0_body.cnodesK52 PRE_first_tail_x15_r0_body.citemsK52 PRE_first_tail_x15_r0_body.cbd52 PRE_first_tail_x15_r0_body.cck52

end Host.Load.Run.Tpl
