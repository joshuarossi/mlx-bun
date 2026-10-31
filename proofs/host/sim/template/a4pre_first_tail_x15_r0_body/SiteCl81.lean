import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK81
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA81 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo81.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd81 : (PRE_first_tail_x15_r0_body.clo81 ++ PRE_first_tail_x15_r0_body.cln81 ++ PRE_first_tail_x15_r0_body.cli81).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle81 : Conv.Cnt.leB (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) (⟨19813, 16904, 2739007, 3561⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck81 : Conv.ncleanListB (⟨19813, 16904, 2739007, 3561⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi).mlx PRE_first_tail_x15_r0_body.clo81 PRE_first_tail_x15_r0_body.cln81 PRE_first_tail_x15_r0_body.cli81 = true
theorem PRE_first_tail_x15_r0_body.cncl81 (h : Conv.NClean (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx) : Conv.NClean (⟨19813, 16904, 2739007, 3561⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle81 PRE_first_tail_x15_r0_body.ckA81 PRE_first_tail_x15_r0_body.cobjsK81 PRE_first_tail_x15_r0_body.cnodesK81 PRE_first_tail_x15_r0_body.citemsK81 PRE_first_tail_x15_r0_body.cbd81 PRE_first_tail_x15_r0_body.cck81

end Host.Load.Run.Tpl
