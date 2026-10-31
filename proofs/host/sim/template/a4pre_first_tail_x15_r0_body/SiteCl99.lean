import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK99
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA99 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s883.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo99.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s883.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd99 : (PRE_first_tail_x15_r0_body.clo99 ++ PRE_first_tail_x15_r0_body.cln99 ++ PRE_first_tail_x15_r0_body.cli99).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle99 : Conv.Cnt.leB (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) (⟨20164, 17264, 2753057, 4334⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck99 : Conv.ncleanListB (⟨20164, 17264, 2753057, 4334⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s883.ffi).mlx PRE_first_tail_x15_r0_body.clo99 PRE_first_tail_x15_r0_body.cln99 PRE_first_tail_x15_r0_body.cli99 = true
theorem PRE_first_tail_x15_r0_body.cncl99 (h : Conv.NClean (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx) : Conv.NClean (⟨20164, 17264, 2753057, 4334⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s883.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle99 PRE_first_tail_x15_r0_body.ckA99 PRE_first_tail_x15_r0_body.cobjsK99 PRE_first_tail_x15_r0_body.cnodesK99 PRE_first_tail_x15_r0_body.citemsK99 PRE_first_tail_x15_r0_body.cbd99 PRE_first_tail_x15_r0_body.cck99

end Host.Load.Run.Tpl
