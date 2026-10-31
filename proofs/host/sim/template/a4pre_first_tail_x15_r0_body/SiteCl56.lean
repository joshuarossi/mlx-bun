import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK56
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA56 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo56.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd56 : (PRE_first_tail_x15_r0_body.clo56 ++ PRE_first_tail_x15_r0_body.cln56 ++ PRE_first_tail_x15_r0_body.cli56).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle56 : Conv.Cnt.leB (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck56 : Conv.ncleanListB (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx PRE_first_tail_x15_r0_body.clo56 PRE_first_tail_x15_r0_body.cln56 PRE_first_tail_x15_r0_body.cli56 = true
theorem PRE_first_tail_x15_r0_body.cncl56 (h : Conv.NClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx) : Conv.NClean (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle56 PRE_first_tail_x15_r0_body.ckA56 PRE_first_tail_x15_r0_body.cobjsK56 PRE_first_tail_x15_r0_body.cnodesK56 PRE_first_tail_x15_r0_body.citemsK56 PRE_first_tail_x15_r0_body.cbd56 PRE_first_tail_x15_r0_body.cck56

end Host.Load.Run.Tpl
