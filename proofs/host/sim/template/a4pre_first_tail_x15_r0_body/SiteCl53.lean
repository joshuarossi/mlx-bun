import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK53
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA53 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo53.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd53 : (PRE_first_tail_x15_r0_body.clo53 ++ PRE_first_tail_x15_r0_body.cln53 ++ PRE_first_tail_x15_r0_body.cli53).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle53 : Conv.Cnt.leB (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck53 : Conv.ncleanListB (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx PRE_first_tail_x15_r0_body.clo53 PRE_first_tail_x15_r0_body.cln53 PRE_first_tail_x15_r0_body.cli53 = true
theorem PRE_first_tail_x15_r0_body.cncl53 (h : Conv.NClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx) : Conv.NClean (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle53 PRE_first_tail_x15_r0_body.ckA53 PRE_first_tail_x15_r0_body.cobjsK53 PRE_first_tail_x15_r0_body.cnodesK53 PRE_first_tail_x15_r0_body.citemsK53 PRE_first_tail_x15_r0_body.cbd53 PRE_first_tail_x15_r0_body.cck53

end Host.Load.Run.Tpl
