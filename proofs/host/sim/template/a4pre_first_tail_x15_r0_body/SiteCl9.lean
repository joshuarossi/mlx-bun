import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK9
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA9 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s94.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s92.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo9.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s94.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd9 : (PRE_first_tail_x15_r0_body.clo9 ++ PRE_first_tail_x15_r0_body.cln9 ++ PRE_first_tail_x15_r0_body.cli9).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle9 : Conv.Cnt.leB (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck9 : Conv.ncleanListB (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s94.ffi).mlx PRE_first_tail_x15_r0_body.clo9 PRE_first_tail_x15_r0_body.cln9 PRE_first_tail_x15_r0_body.cli9 = true
theorem PRE_first_tail_x15_r0_body.cncl9 (h : Conv.NClean (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s92.ffi).mlx) : Conv.NClean (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s94.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle9 PRE_first_tail_x15_r0_body.ckA9 PRE_first_tail_x15_r0_body.cobjsK9 PRE_first_tail_x15_r0_body.cnodesK9 PRE_first_tail_x15_r0_body.citemsK9 PRE_first_tail_x15_r0_body.cbd9 PRE_first_tail_x15_r0_body.cck9

end Host.Load.Run.Tpl
