import host.sim.template.a4pre_first_tail_x15_r0_suffix.SiteK0
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_suffix.ckA0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.arrs (PRE_first_tail_x15_r0_suffix.clo0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.cbd0 : (PRE_first_tail_x15_r0_suffix.clo0 ++ PRE_first_tail_x15_r0_suffix.cln0 ++ PRE_first_tail_x15_r0_suffix.cli0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.cle0 : Conv.Cnt.leB (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.cck0 : Conv.ncleanListB (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx PRE_first_tail_x15_r0_suffix.clo0 PRE_first_tail_x15_r0_suffix.cln0 PRE_first_tail_x15_r0_suffix.cli0 = true
theorem PRE_first_tail_x15_r0_suffix.cncl0 (h : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx) : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_suffix.cle0 PRE_first_tail_x15_r0_suffix.ckA0 PRE_first_tail_x15_r0_suffix.cobjsK0 PRE_first_tail_x15_r0_suffix.cnodesK0 PRE_first_tail_x15_r0_suffix.citemsK0 PRE_first_tail_x15_r0_suffix.cbd0 PRE_first_tail_x15_r0_suffix.cck0

end Host.Load.Run.Tpl
