import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK156
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA156 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo156.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd156 : (PRE_first_tail_x15_r0_body.clo156 ++ PRE_first_tail_x15_r0_body.cln156 ++ PRE_first_tail_x15_r0_body.cli156).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle156 : Conv.Cnt.leB (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) (⟨21287, 18386, 2797885, 6770⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck156 : Conv.ncleanListB (⟨21287, 18386, 2797885, 6770⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx PRE_first_tail_x15_r0_body.clo156 PRE_first_tail_x15_r0_body.cln156 PRE_first_tail_x15_r0_body.cli156 = true
theorem PRE_first_tail_x15_r0_body.cncl156 (h : Conv.NClean (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx) : Conv.NClean (⟨21287, 18386, 2797885, 6770⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle156 PRE_first_tail_x15_r0_body.ckA156 PRE_first_tail_x15_r0_body.cobjsK156 PRE_first_tail_x15_r0_body.cnodesK156 PRE_first_tail_x15_r0_body.citemsK156 PRE_first_tail_x15_r0_body.cbd156 PRE_first_tail_x15_r0_body.cck156

end Host.Load.Run.Tpl
