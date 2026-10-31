import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK80
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA80 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s778.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo80.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s778.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd80 : (PRE_first_tail_x15_r0_body.clo80 ++ PRE_first_tail_x15_r0_body.cln80 ++ PRE_first_tail_x15_r0_body.cli80).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle80 : Conv.Cnt.leB (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) (⟨19769, 16870, 2737256, 3475⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck80 : Conv.ncleanListB (⟨19769, 16870, 2737256, 3475⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s778.ffi).mlx PRE_first_tail_x15_r0_body.clo80 PRE_first_tail_x15_r0_body.cln80 PRE_first_tail_x15_r0_body.cli80 = true
theorem PRE_first_tail_x15_r0_body.cncl80 (h : Conv.NClean (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx) : Conv.NClean (⟨19769, 16870, 2737256, 3475⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s778.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle80 PRE_first_tail_x15_r0_body.ckA80 PRE_first_tail_x15_r0_body.cobjsK80 PRE_first_tail_x15_r0_body.cnodesK80 PRE_first_tail_x15_r0_body.citemsK80 PRE_first_tail_x15_r0_body.cbd80 PRE_first_tail_x15_r0_body.cck80

end Host.Load.Run.Tpl
