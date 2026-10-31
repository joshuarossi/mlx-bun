import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK78
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA78 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo78.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd78 : (PRE_first_tail_x15_r0_body.clo78 ++ PRE_first_tail_x15_r0_body.cln78 ++ PRE_first_tail_x15_r0_body.cli78).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle78 : Conv.Cnt.leB (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) (⟨19749, 16853, 2736477, 3437⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck78 : Conv.ncleanListB (⟨19749, 16853, 2736477, 3437⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx PRE_first_tail_x15_r0_body.clo78 PRE_first_tail_x15_r0_body.cln78 PRE_first_tail_x15_r0_body.cli78 = true
theorem PRE_first_tail_x15_r0_body.cncl78 (h : Conv.NClean (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx) : Conv.NClean (⟨19749, 16853, 2736477, 3437⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle78 PRE_first_tail_x15_r0_body.ckA78 PRE_first_tail_x15_r0_body.cobjsK78 PRE_first_tail_x15_r0_body.cnodesK78 PRE_first_tail_x15_r0_body.citemsK78 PRE_first_tail_x15_r0_body.cbd78 PRE_first_tail_x15_r0_body.cck78

end Host.Load.Run.Tpl
