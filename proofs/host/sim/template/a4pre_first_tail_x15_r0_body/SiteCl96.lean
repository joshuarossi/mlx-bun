import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK96
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA96 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s856.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s854.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo96.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s856.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd96 : (PRE_first_tail_x15_r0_body.clo96 ++ PRE_first_tail_x15_r0_body.cln96 ++ PRE_first_tail_x15_r0_body.cli96).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle96 : Conv.Cnt.leB (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) (⟨20107, 17201, 2750797, 4205⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck96 : Conv.ncleanListB (⟨20107, 17201, 2750797, 4205⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s856.ffi).mlx PRE_first_tail_x15_r0_body.clo96 PRE_first_tail_x15_r0_body.cln96 PRE_first_tail_x15_r0_body.cli96 = true
theorem PRE_first_tail_x15_r0_body.cncl96 (h : Conv.NClean (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s854.ffi).mlx) : Conv.NClean (⟨20107, 17201, 2750797, 4205⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s856.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle96 PRE_first_tail_x15_r0_body.ckA96 PRE_first_tail_x15_r0_body.cobjsK96 PRE_first_tail_x15_r0_body.cnodesK96 PRE_first_tail_x15_r0_body.citemsK96 PRE_first_tail_x15_r0_body.cbd96 PRE_first_tail_x15_r0_body.cck96

end Host.Load.Run.Tpl
