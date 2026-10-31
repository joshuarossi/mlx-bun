import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK74
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA74 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo74.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd74 : (PRE_first_tail_x15_r0_body.clo74 ++ PRE_first_tail_x15_r0_body.cln74 ++ PRE_first_tail_x15_r0_body.cli74).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle74 : Conv.Cnt.leB (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) (⟨19655, 16744, 2732744, 3217⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck74 : Conv.ncleanListB (⟨19655, 16744, 2732744, 3217⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx PRE_first_tail_x15_r0_body.clo74 PRE_first_tail_x15_r0_body.cln74 PRE_first_tail_x15_r0_body.cli74 = true
theorem PRE_first_tail_x15_r0_body.cncl74 (h : Conv.NClean (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx) : Conv.NClean (⟨19655, 16744, 2732744, 3217⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle74 PRE_first_tail_x15_r0_body.ckA74 PRE_first_tail_x15_r0_body.cobjsK74 PRE_first_tail_x15_r0_body.cnodesK74 PRE_first_tail_x15_r0_body.citemsK74 PRE_first_tail_x15_r0_body.cbd74 PRE_first_tail_x15_r0_body.cck74

end Host.Load.Run.Tpl
