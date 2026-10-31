import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK90
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA90 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s805.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo90.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s805.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd90 : (PRE_first_tail_x15_r0_body.clo90 ++ PRE_first_tail_x15_r0_body.cln90 ++ PRE_first_tail_x15_r0_body.cli90).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle90 : Conv.Cnt.leB (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) (⟨19985, 17090, 2745893, 3950⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck90 : Conv.ncleanListB (⟨19985, 17090, 2745893, 3950⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s805.ffi).mlx PRE_first_tail_x15_r0_body.clo90 PRE_first_tail_x15_r0_body.cln90 PRE_first_tail_x15_r0_body.cli90 = true
theorem PRE_first_tail_x15_r0_body.cncl90 (h : Conv.NClean (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx) : Conv.NClean (⟨19985, 17090, 2745893, 3950⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s805.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle90 PRE_first_tail_x15_r0_body.ckA90 PRE_first_tail_x15_r0_body.cobjsK90 PRE_first_tail_x15_r0_body.cnodesK90 PRE_first_tail_x15_r0_body.citemsK90 PRE_first_tail_x15_r0_body.cbd90 PRE_first_tail_x15_r0_body.cck90

end Host.Load.Run.Tpl
