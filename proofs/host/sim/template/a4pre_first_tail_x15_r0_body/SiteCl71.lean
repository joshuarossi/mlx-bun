import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK71
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA71 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo71.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd71 : (PRE_first_tail_x15_r0_body.clo71 ++ PRE_first_tail_x15_r0_body.cln71 ++ PRE_first_tail_x15_r0_body.cli71).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle71 : Conv.Cnt.leB (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) (⟨19597, 16681, 2730466, 3088⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck71 : Conv.ncleanListB (⟨19597, 16681, 2730466, 3088⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx PRE_first_tail_x15_r0_body.clo71 PRE_first_tail_x15_r0_body.cln71 PRE_first_tail_x15_r0_body.cli71 = true
theorem PRE_first_tail_x15_r0_body.cncl71 (h : Conv.NClean (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx) : Conv.NClean (⟨19597, 16681, 2730466, 3088⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle71 PRE_first_tail_x15_r0_body.ckA71 PRE_first_tail_x15_r0_body.cobjsK71 PRE_first_tail_x15_r0_body.cnodesK71 PRE_first_tail_x15_r0_body.citemsK71 PRE_first_tail_x15_r0_body.cbd71 PRE_first_tail_x15_r0_body.cck71

end Host.Load.Run.Tpl
