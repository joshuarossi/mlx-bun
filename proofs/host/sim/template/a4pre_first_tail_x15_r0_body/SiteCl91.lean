import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK91
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA91 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s812.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo91.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s812.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd91 : (PRE_first_tail_x15_r0_body.clo91 ++ PRE_first_tail_x15_r0_body.cln91 ++ PRE_first_tail_x15_r0_body.cli91).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle91 : Conv.Cnt.leB (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck91 : Conv.ncleanListB (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s812.ffi).mlx PRE_first_tail_x15_r0_body.clo91 PRE_first_tail_x15_r0_body.cln91 PRE_first_tail_x15_r0_body.cli91 = true
theorem PRE_first_tail_x15_r0_body.cncl91 (h : Conv.NClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx) : Conv.NClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s812.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle91 PRE_first_tail_x15_r0_body.ckA91 PRE_first_tail_x15_r0_body.cobjsK91 PRE_first_tail_x15_r0_body.cnodesK91 PRE_first_tail_x15_r0_body.citemsK91 PRE_first_tail_x15_r0_body.cbd91 PRE_first_tail_x15_r0_body.cck91

end Host.Load.Run.Tpl
