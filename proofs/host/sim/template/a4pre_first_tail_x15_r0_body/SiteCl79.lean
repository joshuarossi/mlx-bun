import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK79
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA79 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo79.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd79 : (PRE_first_tail_x15_r0_body.clo79 ++ PRE_first_tail_x15_r0_body.cln79 ++ PRE_first_tail_x15_r0_body.cli79).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle79 : Conv.Cnt.leB (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck79 : Conv.ncleanListB (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi).mlx PRE_first_tail_x15_r0_body.clo79 PRE_first_tail_x15_r0_body.cln79 PRE_first_tail_x15_r0_body.cli79 = true
theorem PRE_first_tail_x15_r0_body.cncl79 (h : Conv.NClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx) : Conv.NClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle79 PRE_first_tail_x15_r0_body.ckA79 PRE_first_tail_x15_r0_body.cobjsK79 PRE_first_tail_x15_r0_body.cnodesK79 PRE_first_tail_x15_r0_body.citemsK79 PRE_first_tail_x15_r0_body.cbd79 PRE_first_tail_x15_r0_body.cck79

end Host.Load.Run.Tpl
