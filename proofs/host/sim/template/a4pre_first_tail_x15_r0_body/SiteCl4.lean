import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK4
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA4 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s50.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s48.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo4.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s50.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd4 : (PRE_first_tail_x15_r0_body.clo4 ++ PRE_first_tail_x15_r0_body.cln4 ++ PRE_first_tail_x15_r0_body.cli4).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle4 : Conv.Cnt.leB (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck4 : Conv.ncleanListB (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s50.ffi).mlx PRE_first_tail_x15_r0_body.clo4 PRE_first_tail_x15_r0_body.cln4 PRE_first_tail_x15_r0_body.cli4 = true
theorem PRE_first_tail_x15_r0_body.cncl4 (h : Conv.NClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s48.ffi).mlx) : Conv.NClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s50.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle4 PRE_first_tail_x15_r0_body.ckA4 PRE_first_tail_x15_r0_body.cobjsK4 PRE_first_tail_x15_r0_body.cnodesK4 PRE_first_tail_x15_r0_body.citemsK4 PRE_first_tail_x15_r0_body.cbd4 PRE_first_tail_x15_r0_body.cck4

end Host.Load.Run.Tpl
