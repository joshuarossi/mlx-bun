import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK0
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s15.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd0 : (PRE_first_tail_x15_r0_body.clo0 ++ PRE_first_tail_x15_r0_body.cln0 ++ PRE_first_tail_x15_r0_body.cli0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle0 : Conv.Cnt.leB (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck0 : Conv.ncleanListB (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx PRE_first_tail_x15_r0_body.clo0 PRE_first_tail_x15_r0_body.cln0 PRE_first_tail_x15_r0_body.cli0 = true
theorem PRE_first_tail_x15_r0_body.cncl0 (h : Conv.NClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s15.ffi).mlx) : Conv.NClean (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle0 PRE_first_tail_x15_r0_body.ckA0 PRE_first_tail_x15_r0_body.cobjsK0 PRE_first_tail_x15_r0_body.cnodesK0 PRE_first_tail_x15_r0_body.citemsK0 PRE_first_tail_x15_r0_body.cbd0 PRE_first_tail_x15_r0_body.cck0

end Host.Load.Run.Tpl
