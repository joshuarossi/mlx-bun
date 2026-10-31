import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK73
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA73 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo73.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd73 : (PRE_first_tail_x15_r0_body.clo73 ++ PRE_first_tail_x15_r0_body.cln73 ++ PRE_first_tail_x15_r0_body.cli73).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle73 : Conv.Cnt.leB (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck73 : Conv.ncleanListB (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx PRE_first_tail_x15_r0_body.clo73 PRE_first_tail_x15_r0_body.cln73 PRE_first_tail_x15_r0_body.cli73 = true
theorem PRE_first_tail_x15_r0_body.cncl73 (h : Conv.NClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx) : Conv.NClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle73 PRE_first_tail_x15_r0_body.ckA73 PRE_first_tail_x15_r0_body.cobjsK73 PRE_first_tail_x15_r0_body.cnodesK73 PRE_first_tail_x15_r0_body.citemsK73 PRE_first_tail_x15_r0_body.cbd73 PRE_first_tail_x15_r0_body.cck73

end Host.Load.Run.Tpl
