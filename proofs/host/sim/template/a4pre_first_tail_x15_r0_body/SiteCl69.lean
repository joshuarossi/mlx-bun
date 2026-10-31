import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK69
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA69 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo69.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd69 : (PRE_first_tail_x15_r0_body.clo69 ++ PRE_first_tail_x15_r0_body.cln69 ++ PRE_first_tail_x15_r0_body.cli69).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle69 : Conv.Cnt.leB (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) (⟨19577, 16667, 2729595, 3048⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck69 : Conv.ncleanListB (⟨19577, 16667, 2729595, 3048⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi).mlx PRE_first_tail_x15_r0_body.clo69 PRE_first_tail_x15_r0_body.cln69 PRE_first_tail_x15_r0_body.cli69 = true
theorem PRE_first_tail_x15_r0_body.cncl69 (h : Conv.NClean (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx) : Conv.NClean (⟨19577, 16667, 2729595, 3048⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle69 PRE_first_tail_x15_r0_body.ckA69 PRE_first_tail_x15_r0_body.cobjsK69 PRE_first_tail_x15_r0_body.cnodesK69 PRE_first_tail_x15_r0_body.citemsK69 PRE_first_tail_x15_r0_body.cbd69 PRE_first_tail_x15_r0_body.cck69

end Host.Load.Run.Tpl
