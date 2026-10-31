import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK109
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA109 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s968.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s966.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo109.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s968.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd109 : (PRE_first_tail_x15_r0_body.clo109 ++ PRE_first_tail_x15_r0_body.cln109 ++ PRE_first_tail_x15_r0_body.cli109).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle109 : Conv.Cnt.leB (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck109 : Conv.ncleanListB (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s968.ffi).mlx PRE_first_tail_x15_r0_body.clo109 PRE_first_tail_x15_r0_body.cln109 PRE_first_tail_x15_r0_body.cli109 = true
theorem PRE_first_tail_x15_r0_body.cncl109 (h : Conv.NClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s966.ffi).mlx) : Conv.NClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s968.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle109 PRE_first_tail_x15_r0_body.ckA109 PRE_first_tail_x15_r0_body.cobjsK109 PRE_first_tail_x15_r0_body.cnodesK109 PRE_first_tail_x15_r0_body.citemsK109 PRE_first_tail_x15_r0_body.cbd109 PRE_first_tail_x15_r0_body.cck109

end Host.Load.Run.Tpl
