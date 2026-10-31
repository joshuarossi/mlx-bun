import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK106
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA106 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s941.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo106.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s941.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd106 : (PRE_first_tail_x15_r0_body.clo106 ++ PRE_first_tail_x15_r0_body.cln106 ++ PRE_first_tail_x15_r0_body.cli106).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle106 : Conv.Cnt.leB (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck106 : Conv.ncleanListB (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s941.ffi).mlx PRE_first_tail_x15_r0_body.clo106 PRE_first_tail_x15_r0_body.cln106 PRE_first_tail_x15_r0_body.cli106 = true
theorem PRE_first_tail_x15_r0_body.cncl106 (h : Conv.NClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx) : Conv.NClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s941.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle106 PRE_first_tail_x15_r0_body.ckA106 PRE_first_tail_x15_r0_body.cobjsK106 PRE_first_tail_x15_r0_body.cnodesK106 PRE_first_tail_x15_r0_body.citemsK106 PRE_first_tail_x15_r0_body.cbd106 PRE_first_tail_x15_r0_body.cck106

end Host.Load.Run.Tpl
