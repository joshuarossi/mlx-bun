import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK170
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA170 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1640.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1638.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo170.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1640.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd170 : (PRE_first_tail_x15_r0_body.clo170 ++ PRE_first_tail_x15_r0_body.cln170 ++ PRE_first_tail_x15_r0_body.cli170).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle170 : Conv.Cnt.leB (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) (⟨21543, 18640, 2808084, 7321⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck170 : Conv.ncleanListB (⟨21543, 18640, 2808084, 7321⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1640.ffi).mlx PRE_first_tail_x15_r0_body.clo170 PRE_first_tail_x15_r0_body.cln170 PRE_first_tail_x15_r0_body.cli170 = true
theorem PRE_first_tail_x15_r0_body.cncl170 (h : Conv.NClean (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1638.ffi).mlx) : Conv.NClean (⟨21543, 18640, 2808084, 7321⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1640.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle170 PRE_first_tail_x15_r0_body.ckA170 PRE_first_tail_x15_r0_body.cobjsK170 PRE_first_tail_x15_r0_body.cnodesK170 PRE_first_tail_x15_r0_body.citemsK170 PRE_first_tail_x15_r0_body.cbd170 PRE_first_tail_x15_r0_body.cck170

end Host.Load.Run.Tpl
