import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK84
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA84 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s823.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo84.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s823.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd84 : (PRE_first_tail_x15_r0_body.clo84 ++ PRE_first_tail_x15_r0_body.cln84 ++ PRE_first_tail_x15_r0_body.cli84).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle84 : Conv.Cnt.leB (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) (⟨19871, 16964, 2741377, 3692⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck84 : Conv.ncleanListB (⟨19871, 16964, 2741377, 3692⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s823.ffi).mlx PRE_first_tail_x15_r0_body.clo84 PRE_first_tail_x15_r0_body.cln84 PRE_first_tail_x15_r0_body.cli84 = true
theorem PRE_first_tail_x15_r0_body.cncl84 (h : Conv.NClean (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx) : Conv.NClean (⟨19871, 16964, 2741377, 3692⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s823.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle84 PRE_first_tail_x15_r0_body.ckA84 PRE_first_tail_x15_r0_body.cobjsK84 PRE_first_tail_x15_r0_body.cnodesK84 PRE_first_tail_x15_r0_body.citemsK84 PRE_first_tail_x15_r0_body.cbd84 PRE_first_tail_x15_r0_body.cck84

end Host.Load.Run.Tpl
