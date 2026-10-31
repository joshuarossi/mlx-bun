import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK43
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA43 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s392.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s390.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo43.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s392.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd43 : (PRE_first_tail_x15_r0_body.clo43 ++ PRE_first_tail_x15_r0_body.cln43 ++ PRE_first_tail_x15_r0_body.cli43).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle43 : Conv.Cnt.leB (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck43 : Conv.ncleanListB (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s392.ffi).mlx PRE_first_tail_x15_r0_body.clo43 PRE_first_tail_x15_r0_body.cln43 PRE_first_tail_x15_r0_body.cli43 = true
theorem PRE_first_tail_x15_r0_body.cncl43 (h : Conv.NClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s390.ffi).mlx) : Conv.NClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s392.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle43 PRE_first_tail_x15_r0_body.ckA43 PRE_first_tail_x15_r0_body.cobjsK43 PRE_first_tail_x15_r0_body.cnodesK43 PRE_first_tail_x15_r0_body.citemsK43 PRE_first_tail_x15_r0_body.cbd43 PRE_first_tail_x15_r0_body.cck43

end Host.Load.Run.Tpl
