import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK130
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA130 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo130.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd130 : (PRE_first_tail_x15_r0_body.clo130 ++ PRE_first_tail_x15_r0_body.cln130 ++ PRE_first_tail_x15_r0_body.cli130).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle130 : Conv.Cnt.leB (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck130 : Conv.ncleanListB (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi).mlx PRE_first_tail_x15_r0_body.clo130 PRE_first_tail_x15_r0_body.cln130 PRE_first_tail_x15_r0_body.cli130 = true
theorem PRE_first_tail_x15_r0_body.cncl130 (h : Conv.NClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx) : Conv.NClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle130 PRE_first_tail_x15_r0_body.ckA130 PRE_first_tail_x15_r0_body.cobjsK130 PRE_first_tail_x15_r0_body.cnodesK130 PRE_first_tail_x15_r0_body.citemsK130 PRE_first_tail_x15_r0_body.cbd130 PRE_first_tail_x15_r0_body.cck130

end Host.Load.Run.Tpl
