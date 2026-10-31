import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK45
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA45 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo45.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd45 : (PRE_first_tail_x15_r0_body.clo45 ++ PRE_first_tail_x15_r0_body.cln45 ++ PRE_first_tail_x15_r0_body.cli45).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle45 : Conv.Cnt.leB (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck45 : Conv.ncleanListB (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx PRE_first_tail_x15_r0_body.clo45 PRE_first_tail_x15_r0_body.cln45 PRE_first_tail_x15_r0_body.cli45 = true
theorem PRE_first_tail_x15_r0_body.cncl45 (h : Conv.NClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx) : Conv.NClean (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle45 PRE_first_tail_x15_r0_body.ckA45 PRE_first_tail_x15_r0_body.cobjsK45 PRE_first_tail_x15_r0_body.cnodesK45 PRE_first_tail_x15_r0_body.citemsK45 PRE_first_tail_x15_r0_body.cbd45 PRE_first_tail_x15_r0_body.cck45

end Host.Load.Run.Tpl
