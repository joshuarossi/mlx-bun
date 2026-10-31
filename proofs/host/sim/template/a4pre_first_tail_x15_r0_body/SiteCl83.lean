import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK83
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA83 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s806.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s804.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo83.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s806.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd83 : (PRE_first_tail_x15_r0_body.clo83 ++ PRE_first_tail_x15_r0_body.cln83 ++ PRE_first_tail_x15_r0_body.cli83).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle83 : Conv.Cnt.leB (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) (⟨19833, 16918, 2739878, 3601⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck83 : Conv.ncleanListB (⟨19833, 16918, 2739878, 3601⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s806.ffi).mlx PRE_first_tail_x15_r0_body.clo83 PRE_first_tail_x15_r0_body.cln83 PRE_first_tail_x15_r0_body.cli83 = true
theorem PRE_first_tail_x15_r0_body.cncl83 (h : Conv.NClean (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s804.ffi).mlx) : Conv.NClean (⟨19833, 16918, 2739878, 3601⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s806.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle83 PRE_first_tail_x15_r0_body.ckA83 PRE_first_tail_x15_r0_body.cobjsK83 PRE_first_tail_x15_r0_body.cnodesK83 PRE_first_tail_x15_r0_body.citemsK83 PRE_first_tail_x15_r0_body.cbd83 PRE_first_tail_x15_r0_body.cck83

end Host.Load.Run.Tpl
