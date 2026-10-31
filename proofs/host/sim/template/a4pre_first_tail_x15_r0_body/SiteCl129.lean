import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK129
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA129 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo129.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd129 : (PRE_first_tail_x15_r0_body.clo129 ++ PRE_first_tail_x15_r0_body.cln129 ++ PRE_first_tail_x15_r0_body.cli129).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle129 : Conv.Cnt.leB (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) (⟨20757, 17852, 2776671, 5613⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck129 : Conv.ncleanListB (⟨20757, 17852, 2776671, 5613⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx PRE_first_tail_x15_r0_body.clo129 PRE_first_tail_x15_r0_body.cln129 PRE_first_tail_x15_r0_body.cli129 = true
theorem PRE_first_tail_x15_r0_body.cncl129 (h : Conv.NClean (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx) : Conv.NClean (⟨20757, 17852, 2776671, 5613⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle129 PRE_first_tail_x15_r0_body.ckA129 PRE_first_tail_x15_r0_body.cobjsK129 PRE_first_tail_x15_r0_body.cnodesK129 PRE_first_tail_x15_r0_body.citemsK129 PRE_first_tail_x15_r0_body.cbd129 PRE_first_tail_x15_r0_body.cck129

end Host.Load.Run.Tpl
