import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK101
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA101 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s894.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s892.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo101.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s894.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd101 : (PRE_first_tail_x15_r0_body.clo101 ++ PRE_first_tail_x15_r0_body.cln101 ++ PRE_first_tail_x15_r0_body.cli101).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle101 : Conv.Cnt.leB (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt) (⟨20184, 17281, 2753836, 4372⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck101 : Conv.ncleanListB (⟨20184, 17281, 2753836, 4372⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s894.ffi).mlx PRE_first_tail_x15_r0_body.clo101 PRE_first_tail_x15_r0_body.cln101 PRE_first_tail_x15_r0_body.cli101 = true
theorem PRE_first_tail_x15_r0_body.cncl101 (h : Conv.NClean (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s892.ffi).mlx) : Conv.NClean (⟨20184, 17281, 2753836, 4372⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s894.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle101 PRE_first_tail_x15_r0_body.ckA101 PRE_first_tail_x15_r0_body.cobjsK101 PRE_first_tail_x15_r0_body.cnodesK101 PRE_first_tail_x15_r0_body.citemsK101 PRE_first_tail_x15_r0_body.cbd101 PRE_first_tail_x15_r0_body.cck101

end Host.Load.Run.Tpl
