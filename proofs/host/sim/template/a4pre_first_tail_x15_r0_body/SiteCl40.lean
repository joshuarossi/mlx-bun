import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK40
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA40 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo40.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd40 : (PRE_first_tail_x15_r0_body.clo40 ++ PRE_first_tail_x15_r0_body.cln40 ++ PRE_first_tail_x15_r0_body.cli40).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle40 : Conv.Cnt.leB (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck40 : Conv.ncleanListB (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx PRE_first_tail_x15_r0_body.clo40 PRE_first_tail_x15_r0_body.cln40 PRE_first_tail_x15_r0_body.cli40 = true
theorem PRE_first_tail_x15_r0_body.cncl40 (h : Conv.NClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx) : Conv.NClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle40 PRE_first_tail_x15_r0_body.ckA40 PRE_first_tail_x15_r0_body.cobjsK40 PRE_first_tail_x15_r0_body.cnodesK40 PRE_first_tail_x15_r0_body.citemsK40 PRE_first_tail_x15_r0_body.cbd40 PRE_first_tail_x15_r0_body.cck40

end Host.Load.Run.Tpl
