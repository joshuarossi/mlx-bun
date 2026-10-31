import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK128
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA128 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo128.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd128 : (PRE_first_tail_x15_r0_body.clo128 ++ PRE_first_tail_x15_r0_body.cln128 ++ PRE_first_tail_x15_r0_body.cli128).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle128 : Conv.Cnt.leB (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) (⟨20713, 17818, 2774920, 5527⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck128 : Conv.ncleanListB (⟨20713, 17818, 2774920, 5527⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx PRE_first_tail_x15_r0_body.clo128 PRE_first_tail_x15_r0_body.cln128 PRE_first_tail_x15_r0_body.cli128 = true
theorem PRE_first_tail_x15_r0_body.cncl128 (h : Conv.NClean (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx) : Conv.NClean (⟨20713, 17818, 2774920, 5527⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle128 PRE_first_tail_x15_r0_body.ckA128 PRE_first_tail_x15_r0_body.cobjsK128 PRE_first_tail_x15_r0_body.cnodesK128 PRE_first_tail_x15_r0_body.citemsK128 PRE_first_tail_x15_r0_body.cbd128 PRE_first_tail_x15_r0_body.cck128

end Host.Load.Run.Tpl
