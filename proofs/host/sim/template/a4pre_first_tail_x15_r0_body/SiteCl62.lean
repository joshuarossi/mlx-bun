import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK62
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA62 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s552.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo62.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s552.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd62 : (PRE_first_tail_x15_r0_body.clo62 ++ PRE_first_tail_x15_r0_body.cln62 ++ PRE_first_tail_x15_r0_body.cli62).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle62 : Conv.Cnt.leB (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck62 : Conv.ncleanListB (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s552.ffi).mlx PRE_first_tail_x15_r0_body.clo62 PRE_first_tail_x15_r0_body.cln62 PRE_first_tail_x15_r0_body.cli62 = true
theorem PRE_first_tail_x15_r0_body.cncl62 (h : Conv.NClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s550.ffi).mlx) : Conv.NClean (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s552.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle62 PRE_first_tail_x15_r0_body.ckA62 PRE_first_tail_x15_r0_body.cobjsK62 PRE_first_tail_x15_r0_body.cnodesK62 PRE_first_tail_x15_r0_body.citemsK62 PRE_first_tail_x15_r0_body.cbd62 PRE_first_tail_x15_r0_body.cck62

end Host.Load.Run.Tpl
