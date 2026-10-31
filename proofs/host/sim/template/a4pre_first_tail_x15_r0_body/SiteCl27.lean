import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK27
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA27 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s253.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo27.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s253.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd27 : (PRE_first_tail_x15_r0_body.clo27 ++ PRE_first_tail_x15_r0_body.cln27 ++ PRE_first_tail_x15_r0_body.cli27).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle27 : Conv.Cnt.leB (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck27 : Conv.ncleanListB (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s253.ffi).mlx PRE_first_tail_x15_r0_body.clo27 PRE_first_tail_x15_r0_body.cln27 PRE_first_tail_x15_r0_body.cli27 = true
theorem PRE_first_tail_x15_r0_body.cncl27 (h : Conv.NClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx) : Conv.NClean (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s253.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle27 PRE_first_tail_x15_r0_body.ckA27 PRE_first_tail_x15_r0_body.cobjsK27 PRE_first_tail_x15_r0_body.cnodesK27 PRE_first_tail_x15_r0_body.citemsK27 PRE_first_tail_x15_r0_body.cbd27 PRE_first_tail_x15_r0_body.cck27

end Host.Load.Run.Tpl
