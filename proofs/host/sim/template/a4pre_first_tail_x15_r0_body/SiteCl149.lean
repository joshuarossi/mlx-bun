import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK149
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA149 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1314.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo149.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1314.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd149 : (PRE_first_tail_x15_r0_body.clo149 ++ PRE_first_tail_x15_r0_body.cln149 ++ PRE_first_tail_x15_r0_body.cli149).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle149 : Conv.Cnt.leB (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) (⟨21128, 18229, 2791504, 6424⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck149 : Conv.ncleanListB (⟨21128, 18229, 2791504, 6424⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1314.ffi).mlx PRE_first_tail_x15_r0_body.clo149 PRE_first_tail_x15_r0_body.cln149 PRE_first_tail_x15_r0_body.cli149 = true
theorem PRE_first_tail_x15_r0_body.cncl149 (h : Conv.NClean (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx) : Conv.NClean (⟨21128, 18229, 2791504, 6424⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1314.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle149 PRE_first_tail_x15_r0_body.ckA149 PRE_first_tail_x15_r0_body.cobjsK149 PRE_first_tail_x15_r0_body.cnodesK149 PRE_first_tail_x15_r0_body.citemsK149 PRE_first_tail_x15_r0_body.cbd149 PRE_first_tail_x15_r0_body.cck149

end Host.Load.Run.Tpl
