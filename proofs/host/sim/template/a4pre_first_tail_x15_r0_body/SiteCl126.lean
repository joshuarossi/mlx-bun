import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK126
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA126 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1120.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo126.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1120.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd126 : (PRE_first_tail_x15_r0_body.clo126 ++ PRE_first_tail_x15_r0_body.cln126 ++ PRE_first_tail_x15_r0_body.cli126).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle126 : Conv.Cnt.leB (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) (⟨20693, 17801, 2774141, 5489⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck126 : Conv.ncleanListB (⟨20693, 17801, 2774141, 5489⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1120.ffi).mlx PRE_first_tail_x15_r0_body.clo126 PRE_first_tail_x15_r0_body.cln126 PRE_first_tail_x15_r0_body.cli126 = true
theorem PRE_first_tail_x15_r0_body.cncl126 (h : Conv.NClean (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx) : Conv.NClean (⟨20693, 17801, 2774141, 5489⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1120.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle126 PRE_first_tail_x15_r0_body.ckA126 PRE_first_tail_x15_r0_body.cobjsK126 PRE_first_tail_x15_r0_body.cnodesK126 PRE_first_tail_x15_r0_body.citemsK126 PRE_first_tail_x15_r0_body.cbd126 PRE_first_tail_x15_r0_body.cck126

end Host.Load.Run.Tpl
