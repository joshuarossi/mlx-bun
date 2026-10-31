import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK31
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA31 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s287.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s285.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo31.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s287.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd31 : (PRE_first_tail_x15_r0_body.clo31 ++ PRE_first_tail_x15_r0_body.cln31 ++ PRE_first_tail_x15_r0_body.cli31).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle31 : Conv.Cnt.leB (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck31 : Conv.ncleanListB (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s287.ffi).mlx PRE_first_tail_x15_r0_body.clo31 PRE_first_tail_x15_r0_body.cln31 PRE_first_tail_x15_r0_body.cli31 = true
theorem PRE_first_tail_x15_r0_body.cncl31 (h : Conv.NClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s285.ffi).mlx) : Conv.NClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s287.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle31 PRE_first_tail_x15_r0_body.ckA31 PRE_first_tail_x15_r0_body.cobjsK31 PRE_first_tail_x15_r0_body.cnodesK31 PRE_first_tail_x15_r0_body.citemsK31 PRE_first_tail_x15_r0_body.cbd31 PRE_first_tail_x15_r0_body.cck31

end Host.Load.Run.Tpl
