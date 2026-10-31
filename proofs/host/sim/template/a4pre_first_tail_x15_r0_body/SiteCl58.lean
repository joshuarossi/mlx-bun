import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK58
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA58 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s521.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo58.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s521.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd58 : (PRE_first_tail_x15_r0_body.clo58 ++ PRE_first_tail_x15_r0_body.cln58 ++ PRE_first_tail_x15_r0_body.cli58).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle58 : Conv.Cnt.leB (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck58 : Conv.ncleanListB (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s521.ffi).mlx PRE_first_tail_x15_r0_body.clo58 PRE_first_tail_x15_r0_body.cln58 PRE_first_tail_x15_r0_body.cli58 = true
theorem PRE_first_tail_x15_r0_body.cncl58 (h : Conv.NClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx) : Conv.NClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s521.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle58 PRE_first_tail_x15_r0_body.ckA58 PRE_first_tail_x15_r0_body.cobjsK58 PRE_first_tail_x15_r0_body.cnodesK58 PRE_first_tail_x15_r0_body.citemsK58 PRE_first_tail_x15_r0_body.cbd58 PRE_first_tail_x15_r0_body.cck58

end Host.Load.Run.Tpl
