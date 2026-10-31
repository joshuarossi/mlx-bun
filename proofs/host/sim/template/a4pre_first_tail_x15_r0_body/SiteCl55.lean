import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK55
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA55 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s497.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s495.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo55.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s497.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd55 : (PRE_first_tail_x15_r0_body.clo55 ++ PRE_first_tail_x15_r0_body.cln55 ++ PRE_first_tail_x15_r0_body.cli55).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle55 : Conv.Cnt.leB (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck55 : Conv.ncleanListB (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s497.ffi).mlx PRE_first_tail_x15_r0_body.clo55 PRE_first_tail_x15_r0_body.cln55 PRE_first_tail_x15_r0_body.cli55 = true
theorem PRE_first_tail_x15_r0_body.cncl55 (h : Conv.NClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s495.ffi).mlx) : Conv.NClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s497.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle55 PRE_first_tail_x15_r0_body.ckA55 PRE_first_tail_x15_r0_body.cobjsK55 PRE_first_tail_x15_r0_body.cnodesK55 PRE_first_tail_x15_r0_body.citemsK55 PRE_first_tail_x15_r0_body.cbd55 PRE_first_tail_x15_r0_body.cck55

end Host.Load.Run.Tpl
