import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK67
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA67 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo67.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd67 : (PRE_first_tail_x15_r0_body.clo67 ++ PRE_first_tail_x15_r0_body.cln67 ++ PRE_first_tail_x15_r0_body.cli67).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle67 : Conv.Cnt.leB (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck67 : Conv.ncleanListB (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi).mlx PRE_first_tail_x15_r0_body.clo67 PRE_first_tail_x15_r0_body.cln67 PRE_first_tail_x15_r0_body.cli67 = true
theorem PRE_first_tail_x15_r0_body.cncl67 (h : Conv.NClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx) : Conv.NClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle67 PRE_first_tail_x15_r0_body.ckA67 PRE_first_tail_x15_r0_body.cobjsK67 PRE_first_tail_x15_r0_body.cnodesK67 PRE_first_tail_x15_r0_body.citemsK67 PRE_first_tail_x15_r0_body.cbd67 PRE_first_tail_x15_r0_body.cck67

end Host.Load.Run.Tpl
