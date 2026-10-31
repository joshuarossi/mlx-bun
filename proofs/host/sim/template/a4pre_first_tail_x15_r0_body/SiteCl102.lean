import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK102
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA102 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s910.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s908.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo102.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s910.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd102 : (PRE_first_tail_x15_r0_body.clo102 ++ PRE_first_tail_x15_r0_body.cln102 ++ PRE_first_tail_x15_r0_body.cli102).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle102 : Conv.Cnt.leB (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt) (⟨20221, 17327, 2755317, 4463⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck102 : Conv.ncleanListB (⟨20221, 17327, 2755317, 4463⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s910.ffi).mlx PRE_first_tail_x15_r0_body.clo102 PRE_first_tail_x15_r0_body.cln102 PRE_first_tail_x15_r0_body.cli102 = true
theorem PRE_first_tail_x15_r0_body.cncl102 (h : Conv.NClean (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s908.ffi).mlx) : Conv.NClean (⟨20221, 17327, 2755317, 4463⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s910.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle102 PRE_first_tail_x15_r0_body.ckA102 PRE_first_tail_x15_r0_body.cobjsK102 PRE_first_tail_x15_r0_body.cnodesK102 PRE_first_tail_x15_r0_body.citemsK102 PRE_first_tail_x15_r0_body.cbd102 PRE_first_tail_x15_r0_body.cck102

end Host.Load.Run.Tpl
