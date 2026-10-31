import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK12
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA12 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s133.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s131.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo12.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s133.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd12 : (PRE_first_tail_x15_r0_body.clo12 ++ PRE_first_tail_x15_r0_body.cln12 ++ PRE_first_tail_x15_r0_body.cli12).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle12 : Conv.Cnt.leB (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck12 : Conv.ncleanListB (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s133.ffi).mlx PRE_first_tail_x15_r0_body.clo12 PRE_first_tail_x15_r0_body.cln12 PRE_first_tail_x15_r0_body.cli12 = true
theorem PRE_first_tail_x15_r0_body.cncl12 (h : Conv.NClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s131.ffi).mlx) : Conv.NClean (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s133.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle12 PRE_first_tail_x15_r0_body.ckA12 PRE_first_tail_x15_r0_body.cobjsK12 PRE_first_tail_x15_r0_body.cnodesK12 PRE_first_tail_x15_r0_body.citemsK12 PRE_first_tail_x15_r0_body.cbd12 PRE_first_tail_x15_r0_body.cck12

end Host.Load.Run.Tpl
