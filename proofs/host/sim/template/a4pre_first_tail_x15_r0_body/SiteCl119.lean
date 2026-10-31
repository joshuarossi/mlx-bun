import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK119
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA119 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1050.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1048.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo119.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1050.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd119 : (PRE_first_tail_x15_r0_body.clo119 ++ PRE_first_tail_x15_r0_body.cln119 ++ PRE_first_tail_x15_r0_body.cli119).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle119 : Conv.Cnt.leB (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) (⟨20541, 17629, 2768130, 5140⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck119 : Conv.ncleanListB (⟨20541, 17629, 2768130, 5140⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1050.ffi).mlx PRE_first_tail_x15_r0_body.clo119 PRE_first_tail_x15_r0_body.cln119 PRE_first_tail_x15_r0_body.cli119 = true
theorem PRE_first_tail_x15_r0_body.cncl119 (h : Conv.NClean (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1048.ffi).mlx) : Conv.NClean (⟨20541, 17629, 2768130, 5140⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1050.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle119 PRE_first_tail_x15_r0_body.ckA119 PRE_first_tail_x15_r0_body.cobjsK119 PRE_first_tail_x15_r0_body.cnodesK119 PRE_first_tail_x15_r0_body.citemsK119 PRE_first_tail_x15_r0_body.cbd119 PRE_first_tail_x15_r0_body.cck119

end Host.Load.Run.Tpl
