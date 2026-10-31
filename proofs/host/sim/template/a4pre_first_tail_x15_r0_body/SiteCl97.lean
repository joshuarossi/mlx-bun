import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK97
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA97 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo97.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd97 : (PRE_first_tail_x15_r0_body.clo97 ++ PRE_first_tail_x15_r0_body.cln97 ++ PRE_first_tail_x15_r0_body.cli97).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle97 : Conv.Cnt.leB (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck97 : Conv.ncleanListB (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx PRE_first_tail_x15_r0_body.clo97 PRE_first_tail_x15_r0_body.cln97 PRE_first_tail_x15_r0_body.cli97 = true
theorem PRE_first_tail_x15_r0_body.cncl97 (h : Conv.NClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx) : Conv.NClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle97 PRE_first_tail_x15_r0_body.ckA97 PRE_first_tail_x15_r0_body.cobjsK97 PRE_first_tail_x15_r0_body.cnodesK97 PRE_first_tail_x15_r0_body.citemsK97 PRE_first_tail_x15_r0_body.cbd97 PRE_first_tail_x15_r0_body.cck97

end Host.Load.Run.Tpl
