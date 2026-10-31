import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK2
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA2 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s30.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s28.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo2.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s30.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd2 : (PRE_first_tail_x15_r0_body.clo2 ++ PRE_first_tail_x15_r0_body.cln2 ++ PRE_first_tail_x15_r0_body.cli2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle2 : Conv.Cnt.leB (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck2 : Conv.ncleanListB (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s30.ffi).mlx PRE_first_tail_x15_r0_body.clo2 PRE_first_tail_x15_r0_body.cln2 PRE_first_tail_x15_r0_body.cli2 = true
theorem PRE_first_tail_x15_r0_body.cncl2 (h : Conv.NClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s28.ffi).mlx) : Conv.NClean (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s30.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle2 PRE_first_tail_x15_r0_body.ckA2 PRE_first_tail_x15_r0_body.cobjsK2 PRE_first_tail_x15_r0_body.cnodesK2 PRE_first_tail_x15_r0_body.citemsK2 PRE_first_tail_x15_r0_body.cbd2 PRE_first_tail_x15_r0_body.cck2

end Host.Load.Run.Tpl
