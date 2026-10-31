import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK1
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s23.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s21.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s23.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd1 : (PRE_first_tail_x15_r0_body.clo1 ++ PRE_first_tail_x15_r0_body.cln1 ++ PRE_first_tail_x15_r0_body.cli1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle1 : Conv.Cnt.leB (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck1 : Conv.ncleanListB (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s23.ffi).mlx PRE_first_tail_x15_r0_body.clo1 PRE_first_tail_x15_r0_body.cln1 PRE_first_tail_x15_r0_body.cli1 = true
theorem PRE_first_tail_x15_r0_body.cncl1 (h : Conv.NClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s21.ffi).mlx) : Conv.NClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s23.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle1 PRE_first_tail_x15_r0_body.ckA1 PRE_first_tail_x15_r0_body.cobjsK1 PRE_first_tail_x15_r0_body.cnodesK1 PRE_first_tail_x15_r0_body.citemsK1 PRE_first_tail_x15_r0_body.cbd1 PRE_first_tail_x15_r0_body.cck1

end Host.Load.Run.Tpl
