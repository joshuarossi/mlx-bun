import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK63
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA63 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo63.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd63 : (PRE_first_tail_x15_r0_body.clo63 ++ PRE_first_tail_x15_r0_body.cln63 ++ PRE_first_tail_x15_r0_body.cli63).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle63 : Conv.Cnt.leB (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck63 : Conv.ncleanListB (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx PRE_first_tail_x15_r0_body.clo63 PRE_first_tail_x15_r0_body.cln63 PRE_first_tail_x15_r0_body.cli63 = true
theorem PRE_first_tail_x15_r0_body.cncl63 (h : Conv.NClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx) : Conv.NClean (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle63 PRE_first_tail_x15_r0_body.ckA63 PRE_first_tail_x15_r0_body.cobjsK63 PRE_first_tail_x15_r0_body.cnodesK63 PRE_first_tail_x15_r0_body.citemsK63 PRE_first_tail_x15_r0_body.cbd63 PRE_first_tail_x15_r0_body.cck63

end Host.Load.Run.Tpl
