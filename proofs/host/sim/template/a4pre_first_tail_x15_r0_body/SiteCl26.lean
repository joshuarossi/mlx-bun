import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK26
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA26 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s260.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo26.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s260.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd26 : (PRE_first_tail_x15_r0_body.clo26 ++ PRE_first_tail_x15_r0_body.cln26 ++ PRE_first_tail_x15_r0_body.cli26).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle26 : Conv.Cnt.leB (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) (⟨18711, 15796, 2695072, 1165⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck26 : Conv.ncleanListB (⟨18711, 15796, 2695072, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s260.ffi).mlx PRE_first_tail_x15_r0_body.clo26 PRE_first_tail_x15_r0_body.cln26 PRE_first_tail_x15_r0_body.cli26 = true
theorem PRE_first_tail_x15_r0_body.cncl26 (h : Conv.NClean (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx) : Conv.NClean (⟨18711, 15796, 2695072, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s260.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle26 PRE_first_tail_x15_r0_body.ckA26 PRE_first_tail_x15_r0_body.cobjsK26 PRE_first_tail_x15_r0_body.cnodesK26 PRE_first_tail_x15_r0_body.citemsK26 PRE_first_tail_x15_r0_body.cbd26 PRE_first_tail_x15_r0_body.cck26

end Host.Load.Run.Tpl
