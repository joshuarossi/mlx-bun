import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK25
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA25 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s256.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s254.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo25.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s256.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd25 : (PRE_first_tail_x15_r0_body.clo25 ++ PRE_first_tail_x15_r0_body.cln25 ++ PRE_first_tail_x15_r0_body.cli25).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle25 : Conv.Cnt.leB (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck25 : Conv.ncleanListB (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s256.ffi).mlx PRE_first_tail_x15_r0_body.clo25 PRE_first_tail_x15_r0_body.cln25 PRE_first_tail_x15_r0_body.cli25 = true
theorem PRE_first_tail_x15_r0_body.cncl25 (h : Conv.NClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s254.ffi).mlx) : Conv.NClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s256.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle25 PRE_first_tail_x15_r0_body.ckA25 PRE_first_tail_x15_r0_body.cobjsK25 PRE_first_tail_x15_r0_body.cnodesK25 PRE_first_tail_x15_r0_body.citemsK25 PRE_first_tail_x15_r0_body.cbd25 PRE_first_tail_x15_r0_body.cck25

end Host.Load.Run.Tpl
