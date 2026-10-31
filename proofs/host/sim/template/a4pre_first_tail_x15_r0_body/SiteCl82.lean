import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK82
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA82 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s802.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo82.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s802.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd82 : (PRE_first_tail_x15_r0_body.clo82 ++ PRE_first_tail_x15_r0_body.cln82 ++ PRE_first_tail_x15_r0_body.cli82).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle82 : Conv.Cnt.leB (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck82 : Conv.ncleanListB (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s802.ffi).mlx PRE_first_tail_x15_r0_body.clo82 PRE_first_tail_x15_r0_body.cln82 PRE_first_tail_x15_r0_body.cli82 = true
theorem PRE_first_tail_x15_r0_body.cncl82 (h : Conv.NClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx) : Conv.NClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s802.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle82 PRE_first_tail_x15_r0_body.ckA82 PRE_first_tail_x15_r0_body.cobjsK82 PRE_first_tail_x15_r0_body.cnodesK82 PRE_first_tail_x15_r0_body.citemsK82 PRE_first_tail_x15_r0_body.cbd82 PRE_first_tail_x15_r0_body.cck82

end Host.Load.Run.Tpl
