import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK135
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA135 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1198.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1196.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo135.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1198.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd135 : (PRE_first_tail_x15_r0_body.clo135 ++ PRE_first_tail_x15_r0_body.cln135 ++ PRE_first_tail_x15_r0_body.cli135).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle135 : Conv.Cnt.leB (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) (⟨20872, 17975, 2781297, 5873⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck135 : Conv.ncleanListB (⟨20872, 17975, 2781297, 5873⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1198.ffi).mlx PRE_first_tail_x15_r0_body.clo135 PRE_first_tail_x15_r0_body.cln135 PRE_first_tail_x15_r0_body.cli135 = true
theorem PRE_first_tail_x15_r0_body.cncl135 (h : Conv.NClean (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1196.ffi).mlx) : Conv.NClean (⟨20872, 17975, 2781297, 5873⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1198.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle135 PRE_first_tail_x15_r0_body.ckA135 PRE_first_tail_x15_r0_body.cobjsK135 PRE_first_tail_x15_r0_body.cnodesK135 PRE_first_tail_x15_r0_body.citemsK135 PRE_first_tail_x15_r0_body.cbd135 PRE_first_tail_x15_r0_body.cck135

end Host.Load.Run.Tpl
